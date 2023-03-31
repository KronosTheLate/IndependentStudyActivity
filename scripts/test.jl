using PyCall
py"1+1"
##
DAQC = pyimport("piplates.DAQCplate")
DAQC2 = pyimport("piplates.DAQC2plate")

DAQC.DAQCversion, DAQC2.DAQC2version
DAQC.daqcsPresent, DAQC2.daqc2sPresent

pref_dir = joinpath(homedir(), "IndependentStudyActivity")
if pwd() == pref_dir
    print("In expected directory: `$pref_dir`")
else
    print("Current working directory is different from preferred directory.")
    print("Changing directory to ", pref_dir)
    cd(pref_dir)
end
datadir = joinpath(pref_dir, "data")
# os.mkdir(datadir)

DAQC.VerifyADDR(0)  # Useful to check if adress is valid
