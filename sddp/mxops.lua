function save_mxops()
    if hydro == nil then hydro = Hydro(); end
    hydro.vmax_chronological:save("mxops");
end