local bus_collection = Bus();
local cmgbus = bus_collection:load("cmgbus");

local dclink_collection = DClink()
local dclink = dclink_collection:load("dclink");

local study = Study();
local discount_rate = study.discount_rate:to_list()[1];

local ingreso_tarifario = (cmgbus:select_agents({"AND"}) - cmgbus:select_agents({"NOA"})) * dclink:select_agents({"Andes-Cobos"});
ingreso_tarifario
    :abs()
    :aggregate_blocks(BY_SUM())
    :aggregate_scenarios(BY_AVERAGE())
    :aggregate_stages(BY_SUM(), Profile.PER_YEAR)
    :aggregate_stages(BY_NPV(discount_rate))
    :convert("M$")
    :save("ingreso_tarifario", {csv=true});