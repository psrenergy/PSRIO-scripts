function save_pnomhd()
    if hydro == nil then hydro = Hydro(); end
    hydro.capacity:save("pnomhd")
end