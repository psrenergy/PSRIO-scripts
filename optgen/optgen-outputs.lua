battery = Battery();
hydro = Hydro();
renewable = Renewable();
thermal = Thermal();
project = ExpansionProject();
generic = Generic();
study = Study();

pa = concatenate(
    hydro:load("outhpa"):aggregate_agents(BY_SUM(), "Total hydro"),
    thermal:load("outtpa"):aggregate_agents(BY_SUM(), "Total thermal"),
    renewable:load("outrpa"):aggregate_agents(BY_SUM(), "Total renewable"),
    battery:load("outbpa"):aggregate_agents(BY_SUM(), "Total battery")
);

pa:save("opt1_firmcapacity") -- Potência firme
pa:aggregate_stages(BY_MAX(), Profile.PER_YEAR):save("opt1_yearly_firmcap") -- Potência firme anual

ea = concatenate(
    hydro:load("outhea"):aggregate_agents(BY_SUM(), "Total hydro"),
    thermal:load("outtea"):aggregate_agents(BY_SUM(), "Total thermal"),
    renewable:load("outrea"):aggregate_agents(BY_SUM(), "Total renewable")
);
ea:save("opt1_firmenergy") -- Energia Firme
ea:aggregate_stages(BY_MAX(), Profile.PER_YEAR):save("opt1_yearly_firmenergy") -- Energia firme anual

ca = concatenate(
    hydro:load("pnomhd"):aggregate_agents(BY_SUM(), "Total hydro"),
    thermal:load("pnomtr"):aggregate_agents(BY_SUM(), "Total thermal"),
    renewable:load("pnomnd"):aggregate_agents(BY_SUM(), "Total renewable")
);
ca:save("opt1_installedcapacity") -- Capacidade instalada a cada mês
ca:aggregate_stages(BY_MAX(), Profile.PER_YEAR):save("opt1_yearly_instCap") -- Capacidade instalada a cada ano

outidec = project:load("outidec")
addedcapacity = concatenate(
    outidec:select_agents(Collection.HYDRO):aggregate_agents(BY_SUM(), "Total hydro"),
    outidec:select_agents(Collection.THERMAL):aggregate_agents(BY_SUM(), "Total thermal"),
    outidec:select_agents(Collection.RENEWABLE):aggregate_agents(BY_SUM(), "Total renewable"),
    outidec:select_agents(Collection.BATTERY):aggregate_agents(BY_SUM(), "Total battery")
);
addedcapacity:aggregate_stages(BY_MAX(), Profile.PER_YEAR):save("opt1_addedcapacity") -- Capacidade adicionada pelo Optgen

outdisbu = project:load("outdisbu")
interest = (1 + study.discount_rate) ^ ((study.stage_in_year - 1) / study:stages_per_year())
add_cost = concatenate( 
    outdisbu:select_agents(Collection.HYDRO):aggregate_agents(BY_SUM(), "Total hydro"),
    outdisbu:select_agents(Collection.THERMAL):aggregate_agents(BY_SUM(), "Total thermal"),
    outdisbu:select_agents(Collection.RENEWABLE):aggregate_agents(BY_SUM(), "Total renewable"),
    outdisbu:select_agents(Collection.BATTERY):aggregate_agents(BY_SUM(), "Total battery"),
    outdisbu:select_agents(Collection.CIRCUIT):aggregate_agents(BY_SUM(), "Total circuit")
);
horizon_cost = add_cost:select_stages()/interest -- Elimina os meses além do horizonte da simulação
horizon_cost:aggregate_stages(BY_SUM(), Profile.PER_YEAR):convert("M$"):save("opt1_yearly_invCost") -- Custo do plano do Optgen

function levcost(collection, generation, opex)
	capex = (outdisbu:select_agents(collection):select_stages()/interest):aggregate_stages(BY_SUM(), Profile.PER_YEAR)
	ger = generation:aggregate_blocks(BY_SUM()):aggregate_stages(BY_SUM(), Profile.PER_YEAR)
	return ifelse(ger:eq(0), -1, capex / ger + opex):select_agents(outdisbu:agents()):convert("$/MWh")
end

levcost(Collection.RENEWABLE, renewable:load("gergnd"), renewable.om_cost:select_stages():aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR)):save("levcostrenw")
levcost(Collection.THERMAL  , thermal:load("gerter")  , thermal:load("cinte1"):aggregate_blocks(BY_AVERAGE()):aggregate_stages(BY_AVERAGE(), Profile.PER_YEAR)):save("levcosttherm")
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
total_cost = concatenate(
    (costs:aggregate_agents(BY_SUM(), "Ope. Cost"):aggregate_scenarios(BY_AVERAGE()) * study_outdfact):aggregate_stages(BY_SUM()),
    (study_outdbtot * study_outdfact):aggregate_stages(BY_SUM())
); -- Concatena os valores totais da simulação de operação e investimento

total_cost:convert("M$"):save("opt1_totalcosts"); -- Pizza dos custos totais