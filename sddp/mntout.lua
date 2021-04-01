function save_mntout()
    if hydro == nil then hydro = Hydro(); end
    hydro.min_total_outflow_modification:save("mntout")
end