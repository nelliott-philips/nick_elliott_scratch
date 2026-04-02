import DiagnosticInterface as di
import time
import numpy as np
import json
import digiLib as dl

targetNode  = 0x101    # 0x101 PIM     0x100 ACE 
connPort    = 0x01
capPort     = 0x02
devPort     = 0x30 if di.UseVpipThree() else 0x10
pimPort     = 0x31 if di.UseVpipThree() else 0x11
dbgPort     = 0x20

cmdBogus    = 0xF000
nakBadCmd   = 0x1001

print (hex(devPort))
print (hex(pimPort))

# Connection cmds
cmdPing     = 0x0300

# Device cmds
cathDataGet = 0x0505
cathDataSet = 0x0507
regSim = 0x0013

# Timeout values
tmDefault     = 1000
tmMedium      = 5000
tmLong        = 20000
tmVeryLong    = 300000

# Max packet size
maxPkt        = 2048

node = dl.digiNode

#-------------------------------------------------
# EEPROM read
#-------------------------------------------------
def EEPROMread():
   addr = int(0) #in location 15 for config code
   size = 128
 
   param = np.array([addr, size], dtype=np.uint32)
   paramData = param.view(np.uint8)
   store = np.zeros(size-np.size(paramData), dtype=np.uint8)
   data = np.concatenate((paramData, store))
   print(np.size(data))
   print(data)
   di.RequestCommandData(cathDataGet, node, pimPort, data, tmMedium)
   print(np.size(data))
   print(data)
   return 1

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   if not dl.CheckConnection(node):
      exit

   np.set_printoptions(formatter={'int':hex})
   print('EEPROM read starts...') 
   EEPROMread()  
   print('EEPROM read ends') 
else:
   print(__name__)
