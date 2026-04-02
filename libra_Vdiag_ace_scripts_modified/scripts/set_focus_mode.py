#
# based on the boot mode, select the Focus FPGA slot
#

import DiagnosticInterface as di
import time
import numpy as np

def sendCommand(hdr):
   targetNode  = 0x100
   devPort     = 0x30 if di.UseVpipThree() else 0x10

   cmdRebootSys = 0x0B41
   tmDefault    = 1000

   print(hex(devPort))

   data = hdr.view(np.uint8)
   di.SendCommandData(cmdRebootSys, targetNode, devPort, data, tmDefault)
#enddef

def setBootMode(bootMode):
   # don't bother if the boot mode is undefined
   if bootMode != -1:
      print ('setBootMode(',bootMode,')')

      if bootMode == 5:
         # focus FPGA is 1 and Revo is loaded into slot 3 = 0x13
         hdr = np.array([0x13], dtype=np.uint32)
         sendCommand(hdr)
      elif bootMode == 4:
         # focus FPGA is 1 and PV.014/Eagle Eye is loaded into slot 1 = 0x11
         hdr = np.array([0x11], dtype=np.uint32)
         sendCommand(hdr)
      elif bootMode == 3:
         # focus FPGA is 1 and PV.018 is loaded into slot 0 = 0x10
         hdr = np.array([0x10], dtype=np.uint32)
         sendCommand(hdr)
      elif bootMode == 2:
         # focus FPGA is 1 and PV.035 is loaded into slot 2 = 0x12
         hdr = np.array([0x12], dtype=np.uint32)
         sendCommand(hdr)
      elif bootMode == 7:
         # for the test system, Prodigy is loaded into slot 1 (0x11) - but likely will replace Revo (0x13)
         hdr = np.array([0x11], dtype=np.uint32)
         sendCommand(hdr)
      else:
         print ("unsupported boot mode:", bootMode)
      #endif
   #endif
#enddef

if __name__ != 'builtins':
   print(__name__)
else:
   setBootMode(di.GetBootMode())
#endif
