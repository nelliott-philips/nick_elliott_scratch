import json
import time
import digiLib as dl

node = dl.digiNode

#-------------------------------------------------
# Set RGC
#-------------------------------------------------
def PimSetPwrHv():
   dl.SetDebugLevel(node, dl.dbgGen, dl.lvlVerb)
   dl.SetRegSim(node, 0)

   # Test config set command
   str = json.dumps({'pimCfg':{'powerCtl':{'hvBoost':60, 'hv':50, 'hvOvThreshold':64, 'hvUvThreshold':48}}})
   dl.SetPimCfg(node, str)

   time.sleep(2)
   
   dl.SetRegSim(node, 1)
   dl.SetDebugLevel(node, dl.dbgGen, dl.lvlWarn)

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Set Pim HV...')

   if not dl.CheckConnection(node):
      exit

   PimSetPwrHv()
else:
   print(__name__)
