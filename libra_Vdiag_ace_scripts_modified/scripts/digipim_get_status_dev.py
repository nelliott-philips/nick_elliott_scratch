import digiLib as dl

node = dl.digiNode
port = dl.devPort

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Get status...')

   if not dl.CheckConnection(node):
      exit

   print(dl.GetDevStatus(node))
else:
   print(__name__)
