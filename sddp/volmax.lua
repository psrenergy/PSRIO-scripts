function save_volmax()
    if hydro == nil then hydro = Hydro(); end
    hydro.vmax:save("volmax", {remove_zeros = true});
end