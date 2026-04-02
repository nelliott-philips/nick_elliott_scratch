import digiLib as dl

node = dl.aceNode
port = dl.devPort

#-------------------------------------------------
# Main test section
#-------------------------------------------------
if __name__ == 'builtins':
   print('Get status...')

   if not dl.CheckConnection(node):
      exit

   print(dl.GetStatus(node, port))
else:
   print(__name__)
