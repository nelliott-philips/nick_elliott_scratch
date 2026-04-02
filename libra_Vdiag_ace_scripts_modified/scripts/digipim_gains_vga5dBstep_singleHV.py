import Config
import DiagnosticInterface
import ProductionInterface
import GuiTest
import ImageOperations
import time
import os

gblWait          = 1
captureRawFrames = 10

# image long enough to collect X frames
def captureX(framesToGet):
    wt = gblWait
    time.sleep(wt)

    # turn imaging on
    GuiTest.image(True)
    time.sleep(wt)
    GuiTest.setFrameLimit(framesToGet)

    # set to zero to make sure we don't fall out too quickly from the while loop
    GuiTest.setFrameCountRec(0)
    GuiTest.runTabButton('rec', True)

    while GuiTest.getFrameCountRec()<framesToGet:
        time.sleep(0.5)

        # check if imaging has stopped
        if not ProductionInterface.ImagingActive():
            print('ERROR: imaging stopped')
            break
        #endif
    #endwhile

    # turn imaging off
    GuiTest.image(False)
#enddef

# configure the VGA gain on the digiPIM and collect raw data
def collectRawData(fileName, rgcRampSPIdataRegister_64_1, rgcRampSPIdataRegister_64_2, rgcRampSPIdataRegister_64_3, rgcRampSPIdataRegister_64_4, last=False):
    if GuiTest.noneBootModeChecked():
        print('ERROR: no catheter connected')
        return
    #endif

    DiagnosticInterface.WriteToDigiPim(0x70000064, rgcRampSPIdataRegister_64_1)
    DiagnosticInterface.WriteToDigiPim(0x70000064, rgcRampSPIdataRegister_64_2)
    DiagnosticInterface.WriteToDigiPim(0x70000064, rgcRampSPIdataRegister_64_3)
    DiagnosticInterface.WriteToDigiPim(0x70000064, rgcRampSPIdataRegister_64_4)
    time.sleep(0.5)

    # these are SPI registers so there isn't any read back
    print ('collect raw data '+fileName)

    # check if chromaflo is enabled
    prefix = 'gs'
    frames = captureRawFrames
    if ImageOperations.ChromafloEnabled():
        prefix = 'cf'
        frames = frames*2

    GuiTest.rawFilepathSet(root + prefix+'_'+fileName+'.bin')
    captureX(frames)

    # turn off imaging
    if not last:
        GuiTest.image(False)
        time.sleep(gblWait)
    #endif
#enddef

def collectDataSet(suffix):
    # if there is a suffix, it is a realterm script
    if suffix != '':
        print ('----> execute script')
        result = GuiTest.executeScript(suffix+'.txt')

        if result == -1:
            print (suffix+' script not found')
        #endif

        # append an underscore for the data collection
        suffix = suffix + '_'
    #endif

    collectRawData(suffix+'s_Prod_1_FGA30_VMAG5_VDBS0', 0x190000, 0x180000, 0x1B0000, 0x1A0000)
    collectRawData(suffix+'s_Prod_1_FGA30_VMAG5_VDBS5', 0x190906, 0x180906, 0x1B0906, 0x1A0906)
    collectRawData(suffix+'s_Prod_1_FGA30_VMAG5_VDBS10', 0x19120C, 0x18120C, 0x1B120C, 0x1A120C)
    collectRawData(suffix+'s_Prod_1_FGA30_VMAG5_VDBS15', 0x191B12, 0x181B12, 0x1B1B12, 0x1A1B12)
    collectRawData(suffix+'s_Prod_1_FGA30_VMAG5_VDBS20', 0x192418, 0x182418, 0x1B2418, 0x1A2418)
    collectRawData(suffix+'s_Prod_1_FGA30_VMAG5_VDBS25', 0x192D1E, 0x182D1E, 0x1B2D1E, 0x1A2D1E)
    collectRawData(suffix+'s_Prod_1_FGA30_VMAG5_VDBS30', 0x193624, 0x183624, 0x1B3624, 0x1A3624)
    collectRawData(suffix+'s_Prod_1_FGA30_VMAG5_VDBS35', 0x193F2A, 0x183F2A, 0x1B3F2A, 0x1A3F2A)
    collectRawData(suffix+'s_Prod_1_FGA30_VMAG5_VDBS40', 0x194830, 0x184830, 0x1B4830, 0x1A4830, True)

# turn off auto imaging - potential race (only really care for auto start testing)
GuiTest.toolTabCbx('auto', False)

# set the correct header offset radio button on the tools tab
GuiTest.toolTabCbx('offset', True)

# record digiPIM temperature (not necessary, but it will be needed for Bernhard's thermal test)
GuiTest.toolTabCbx('temp', True)

# wait until the digiPIM is connected (otherwise the Prodigy isn't enabled)
explain = True
while not GuiTest.prodigyBootModeEnabled():
    if explain:
        print("connect the digiPIM")
        explain = False
    #endif

    time.sleep(3)
#endwhile

# wait for a catheter to be connected (doesn't have to be prodigy)
explain = True
while GuiTest.noneBootModeChecked():
    if explain:
        print("connect a catheter")
        explain = False
    #endif

    time.sleep(3)
#endwhile

# based on the boot mode create the data directory
bootMode = DiagnosticInterface.GetBootMode()
folder   = 'Unknown'
prodigy  = False

if bootMode == 2:
    folder = 'pv035'
elif bootMode == 3:
    folder = 'pv018'
elif bootMode == 4:
    folder = 'eep'
elif bootMode == 7:
    folder  = 'prodigy'
    prodigy = True
else:
    print('boot mode', bootMode, 'not recognized')
    exit(-1)
#endif

# the current working directory is the Subfolder "Release", the dirname() function goes up one level to get to the VDiag root directory.
rootVDiagInstall = os.path.dirname(os.getcwd())

# save path to dump the data.
root = "C:\\autodump\\" + folder + "\\"

if not os.path.exists(root):
    print ("creating "+root+" directory")
    os.makedirs(root)
#endif

# turn off imaging
GuiTest.image(False)

# open the image display
GuiTest.runTabButton('disp1', True)

# set the cable length - yes this is a digiPIM, but the focus engine is still on the ACE card
GuiTest.setCableLength('5')
time.sleep(gblWait)

# grab only raw data
# we need at least 31 frames of processed env data before we can start matching.
GuiTest.runTabCbx('env',   False)
GuiTest.runTabCbx('ausil', False)
GuiTest.runTabCbx('raw',   True)

# for prodigy run a script to change the ASIC voltage
# if prodigy:
    # allowMultipleScripts = Config.ReadInt('Scripts', 'allowMultiple', 0)

    # if allowMultipleScripts == 0:
        # Config.WriteInt('Scripts', 'allowMultiple', 1)

    # collectDataSet('HV10V')
    # collectDataSet('HV15V')
    # collectDataSet('HV20V')
    # collectDataSet('HV25V')
    # collectDataSet('HV30V')
    # collectDataSet('HV35V')
    # collectDataSet('HV40V')
    # collectDataSet('HV45V')
    # collectDataSet('HV50V')

    # if allowMultipleScripts == 0:
        # Config.WriteInt('Scripts', 'allowMultiple', 0)
    # #endif
# else:
collectDataSet('')
#endif

# disable raw data collection
GuiTest.runTabCbx('raw',False)


