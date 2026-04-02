import digiLib as dl

node = dl.digiNode

#-------------------------------------------------
# Get RGC
#-------------------------------------------------
def PimGetRgc():
   print(dl.GetPimCfg(node))

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Get Pim RGC...')

   if not dl.CheckConnection(node):
      exit

   PimGetRgc()
else:
   print(__name__)
