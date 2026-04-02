import DiagnosticInterface as di
import GuiTest
import Popup
import time
import numpy as np
import json
import time

import LoggerOperations

targetNode = 0x101
pimPort    = 0x31
pimStr     = 'pim'
pimCfgStr  = 'pimCfg'

# Pim cmds
cmdCfgGet = 0x0801
cmdCfgSet = 0x0803

# Timeout values
tmDefault = 1000

if __name__ == 'builtins':
    cleanup = False
    explain = True

    while GuiTest.pimName() == 'None':
        if explain:
            Popup.NonBlockingPopup("connect a PIM", "Set Channel Match")
            explain = False
            cleanup = True
        time.sleep(3)

    explain = True
    while GuiTest.noneBootModeChecked():
        if explain:
            Popup.NonBlockingPopup("connect a catheter", "Set Channel Match")
            explain = False
            cleanup = True
        time.sleep(3)

    if cleanup:
        Popup.Close("Set Channel Match")

    str = json.dumps({
        'pimCfg': {
            'channelMatch': {
                'enable': True,
                'curAvg': -67,
                'trueAvg': -43,
                'threshA': -170,
                'threshB': -170,
                'threshC': 30,
                'digiChromaOff': 0,
                'sensElems': [-96, -210, -140, -1, -68, -10, -69, -64, -60, -62, -61, -87, -58, -70, 0, -56,
                              -56, -56, -125, -56, -62, -58, -63, -67, -59, -63, -60, -71, -61, -63, -64, -61,
                              -65, -62, -61, -64, -59, -57, -59, -58, -73, -71, -64, -61, -63, -64, -63, -63,
                              -62, -57, -68, -57, -155, -57, -63, -57, -59, -58, -57, -57, -140, -62, -39, -49]}}})
    print(str)
    LoggerOperations.LogInfo(str)
    LoggerOperations.LogInfo("SET CHANNEL MATCH")
    data = np.fromstring(str, dtype=np.uint8)
    if di.SendCommandData(cmdCfgSet, targetNode, pimPort, data, tmDefault) <= 0:
        print('config set cmd failed')
else:
    print(__name__)

