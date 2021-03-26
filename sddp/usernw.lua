if renewable == nil then renewable = Renewable(); end

-- USERNW - Renewable dispatch factor
gergnd = renewable:load("gergnd");
(gergnd:convert("MW") / renewable.capacity):convert("%"):save("usernw");