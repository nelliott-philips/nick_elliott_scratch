import DiagnosticInterface as di
import time
import numpy as np
import json

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
cmdCfgGet   = 0x0801
cmdCfgSet   = 0x0803

# Timeout values
tmDefault   = 1000

#-------------------------------------------------
# Check connection
#-------------------------------------------------
def CheckConnection():
   # Ping the node to see if there is a connection.
   return di.SendCommandBlock(cmdPing, targetNode, connPort, tmDefault)

#-------------------------------------------------
# Set RGC
#-------------------------------------------------
def PimSetRgc():
   # Turn off reg sim
   data = np.array([0], dtype=np.uint8)
   di.SendCommandData(regSim, targetNode, dbgPort, data, tmDefault)
   
   # Test config set command
   str = json.dumps({'pimCfg':{'bootMode':"prodigy"}})
   data = np.fromstring(str, dtype=np.uint8)
   di.SendCommandData(cmdCfgSet, targetNode, pimPort, data, tmDefault)

   time.sleep(2)
   
   # Turn on reg sim again  
   data = np.array([1], dtype=np.uint8)
   di.SendCommandData(regSim, targetNode, dbgPort, data, tmDefault)
   return 1

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Pim RGC...')

   if CheckConnection() <= 0:
      print('No connection')
      exit

   PimSetRgc()
else:
   print(__name__)
