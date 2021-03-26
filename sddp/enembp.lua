if hydro == nil then hydro = Hydro(); end

-- ENEMBP - Perc. of stored energy by reserv.
eneemb = hydro:load("eneemb");
eembmx = hydro:load("eembmx");
(eneemb / eembmx):convert("%"):save("enembp", {remove_zeros = true});