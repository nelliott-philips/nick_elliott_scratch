import digiLib as dl

node = dl.digiNode
port = dl.pimPort

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Get status...')

   if not dl.CheckConnection(node):
      exit

   print(dl.GetPimStatus(node))
else:
   print(__name__)
