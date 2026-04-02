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

if __name__ == 'builtins':
   str = json.dumps({'pimCfg':{'gain':{'userAdjust':0, 'userAdjustChroma':0}, 'rgc':{'override':False, 'data':[0, 128, 255]}}})
   data = np.fromstring(str, dtype=np.uint8)
   if di.SendCommandData(cmdCfgSet, targetNode, pimPort, data, tmDefault) <= 0:
      print('RgcOvr: config set cmd failed')
else:
   print(__name__)

