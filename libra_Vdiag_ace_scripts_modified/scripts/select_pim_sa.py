import DiagnosticInterface as di
import time
import numpy as np
import json

targetNode  = 0x100
pimPort     = 0x31 if di.UseVpipThree() else 0x11

print (hex(pimPort))

# Pim Select
cmdSelectPim = 0x0101

# Timeout values
tmDefault = 1000

if __name__ == 'builtins':
   saPim   = 'SA'
   print (saPim)
   npSaPim = np.fromstring(saPim, dtype=np.uint8)
   print (npSaPim)
   data    = np.concatenate((npSaPim,np.array([0], dtype=np.uint8)))
   print (data)

   if di.SendCommandData(cmdSelectPim, targetNode, pimPort, data, tmDefault) <= 0:
      print('Select Pim failed')
else:
   print(__name__)

