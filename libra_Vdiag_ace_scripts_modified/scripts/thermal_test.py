import Config
import DiagnosticInterface
import GuiTest
import Popup
import ProductionInterface
import time
import os

# requirements
#  1) The length of the imaging session should be adjustable
#  2) The number of repeats should be adjustable
#  3) The length of the imaging break should be adjustable

gblWait = 1

# keep imaging for howLong seconds
def image(howLong):
    wt       = gblWait
    failures = 0

    # get the start time
    start = time.time()
    GuiTest.image(True)

    while (time.time() - start < howLong):
        time.sleep(wt)

        # check if imaging has stopped
        if ProductionInterface.ImagingActive():
            continue
        #endif

        # can imaging be restarted?
        if ProductionInterface.ImagingReady():
            # reset the counter if we're good to image
            failures = 0

            # restart imaging
            GuiTest.image(True)
            continue
        #endif

        failures += 1

        # "wait a minute"
        if failures > 60:
            return False
        # endif
    #endwhile

    # turn imaging off
    GuiTest.image(False)
    return True
#enddef


# the current working directory is the Subfolder "Release", the dirname() function goes up one level to get to the VDiag root directory.
rootVDiagInstall = os.path.dirname(os.getcwd())

# save path to dump the data.
root = "C:\\autodump\\prodigy\\"

if not os.path.exists(root):
    print ("creating "+root+" directory")
    os.makedirs(root)
#endif

# turn off auto imaging - potential race (only really care for auto start testing)
GuiTest.toolTabCbx('auto', False)

# set the correct header offset radio button on the tools tab
GuiTest.toolTabCbx('offset', True)

# record digiPIM temperature
GuiTest.toolTabCbx('temp', True)

# wait until a PIM is connected (the thermal test spec uses an SA PIM in one of its tests)
explain = True
cleanup = False

while GuiTest.pimName() == 'None':
    if explain:
        Popup.NonBlockingPopup("connect a PIM", "Thermal Test")
        explain = False
        cleanup = True
    #endif

    time.sleep(3)
#endwhile

explain = True
while GuiTest.noneBootModeChecked():
    if explain:
        Popup.NonBlockingPopup("connect a catheter", "Thermal Test")
        explain = False
    cleanup = True
    #endif

    time.sleep(3)
#endwhile

if cleanup:
    Popup.Close("Thermal Test")

# turn off imaging
GuiTest.image(False)

# open the image display
GuiTest.runTabButton('disp1', True)

# set the cable length
GuiTest.setCableLength('5')
time.sleep(gblWait)

# the config file entries are expected to be in minutes
lengthImagingSessionSeconds = Config.ReadInt('ThermalTest', 'ImageHowLong',  4*60)*60
lengthImagingBreakSeconds   = Config.ReadInt('ThermalTest', 'BreakHowLong',  20)*60
tests                       = Config.ReadInt('ThermalTest', 'TestsHowMany', 2)
lengthWarmUpHowLongSeconds  = Config.ReadInt('ThermalTest', 'WarmUpHowLong', 90)*60

for test in range(tests):
    # it would be better if this checked for the PIM and bailed?
    if test == 0:
        DiagnosticInterface.Trace("thermal_test.py", 120, "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< WARMUP")

        print('\nwarmup', lengthWarmUpHowLongSeconds, 'secs')
        time.sleep(lengthWarmUpHowLongSeconds)
    else:
        DiagnosticInterface.Trace("thermal_test.py", 125, "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< PAUSE")

        print('\nbreak', lengthImagingBreakSeconds, 'secs')
        time.sleep(lengthImagingBreakSeconds)
    #endif

    print('\nimage test', test+1, lengthImagingSessionSeconds, 'secs')

    DiagnosticInterface.Trace("thermal_test.py", 133, "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< IMAGE")
    if not image(lengthImagingSessionSeconds):
        DiagnosticInterface.Trace("thermal_test.py", 135, "<<<<<<<<<<<<<<<<<<<<<<<<<< Imaging failed")
        break
    #endif
#endfor



