if interconnection == nil then interconnection = Interconnection(); end

-- REMINT - Interconnection income
interc = interconnection:load("interc"):convert("MW");
cmgint = interconnection:load("cmgint");
(interc * cmgint):abs():save("remint");