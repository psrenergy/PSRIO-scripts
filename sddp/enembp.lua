function save_enembp()
    if hydro == nil then hydro = Hydro(); end
    local eneemb = hydro:load("eneemb");
    local eembmx = hydro:load("eembmx");
    (eneemb / eembmx):convert("%"):save("enembp", {remove_zeros = true});
end