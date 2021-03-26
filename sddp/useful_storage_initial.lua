if hydro == nil then hydro = Hydro(); end

local suffixes = {"", "__day", "__week", "__hour", "__trueup"}
for _, suffix in ipairs(suffixes) do
    local volini = hydro:load("volini" .. suffix)
    -- USEFUL_STORAGE_INITIAL
    (volini - hydro.vmin):save("useful_storage_initial" .. suffix);
end