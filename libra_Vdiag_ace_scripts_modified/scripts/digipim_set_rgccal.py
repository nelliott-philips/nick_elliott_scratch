import json
import time
import digiLib as dl

node = dl.digiNode

#-------------------------------------------------
# Set RGC
#-------------------------------------------------
def PimSetRgc():
   dl.SetDebugLevel(node, dl.dbgGen, dl.lvlVerb)
   dl.SetRegSim(node, 0)
   
   # Test config set command
   str = json.dumps({'pimCfg':{'rgcCal':0}})
   dl.SetPimCfg(node, str)

   time.sleep(2)
   
   dl.SetRegSim(node, 1)
   dl.SetDebugLevel(node, dl.dbgGen, dl.lvlWarn)

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Set Pim RGC cal...')

   if not dl.CheckConnection(node):
      exit

   PimSetRgc()
else:
   print(__name__)
