#------------------------------------------------------------------------------
# script to tell the user to use ACE Flash
#------------------------------------------------------------------------------
import Config
import DiagnosticInterface
import Popup

import ctypes
import glob
import sys
import time

YES   = 6
NO    = 7

#-------------------------------------------------
# Code fragment.  clear the auto start script in
# the vdiag config file
#-------------------------------------------------

def done():
   # erase the startup script - verified that VDiag is up to date
   Config.WriteString('Script', 'Startup', '')
#enddef

#-------------------------------------------------
# Code fragment.  use the popup to display a message
#-------------------------------------------------

def okay(prompt, title):
   # prompt the user to disconnect the PIM
   # style:
   #  OK
   #  Explanation 
   #  Top most 
   Popup.Display(prompt, title, 0x40030)
#enddef

#-------------------------------------------------
# Main section
#   this script does nothing if the Image FPGA is 42, 
#   otherwise, the FPGAs and flash files are updated 
#   and the PC is shutdown.
#-------------------------------------------------

if __name__ != 'builtins':
   print(__name__)

elif DiagnosticInterface.NoAceCard():
   Popup.Display('ACE card not detected', 'ACE Flash', 0x40010)

else:
   aceCardConfig = DiagnosticInterface.ACE_CONFIGURATION()
   DiagnosticInterface.GetAceCardConfiguration(aceCardConfig)

   # get the Image FPGA firmware version
   version = aceCardConfig.m_ImageFpgaId
   version += aceCardConfig.m_SubVersion/10

   # poll waiting for VPIP
   while DiagnosticInterface.GetVpipVersion() == 0:
      time.sleep (0.1)

   if (DiagnosticInterface.GetVpipVersion() == -1):
      Popup.Display('VPIP not detected', 'ACE Flash', 0x400)
      sys.exit()

   requiredVersion = float(DiagnosticInterface.GetRequiredFpgaVersion())
   latestVersion   = float(DiagnosticInterface.GetLatestFpgaVersion())
   title = DiagnosticInterface.GetLatestFpgaReleaseName()
   if title == '': title = 'ACE Flash'

   print ('Image FPGA version:', version, requiredVersion)

   # likely don't have permission to use the driver
   if version == 0:
      # style: top most + stop sign
      Popup.Display('Unable to read the Image FPGA version', title, 0x40010)

   # use ACE Flash
   elif version < requiredVersion:
      okay('Use ACE Flash to update the ACE card', title)

   # everything is good
   elif version == requiredVersion:
      # erase the startup script - VDiag is up to date
      done()

   # error - FPGA booted to the fallback FPGA
   elif version == 0xEE:
      # style: top most + stop sign
      Popup.Display('Fallback Image FPGA detected.', title, 0x40010)

      # the Image FPGA is beyond what VDiag supports
   elif version > latestVersion:
      # style: top most + stop sign
      Popup.Display('Obsolete VDiag (Image FPGA version is greater than ' + str(latestVersion), title, 0x40010)
   #endif
#endif


