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
            'bootMode':'prodigy',
            'imageMode': 'bmode', 
            'rgcCal': 0,
            'rgcBmode': {
                'startGain': 121,
                'endGain': 121,
                'slope': 3,
                'gainAdj': 0,
                'holdOff': 198560},
            'rgcChroma': {
                'startGain': 276,
                'endGain': 296,
                'slope': 0,
                'gainAdj': 0,
                'holdOff': 310},
            'bandPassFilter': False,
            'channelMatch': {
                'enable': False,
                'curAvg': -70,
                'trueAvg': -70,
                'threshA': -200,
                'threshB': -170,
                'threshC': 30,
                'digiChromaOff': 0,
                'sensElems': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}, 
            'accumulation': True,
            'rfTiming': {
                'acquisition': 275,
                'muxSwitch':10,
                'ampSwitch':125},
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
                'rxStartBmode': 58,
                'txStartChroma': 55,
                'rxStartChroma': 55,
                'firingIntervalBmode': 18600,
                'firingIntervalChroma': 14600,
                'elementCnt': 64,
                'apertureCntBmode': 64,
                'aptSizeBmode': 14,
                'aptSizeChroma': 1,
                'fireCntBmode': 2,
                'fireCntChroma': 64,
                'altScanDir': True,
                'tgcDaughtercardDisable': True,
                'tgcDaughtercardState': True,
                'catAmpSwitchDisable': False,
                'catPulseDisable': False,
                'catTxSwitchDisable': False},
            'pulseTiming': {
                'txPulseBmode': {
                    'cycleCnt': 2,
                    'zone0': 20,
                    'zone1': 25,
                    'zone2': 20,
                    'zone3': 25,
                    'zone4': 0,
                    'zone5': 0},
                'txPulseChroma': {
                    'cycleCnt': 1,
                    'zone0': 20,
                    'zone1': 25,
                    'zone2': 0,
                    'zone3': 0,
                    'zone4': 0,
                    'zone5': 0},
                'command': {
                    'zone0': 15,
                    'zone1': 15,
                    'idle': 30}},
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

