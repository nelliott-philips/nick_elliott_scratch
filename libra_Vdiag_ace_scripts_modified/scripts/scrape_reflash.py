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
TITLE = 'DIGI'
VERSION = 50.9

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
# Code fragment.  reflash the FPGA slots.  Using the CDS file format which
#   includes which FPGA slot to use.
#-------------------------------------------------

def fpga():
   import reflash

   # install all the cds files
   for d in glob.glob('../scrape/*.cds'):
      d = d.replace('\\','/')
      print (d)

      while reflash.DevReflash(d, 0x00000000) == -1:
          print ('reflash failed: trying again')
      #endwhile
   #endfor
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
      fpga()

      # erase the startup script - the FPGAs have been rolled back
      done()

      # shutdown - which forces the FPGA to reload
      shutdown()
   #endif

#-------------------------------------------------
# Main section
#   this script will only reflash the FPGA if Image FPGA is 51.1 (SCRAP-e_06), 
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
   elif version >= int(VERSION):
      reprogram()

   # the Image FPGA wasn't SCRAP-e_06
   else:
      # style: top most + stop sign
      ctypes.windll.user32.MessageBoxW(None, 'Use ACE Flash instead', TITLE, 0x40010)
   #endif
#endif
