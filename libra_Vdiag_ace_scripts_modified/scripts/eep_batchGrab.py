import GuiTest
import time
import os

nFrames = 4
nFrames2WaitRD = 104
nFramesRaw = 120
fpsBM = 30
fpsCF = 11

gblWait = 1
loadtablewait = 10

rootVDiagInstall = os.path.dirname(os.getcwd()) # the current working directory is the Subfolder "Release", the dirname() function goes up one level to get to the Vdiag root directory.
root = "C:\\autodump\\eep\\" # save path to dump the data. Should be updated and use '\\' for file seperators and surrounded by ""

subDirChroma = 'ACE\\CF\\EE\\EE_COnlyMode_1Frame_Noise_PreAccum.bin' # subdirectory in the VDiag root that paths to the memory loaded test patterns for chromaflo, loads in A frame
subDirBmode = 'ACE\\CF\\EE\\EE_BOnlyMode_1Frame_Noise_PreAccum.bin' # subdirectory in the VDiag root that paths to the memory loaded test patterns for bmode, loads in B frame

if not os.path.exists(root):
	os.makedirs(root)

# load in the EEP bootmode and ensure some test patterns are working before running this.
while not GuiTest.toolTabRdn('bm4'):
	time.sleep(3)
while not GuiTest.toolTabCbx('tpat',True):
	time.sleep(3)

def captureX(framesToGet):
	wt = gblWait
	time.sleep(wt)
	GuiTest.image(True) #  on
	time.sleep(wt)
	GuiTest.setFrameLimit(framesToGet)
	GuiTest.setFrameCountRec(0) # set to zero to make sure we don't fall out too quickly from the while loop
	GuiTest.runTabButton('rec',True)
	while GuiTest.getFrameCountRec()<framesToGet:
		time.sleep(0.5)
	GuiTest.image(False) # off
	
def captureRDX(type,frames2wait,framesToGet,fps): # type should be 'rdm' or 'rda'
	wt = gblWait
	eta2wait = (frames2wait/fps)*1.2; # 20% more over what's expected based on the frame rate.
	time.sleep(wt)
	GuiTest.image(True) #  on
	if (type == 'rda' ):
		GuiTest.runTabButton('rda',True)
	time.sleep(eta2wait) 
	GuiTest.runTabButton('rdm',True) 
	GuiTest.setFrameLimit(framesToGet)
	GuiTest.setFrameCountRec(0) # set to zero to make sure we don't fall out too quickly from the while loop
	time.sleep(eta2wait) # wait enough time to allow the frames 2 wait to accumlate before starting a rec.
	GuiTest.runTabButton('rec',True)
	while GuiTest.getFrameCountRec()<framesToGet:
		time.sleep(0.5)
	GuiTest.image(False) # off
	if (type == 'rda'):
		GuiTest.runTabButton('rda',True) 
	GuiTest.runTabButton('rdm',True)
	

# turn off auto imaging - potential race (only really care for auto start testing)
GuiTest.toolTabCbx('auto',False)

# turn off imaging
GuiTest.image(False)

# set the cable length to default mode - 5 m.
GuiTest.setCableLength('5')
time.sleep(gblWait) # wait to let the settings take affect.

# load the tables (sequencers, focus maps, and test patterns)
GuiTest.toolTabButton('loadtab',True)
time.sleep(loadtablewait)

# Grab only raw data, then disable further raw data saves
# we need at least 31 frames of processed env data before we can start matching. Gathering 60 frames of raw
# 0 (A)
GuiTest.runTabCbx('env',False)
GuiTest.runTabCbx('ausil',False)
GuiTest.runTabCbx('raw',True)
GuiTest.rawFilepathSet(root + 'raw.bin')
captureX(nFramesRaw)
GuiTest.runTabCbx('raw',False)

# Enable env data saves and set the frames back down to 10 for all non RD env saves.
GuiTest.runTabCbx('env',True)

# set defaults
GuiTest.configTabCbx('raw',False)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('rof',False)
GuiTest.configTabCbx('lpf',False)
GuiTest.configTabCbx('env',True)
GuiTest.configTabCbx('tgc',False)
GuiTest.configTabCbx('2sc',False)
GuiTest.configTabCbx('cal',False)

# all off
# 1 (B)
GuiTest.envFilepathSet(root + 'off.bin')
captureX(nFrames)

# bpf only
# 2 (C)
GuiTest.envFilepathSet(root + 'bpf.bin')
GuiTest.configTabCbx('bpf',True)
captureX(nFrames)
GuiTest.configTabCbx('bpf',False)

# skip ringdown manual here because we need to collect more frames than 10

# tgc00-07
# 4 (E) thru 11 (L)
GuiTest.configTabCbx('tgc',True)
for x in range(8):
	FN_Snip = 'tgc%02d.bin' % x
	GuiTest.envFilepathSet(root + FN_Snip)
	GuiTest.setFPGATGC(x)
	captureX(nFrames)
GuiTest.configTabCbx('tgc',False)

# rect
# 12 (M)
GuiTest.envFilepathSet(root + 'rect.bin')
GuiTest.configTabCbx('rect',True)
captureX(nFrames)
GuiTest.configTabCbx('rect',False)

# rect + lpf
# 13 (N)
GuiTest.envFilepathSet(root + 'rect_lpf.bin')
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('lpf',True)
captureX(nFrames)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('lpf',False)

# rect + rof01-rof10
# 14 (O) thru 23 (X)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('rof',True)
for x in range(1,11):
   FN_Snip = 'rect_rof%02d.bin' % x
   GuiTest.envFilepathSet(root + FN_Snip)
   while not GuiTest.setROF(x):
      time.sleep(gblWait)
   captureX(nFrames)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('rof',False)

# bpf + tgc05 
# 24 (Y)
GuiTest.envFilepathSet(root + 'bpf_tgc05.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('tgc',True)
GuiTest.setFPGATGC(5)
captureX(nFrames)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('tgc',False)

# bpf + tgc05 + rect
# 25 (Z)
GuiTest.envFilepathSet(root + 'bpf_tgc05_rect.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('tgc',True)
GuiTest.configTabCbx('rect',True)
GuiTest.setFPGATGC(5)
captureX(nFrames)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('tgc',False)
GuiTest.configTabCbx('rect',False)

# bpf + tgc05 + rect + lpf
# 26 (AA)
GuiTest.envFilepathSet(root + 'bpf_tgc05_rect_lpf.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('tgc',True)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('lpf',True)
GuiTest.setFPGATGC(5)
captureX(nFrames)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('tgc',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('lpf',False)

# bpf + tgc05 + rect + lpf + rof05
# 27 (BB)
GuiTest.envFilepathSet(root + 'bpf_tgc05_rect_lpf_rof05.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('tgc',True)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('lpf',True)
GuiTest.configTabCbx('rof',True)
GuiTest.setFPGATGC(5)
while not GuiTest.setROF(x):
   time.sleep(gblWait)
captureX(nFrames)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('tgc',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('lpf',False)
GuiTest.configTabCbx('rof',False)

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# RINGDOWN - BMODE
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# 3 (D) rdM
GuiTest.envFilepathSet(root + 'rdM.bin')
GuiTest.setRdrIIR(127)
captureRDX('rdm',nFrames2WaitRD,nFrames,fpsBM)

# 28 (CC) bpf + rdM + tgc05 + rect + lpf + rof05
GuiTest.envFilepathSet(root + 'bpf_rdM_tgc05_rect_lpf_rof05.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('tgc',True)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('lpf',True)
GuiTest.configTabCbx('rof',True)
GuiTest.setFPGATGC(5)
while not GuiTest.setROF(x):
   time.sleep(gblWait)
GuiTest.setRdrIIR(127)
captureRDX('rdm',nFrames2WaitRD,nFrames,fpsBM)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('tgc',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('lpf',False)
GuiTest.configTabCbx('rof',False)

# rdA40
# no number given, but test needed.
GuiTest.envFilepathSet(root + 'rdA40.bin')
GuiTest.setRdrIIR(40)
captureRDX('rda',nFrames2WaitRD,nFrames,fpsBM)

# bpf + rdA40 + tgc05 + rect + lpf + rof05
# no number given, but test needed
GuiTest.envFilepathSet(root + 'bpf_rdA40_tgc05_rect_lpf_rof05.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('tgc',True)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('lpf',True)
GuiTest.configTabCbx('rof',True)
GuiTest.setFPGATGC(5)
while not GuiTest.setROF(x):
   time.sleep(gblWait)
GuiTest.setRdrIIR(40)
captureRDX('rda',nFrames2WaitRD,nFrames,fpsBM)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('tgc',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('lpf',False)
GuiTest.configTabCbx('rof',False)


# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# CF
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
GuiTest.runTabButton('cf',True) # turn on ChromaFlo
GuiTest.toolTabCbx('tpat',True) # enable the custom test patterns 
# load the test patterns.
GuiTest.toolTabButton('loadtab',True)
time.sleep(loadtablewait)

# cf - raw
# Grab only raw data, then disable further raw data saves
# 29 (DD)
GuiTest.configTabCbx('raw',True)
GuiTest.runTabCbx('env',False)
GuiTest.runTabCbx('ausil',False)
GuiTest.runTabCbx('raw',True)
GuiTest.rawFilepathSet(root + 'cf_raw.bin')
captureX(2*nFramesRaw) # needed to gather 2*40 frames for RD (40 for B-mode, 40 for CF)
GuiTest.runTabCbx('raw',False)
GuiTest.configTabCbx('raw',False)

# Enable env data saves
GuiTest.runTabCbx('env',True)
GuiTest.bufferSet('A')

# cf full, by def. all CF settings are def.
# 35.5 not need, like 36 (MM) but no RD applied.
GuiTest.envFilepathSet(root + 'cf_full.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('tgc',True)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('lpf',True)
GuiTest.configTabCbx('rof',True)
GuiTest.setFPGATGC(5)
while not GuiTest.setROF(x):
   time.sleep(gblWait)
captureX(nFrames) # shorten the frames (env +w/oRD)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('tgc',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('lpf',False)
GuiTest.configTabCbx('rof',False)

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# CF + BM - RD
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# cf/bm + full + rdM
# 36 (MM) 
GuiTest.bufferSet('A/B')
GuiTest.envFilepathSet(root + 'cf_full_rdM.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('tgc',True)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('lpf',True)
GuiTest.configTabCbx('rof',True)
GuiTest.setFPGATGC(5)
while not GuiTest.setROF(x):
   time.sleep(gblWait)
GuiTest.setRdrIIR(127)
captureRDX('rdm',nFrames2WaitRD,nFrames,fpsCF)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('tgc',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('lpf',False)
GuiTest.configTabCbx('rof',False)

# cf + full + rdA40
# no number given, but test needed.
GuiTest.envFilepathSet(root + 'cf_full_rdA40.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('tgc',True)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('lpf',True)
GuiTest.configTabCbx('rof',True)
GuiTest.setFPGATGC(5)
while not GuiTest.setROF(x):
   time.sleep(gblWait)
GuiTest.setRdrIIR(40)
captureRDX('rda',nFrames2WaitRD,nFrames,fpsCF)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('tgc',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('lpf',False)
GuiTest.configTabCbx('rof',False)

GuiTest.runTabButton('cf',True) # turn ChromaFlo back off

GuiTest.toolTabCbx('tpat',False) # disable the custom test patterns 
