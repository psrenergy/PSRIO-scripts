battery = Battery();
hydro = Hydro();
renewable = Renewable();
thermal = Thermal();
project = ExpansionProject();
generic = Generic();
study = Study();
emission = GasEmission();

pa = concatenate(
    hydro:load("outhpa"):aggregate_agents(BY_SUM(), "Total hydro"),
    thermal:load("outtpa"):aggregate_agents(BY_SUM(), "Total thermal"),
    renewable:load("outrpa"):select_agents(renewable.tech_type:eq(0)):aggregate_agents(BY_SUM(), "Total other renewables"),
    battery:load("outbpa"):aggregate_agents(BY_SUM(), "Total battery"),
    renewable:load("outrpa"):select_agents(renewable.tech_type:eq(1)):aggregate_agents(BY_SUM(), "Total wind"),
    renewable:load("outrpa"):select_agents(renewable.tech_type:eq(2)):aggregate_agents(BY_SUM(), "Total solar"),
    renewable:load("outrpa"):select_agents(renewable.tech_type:eq(3)):aggregate_agents(BY_SUM(), "Total biomass"),
    renewable:load("outrpa"):select_agents(renewable.tech_type:eq(4)):aggregate_agents(BY_SUM(), "Total small hydro"),
    renewable:load("outrpa"):select_agents(renewable.tech_type:eq(5)):aggregate_agents(BY_SUM(), "Total CSP")
);

pa:save("opt1_dashboard_firmcapacity") -- Potência firme
pa:aggregate_stages(BY_MAX(), Profile.PER_YEAR):save("opt1_dashboard_yearly_firmcap") -- Potência firme anual

ea = concatenate(
    hydro:load("outhea"):aggregate_agents(BY_SUM(), "Total hydro"),
    thermal:load("outtea"):aggregate_agents(BY_SUM(), "Total thermal"),
    renewable:load("outrea"):select_agents(renewable.tech_type:eq(0)):aggregate_agents(BY_SUM(), "Total other renewables"),
    battery:load("outbea"):aggregate_agents(BY_SUM(), "Total battery"),
    renewable:load("outrea"):select_agents(renewable.tech_type:eq(1)):aggregate_agents(BY_SUM(), "Total wind"),
    renewable:load("outrea"):select_agents(renewable.tech_type:eq(2)):aggregate_agents(BY_SUM(), "Total solar"),
    renewable:load("outrea"):select_agents(renewable.tech_type:eq(3)):aggregate_agents(BY_SUM(), "Total biomass"),
    renewable:load("outrea"):select_agents(renewable.tech_type:eq(4)):aggregate_agents(BY_SUM(), "Total small hydro"),
    renewable:load("outrea"):select_agents(renewable.tech_type:eq(5)):aggregate_agents(BY_SUM(), "Total CSP")
);
ea:save("opt1_dashboard_firmenergy") -- Energia Firme
ea:aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR):save("opt1_dashboard_yearly_firmenergy") -- Energia firme anual

ca = concatenate(
    hydro:load("pnomhd"):aggregate_agents(BY_SUM(), "Total hydro"),
    thermal:load("pnomtr"):aggregate_agents(BY_SUM(), "Total thermal"),
    renewable:load("pnomnd"):select_agents(renewable.tech_type:eq(0)):aggregate_agents(BY_SUM(), "Total renewable"),
    battery:load("pnombat"):aggregate_agents(BY_SUM(), "Total battery"),
    renewable:load("pnomnd"):select_agents(renewable.tech_type:eq(1)):aggregate_agents(BY_SUM(), "Total wind"),
    renewable:load("pnomnd"):select_agents(renewable.tech_type:eq(2)):aggregate_agents(BY_SUM(), "Total solar"),
    renewable:load("pnomnd"):select_agents(renewable.tech_type:eq(3)):aggregate_agents(BY_SUM(), "Total biomass"),
    renewable:load("pnomnd"):select_agents(renewable.tech_type:eq(4)):aggregate_agents(BY_SUM(), "Total small hydro"),
    renewable:load("pnomnd"):select_agents(renewable.tech_type:eq(5)):aggregate_agents(BY_SUM(), "Total CSP")
);
ca:save("opt1_dashboard_installedcapacity") -- Capacidade instalada a cada mês
ca:aggregate_stages(BY_MAX(), Profile.PER_YEAR):save("opt1_dashboard_yearly_instCap") -- Capacidade instalada a cada ano

outidec = generic:load("outidec")
addedcapacity = concatenate(
    outidec:select_agents(Collection.HYDRO):aggregate_agents(BY_SUM(), "Total hydro"),
    outidec:select_agents(Collection.THERMAL):aggregate_agents(BY_SUM(), "Total thermal"),
    outidec:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(0)):aggregate_agents(BY_SUM(), "Total other renewables"),
    outidec:select_agents(Collection.BATTERY):aggregate_agents(BY_SUM(), "Total battery"),
    outidec:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(1)):aggregate_agents(BY_SUM(), "Total wind"),
    outidec:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(2)):aggregate_agents(BY_SUM(), "Total solar"),
    outidec:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(3)):aggregate_agents(BY_SUM(), "Total biomass"),
    outidec:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(4)):aggregate_agents(BY_SUM(), "Total small hydro"),
    outidec:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(5)):aggregate_agents(BY_SUM(), "Total CSP")
);
addedcapacity:aggregate_stages(BY_LAST_VALUE(), Profile.PER_YEAR):save("opt1_dashboard_addedcapacity") -- Capacidade adicionada pelo Optgen

addedtransmission = concatenate(
    outidec:select_agents(Collection.CIRCUIT):aggregate_agents(BY_SUM(), "Total circuit"):remove_zeros(),
    outidec:select_agents(Collection.DCLINK):aggregate_agents(BY_SUM(), "Total dclink"):remove_zeros(),
    outidec:select_agents(Collection.INTERCONNECTION):aggregate_agents(BY_SUM(), "Total interconnection"):remove_zeros()
);
addedtransmission:aggregate_stages(BY_LAST_VALUE(), Profile.PER_YEAR):save("opt1_dashboard_transmission") -- Capacidade adicionada pelo Optgen

outdisbu = generic:load("outdisbu")
interest = (1 + study.discount_rate) ^ ((study.stage_in_year - 1) / study:stages_per_year())
add_cost = concatenate( 
    outdisbu:select_agents(Collection.HYDRO):aggregate_agents(BY_SUM(), "Total hydro"),
    outdisbu:select_agents(Collection.THERMAL):aggregate_agents(BY_SUM(), "Total thermal"),
    outdisbu:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(0)):aggregate_agents(BY_SUM(), "Total other renewables"),
    outdisbu:select_agents(Collection.BATTERY):aggregate_agents(BY_SUM(), "Total battery"),
    outdisbu:select_agents(Collection.CIRCUIT):aggregate_agents(BY_SUM(), "Total circuit"),
    outdisbu:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(1)):aggregate_agents(BY_SUM(), "Total wind"),
    outdisbu:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(2)):aggregate_agents(BY_SUM(), "Total solar"),
    outdisbu:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(3)):aggregate_agents(BY_SUM(), "Total biomass"),
    outdisbu:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(4)):aggregate_agents(BY_SUM(), "Total small hydro"),
    outdisbu:select_agents(Collection.RENEWABLE):select_agents(renewable.tech_type:eq(5)):aggregate_agents(BY_SUM(), "Total CSP")
);
horizon_cost = add_cost:select_stages()/interest -- Elimina os meses além do horizonte da simulação
horizon_cost:aggregate_stages(BY_SUM(), Profile.PER_YEAR):convert("M$"):save("opt1_dashboard_yearly_invCost") -- Custo do plano do Optgen

function levcost(collection, generation, opex)
	capex = (outdisbu:select_agents(collection):select_stages()/interest):aggregate_stages(BY_SUM(), Profile.PER_YEAR)
	ger = generation:aggregate_blocks(BY_SUM()):aggregate_stages(BY_SUM(), Profile.PER_YEAR)
	return ifelse(ger:eq(0), -1, capex / ger + opex):select_agents(outdisbu:agents()):convert("$/MWh")
end

local thermal_ger = thermal:load("gerter")

levcost(Collection.RENEWABLE, renewable:load("gergnd"), renewable.om_cost:select_stages():aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR)):save("levcostrenw")
levcost(Collection.THERMAL  , thermal_ger             , thermal:load("cinte1"):aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR)):save("levcosttherm")
levcost(Collection.HYDRO    , hydro:load("gerhid")    , hydro.om_cost:select_stages():aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR)):save("levcosthydro")

objcop = generic:load("objcop");
outdbtot = generic:load("outdbtot");
outdfact = generic:load("outdfact");

if study:is_hourly() then
    costs = objcop:remove_agents({1}):aggregate_blocks(BY_SUM()); -- remove future cost
else
    costs = objcop:remove_agents({1}):aggregate_blocks(BY_SUM()); -- remove total cost
    costs = costs:remove_agents({-1}); -- remove future cost
end

study_outdbtot = outdbtot:aggregate_agents(BY_SUM(), "Inv. Cost."); -- Custos totais de investimento
study_outdfact = outdfact:aggregate_agents(BY_SUM(), "PSRStudy"); -- Taxa de desconto

ope_cost = (costs:aggregate_agents(BY_SUM(), "Ope. Cost"):aggregate_scenarios(BY_AVERAGE()) * study_outdfact):aggregate_stages(BY_SUM());
inv_cost = (study_outdbtot * study_outdfact):aggregate_stages(BY_SUM())

if not ope_cost:loaded() then
	ope_cost = generic:create("Ope. Cost", "M$", {0});
end

if not inv_cost:loaded() then
	inv_cost = generic:create("Inv. Cost.", "M$", {0});
end

total_cost = concatenate(ope_cost, inv_cost); -- Concatena os valores totais da simulação de operação e investimento
total_cost:convert("M$"):save("opt1_dashboard_totalcosts"); -- Pizza dos custos totais

local vertimento = renewable:load("vergnd");

total_vert = concatenate(
	   vertimento:select_agents(renewable.tech_type:eq(0)):aggregate_agents(BY_SUM(), "Total other renewables"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()),
	   vertimento:select_agents(renewable.tech_type:eq(1)):aggregate_agents(BY_SUM(), "Total wind"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()),
	   vertimento:select_agents(renewable.tech_type:eq(2)):aggregate_agents(BY_SUM(), "Total solar"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()),
	   vertimento:select_agents(renewable.tech_type:eq(3)):aggregate_agents(BY_SUM(), "Total biomass"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()),
	   vertimento:select_agents(renewable.tech_type:eq(4)):aggregate_agents(BY_SUM(), "Total small hydro"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE()),
	   vertimento:select_agents(renewable.tech_type:eq(5)):aggregate_agents(BY_SUM(), "Total CSP"):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE())
);
total_vert:save("sddp_dashboard_verxxd");

local emiValues = generic:load("teremi");
local emiNames  = emission:labels();
local emiValuesPerStage = emiValues:aggregate_blocks(BY_SUM())

local gerterPerStage = thermal_ger:aggregate_blocks(BY_SUM())

local emiAux = {}

for _,iName in ipairs(emiNames) do
	table.insert(emiAux, emiValuesPerStage:select_agents_by_regex(iName.."(.*)"):aggregate_agents(BY_SUM(),iName))
end

emiStage_per_emission = concatenate(emiAux):select_agents(Collection.GAS_EMISSION)
emiStage_per_emission:aggregate_scenarios(BY_AVERAGE()):save("sddp_dashboard_co2")

emiStage_per_emission:save("emiStage_per_emission", {csv=true})
gerterPerStage:save("gerterPerStage", {csv=true})

em2ter = study:get_relationship_map(Collection.GAS_EMISSION,Collection.THERMAL)

local intAux = {}

for _,iName in ipairs(emiNames) do
    terLista = em2ter[iName]
    table.insert(intAux, safe_divide(emiStage_per_emission:select_agent(iName),gerterPerStage:select_agents(terLista):aggregate_agents(BY_SUM(),iName):convert("MWh")))
end

emiIntensityPerStageAvg = concatenate(intAux):aggregate_scenarios(BY_AVERAGE()):force_unit("uni/MWh"):save("sddp_dashboard_co2int")