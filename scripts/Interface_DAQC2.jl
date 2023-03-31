using OhMyREPL
using PyCall
using CSV
py"1+1"
##
DAQC2 = pyimport("piplates.DAQC2plate")
# DAQC = pyimport("piplates.DAQCplate")

@show DAQC2.DAQC2version
@show DAQC2.daqc2sPresent

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

DAQC2.VerifyADDR(0)  # Useful to check if adress is valid

##¤ Making continous measurements with ADC
"""
 T = Sample duration in seconds
fs = samples per second
"""
function ADC_sample_and_print(addr, bit; T=1, fs=10)
    Ts = 1/fs

    println("Making ADC measurements on channel ", bit)
    println("Sample rate: ", fs, " Hz")
    println("Duration: ", T, " s")
    t_initial = time()
    while true
        println(DAQC2.getADC(addr, bit))
        if time() - t_initial > T
            break
        end
        sleep(Ts)
    end
end
print_line(itr, width=7) = (foreach(print, rpad(string(m), width) for m in itr); println())
function ADC_sample_and_print_all(addr, width=7; T=1, fs=10)
    Ts = 1/fs

    println("Making ADC measurements on all channels")
    println("Sample rate: ", fs, " Hz")
    println("Duration: ", T, " s")
    t_initial = time()
    print_line(0:3, width)
    while true
        measurements = [DAQC2.getADC(addr, i) for i in 0:3]
        println()
        print_line(measurements, width)
        if time() - t_initial > T
            println()
            break
        end
        sleep(Ts)
    end
end
ADC_sample_and_print_all(0; T=100)
ADC_sample_and_print(0, 0; T=10)


##¤ Setting DAC
# DAQC2.setDAC(0, 0, 1); sleep(0.1); DAQC2.getADC(0, 0)|>println
begin
    width = 7
    print_line(("v_set", "v_mes", "diff"), width)
    for v_set in range(0, 4, length=50)
        v_set = round(v_set, digits=3)
        DAQC2.setDAC(0, 0, v_set)
        sleep(0.05)
        v_mes = DAQC2.getADC(0, 0)
        print_line((v_set, v_mes, round(v_mes-v_set, digits=3)), width)
    end
end

function set_and_meas()
    v_targets = range(0, 4, length=50)
    v_targets = [v_targets; 0]
    output = (v_set = Float32[], v_mes = Float32[])
    for v_target in v_targets
        DAQC2.setDAC(0, 0, v_target)
        v_set = round(DAQC2.getDAC(0, 0), digits=3)
        sleep(0.05)
        v_mes = DAQC2.getADC(0, 0)
        for i in eachindex(output)
            push!(output[1], v_set)
            push!(output[2], v_mes)
        end
    end
    return output
end

begin
    output = set_and_meas()
    CSV.write(joinpath(datadir, "buffer_follower_7_5k_Ohm_andDiode.csv"), output)
end