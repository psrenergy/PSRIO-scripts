function save_useful_storage_final(suffix)
    if hydro == nil then hydro = Hydro(); end
    local volfin = hydro:load("volfin" .. (suffix or ""));
    (volfin - hydro.vmin):save("useful_storage_final" .. (suffix or ""));
end