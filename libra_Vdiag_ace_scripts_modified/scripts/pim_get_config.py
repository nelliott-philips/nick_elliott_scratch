import DiagnosticInterface as di
import time
import numpy as np
import json

targetNode  = 0x100
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
tmDefault   = 1000

#-------------------------------------------------
# Check connection
#-------------------------------------------------
def CheckConnection():
   # Ping the node to see if there is a connection.
   if di.SendCommandBlock(cmdPing, targetNode, connPort, tmDefault) <= 0:
      print('CfgTest: no connection')
      return 0
   return 1

#-------------------------------------------------
# Pim get config
#-------------------------------------------------
def PimGetCfg():
   # Test config get command
   data = np.zeros(1024, dtype=np.uint8)
   if di.RequestCommand(cmdCfgGet, targetNode, pimPort, data, tmDefault) <= 0:
      print('CfgTest: config get cmd failed')
      return 0
   dataStr = data.tostring()        # Convert the array to a string object
   str = dataStr.decode('utf-8')    # Decode string
   print(str.split('\n')[0])
   return 1

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Pim get config...')

   if CheckConnection():
      PimGetCfg()
else:
   print(__name__)
