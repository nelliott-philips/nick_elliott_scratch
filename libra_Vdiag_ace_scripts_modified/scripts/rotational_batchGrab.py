import GuiTest
import time
import os

nFramesEnv = 4 # number of env data frames to save
nFramesRaw = 40 # number of raw data frames to save
gblWait = 1 # the number of seconds to wait between toggling image states. 1 is typically used.

rootVDiagInstall = os.path.dirname(os.getcwd()) # the current working directory is the Subfolder "Release", the dirname() function goes up one level to get to the Vdiag root directory.
root = "C:\\autodump\\revo\\" # save path to dump the data. Should be updated and use '\\' for file seperators and surrounded by ""
if not os.path.exists(root):
	os.makedirs(root)

# load in the Revo bootmode and ensure some test patterns are working before running this.
while not GuiTest.toolTabRdn('bm5'):
	time.sleep(3)
# tool tab check box test pattern is the test pattern read from VDIAG memory. The on-board generated test pattern doesn't seem to work with Revo, so using the memory one instead.
while not GuiTest.toolTabCbx('tpat',True):
	time.sleep(3)

def capture(framesToGet):
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

# turn off auto imaging - potential race (only really care for auto start testing)
GuiTest.toolTabCbx('auto',False)

# turn off imaging
GuiTest.image(False)

# set the cable length to 5 m setting. 
GuiTest.setCableLength('5')

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#            RAW
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

# Grab raw data, then disable further raw data saves
GuiTest.configTabCbx('tpat',True) #should already be set, but setting again to make sure
GuiTest.configTabCbx('ttrig',True) #should already be set, but setting again to make sure

# make sure only raw is being saved
# 0 (A)
GuiTest.runTabCbx('env',False)
GuiTest.runTabCbx('ausil',False)
GuiTest.runTabCbx('raw',True)
GuiTest.rawFilepathSet(root + 'raw.bin')
capture(nFramesRaw)
GuiTest.runTabCbx('raw',False)

# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#             ENV
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
# Enable env data saves
GuiTest.runTabCbx('env',True)

# set defaults
GuiTest.configTabCbx('raw',True)
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
capture(nFramesEnv)

# bpf only
# 2 (C)
GuiTest.envFilepathSet(root + 'bpf.bin')
GuiTest.configTabCbx('bpf',True)
capture(nFramesEnv)
GuiTest.configTabCbx('bpf',False)

# rect only
# 4 (D) - note the table skips one "3" here - must be a typo
GuiTest.envFilepathSet(root + 'rect.bin')
GuiTest.configTabCbx('rect',True)
capture(nFramesEnv)
GuiTest.configTabCbx('rect',False)

# rect + rof06
# 5 (E)
GuiTest.envFilepathSet(root + 'rect_rof06.bin')
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('rof',True)
GuiTest.setROF(6)
capture(nFramesEnv)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('rof',False)

# rect + lpf
# 6 (F)
GuiTest.envFilepathSet(root + 'rect_lpf.bin')
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('lpf',True)
capture(nFramesEnv)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('lpf',False)

# rect + +rof06 + lpf
# 7 (G)
GuiTest.envFilepathSet(root + 'rect_rof06_lpf.bin')
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('rof',True)
GuiTest.configTabCbx('lpf',True)
GuiTest.setROF(6)
capture(nFramesEnv)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('rof',False)
GuiTest.configTabCbx('lpf',False)

# bpf + rect 
# 8 (H)
GuiTest.envFilepathSet(root + 'bpf_rect.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('rect',True)
capture(nFramesEnv)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('rect',False)

# bpf + rect + rof06
# 9 (I)
GuiTest.envFilepathSet(root + 'bpf_rect_rof06.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('rof',True)
GuiTest.setROF(6)
capture(nFramesEnv)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('rof',False)

# bpf + rect + lpf 
# 10 (J)
GuiTest.envFilepathSet(root + 'bpf_rect_lpf.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('lpf',True)
capture(nFramesEnv)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('lpf',False)

# bpf + rect + rof06 + lpf 
# 11 (K)
GuiTest.envFilepathSet(root + 'bpf_rect_rof06_lpf.bin')
GuiTest.configTabCbx('bpf',True)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('rof',True)
GuiTest.configTabCbx('lpf',True)
GuiTest.setROF(6)
capture(nFramesEnv)
GuiTest.configTabCbx('bpf',False)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('rof',False)
GuiTest.configTabCbx('lpf',False)

# rect + rof01-11 (only need 1, 3, 5, 6, 7, 9 11 for comparisons)
# 12 (L) thru 17 (Q)
GuiTest.configTabCbx('rect',True)
GuiTest.configTabCbx('rof',True)
for x in range(1,12):
	FN_Snip = 'rect_rof%02d.bin' % x
	GuiTest.envFilepathSet(root + FN_Snip)
	GuiTest.setROF(x)
	capture(nFramesEnv)
GuiTest.configTabCbx('rect',False)
GuiTest.configTabCbx('rof',False)

GuiTest.toolTabCbx('tpat',False) # disable the custom test patterns 