import DiagnosticInterface as di
import time
import numpy as np
import json

targetNode  = 0x100
pimPort     = 0x31

print (hex(pimPort))

# Pim Config
cmdSetPimConfig = 0x0803

# Timeout values
tmDefault   = 1000

if __name__ == 'builtins':
   if di.UseVpipThree():
      str  = json.dumps({'pimCfg':{'bootMode':'prodigy'}})
      data = np.fromstring(str, dtype=np.uint8)
      if di.SendCommandData(cmdSetPimConfig, targetNode, pimPort, data, tmDefault) <= 0:
         print('SetPimConfig(bootMode, prodigy failed')
else:
   print(__name__)

