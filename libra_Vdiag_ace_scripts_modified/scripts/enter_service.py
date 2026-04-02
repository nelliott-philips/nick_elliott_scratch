import DiagnosticInterface as di
import time
import numpy as np

targetNode  = 0x101
connPort    = 0x01
pimPort     = 0x31 if di.UseVpipThree() else 0x11
dbgPort     = 0x20

pimStr      = 'pim'
pimCfgStr   = 'pimCfg'

cmdBogus    = 0xF000
nakBadCmd   = 0x1001
regSim = 0x0013

print (hex(pimPort))

# Connection cmds
cmdConn     = 0x0001
cmdPrxConn  = 0x0101
cmdPing     = 0x0300
cmdDisConn  = 0x1000

# Pim cmds
cmdEnterService   = 0x0901
cmdExitService    = 0x0903

# Timeout values
tmDefault   = 1000

#-------------------------------------------------
# Check connection
#-------------------------------------------------
def CheckConnection():
   # Ping the node to see if there is a connection.
   return di.SendCommandBlock(cmdPing, targetNode, connPort, tmDefault)

#-------------------------------------------------
# Enter service
#-------------------------------------------------
def EnterService():
   str = "Trinity"
   data = np.fromstring(str, dtype=np.uint8)
   print(data)
   di.SendCommandData(cmdEnterService, targetNode, dbgPort, data, tmDefault)
   return 1

#-------------------------------------------------
# Exit service
#-------------------------------------------------
def ExitService():
   di.SendCommandBlock(cmdExitService, targetNode, dbgPort, tmDefault)
   return 1

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Enter service...')

   if CheckConnection() <= 0:
      print('No connection')
      exit

   EnterService()
else:
   print(__name__)
