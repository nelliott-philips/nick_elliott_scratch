#------------------------------------------------------------------------------
# This is a variant of the SCRAPE script that is used to update the FPGAs,
# if you already have SCRAP-e installed. It is intended for doing SCRAP-e
# updates
#------------------------------------------------------------------------------
import Config
import DiagnosticInterface
import GuiTest

import ctypes
import glob
import sys

YES    = 6
NO     = 7
TITLE = 'Digi'
VERSION = 51.1

#-------------------------------------------------
# Code fragment.  clear the auto start script in
# the vdiag config file
#-------------------------------------------------

def done():
   # erase the startup script - verified that VDiag is up to date
   Config.WriteString('Script', 'Startup', '')

#-------------------------------------------------
# Code fragment.  shutdown the PC - needed so that
# the Image FPGA will load from flash
#-------------------------------------------------

def shutdown():
   import os

   # shutdown the PC 
   os.system("shutdown /s")

#-------------------------------------------------
# Code fragment.  use the popup to get a yes cancel response
# Return 6 - Yes
#        7 - No
#-------------------------------------------------

def ask(prompt):
   # prompt the user before reflashing
   # style:
   # Yes or No
   # Question icon
   # Top most 
   return ctypes.windll.user32.MessageBoxW(None, prompt, TITLE,0x40024)

#-------------------------------------------------
# Code fragment.  use the popup to display a message
#-------------------------------------------------

def okay(prompt):
   # prompt the user to disconnect the PIM
   # style:
   #  OK
   #  Explanation 
   #  Top most 
   ctypes.windll.user32.MessageBoxW(None, prompt, TITLE,0x40030)

#-------------------------------------------------
# Code fragment.  flash a bin file - allow a maximum of 10 attempts
#-------------------------------------------------

def flash(file, code):
   import reflash

   file = file.replace('\\', '/')
   print (file)

   for attempt in range(10):
      if reflash.DevReflash(file, code) != -1:
         return

      print('reflash failed: trying again')
   #endfor
#edndef

#-------------------------------------------------
# Code fragment.  reflash the FPGA slots.  Using the CDS file format which
#   includes which FPGA slot to use.
#-------------------------------------------------

def fpga():
   version = DiagnosticInterface.GetAceCardNumber()
   number  = version.split('-')
   slot    = number[0].split('.')
   reboot  = False

   # there should be 5 fields, if firmware focus doesn't parse, you only get the Image portion
   if len(slot) != 5:
      print('unexpected ACE card version string: <'+number[0]+'>')
      flash_image_slot  = True
      flash_focus_slot1 = True
      flash_focus_slot2 = True
      flash_focus_slot3 = True
      flash_focus_slot4 = True
   else:
      flash_image_slot  = slot[0] != '509'
      flash_focus_slot1 = slot[1]  < '925'
      flash_focus_slot2 = slot[2]  < '435'
      flash_focus_slot3 = slot[3]  < '725'
      flash_focus_slot4 = slot[4]  < '25'
   #endif

   # install all the cds files
   for d in glob.glob('../digipim/*.bin'):
      # focus slot 0
      if d.find('focus_top_018') != -1:
         if flash_focus_slot1:
            flash(d, 0x01001010)
            reboot = True

      # focus slot 1
      elif d.find('focus_top_EEP') != -1:
         if flash_focus_slot2:
            flash (d, 0x01001011)
            reboot = True

      # focus slot 2
      elif (d.find('focus_top_035') != -1):
         if flash_focus_slot3:
            flash (d, 0x01001012)
            reboot = True

      # image slot 1
      elif (d.find('ace_image_top') != -1):
         # only interested in the 50.9 version (prevent a DMA short)
         if flash_image_slot and (d.find('ace_image_top_digi') != -1):
            flash (d, 0x01001001)
            reboot = True

      elif (d.find('digipim_r4') == -1) and (d.find('digipim_top') == -1):
         print (d+' file not recognized')
      #endif
   #endfor

   # exist otherwise the PC will reboot
   if not reboot:
      print ('no FPGA slots updated')

   return reboot
#enddef

#-------------------------------------------------
# erase the DAT files 
#-------------------------------------------------

def erase_files():
   import filesys

   # erase any DAT files
   for d in glob.glob('../scrape/*.dat'):
      index = d.rfind('\\') 
      if (index == -1):
         index = d.rfind('/')

      # the index either points at the slash or is -1
      index += 1
      
      d = d[index:]
      print('erase', d)
      filesys.Delete(d)

   # erase the master config file 
   filesys.Delete('MasterCfg.json')

#-------------------------------------------------
# Code fragment.  update the flash file system to support PV014/EEP, PV018 and PV035
#-------------------------------------------------

def flash_files():
   import filesys

   # update the catheter DAT files
   for d in glob.glob('../scrape/*.dat'):
      d = d.replace('\\','/')
      print ('flash', d)
      filesys.Add(d)

   # update the Master Config file
   for d in glob.glob('../scrape/*.json'):
      d = d.replace('\\','/')
      print ('flash', d)
      filesys.Add(d)

#-------------------------------------------------
# Code fragment.  update the flash file system to support PV014/EEP, PV018 and PV035
#-------------------------------------------------

def reprogram():
   if ask('Reprogram the FPGAs and the flash file system') == YES:
      if GuiTest.pimName() != 'None':
         okay('Disconnect the PIM')
      #endif

      # put the ace card into test mode
      DiagnosticInterface.SetVpipTestMode(True)

      # erase the file system - it will go faster
      # erase_files()

      # update the flash files
      # flash_files()

      # update the fpgas
      if fpga():
          # erase the startup script - the FPGAs have been rolled back
          done()

          # shutdown - which forces the FPGA to reload
          shutdown()
      #endif
   #endif

#-------------------------------------------------
# Main section
#   this script will only reflash the FPGA if Image FPGA is 51.0 (SCRAP-e_05), 
#   otherwise, the standard scrape script should be used.  
#   this script is intended for updates and JTAG recovery.
#-------------------------------------------------

if __name__ != 'builtins':
   print(__name__)
else:
   # use the file and reflash scripts
   sys.path.append("../ACE/scripts")

   # change the name to call into the file+reflash scripts
   __name__ = 'scrape_reflash'

   aceCardConfig = DiagnosticInterface.ACE_CONFIGURATION()
   DiagnosticInterface.GetAceCardConfiguration(aceCardConfig)

   # ENDEVOUR2 bumped the subversion ID 
   version = aceCardConfig.m_ImageFpgaId

   if version > 48:
      version += aceCardConfig.m_SubVersion/10
   #endif

   print ('Image FPGA version:', version)

   # likely don't have permission to use the driver
   if version == 0:
      # style: top most + stop sign
      ctypes.windll.user32.MessageBoxW(None, 'Unable to read the Image FPGA version', TITLE, 0x40010)

   # error - FPGA booted to the fallback FPGA
   elif version == 0xEE:
      # style: top most + stop sign
      ctypes.windll.user32.MessageBoxW(None, 'Fallback Image FPGA detected. Use the scrape script instead', TITLE, 0x40010)

   # Reflash SCRAP-e
   else:
      reprogram()
   #endif
#endif
