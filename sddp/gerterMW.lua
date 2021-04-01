
function gerterMW()
    if thermal == nil then thermal = Thermal(); end
    local gerter = thermal:load("gerter");
    gerter:convert("MW"):save("gerterMW");
end