function save_mnsout()
    if hydro == nil then hydro = Hydro(); end
    hydro.min_spillage:save("mnsout");
end