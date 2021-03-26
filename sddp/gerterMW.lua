if thermal == nil then thermal = Thermal(); end

-- GERTERMW
gerter = thermal:load("gerter");
gerter:convert("MW"):save("gerterMW");