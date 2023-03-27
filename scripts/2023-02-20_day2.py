import piplates.DAQC2plate as DAQC2  # As per https://pi-plates.com/daqc2-users-guide/ 
import piplates.DAQCplate as DAQC    # Apropriated from above
import time

print("DAQC2 version : ", DAQC2.DAQC2version)
print("DAQC2's present: ", DAQC2.daqc2sPresent)

import numpy as np  # For linspace to make sweep, and to make and save arrays
import os  # To get directory capabilities
pref_dir = '/home/pi/IndividualStudyActivity'
if os.getcwd() == pref_dir:
    print("In expected directory")
else:
    print("Current working directory is different from preferred directory.")
    print("Changing directory to ", pref_dir)
    os.chdir(pref_dir)
datadir = os.path.join(os.getcwd(), "data")
# os.mkdir(datadir)

##¤ Function generator mode   - limited to 0 V to 4.095 V
# The following arguments are used in the Function Generator commands:
addr = 0        # the address of the DAQC2plate board being addressed. This can be 0-7 and is set via the address selection header described above
chan = 1        # the output channel being referenced by the command. This can take on the value of 1 or 2.
# freq: the desired output frequency of the selected channel. This should be in the range of 10 to 10,000.
# type: this argument sets the waveshape. Valid values are:
# 1: sine - lookup table generated
# 2: triangle - lookup table generated triangle wave
# 3: square - computed
# 4: sawtooth - lookup table generated
# 5: inverted sawtooth - lookup table generated
# 6: noise - computed 24 bit pseudo random output updated at 200Khz
# 7: sinc - the classic sin(x)/x function generated with lookup table

# level: the two function generator outputs can be attenuated using the following level values:
# 4: Full amplitude
# 3: 1/2 amplitude
# 2: 1/4 amplitude
# 1: 1/8 amplitude

#DAQC2.fgON(addr, chan)     # enable function generator on selected channel. Note that this function also places the DAQCplate in Function Generator mode.
#DAQC2.fgOFF(addr,chan)     # disable function generator on selected channel. Note that both channels have to be OFF before the DAQCplate will exit the Function Generator mode.
#fgFREQ(addr,chan,freq)     # sets the desired frequency of the selected channel
#fgTYPE(addr,chan,type)     # sets the waveshape of the selected channel. See the list of applicable values above.
#fgLEVEL(addr,chan,level)   # sets the amplitude of the selected channel. See the list of applicable values above.
DAQC2.fgON(0, 1)
DAQC2.fgFREQ(0, 1, 100)
DAQC2.fgTYPE(0, 1, 2)
DAQC2.fgLEVEL(0, 1, 4)

DAQC2.fgOFF(0, 1)
DAQC2.getMode(0)  # 0 => Legacy, 1 => f-generator, 2 => Oscilloscope

##¤ Oscilloscope
def bla_setup():
    DAQC2.startOSC(0)           #enable oscope
    DAQC2.getMode(0) == 2       #d- cheching that mode is as expected
    DAQC2.setOSCchannel(0,1,0)  #use channel 1
    ## Set up trigger:
    ## Use addr 0
    ## Use channel 1
    ## type:    Normal trigger mode (don't collect data until trigger conditions are met)
    ## edge:    Trigger on rising edge of waveform
    ## level:   Trigger at 0.0 volts
    DAQC2.setOSCtrigger(0, 1,'normal','rising',2048)
    ## setup sample rate. Integer corresponds to rate
    #   0: 100
    #   1: 200
    #   2: 500
    #   3: 1000
    #   4: 2000
    #   5: 5000
    #   6: 10,000
    #   7: 20,000
    #   8: 50,000
    #   9: 100,000
    #   10: 200,000
    #   11: 500,000
    #   12: 1,000,000  # Only available when using 1 channel
    DAQC2.setOSCsweep(0, 12)
    DAQC2.intEnable(0)      #enable interrupts
    DAQC2.runOSC(0)         #start oscope
def convert_bitval_to_val(val, bits=12, span=12):
    return (val-2**(bits-1))/2**(bits-1)*span
convert_bitval_to_val(2048)
def bla():
    ## Wait for sweep to complete by monitoring Ocsope interrupt flag
    dataReady=0
    while(dataReady==0):
        if(DAQC2.GPIO.input(22)==0):
            dataReady=1
            DAQC2.getINTflags(0) #clear interrupt flags

    DAQC2.getOSCtraces(0)
    ### print out first 1000 converted values and not the conversion from A2D integer
    # data to measured voltage
    for i in range(1000):
        print(convert_bitval_to_val(DAQC2.trace1[i], 12, 12))
    # DAQC2.stopOSC(0)
    #turn off oscilloscope mode
bla_setup()
bla()
