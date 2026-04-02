import DiagnosticInterface as di
import time
import numpy as np
import json

targetNode  = 0x101
connPort    = 0x01
pimPort     = 0x31 if di.UseVpipThree() else 0x11
pimStr      = 'pim'
pimCfgStr   = 'pimCfg'

cmdBogus    = 0xF000
nakBadCmd   = 0x1001

print (hex(pimPort))

# Connection cmds
cmdConn     = 0x0001
cmdPrxConn  = 0x0101
cmdPing     = 0x0300
cmdDisConn  = 0x1000

# Pim cmds
cmdCfgGet   = 0x0801
cmdCfgSet   = 0x0803

# Timeout values
tmDefault   = 100000

#-------------------------------------------------
# Check connection
#-------------------------------------------------
def CheckConnection():
   # Ping the node to see if there is a connection.
   return di.SendCommandBlock(cmdPing, targetNode, connPort, tmDefault)

#-------------------------------------------------
# Set RGC
#-------------------------------------------------
def PimGetRgc():
   # Test config set command
   data = np.zeros(2048, dtype=np.uint8)
   if di.RequestCommand(cmdCfgGet, targetNode, pimPort, data, tmDefault) <= 0:
      print('PimCfg: config get cmd failed')
      return 0
   dataStr = data.tostring()        # Convert the array to a string object
   str = dataStr.decode('utf-8')    # Decode string
   print(str.split('\n')[0])
   return 1

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Pim RGC...')

   if CheckConnection() <= 0:
      print('No connection')
      exit

   PimGetRgc()
else:
   print(__name__)
