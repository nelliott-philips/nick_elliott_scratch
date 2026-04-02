# 'import' is used to import a given module (file) from Python to use its functionality
import GuiTest
import ProductionInterface
import time

# READ THIS
# 1) the user must clear the fan motor warning manually.  The script will fail if that's not done
# 2) make certain that bad frame number halt is disabled.  VDiag will fire an asynch notification, which
#    will exit the script, but leave the ACE card imaging.

# this will only work if the GUI test module has been initialized by the main window

# turn off auto imaging - potential race (only really care for auto start testing)
GuiTest.toolTabCbx('auto',False)

# turn off imaging
# ProductionInterface.Image(False)

# the ACE card now reports a missing Fan Controller - clear the warning, so it isn't confused with the IVACEPIW0025
GuiTest.clearErrorWindow()

# click on the display - really it needs a way of getting the button state
GuiTest.runTabButton('disp1',True)

iteration    = 1
test         = 0
chroma_delay = False
failures     = 0

# turn off test pattern
# GuiTest.configTabCbx('tpat', False)

# if we're not ready to image, exit the script
if not ProductionInterface.ImagingReady():
   print('not ready to image')
else:
   while True:
      print(iteration)
      iteration += 1

      # if we're not ready to image, exit the script
      if not ProductionInterface.ImagingReady():
         print('not ready to image')
         failures += 1

         # "wait a minute"
         if failures > 12:
            break
         #endif
      else:
         # reset the counter if we're good to image
         failures = 0
         # turn on imaging
         GuiTest.image(True)
      #endif

      # image for a second, and check back
      time.sleep(5)
   #endwhile

   print('keep imaging script ending')
#endif
