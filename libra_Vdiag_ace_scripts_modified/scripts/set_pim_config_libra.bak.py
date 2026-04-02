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
            'bootMode': 'libra',
            'imageMode': 'bmode',
            'rgcCal': 0,
            'rgcBmode': {
                'startGain': 229,
                'endGain': 264,
                'slope': 3,
                'gainAdj': 0,
                'holdOff': 0},
            'rgcChroma': {
                'startGain': 59,
                'endGain': 94,
                'slope': 0,
                'gainAdj': 0,
                'holdOff': 0},
            'bandPassFilter': True,
            'channelMatch': {
                'enable': False,
                'curAvg': 0,
                'trueAvg': 0,
                'threshA': 0,
                'threshB': 0,
                'threshC': 0,
                'digiChromaOff': 0,
                'sensElems': []},
                'accumulation': True,
            'rfTiming': {
                'acquisition': 0,
                'muxSwitch': 0,
                'ampSwitch': 0},
            'rfCtl': {
                'selfTestSel': 0,
                'vmag': 3,
                'atr7out': False},
            'adc': {
                'randomizer': True,
                'twoComplement': True,
                'altBitPolarity': False,
                'invertClk': False,
                'internalTerm': False,
                'phase': 0,
                'current': 0,
                'outputMode': 1,
                'testMode': 0},
            'sequencer': {
                'txStartBmode': 0,
                'rxStartBmode': 0,
                'txStartChroma': 0,
                'rxStartChroma': 0,
                'firingIntervalBmode': 0,
                'firingIntervalChroma': 0,
                'elementCnt': 0,
                'apertureCntBmode': 0,
                'aptSizeBmode': 0,
                'aptSizeChroma': 0,
                'fireCntBmode': 0,
                'fireCntChroma': 0,
                'altScanDir': False,
                'tgcDaughtercardDisable': False,
                'tgcDaughtercardState': False,
                'catAmpSwitchDisable': False,
                'catPulseDisable': False,
                'catTxSwitchDisable': False},
            'pulseTiming': {
              'txPulseBmode': {
                  'cycleCnt': 3,
                  'zone0': 50,
                  'zone1': 50,
                  'zone2': 50,
                  'zone3': 50,
                  'zone4': 50,
                  'zone5': 50},
            'txPulseChroma': {
                'cycleCnt': 0,
                'zone0': 0,
                'zone1': 0,
                'zone2': 0,
                'zone3': 0,
                'zone4': 0,
                'zone5': 0},
            'command': {
                'zone0': 0,
                'zone1': 0,
                'idle': 0}},
        'powerCtl': {
                'hvBoost': 52,
                'hv': 50,
                'hvOvThreshold': 52,
                'hvUvThreshold': 48,
                'stepDelay':100}}})

    print(str)
    LoggerOperations.LogInfo(str)
    LoggerOperations.LogInfo("SET PIM CONFIG")
    data = np.fromstring(str, dtype=np.uint8)
    if di.SendCommandData(cmdCfgSet, targetNode, pimPort, data, tmDefault) <= 0:
        print('config set cmd failed')
else:
    print(__name__)

