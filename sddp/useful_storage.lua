function save_useful_storage()
    if hydro == nil then hydro = Hydro(); end
    (hydro.vmax - hydro.vmin):save("useful_storage");
end