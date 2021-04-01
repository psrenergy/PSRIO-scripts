function save_usernw()
    if renewable == nil then renewable = Renewable(); end
    local gergnd = renewable:load("gergnd");
    (gergnd:convert("MW") / renewable.capacity):convert("%"):save("usernw");
end