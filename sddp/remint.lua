function save_remint()
    if interconnection == nil then interconnection = Interconnection(); end
    local interc = interconnection:load("interc"):convert("MW");
    local cmgint = interconnection:load("cmgint");
    (interc * cmgint):abs():save("remint");
end