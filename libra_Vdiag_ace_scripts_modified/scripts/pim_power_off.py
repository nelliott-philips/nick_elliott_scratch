import DiagnosticInterface as di
import time
import numpy as np

targetNode  = 0x100
pimPort     = 0x31 if di.UseVpipThree() else 0x11

cmdPimPower = 0x0121
tmDefault   = 1000

print (hex(pimPort))

hdr  = np.array([0x01], dtype=np.uint8)
data = hdr.view(np.uint8)
di.SendCommandData(cmdPimPower, targetNode, pimPort, data, tmDefault)

