import piplates.DAQC2plate as DAQC2  # As per https://pi-plates.com/daqc2-users-guide/ 
import piplates.DAQCplate as DAQC    # Apropriated from above
import time

DAQC.DAQCversion
DAQC.daqcsPresent

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

DAQC.VerifyADDR(0)  # Useful to check if adress is valid

##¤ Setting digital voltage:
# DAQC.setDOUTbit(0, 0)
# DAQC.clrDOUTbit(0, 0)

##¤ Making continous measurements with ADC
def ADC_continous_sample_and_print(addr, bit, duration=1, sample_rate=10):
    sample_delay = 1/sample_rate

    print("Making ADC measurements on channel ", bit)
    print("Sample rate: ", sample_rate, " Hz")
    print("Duration: ", duration, "seconds.")
    t_initial = time.time()
    while True:
        print(DAQC.getADC(addr, bit))
        if time.time() - t_initial > duration:
            print("Time elapsed: ", time.time() - t_initial, " seconds")
            break
        time.sleep(sample_delay)

ADC_continous_sample_and_print(0, 0, duration=5, sample_rate=2)

##¤ Making single measurement with ADC
DAQC.getADC(0, 0)

##¤ Setting DAC
DAQC.setDAC(0, 0, 0.2)

##¤ Setting DAC and measuring with ADC
def setDAC_measureADC(addr, bit, voltage, Print=True):
    DAQC.setDAC(addr, bit, voltage)
    set_value = DAQC.getDAC(addr, bit)
    if Print:
        print("Seting to: ", set_value)
    # t_i = time.time()
    counter = 0
    meas1 = DAQC.getADC(addr, bit)
    time.sleep(0.05)   # Without sleep, can make same measurement twice before settling
    meas2 = DAQC.getADC(addr, bit)
    while meas1 != meas2:
        meas1 = meas2
        time.sleep(0.05)
        meas2 = DAQC.getADC(addr, bit)
        counter += 1
    # t_f = time.time()
    if Print:
        try:
            print("Measured:  ", meas2)
            print("Difference, abs: ",  - meas2)
            print("Difference, rel: ", 1 - set_value / meas2)
        except:
            print("Errored on printing")  # Sometimes div by zero
        print("Waited ", counter, " time(s) for level to settle\n")
    return (set_value, meas2)

setDAC_measureADC(0, 0, 2)

def setDAC_measureADC_returnMeasurements(addr, bit, low=0, high=4, N=200, finnish_at_zero=True):
    set_values = np.zeros(N)
    measured_values = np.zeros(N)
    voltages = np.linspace(low, high, N)
    for ind in range(N):
        setval, measval = setDAC_measureADC(addr, bit, voltages[ind], False)
        print("Measurement: ", measval)
        set_values[ind] = setval
        measured_values[ind] = measval
    print("Finnished!")
    if finnish_at_zero:
        DAQC.setDAC(addr, bit, 0)
    return (set_values, measured_values)
set_values, measured_values = setDAC_measureADC_returnMeasurements(0, 0, low=0, high=0.4444, N=75)

R_g = 10e3
G = (100e3 - R_g)/R_g
G

##

import pandas as pd
my_data = pd.DataFrame({"set_values": set_values, "measured_values": measured_values})
pd.DataFrame.to_csv(my_data, os.path.join(datadir, "first_data_AD623_G=9.csv"))