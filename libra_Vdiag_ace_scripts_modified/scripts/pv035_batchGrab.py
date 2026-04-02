import GuiTest
import time
import os

nFrames = 4
nFrames2WaitRD = 33
nFramesRaw = 50
fpsBM = 11

gblWait = 2
loadtablewait = 10

rootVDiagInstall = os.path.dirname(os.getcwd()) # the current working directory is the Subfolder "Release", the dirname() function goes up one level to get to the Vdiag root directory.
root = "C:\\autodump\\pv035\\" # save path to dump the data. Should be updated and use '\\' for file seperators and surrounded by ""
if not os.path.exists(root):
	os.makedirs(root)

# load in the PV.035 bootmode and ensure some test patterns are working before running this.
while not GuiTest.toolTabRdn('bm2'):
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
		time.sleep(0.1)
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
while not GuiTest.setROF(5):
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

# bpf + rdM + tgc05 + rect + lpf + rof05
# 28 (CC)
GuiTest.envFilepathSet(root + 'bpf_rdM_tgc05_rect_lpf_rof05.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('tgc',True)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('lpf',True)
GuiTest.configTabCbx('rof',True)
GuiTest.setFPGATGC(5)
while not GuiTest.setROF(5):
   time.sleep(gblWait)
GuiTest.setRdrIIR(127)
captureRDX('rdm',nFrames2WaitRD,nFrames,fpsBM)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('tgc',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('lpf',False)
GuiTest.configTabCbx('rof',False)
