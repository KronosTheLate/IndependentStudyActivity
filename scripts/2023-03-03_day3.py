import piplates.DAQC2plate as DAQC2  # As per https://pi-plates.com/daqc2-users-guide/ 
import piplates.DAQCplate as DAQC    # Apropriated from above
import time

DAQC2.DAQC2version
DAQC2.daqc2sPresent
DAQC.daqcsPresent

import numpy as np      # For linspace to make sweep, and to make and save arrays
import pandas as pd     # For making dataframe to save to disk
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

##¤ Setting DAC and measuring with ADC
def getADC_ifsettled(addr, bit, sleeptime=0.01, maxiter=100, Print=True):
    meas1 = DAQC2.getADC(addr, bit)
    time.sleep(sleeptime)
    meas2 = DAQC2.getADC(addr, bit)
    time.sleep(sleeptime)
    meas3 = DAQC2.getADC(addr, bit)
    counter = 2     # Start having waited 2 sleeptimes
    while (meas1!=meas2 or meas1 != meas3):
        meas1 = meas2
        meas2 = meas3
        time.sleep(sleeptime)
        meas3 = DAQC2.getADC(addr, bit)
        counter += 1
        if counter > maxiter:
            print("Timeout after ", counter, " iterations,  ", counter*sleeptime, " seconds")
            return meas3
    if Print:
        print("Waited ", counter, " times,  ", counter*sleeptime, " seconds")
    return meas3
getADC_ifsettled(0, 0)
DAQC2.getADC(0, 0)


def setDAC_measureADC(addr, bitDAC, bitADC, voltage, Print=True):
    DAQC2.setDAC(addr, bitDAC, voltage)
    set_value = DAQC2.getDAC(addr, bitDAC)
    if Print:
        print("DAC is set to ", set_value)
    measurement = getADC_ifsettled(addr, bitADC, Print=Print)
    if Print:
        try:
            print("ADC measured  ", measurement)
            print("Error, abs: ",  measurement - set_value)
            print("Error, rel: ", measurement/set_value - 1)
        except:
            print("Errored on printing")  # Sometimes div by zero
    return (set_value, measurement)
setDAC_measureADC(0, 1, 0, 0)



setDAC_measureADC(0, 1, 0, 3)
DAQC2.setDAC(0, 1, 4)
DAQC2.getADC(0, 0)

DAQC2.setPWM(0, 0, 0)
DAQC2.setPWM(0, 0, 50)
DAQC2.getPWM(0, 0)


def setDAC_measureADC_returnMeasurements(addr, bit, low=0.0, high=4.0, N=50, finnish_at_zero=True):
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
        DAQC2.setDAC(addr, bit, 0)
    return (set_values, measured_values)
set_values, measured_values = setDAC_measureADC_returnMeasurements(0, 0, low=0, high=4.095, N=50)


# import pandas as pd
# my_data = pd.DataFrame({"set_values": set_values, "measured_values": measured_values})
# pd.DataFrame.to_csv(my_data, os.path.join(datadir, "2023-03-03_75kOhm.csv"))

def sweep_DAC_and_ADC_save_file(filename, addr, bit, low=0.0, high=4.0, N=50, finnish_at_zero=True):
    set_values, measured_values = setDAC_measureADC_returnMeasurements(addr, bit, low, high, N, finnish_at_zero)
    my_data = pd.DataFrame({"set_values": set_values, "measured_values": measured_values})
    pd.DataFrame.to_csv(my_data, os.path.join(datadir, filename + ".csv"))
    print("File " + filename +".csv was written.")

sweep_DAC_and_ADC_save_file("2023-03-03_ExtSupply_330Ohm", 0, 0, 0, 4)

##! Measuring +- 12 V DC
def ADC_continous_sample_and_print(addr, bit, duration=1, sample_rate=10):
    t_initial = time.time()
    sample_delay = 1/sample_rate
    N_samples_expected = duration * sample_rate
    counter = 0

    print("Making ADC measurements on channel ", bit)
    print("Sample rate: ", sample_rate, " Hz")
    print("Duration: ", duration, "seconds.")
    t_lastprint = time.time()
    while True:
        measurement = DAQC2.getADC(addr, bit)
        if time.time() - t_lastprint > sample_delay:
            t_lastprint = time.time()
            print(measurement)
        counter += 1
        if time.time() - t_initial > duration:
            print("Time elapsed: ", time.time() - t_initial, " seconds")
            print(counter, "samples printed (", N_samples_expected, ") expected")
            break
        time.sleep(sample_delay)
ADC_continous_sample_and_print(0, 0, 30, 1)