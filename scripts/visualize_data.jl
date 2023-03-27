cd("/home/dennishb/Nextcloud/Uni/Semester/8. Sem/Independent Study Activity")
datadir = joinpath(pwd(), "data")

using GLMakie; Makie.inline!(true)
using CSV


##?
data1 = CSV.read("data/2023-03-03_330Ohm_redLED.csv", NamedTuple)
data2 = CSV.read("data/2023-03-03_660Ohm_redLED.csv", NamedTuple)
data3 = CSV.read("data/2023-03-03_10Ohm.csv", NamedTuple)
data4 = CSV.read("data/2023-03-03_OpenCircuit.csv", NamedTuple)
data5 = CSV.read("data/2023-03-03_1MOhm.csv", NamedTuple)
data6 = CSV.read("data/2023-03-03_165Ohm.csv", NamedTuple)
data7 = CSV.read("data/2023-03-03_330Ohm.csv", NamedTuple)
data8 = CSV.read("data/2023-03-03_66Ohm.csv", NamedTuple)
data9 = CSV.read("data/2023-03-03_7500Ohm.csv", NamedTuple)
data10 = CSV.read("data/2023-03-03_75kOhm.csv", NamedTuple)


with_theme(fontsize=20, linewidth=4) do
    fig, ax, plt = lines(data1.set_values, identity, label="x=y", color=:black)
    lines!(data3.set_values, data3.measured_values, label="Measured values 10 Ω")
    lines!(data6.set_values, data6.measured_values, label="Measured values 165 Ω")
    lines!(data7.set_values, data7.measured_values, label="Measured values 330 Ω")
    lines!(data8.set_values, data8.measured_values, label="Measured values 660 Ω")
    lines!(data9.set_values, data9.measured_values, label="Measured values 7.5 kΩ")
    lines!(data10.set_values, data10.measured_values, label="Measured values 75 kΩ")
    lines!(data5.set_values, data5.measured_values, label="Measured values 1 MΩ")
    lines!(data4.set_values, data4.measured_values, label="Measured values ∞ Ω (OC)")
    lines!(data1.set_values, data1.measured_values, label="Measured values 330 Ω + LED")
    lines!(data2.set_values, data2.measured_values, label="Measured values 660 Ω + LED")
    
    ax.xlabel = "Set values [V]"
    ax.ylabel = "Voltage [V]"
    axislegend(position=(0.05, 0.95))
    # save(joinpath(datadir, "saturation_investigation_1.png"), fig);
    fig|>display
    nothing
end

##! Estimating internal resistance. Conclusion: It is load dependent somehow.
let all_data = [(data3, 10), (data5, 10*10^6), (data6, 165), (data7, 330), (data8, 660), (data9, 7.5e3), (data10, 75e3)]
    sort!(all_data, by=last)
    set_valuess = [data[1].set_values for data in all_data]
    if all(vcat([set_vals.-set_valuess[1] for set_vals in set_valuess]...) .== 0)
        set_values = set_valuess[1]
    else
        @warn "Set values not identical"
    end
    
    R_int(R_ext, V_set, V_meas) = R_ext*(V_set/V_meas-1)
    R_ints_estimates = map(all_data) do (data, R_ext)
        V_set = data.set_values
        V_meas = data.measured_values
        R_int.(R_ext, V_set, V_meas)
    end
    fig = Figure()
    ax = Axis(fig[1, 1], xlabel="Set voltage [V]", ylabel="R_int_est")
    # ax.yscale = log10
    for R_ints in R_ints_estimates
        lines!(ax, set_values, R_ints, label="R_ext = $(-R_ints[1])")
    end
    xlims!(0, 4)
    ylims!(0, 2000)
    axislegend()
    display(fig)
    
    
    
    # R_int.(R_ext, data.set_values, data.measured_values)
end

##! Current
let all_data = [(data3, 10), (data5, 10*10^6), (data6, 165), (data7, 330), (data8, 660), (data9, 7.5e3), (data10, 75e3)]
    sort!(all_data, by=last)
    set_valuess = [data[1].set_values for data in all_data]
    if all(vcat([set_vals.-set_valuess[1] for set_vals in set_valuess]...) .== 0)
        set_values = set_valuess[1]
    else
        @warn "Set values not identical"
    end
    
    I(R_ext, V_meas_ext) = V_meas_ext/R_ext
    
    I_estimatess = map(all_data) do (data, R_ext)
        V_meas_ext = data.measured_values
        I.(R_ext, V_meas_ext)
    end
    fig = Figure()
    ax = Axis(fig[1, 1], xlabel="Set voltage [V]", ylabel="Estimated current [mA]")#, yscale=log10)
    for (R_ext, I_estimates) in zip(getindex.(all_data, 2), I_estimatess)
        lines!(ax, set_values, I_estimates .* 1e3, label="R_ext = $R_ext")
    end
    axislegend()
    DataInspector()
    display(fig)
    # R_int.(R_ext, data.set_values, data.measured_values)
end

##! Oscilloscope data
# An actual oscilloscope showed 7 volts max, 104 kHz and 13.3 V Peak-Valley.
osc_data_raw = [2072, 1719, 1517, 1565, 1851, 2253, 2590, 2737, 2659, 2383, 2009, 1671, 1506, 1595, 1910, 2313, 2626, 2739, 2625, 2326, 1949, 1629, 1503, 1633, 1974, 2374, 2658, 2735, 2589, 2267, 1890, 1594, 1506, 1678, 2039, 2432, 2686, 2727, 2547, 2207, 1834, 1563, 1517, 1727, 2106, 2487, 2709, 2714, 2502, 2148, 1781, 1540, 1535, 1781, 2172, 2536, 2726, 2693, 2452, 2086, 1730, 1520, 1558, 1836, 2236, 2579, 2735, 2666, 2397, 2023, 1683, 1508, 1588, 1896, 2299, 2618, 2739, 2635, 2341, 1963, 1640, 1502, 1624, 1958, 2360, 2652, 2737, 2599, 2283, 1905, 1603, 1505, 1666, 2024, 2419, 2681, 2731, 2559, 2224, 1848, 1571, 1514, 1713, 2088, 2472, 2703, 2717, 2513, 2163, 1794, 1545, 1529, 1764, 2152, 2521, 2720, 2698, 2465, 2102, 1743, 1525, 1550, 1819, 2217, 2566, 2732, 2674, 2412, 2041, 1695, 1511, 1578, 1878, 2280, 2606, 2738, 2645, 2358, 1982, 1652, 1504, 1614, 1940, 2343, 2643, 2739, 2611, 2301, 1923, 1614, 1503, 1653, 2003, 2401, 2672, 2733, 2570, 2240, 1865, 1580, 1510, 1698, 2069, 2457, 2697, 2721, 2527, 2180, 1809, 1552, 1523, 1749, 2135, 2508, 2716, 2705, 2480, 2120, 1759, 1531, 1545, 1805, 2202, 2556, 2731, 2683, 2428, 2059, 1709, 1514, 1570, 1862, 2264, 2597, 2737, 2653, 2372, 1997, 1663, 1504, 1602, 1923, 2326, 2633, 2738, 2619, 2316, 1937, 1623, 1502, 1642, 1987, 2386, 2664, 2735, 2582, 2257, 1880, 1588, 1507, 1686, 2052, 2443, 2691, 2726, 2540, 2198, 1825, 1560, 1521, 1737, 2119, 2497, 2713, 2710, 2493, 2136, 1771, 1534, 1537, 1789, 2183, 2543, 2727, 2688, 2441, 2075, 1721, 1517, 1562, 1847, 2246, 2586, 2736, 2661, 2388, 2014, 1675, 1507, 1594, 1908, 2310, 2624, 2739, 2629, 2332, 1955, 1634, 1503, 1632, 1971, 2371, 2658, 2738, 2593, 2273, 1895, 1598, 1506, 1674, 2035, 2428, 2685, 2729, 2551, 2213, 1838, 1566, 1515, 1722, 2101, 2482, 2708, 2715, 2505, 2152, 1785, 1541, 1532, 1775, 2166, 2531, 2724, 2694, 2456, 2092, 1735, 1522, 1556, 1832, 2231, 2576, 2735, 2670, 2403, 2030, 1689, 1510, 1586, 1891, 2294, 2615, 2739, 2639, 2347, 1969, 1643, 1503, 1619, 1951, 2353, 2648, 2737, 2601, 2288, 1909, 1604, 1503, 1660, 2016, 2411, 2678, 2730, 2561, 2228, 1853, 1572, 1511, 1708, 2082, 2467, 2700, 2718, 2517, 2168, 1800, 1547, 1527, 1760, 2148, 2518, 2720, 2700, 2470, 2108, 1748, 1526, 1549, 1816, 2213, 2563, 2731, 2676, 2417, 2046, 1699, 1512, 1577, 1875, 2277, 2605, 2738, 2647, 2362, 1985, 1655, 1504, 1610, 1937, 2339, 2640, 2739, 2612, 2303, 1925, 1615, 1503, 1651, 2001, 2399, 2671, 2734, 2573, 2245, 1867, 1582, 1511, 1699, 2069, 2457, 2699, 2723, 2529, 2183, 1811, 1553, 1524, 1750, 2136, 2508, 2717, 2705, 2480, 2119, 1758, 1530, 1545, 1805, 2201, 2556, 2730, 2680, 2427, 2057, 1707, 1514, 1571, 1863, 2266, 2597, 2737, 2652, 2371, 1995, 1663, 1504, 1604, 1927, 2330, 2636, 2740, 2619, 2314, 1936, 1623, 1503, 1644, 1990, 2388, 2667, 2734, 2579, 2253, 1876, 1586, 1507, 1689, 2055, 2444, 2692, 2724, 2535, 2192, 1820, 1556, 1520, 1739, 2122, 2498, 2713, 2708, 2489, 2131, 1767, 1534, 1539, 1793, 2188, 2546, 2728, 2686, 2437, 2069, 1718, 1518, 1567, 1853, 2254, 2591, 2738, 2659, 2384, 2009, 1672, 1507, 1598, 1914, 2317, 2628, 2740, 2626, 2325, 1948, 1630, 1502, 1634, 1976, 2376, 2660, 2737, 2589, 2267, 1889, 1594, 1506, 1678, 2041, 2433, 2687, 2728, 2547, 2208, 1834, 1564, 1518, 1728, 2108, 2488, 2711, 2715, 2503, 2148, 1782, 1541, 1535, 1781, 2172, 2536, 2727, 2694, 2453, 2087, 1731, 1521, 1558, 1836, 2236, 2580, 2736, 2667, 2399, 2025, 1685, 1509, 1589, 1895, 2299, 2618, 2740, 2636, 2344, 1966, 1642, 1503, 1624, 1957, 2358, 2651, 2738, 2600, 2285, 1907, 1604, 1505, 1665, 2023, 2418, 2682, 2732, 2561, 2226, 1851, 1573, 1514, 1714, 2088, 2472, 2704, 2718, 2514, 2164, 1795, 1546, 1529, 1764, 2154, 2522, 2722, 2699, 2466, 2103, 1744, 1526, 1552, 1822, 2221, 2569, 2733, 2675, 2412, 2041, 1695, 1512, 1580, 1882, 2284, 2610, 2741, 2645, 2357, 1981, 1652, 1504, 1615, 1944, 2346, 2645, 2739, 2609, 2299, 1920, 1612, 1503, 1655, 2006, 2403, 2674, 2732, 2570, 2239, 1862, 1578, 1510, 1700, 2071, 2459, 2699, 2722, 2526, 2179, 1808, 1551, 1524, 1752, 2138, 2511, 2718, 2705, 2479, 2117, 1756, 1530, 1545, 1807, 2205, 2559, 2732, 2682, 2428, 2057, 1708, 1515, 1572, 1866, 2269, 2600, 2739, 2652, 2371, 1995, 1661, 1505, 1605, 1928, 2331, 2636, 2740, 2618, 2313, 1934, 1622, 1503, 1645, 1991, 2389, 2667, 2734, 2580, 2254, 1876, 1587, 1509, 1690, 2058, 2448, 2695, 2726, 2537, 2194, 1822, 1558, 1521, 1741, 2124, 2500, 2714, 2709, 2490, 2131, 1767, 1534, 1540, 1794, 2189, 2547, 2729, 2687, 2438, 2070, 1718, 1517, 1565, 1852, 2252, 2590, 2737, 2659, 2384, 2009, 1671, 1506, 1597, 1912, 2315, 2627, 2739, 2626, 2327, 1949, 1631, 1503, 1634, 1976, 2375, 2660, 2737, 2591, 2270, 1892, 1596, 1506, 1677, 2039, 2432, 2687, 2727, 2548, 2208, 1834, 1563, 1516, 1725, 2105, 2485, 2708, 2712, 2501, 2146, 1780, 1539, 1534, 1779, 2171, 2534, 2724, 2692, 2452, 2085, 1729, 1520, 1557, 1836, 2236, 2579, 2736, 2668, 2399, 2026, 1684, 1509, 1588, 1898, 2299, 2619, 2740, 2635, 2341, 1963, 1640, 1502, 1624, 1959, 2361, 2652, 2737, 2598, 2282, 1904, 1602, 1504, 1666, 2023, 2418, 2680, 2729, 2557, 2222, 1847, 1570, 1513, 1713, 2089, 2472, 2704, 2716, 2512, 2160, 1792, 1544, 1529, 1767, 2157, 2524, 2723, 2698, 2464, 2101, 1742, 1525, 1553, 1824, 2222, 2569, 2733, 2673, 2411, 2038, 1693, 1510, 1581, 1882, 2285, 2609, 2739, 2643, 2354, 1978, 1650, 1504, 1615, 1945, 2346, 2644, 2739, 2607, 2296, 1918, 1611, 1503, 1656, 2009, 2405, 2675, 2734, 2569, 2239, 1862, 1580, 1512, 1703, 2074, 2462, 2700, 2722, 2525, 2178, 1807, 1551, 1525, 1754, 2141, 2512, 2718, 2704, 2477, 2116, 1755, 1529, 1545, 1809, 2205, 2558, 2732, 2681, 2425, 2055, 1706, 1514, 1572, 1867, 2268, 2600, 2738, 2652, 2370, 1994, 1662, 1505, 1605, 1928, 2330, 2636, 2740, 2620, 2316, 1937, 1623, 1504, 1645, 1990, 2389, 2667, 2735, 2580, 2255, 1878, 1587, 1507, 1687, 2054, 2444, 2692, 2724, 2537, 2194, 1822, 1558, 1519, 1736, 2119, 2495, 2712, 2709, 2491, 2134, 1770, 1534, 1537, 1790, 2184, 2544, 2728, 2688, 2442, 2075, 1722, 1519, 1564, 1848, 2249, 2588, 2737, 2661, 2389, 2014, 1675, 1507, 1594, 1907, 2310, 2624, 2739, 2629, 2332, 1954, 1633, 1503, 1630, 1968, 2369, 2656, 2736, 2594, 2275, 1897, 1598, 1505, 1671, 2032, 2426, 2684, 2728, 2553, 2215]
osc_data = [(dat-2^11)/2^11*12 for dat in osc_data_raw]
begin
    lines(osc_data[begin:end÷100*20] .* 12/4.095, axis=(ylabel="Voltage", xlabel="Sample #"))
    current_figure() |> display
end
using UnicodePlots
names(UnicodePlots)
maximum(osc_data[begin:end÷100*20] .* 12/4.095)


##? First plotting
data1 = CSV.read(joinpath(datadir, "first_data.csv"), NamedTuple)
data2 = CSV.read(joinpath(datadir, "first_data_AD623.csv"), NamedTuple)
data3 = CSV.read(joinpath(datadir, "first_data_AD623_G=9.csv"), NamedTuple)

with_theme(fontsize=20, linewidth=4) do
    fig, ax, plt = lines(data1.set_values, identity, label="x=y", color=:black)
    lines!(data1.set_values, data1.measured_values, label="Measured values")
    lines!(data2.set_values, data2.measured_values, label="Measured values, AD623")
    lines!(data3.set_values, data3.measured_values, label="Measured values, AD623, G=9")
    lines!(data3.set_values.*9, data3.measured_values, label="Measured values, AD623, G=9, adjusted")
    
    ax.xlabel = "Set values [V]"
    ax.ylabel = "Voltage [V]"
    axislegend(position=(0.05, 0.95))
    # save(joinpath(datadir, "first_data_visualized.png"), fig);
    fig|>display
    nothing
end
