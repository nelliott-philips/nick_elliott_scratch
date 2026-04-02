import json
import time
import digiLib as dl

node = dl.digiNode

#-------------------------------------------------
# Set bandpass mode
#-------------------------------------------------
def PimSetMode():
   dl.SetDebugLevel(node, dl.dbgGen, dl.lvlVerb)
   dl.SetRegSim(node, 0)
   
   # Test config set command
   str = json.dumps({'pimCfg':{'bandPassFilter':True}})
   dl.SetPimCfg(node, str)

   time.sleep(2)
   
   dl.SetRegSim(node, 1)
   dl.SetDebugLevel(node, dl.dbgGen, dl.lvlWarn)

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Pim set bandpassfilter to true...')

   if not dl.CheckConnection(node):
      exit

   PimSetMode()
else:
   print(__name__)
