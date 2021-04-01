function save_useful_storage_initial(suffix)
    if hydro == nil then hydro = Hydro(); end
    volini = hydro:load("volini" .. (suffix or ""));
    (volini - hydro.vmin):save("useful_storage_initial" .. (suffix or ""));
end