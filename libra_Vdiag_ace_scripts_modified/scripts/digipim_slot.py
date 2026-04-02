import DiagnosticInterface as di
import time
import numpy as np

targetNode  = 0x100
devPort     = 0x30 if di.UseVpipThree() else 0x10

cmdRebootSys = 0x0B41
tmDefault   = 1000

print (hex(devPort))

# DigiPim Focus FPGA is loaded in slot 1 of the Focus FPGA (x10)
hdr = np.array([0x11], dtype=np.uint32)
data = hdr.view(np.uint8)
di.SendCommandData(cmdRebootSys, targetNode, devPort, data, tmDefault)

