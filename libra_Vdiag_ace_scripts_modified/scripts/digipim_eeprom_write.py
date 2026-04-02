import DiagnosticInterface as di
import digiLib as dl
import crcLsb
import time
import os
import numpy as np
import tkinter as tk
from tkinter.filedialog import askopenfilename
import json


targetNode  = 0x101    # 0x101 PIM     0x100 ACE 
connPort    = 0x01
capPort     = 0x02
devPort     = 0x30 if di.UseVpipThree() else 0x10
pimPort     = 0x31 if di.UseVpipThree() else 0x11
dbgPort     = 0x20

cmdBogus    = 0xF000
nakBadCmd   = 0x1001

print (hex(devPort))
print (hex(pimPort))

# Connection cmds
cmdPing     = 0x0300

# Device cmds
cathDataSet = 0x0507
regSim      = 0x0013

# Timeout values
tmDefault     = 1000
tmMedium      = 5000
tmLong        = 20000
tmVeryLong    = 300000

# Max packet size
maxPkt        = 2048

node = dl.digiNode

#-------------------------------------------------
# EEPROM write
#-------------------------------------------------
def EEPROMwrite():
   # Turn off reg sim
   data = np.array([0], dtype=np.uint8)
   di.SendCommandData(regSim, targetNode, dbgPort, data, tmDefault)
   
   addr = int(15) #in location 15 for config code
   size = 1
   val = int(3) # make config code = 3

   param = np.array([addr, size], dtype=np.uint32)
   paramData = param.view(np.uint8)
   data = np.concatenate((paramData, np.array([val], dtype=np.uint8)))

   di.SendCommandData(cathDataSet, targetNode, pimPort, data, tmDefault)

   time.sleep(2)
   
   # Turn on reg sim again  
   data = np.array([1], dtype=np.uint8)
   di.SendCommandData(regSim, targetNode, dbgPort, data, tmDefault)

   return 1

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   if not dl.CheckConnection(node):
      exit
      
   np.set_printoptions(formatter={'int':hex})      
      
   print('EEPROM write starts...') 
   EEPROMwrite()  
   print('EEPROM write ends') 
else:
   print(__name__)
