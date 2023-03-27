ENV["JULIA_CONDAPKG_BACKEND"] != "Null"  &&  @warn "Non-default python installation will be used"
using PythonCall
DAQC = pyimport("piplates.DAQCplate")
import piplates.DAQC2plate as DAQC2
#comment