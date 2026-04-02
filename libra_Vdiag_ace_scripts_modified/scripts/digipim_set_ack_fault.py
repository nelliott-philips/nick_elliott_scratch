import json
import time
import digiLib as dl

node = dl.digiNode

#-------------------------------------------------
# Set Fault Ack
#-------------------------------------------------
def PimSetAckFault():
   #dl.SetDebugLevel(node, dl.dbgGen, dl.lvlVerb)
   #dl.SetRegSim(node, 0)
   
   # Test config set command
   str = json.dumps({'faultAck':['CathChkFail']})
   #str = json.dumps({'faultAck':['CathCurFault']})
   dl.SetFaultAck(node, str)

   time.sleep(2)

   #dl.SetDebugLevel(node, dl.dbgGen, dl.lvlWarn)

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Pim set ack fault...')

   if not dl.CheckConnection(node):
      exit

   PimSetAckFault()
else:
   print(__name__)
