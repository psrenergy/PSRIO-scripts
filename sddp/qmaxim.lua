function save_qmaxim()
    if hydro == nil then hydro = Hydro(); end
    hydro.qmax:save("qmaxim");
end