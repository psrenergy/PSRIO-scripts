if hydro == nil then hydro = Hydro(); end

local suffixes = {"", "__day", "__week", "__hour", "__trueup"}
for _, suffix in ipairs(suffixes) do
    local volfin = hydro:load("volfin" .. suffix)
    -- USEFUL_STORAGE_FINAL
    (volfin - hydro.vmin):save("useful_storage_final" .. suffix);
end