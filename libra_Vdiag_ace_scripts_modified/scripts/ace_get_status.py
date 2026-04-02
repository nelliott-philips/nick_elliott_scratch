import DiagnosticInterface as di
import time
import numpy as np
import json

targetNode  = 0x100
connPort    = 0x01
devPort     = 0x30 if di.UseVpipThree() else 0x10
pimPort     = 0x31 if di.UseVpipThree() else 0x11

cmdPing     = 0x0300
cmdStsReq   = 0x0011
cmdStsReg   = 0x0031
cmdStsUnReg = 0x0033

tmDefault   = 1000

print (hex(devPort))
print (hex(pimPort))

#-------------------------------------------------
# Check connection
#-------------------------------------------------
def CheckConnection():
   # Ping the node to see if there is a connection.
   if di.SendCommandBlock(cmdPing, targetNode, connPort, tmDefault) <= 0:
      print('GetStatus: no connection')
      return 0
   return 1

#-------------------------------------------------
# GetStatus
#-------------------------------------------------
def GetStatus():
   # Test status register
   if di.SendCommandBlock(cmdStsReg, targetNode, devPort, tmDefault) <= 0:
      print('GetStatus: status reg cmd failed')
      return ''

   # Test status request
   data = np.zeros(1024, dtype=np.uint8)
   if di.RequestCommand(cmdStsReq, targetNode, devPort, data, tmDefault) <= 0:
      print('GetStatus: status req cmd failed')
      return ''
   dataStr = data.tostring()        # Convert the array to a string object
   str = dataStr.decode('utf-8')    # Decode string

   # Test status unregister
   if di.SendCommandBlock(cmdStsUnReg, targetNode, devPort, tmDefault) <= 0:
      print('GetStatus: status unreg cmd failed')
      return ''

   return str.split('\n')[0]

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Get status...')

   if CheckConnection():
      str = GetStatus()
      print(str)
else:
   print(__name__)
