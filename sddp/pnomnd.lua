function save_pnomnd()
    if renewable == nil then renewable = Renewable(); end
    renewable.capacity:save("pnomnd");
end