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
            Popup.NonBlockingPopup("connect a PIM", "Set Pim Config")
            explain = False
            cleanup = True
        time.sleep(3)

    if cleanup:
        Popup.Close("Set Pim Config")

    str = json.dumps({
        'pimCfg': {
            'bootMode': 'eagleEye', 'imageMode': 'bmode', 'rgcCal': 0,
            'rgcBmode': {'startGain': 129, 'endGain': 188, 'slope': 3, 'gainAdj': 0, 'holdOff': 0},
            'rgcChroma': {'startGain': 79, 'endGain': 138, 'slope': 2, 'gainAdj': 0, 'holdOff': 0},
            'bandPassFilter': True,
            'channelMatch': {'enable': False, 'curAvg': 0, 'trueAvg': 0, 'threshA': 0, 'threshB': 0,
                             'threshC': 0, 'digiChromaOff': 0, 'sensElems': []}, 'accumulation': True,
            'rfTiming': {'acquisition': 0, 'muxSwitch': 0, 'ampSwitch': 0},
            'rfCtl': {'selfTestSel': 1, 'vmag': 3, 'atr7out': True},
            'adc': {'randomizer': True, 'twoComplement': True, 'altBitPolarity': False, 'invertClk': False,
                    'internalTerm': False, 'phase': 0, 'current': 0, 'outputMode': 1, 'testMode': 0},
            'sequencer': {'txStartBmode': 0, 'rxStartBmode': 0, 'txStartChroma': 0, 'rxStartChroma': 0,
                          'firingIntervalBmode': 0, 'firingIntervalChroma': 0, 'elementCnt': 0,
                          'apertureCntBmode': 0, 'aptSizeBmode': 0, 'aptSizeChroma': 0, 'fireCntBmode': 0,
                          'fireCntChroma': 0, 'altScanDir': False, 'tgcDaughtercardDisable': False,
                          'tgcDaughtercardState': False, 'catAmpSwitchDisable': False,
                          'catPulseDisable': False, 'catTxSwitchDisable': False}, 'pulseTiming': {
            'txPulseBmode': {'cycleCnt': 2, 'zone0': 20, 'zone1': 25, 'zone2': 20, 'zone3': 25, 'zone4': 0,
                             'zone5': 0},
            'txPulseChroma': {'cycleCnt': 2, 'zone0': 20, 'zone1': 25, 'zone2': 20, 'zone3': 25, 'zone4': 0,
                              'zone5': 0}, 'command': {'zone0': 0, 'zone1': 0, 'idle': 0}}}})

    print(str)
    LoggerOperations.LogInfo(str)
    LoggerOperations.LogInfo("SET PIM CONFIG")
    data = np.fromstring(str, dtype=np.uint8)
    if di.SendCommandData(cmdCfgSet, targetNode, pimPort, data, tmDefault) <= 0:
        print('config set cmd failed')
else:
    print(__name__)

