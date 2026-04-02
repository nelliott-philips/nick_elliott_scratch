import DiagnosticInterface as di
import time
import os
import numpy as np
import json
import tkinter as tk
from tkinter.filedialog import askopenfilename,askdirectory
import tkinter.messagebox

# temporary code used to inject buffer mismatches - code commented out
# import random

targetNode  = 0x100
connPort    = 0x01
capPort     = 0x02
devPort     = 0x30 if di.UseVpipThree() else 0x10
print (hex(devPort))

cmdBogus    = 0xF000
nakBadCmd   = 0x1001

# Connection cmds
cmdPing     = 0x0300

# Capability cmds
cmdCapReq   = 0x0001

# Device cmds
cmdDirList    = 0x0A01
cmdFileOpen   = 0x0A11
cmdFileClose  = 0x0A21
cmdFileRead   = 0x0A31
cmdFileWrite  = 0x0A41
cmdFileSeek   = 0x0A51
cmdFileDelete = 0x0A61
cmdFileFormat = 0x0AF1

# Timeout values
tmDefault     = 3000
tmLong        = 7000
tmVeryLong    = 25000

# Max packet size
maxPkt        = 2048

#-------------------------------------------------
# Check connection
#-------------------------------------------------
def CheckConnection():
   # Ping the node to see if there is a connection.
   if di.SendCommandBlock(cmdPing, targetNode, connPort, tmDefault) <= 0:
      print('File: no connection')
      return 0
   return 1

#-------------------------------------------------
# Get the port caps
#-------------------------------------------------
def GetPortCaps(port):
   data = np.zeros((8*8), dtype=np.uint8)
   if di.RequestCommand(cmdCapReq, targetNode, capPort, data, tmDefault) <= 0:
      print('CommTest: cap req cmd failed')
      return 0
   dataU32 = data.view(np.uint32)
   if dataU32[0] > 8:
      return 0
   for x in range(dataU32[0]):
      offset = (x*2) + 1
      if ((dataU32[offset] & 0xFF) == port):
         global maxPkt
         pktSize = dataU32[offset+1]
         if (pktSize >= 4064):
            maxPkt = 4064
         elif (pktSize >= 2048):
            maxPkt = 2048
         else:
            maxPkt = 1024
         return 1
   return 0

#-------------------------------------------------
# Handle refresh
#-------------------------------------------------
def HandleRefresh(lb):
   data = np.zeros(2048, dtype=np.uint8)
   if di.RequestCommand(cmdDirList, targetNode, devPort, data, tmDefault) <= 0:
      print('File: dir list cmd failed')
      return 0
   dataStr = data.tostring()        # Convert the array to a string object
   str = dataStr.decode('utf-8')    # Decode string
   jObj = json.loads(str.split('\n')[0])
   if 'directory' not in jObj:
      print('File: bad json string')
      return 0
   lb.delete(0, tk.END)
   for item in jObj['directory']['files']:
      entry = '%s (%d)' % (item['name'], item['size'])
      lb.insert(tk.END, entry)
   return 1

#-------------------------------------------------
# Handle save file
#-------------------------------------------------
def HandleSaveFile(dname, fname, fsize):
   # Open the device file
   print('File: open %s on device.' % (fname))
   aname = np.fromstring(fname, dtype=np.uint8)
   data = np.concatenate((np.array([0], dtype=np.uint8),aname,np.array([0], dtype=np.uint8)))
   result = di.SendCommandData(cmdFileOpen, targetNode, devPort, data, tmLong)
   if result != 1:
      print('File: %s open fail code 0x%X.' % (fname,result))
      return 0

   pktSize = maxPkt
   buf = np.zeros(fsize, dtype=np.uint8)
   size = fsize
   offset = 0
   done = 0
   ok = 1
   while (size > 0) and not done:
      if size >= pktSize:
         amount = pktSize
      else:
         amount = size

      data = buf[offset:(offset+amount)]

      data[0] = amount & 0xFF
      data[1] = (amount >> 8) & 0xFF

      print('File: reading %d of %d bytes' % (offset+amount, fsize))
      attempt = 0
      while 1:
         attempt += 1
         result = di.RequestCommandData(cmdFileRead, targetNode, devPort, data, tmLong)
         sts = result & 0xFF
         if sts == 0x01:
            amount = result >> 16
            break
         elif sts == 0x85:
            amount = result >> 16
            print('Recv end')
            done = 1
            break
         else:
            print('File: pkt read fail code 0x%X.' % sts)
            if attempt >= 3:
               ok = 0
               done = 1
               break

      offset += amount
      size -= amount

   # Close the device file
   di.SendCommandBlock(cmdFileClose, targetNode, devPort, tmDefault)

   # Do not proceed if the device file read failed
   if not ok:
      return 0

   # Write to the host file
   hostfile = dname + '/' + fname
   f = open(hostfile, 'wb')
   try:
      f.write(buf)
   except:
      return 0
   finally:
      f.close()

   print('File: save %s done.' % (fname))
   return 1

#-------------------------------------------------
# Handle get file
#-------------------------------------------------
def HandleGetFile(lb):
   # Make sure at least 1 file is selected
   flist = lb.curselection()
   if len(flist) == 0:
      return 0

   # Get the directory name to save the files to
   dname = 'none'
   dname = askdirectory()
   if dname == 'none':
      return 0

   # Save the files to the destination directory
   for idx in flist:
      item = lb.get(idx).split(' ')
      fname = item[0]
      fsize = int(item[1][1:-1])
      HandleSaveFile(dname, fname, fsize)
   return 1

#-------------------------------------------------
# add file
#-------------------------------------------------
def Add(file):
   # Get the file size
   fsize = os.path.getsize(file)
   if fsize <= 0:
      return 0

   # Read the file.
   f = open(file, 'rb')
   try:
      buf = bytearray(fsize)
      f.readinto(buf)
   except:
      return 0
   finally:
      f.close()

   # Open the file on the device
   fname = file.split('/')[-1]
   print('File: open %s on device.' % (fname))
   aname = np.fromstring(fname, dtype=np.uint8)
   data = np.concatenate((np.array([1], dtype=np.uint8),aname,np.array([0], dtype=np.uint8)))
   result = di.SendCommandData(cmdFileOpen, targetNode, devPort, data, tmLong)
   if result != 1:
      print('File: open fail code 0x%X.' % result)
      return 0

   # Send the data packets
   pktSize = maxPkt
   size = fsize
   offset = 0
   done = 0
   ok = 1
   index = 0

   while (size > 0) and not done:
      if size >= pktSize:
         amount = pktSize
      else:
         amount = size
      data = np.frombuffer(buf, dtype=np.uint8, count=amount, offset=offset)

      # limit the amount of screen printing
      if index % 100 == 0:
         print('File: sending %d of %d bytes' % (offset+amount, fsize))
      #endif

      index += 1

      attempt = 0
      while not done:
         attempt += 1
         result = di.SendCommandData(cmdFileWrite, targetNode, devPort, data, tmVeryLong)

         if result == -1:
            print('file write command timed out')
         else:
            sts = result & 0xFF
            if sts != 0x01:
               print('File: pkt fail code 0x%X.' % sts)
            else:
               amount = result >> 16
               if amount == 0:
                  print('empty file write')
               else:
                  break

         if attempt > 2:
            print('File: failed retry')
            ok   = 0
            done = 1
            break

         print('File: retry %d' % attempt)
         pos = np.array([offset], dtype=np.uint32)
         posData = pos.view(np.uint8)
         seekAttempt = 0
         while 1:
            seekAttempt += 1
            result = di.SendCommandData(cmdFileSeek, targetNode, devPort, posData, tmLong)
            if result == 0x01:
               break

            if seekAttempt > 2:
               print('File: file seek failed')
               ok   = 0
               done = 1
               break

            print('File: file seek failed attempt %d' % seekAttempt)

      offset += amount
      size -= amount

   # Close the file on the device
   if di.SendCommandBlock(cmdFileClose, targetNode, devPort, tmDefault) != 1:
      print('File: close failed.')
      return 0

   if ok:
      print('File: add %s done.' % (fname))

   return 1

#-------------------------------------------------
# Handle add file
#-------------------------------------------------
def HandleAddFile():
   name = 'none'
   name = askopenfilename()
   if name == 'none':
      return 0

   # test for readback
   # return ReadBackFile(name)

   return Add(name)

#-------------------------------------------------
# delete file
#-------------------------------------------------
def Delete(file):
   aname = np.fromstring(file, dtype=np.uint8)
   data  = np.concatenate((aname,np.array([0], dtype=np.uint8)))
   if di.SendCommandData(cmdFileDelete, targetNode, devPort, data, tmLong) <= 0:
      print('File: del fail.')
      return 0

   return 1

#-------------------------------------------------
# Handle delete file
#-------------------------------------------------
def HandleDelFile(lb):
   for idx in lb.curselection():
      file = lb.get(idx).split(' ')[0]
      if Delete(file) <= 0:
         return 0
   return 1

#-------------------------------------------------
# Handle format
#-------------------------------------------------
def HandleFormat():
   print('File: formating...')
   if di.SendCommandBlock(cmdFileFormat, targetNode, devPort, tmVeryLong) == 0x01:
      print('File: format done.')
   else:
      print('File: format fail.')
      return 0
   return 1

#-------------------------------------------------
# FileWindow
#-------------------------------------------------
def FileWindow():
   if CheckConnection() <= 0:
      return 0

   GetPortCaps(devPort)

   # Display the files window.
   root = tk.Tk()
   root.title('Ace Files')
   root.geometry('400x350+30+30')

   pw = tk.PanedWindow(root, height=350, width=300)
   sc = tk.Scrollbar(pw, orient=tk.VERTICAL)
   lb = tk.Listbox(pw, width=40, selectmode=tk.MULTIPLE, yscrollcommand=sc.set)
   sc.config(command=lb.yview)
   sc.pack(side=tk.RIGHT, fill=tk.Y)
   pw.pack(side=tk.LEFT, fill=tk.Y)

   lb.pack(side=tk.LEFT, fill=tk.BOTH, expand=1)

   def HandleRefreshBtn():
      HandleRefresh(lb)

   def HandleGetFileBtn():
      HandleGetFile(lb)

   def HandleAddFileBtn():
      if HandleAddFile() > 0:
         HandleRefresh(lb)

   def HandleDelFileBtn():
      if HandleDelFile(lb) > 0:
         HandleRefresh(lb)

   def HandleFormatBtn():
      result = tkinter.messagebox.askquestion('Format', 'Are you sure?', icon='warning')
      if result == 'yes':
         HandleFormat()
         HandleRefresh(lb)

   # Display the buttons.
   tk.Button(root, text='Refresh', width=10,
             command=HandleRefreshBtn).place(x=275, y=25, width=100, height=25)
   tk.Button(root, text='Get', width=10,
             command=HandleGetFileBtn).place(x=275, y=75, width=100, height=25)
   tk.Button(root, text='Add', width=10,
             command=HandleAddFileBtn).place(x=275, y=125, width=100, height=25)
   tk.Button(root, text='Del', width=10,
             command=HandleDelFileBtn).place(x=275, y=175, width=100, height=25)
   tk.Button(root, text='Format', width=10,
             command=HandleFormatBtn).place(x=275, y=225, width=100, height=25)
   tk.Button(root, text='Exit', width=10,
             command=root.destroy).place(x=275, y=275, width=100, height=25)

   #HandleRefresh(lb)
   root.mainloop()
   return 1

#-------------------------------------------------
# Readback a file and compare it to it's disk image
# used to verify catheter data files to insure that
# there are no write errors, which cause IVACE1620
# errors.
#-------------------------------------------------
def ReadBackFile(file):
   # Get the file size
   fsize = os.path.getsize(file)
   if fsize <= 0:
      return 0

   # Read the file from disk.
   f = open(file, 'rb')
   try:
      buf = bytearray(fsize)
      f.readinto(buf)
   except:
      return 0
   finally:
      f.close()

   # how many blocks are read from the file (use integer division)
   readBlocks = fsize//maxPkt
   if readBlocks*maxPkt < fsize:
      readBlocks += 1

   # create a vector on whether each block matches the reference file
   #  1 is a match (don't need to recheck)
   #  0 is not yet compared
   # -1 is a mismatch (but it could be a read error)
   match = np.zeros(readBlocks)

   # make three attempts to get a good read back.
   readBackAttempt  = 0

   while readBackAttempt < 3:
      readBackAttempt += 1
      mismatchDetected = False

      # Open the file on the device
      fname = file.split('/')[-1]
      print('File: open %s on device.' % (fname))
      aname = np.fromstring(fname, dtype=np.uint8)
      data = np.concatenate((np.array([1], dtype=np.uint8), aname, np.array([0], dtype=np.uint8)))
      result = di.SendCommandData(cmdFileOpen, targetNode, devPort, data, tmLong)
      if result != 1:
         print('File: %s open fail code 0x%X.' % (file,result))
         return 0

      # read the file from the device
      pktSize = maxPkt

      size    = fsize
      offset  = 0
      done    = False
      ok      = True
      block   = 0

      while (size > 0) and not done:
         if size >= pktSize:
            amount = pktSize
         else:
            amount = size

         # use the pktSize instead of amount to avoid the special case of amount of 1
         data    = np.zeros(pktSize, dtype=np.uint8)
         data[0] = amount & 0xFF
         data[1] = (amount >> 8) & 0xFF
         attempt = 0

         if match[block] != 1:
            print('File: reading block %d: %d of %d bytes' % (block, offset+amount, fsize))

         while True:
            attempt += 1
            result   = di.RequestCommandData(cmdFileRead, targetNode, devPort, data, tmLong)
            sts      = result & 0xFF

            if sts == 0x01:
               amount = result >> 16
               break
            elif sts == 0x85:
               amount = result >> 16
               print('Recv end')
               done = 1
               break
            else:
               print('File: pkt read fail code 0x%X.' % sts)
               if attempt >= 3:
                  ok   = False
                  done = True
                  break

         # error injection
         # if random.randint(1,readBlocks) < 5:
         #    print ('inject error')
         #    data[0] = ~data[0]

         # if the block has already matched, there is no need to check it again
         if match[block] != 1:
            if np.array_equal(data[0:amount], buf[offset:offset+amount]):
               match[block] = 1
            else:
               print('mismatch detected')
               mismatchDetected = True
               match[block]     = -1

         # advance to the next block in the file
         offset += amount
         size   -= amount
         block  += 1

      # Close the device file
      di.SendCommandBlock(cmdFileClose, targetNode, devPort, tmDefault)

      # if there were no mismatches, we can exit the readback loop
      if not mismatchDetected:
         print('no errors detected')
         return 1

   print('read back failed to match')
   return 0

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('File start...')

   mode = di.GetVpipTestMode()
   di.SetVpipTestMode(True)
   FileWindow()
   di.SetVpipTestMode(mode)
   
   print('File exit.')
else:
   print(__name__)
