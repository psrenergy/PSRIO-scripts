function save_qriego()
    if hydro == nil then hydro = Hydro(); end
    hydro.irrigation:save("qriego", {remove_zeros = true});
end