local bus = Bus();
local cmgbus = bus:load("cmgbus");

local generic = Generic();

local busChilca = cmgbus:select_agents({"CHILCA220   "});
local busSantaRosa = cmgbus:select_agents({"SANTAROSA220"});
local busSocayaba = cmgbus:select_agents({"SOCABAYA220 "});
local busTrujillo = cmgbus:select_agents({"TRUJILLO220 "});

local Q_Chilca = generic:load("quantidade_ppa_chilca"):force_hourly();
local Q_SantaRosa = generic:load("quantidade_ppa_starosa"):force_hourly();
local Q_Socayaba = generic:load("quantidade_ppa_socabaya"):force_hourly();
local Q_Trujillo = generic:load("quantidade_ppa_trujillo"):force_hourly();

local R_PPAChilca = (-Q_Chilca * busChilca);
local R_PPASantaRosa = (-Q_SantaRosa * busSantaRosa);
local R_PPASocayaba = (-Q_Socayaba * busSocayaba);
local R_PPATrujillo = (-Q_Trujillo * busTrujillo);

local R_PPA_All_stg = (R_PPAChilca + R_PPASantaRosa + R_PPASocayaba + R_PPATrujillo):aggregate_blocks(BY_SUM()):aggregate_scenarios(BY_AVERAGE());

R_PPA_All_stg:save("OUT_R_PPA_All_stg", {csv=true});