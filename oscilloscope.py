import piplates.DAQC2plate as DAQC2  # As per https://pi-plates.com/daqc2-users-guide/
import piplates.DAQCplate as DAQC    # Apropriated from above
import time

print("DAQC2 version : ", DAQC2.DAQC2version)
print("DAQC2's present: ", DAQC2.daqc2sPresent)
print("DAQC2's present: ", DAQC.daqcsPresent)

import numpy as np      # For linspace to make sweep, and to make and save arrays
import pandas as pd     # For making dataframe to save to disk
import os  # To get directory capabilities
pref_dir = '/home/pi/IndividualStudyActivity'
if os.getcwd() == pref_dir:
    print("In expected directory.")
else:
    print("Current working directory is different from preferred directory.")
    print("Changing directory to ", pref_dir)
    os.chdir(pref_dir)
datadir = os.path.join(os.getcwd(), "data")
# os.mkdir(datadir)

## New for 20/03

