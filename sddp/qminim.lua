function save_qminim()
    if hydro == nil then hydro = Hydro(); end
    hydro.qmin:save("qminim");
end