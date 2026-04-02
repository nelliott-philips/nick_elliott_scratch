import DiagnosticInterface as di
import crcLsb
import time
import os
import numpy as np
import tkinter as tk
from tkinter.filedialog import askopenfilename

targetNode  = 0x100
connPort    = 0x01
devPort     = 0x30 if di.UseVpipThree() else 0x10
pimPort     = 0x31 if di.UseVpipThree() else 0x11

cmdBogus    = 0xF000
nakBadCmd   = 0x1001

# Connection cmds
cmdPing     = 0x0300

# Capability cmds
cmdCapReq   = 0x0001

# Device cmds
cmdUpdSys     = 0x0B01
cmdUpdSysData = 0x0B11
cmdGetSysSts  = 0x0B21

# Timeout values
tmDefault     = 1000
tmMedium      = 5000
tmLong        = 20000
tmVeryLong    = 300000

# Max packet size
maxPkt        = 2048

#-------------------------------------------------
# Check connection
#-------------------------------------------------
def CheckConnection():
   # Ping the node to see if there is a connection.
   if di.SendCommandBlock(cmdPing, targetNode, connPort, tmDefault) <= 0:
      print('Reflash: no connection')
      return 0
   return 1

#-------------------------------------------------
# Device reflash
#-------------------------------------------------
def DevReflash(name, val):
   if name == 'none':
      return 0
   #endif

   # Get the file size
   size = os.path.getsize(name)
   if size <= 0:
      return 0
   #endif

   ext = name.split('.')[-1]
   if ext == 'cds':
      cdsFile = 1
   else:
      cdsFile = 0
   #endif

   # Read the file and compute the crc
   print('Reflash: computing crc.')
   f = open(name, 'rb')
   try:
      buf = bytearray(size)
      f.readinto(buf)
      crc = crcLsb.crc32(buf)
   except:
      return 0
   finally:
      f.close()
   #endtry

   print('Reflash: size %d  crc: 0x%08X' % (size, crc))

   if cdsFile:
      cdsHdr = np.frombuffer(buf, dtype=np.uint32, count=(8*4))
      cdsType = cdsHdr[0]
      node = int((cdsType >> 16) & 0xFFF)
      port = int((cdsType >> 8) & 0xFF)
      type = cdsType
   else:
      node = val >> 16
      port = (val >> 8) & 0xFF
      type = val & 0xFF
   #endif

   # Send the system update type
   print('Reflash: requesting system update mode.')
   hdr = np.array([type, size, crc], dtype=np.uint32)
   data = hdr.view(np.uint8)
   if di.SendCommandData(cmdUpdSys, node, port, data, tmLong) <= 0:
      print('Reflash: system update rejected.')
      # return 0
   #endif

   pktSize = maxPkt

   offset = 0
   seqCnt = (size + pktSize - 1) // pktSize
   seqIdx = 1

   # Send the data packets
   while size > 0:
      if size >= pktSize:
         amount = pktSize
      else:
         amount = size;
      #endif

      data = np.frombuffer(buf, dtype=np.uint8, count=amount, offset=offset)
      offset += amount
      size -= amount

      while 1:
         print('Reflash: sending pkt %d of %d' % (seqIdx, seqCnt))

         # use the longer timeout for the last packet
         timeout = tmMedium if seqIdx < seqCnt else tmLong

         result = di.SendCommandSequence(cmdUpdSysData, node, port, seqIdx, seqCnt, data, timeout)
         if result == 1:
            break
         #endif

         if result == -1:
            print('timeout')
         elif (result != 0x81) and (result != 0x82):
            print('Reflash: pkt %d fail code 0x%X. Retrying...' % (seqIdx, result))
         else:
            print('Reflash: pkt %d failed' % seqIdx)
            return -1
         #endif
      #endwhile

      seqIdx += 1
   #endwhile

   # update writing when something changes
   progress = -1

   while 1:
      result = di.SendCommandBlock(cmdGetSysSts, node, port, tmLong)

      if result == -1:
         print('timeout')
      else:
         sts = result & 0xFF

         if sts == 0x91:
            temp = result >> 16
            if temp != progress:
               progress = temp
               print('Reflash: caching (%dKB)' % progress)
            #endif
         elif sts == 0x92:
            temp = result >> 16
            if temp != progress:
               progress = temp
               print('Reflash: writing (%dKB)' % progress)
            #endif
         elif sts == 0x93:
            print('Reflash: done')
            return 1
         elif sts == 0xA1:
            print('Reflash: aborted')
            return -1
         elif sts == 0xA2:
            print('Reflash: bad crc')
            return -1
         elif sts == 0xA3:
            print('Reflash: bad image')
            return -1
         elif sts == 0xA4:
            print('Reflash: cache failed')
            return -1
         elif sts == 0xA5:
            print('Reflash: write failed')
            return -1
         else:
            print('Reflash: log code 0x%X' % result)
         #endif
      #endif

      time.sleep(2)
   #endwhile

   return 1
#enddef

#-------------------------------------------------
# Reflash
#-------------------------------------------------
def Reflash():
   if CheckConnection() <= 0:
      return 0
   #enddef

   # Display the selection popup.
   root = tk.Tk()
   root.title('Flash Selection')
   root.geometry('300x400+30+30')

   name = ['none']
   v = tk.IntVar()
   v.set(0x00000000)

   types = [
      ('CDS file',           0x00000000),
      ('Ace Image recovery', 0x01003000 if di.UseVpipThree() else 0x01001000),
      ('Ace Image slot 1',   0x01003001 if di.UseVpipThree() else 0x01001001),
      ('Ace Focus slot 0',   0x01003010 if di.UseVpipThree() else 0x01001010),
      ('Ace Focus slot 1',   0x01003011 if di.UseVpipThree() else 0x01001011),
      ('Ace Focus slot 2',   0x01003012 if di.UseVpipThree() else 0x01001012),
      ('Ace Focus slot 3',   0x01003013 if di.UseVpipThree() else 0x01001013),
      ('DigiPim recovery',   0x01013000 if di.UseVpipThree() else 0x01011000),
      ('DigiPim',            0x01013001 if di.UseVpipThree() else 0x01011001)
   ]

   def HandleFile():
      name[0] = askopenfilename()
      nameLbl[0].config(text=name)
   #enddef

   def HandleReflash():
      mode = di.GetVpipTestMode()
      di.SetVpipTestMode(True)

      # add a retry loop to prevent VDiag from bricking the ACE card
      while DevReflash(name[0], v.get()) == -1:
         print ("reflash failed. trying again")
      #endwhile

      di.SetVpipTestMode(mode)
   #enddef

   btnFile = tk.Button(root, text='File', command=HandleFile)
   btnFile.place(x=10, y=10, width=50, height=25)
   nameLbl = [tk.Label(root, text=name[0], relief=tk.RIDGE, anchor=tk.W)]
   nameLbl[0].place(x=65, y=10, width=225, height=25)

   yPos = 40;
   tk.Label(root, text='Choose slot:').place(x=10, y=yPos, height=25)
   yPos += 30;
   for txt, val in types:
      tk.Radiobutton(root, text=txt, variable=v,
                     value=val).place(x=90, y=yPos , anchor=tk.W)
      yPos += 25
   #endfor

   tk.Button(root, text='Flash', width=10,
             command=HandleReflash).place(x=40, y=yPos, width=100, height=25)
   tk.Button(root, text='Exit', width=10,
             command=root.destroy).place(x=170, y=yPos, width=100, height=25)

   root.mainloop()
#enddef

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Reflash start...')
   Reflash()
   print('Reflash exit.')
else:
   print(__name__)
