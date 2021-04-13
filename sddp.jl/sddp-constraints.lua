local hydro = require("collection/hydro");

local qturbi__week = hydro:load("qturbi__week");
local qverti__week = hydro:load("qverti__week");

local maxTO_nodata = hydro.max_total_outflow_historical_scenarios_nodata;
local maxTO = hydro.max_total_outflow_historical_scenarios;
ifelse(maxTO_nodata:gt(0), 0, max(0, qturbi__week + qverti__week - maxTO)):convert("hm3"):save("constraint_max_total_outflow");

local minTO_nodata = hydro.min_total_outflow_historical_scenarios_nodata;
local minTO = hydro.min_total_outflow_historical_scenarios;
local minTODf = hydro.min_total_outflow_modification;
ifelse(minTO_nodata:gt(0), ifelse(minTODf:gt(0), max(0, -qturbi__week - qverti__week + minTODf) , 0), max(0, -qturbi__week - qverti__week + minTO)):convert("hm3"):save("constraint_min_total_outflow");

local maxSpill_nodata = hydro.max_spillage_historical_scenarios_nodata;
local maxSpill = hydro.max_spillage_historical_scenarios;
ifelse(maxSpill_nodata:gt(0), 0, max(0, qverti__week - maxSpill)):convert("hm3"):save("constraint_max_spillage");

local minSpill_nodata = hydro.min_spillage_historical_scenarios_nodata;
local minSpill = hydro.min_spillage_historical_scenarios;
ifelse(minSpill_nodata:gt(0), 0, max(0, -qverti__week + minSpill)):convert("hm3"):save("constraint_min_spillage");

local qmin = hydro.qmin;
max(0, -qturbi__week + qmin):convert("hm3"):save("constraint_min_turbining");

local volfin = hydro:load("volfin__week"):aggregate_blocks(BY_LAST_VALUE());
volfin:save("volfin_");

local maxVol_nodata = hydro.vmax_chronological_historical_scenarios_nodata;
local maxVol = hydro.vmax_chronological_historical_scenarios;
ifelse(maxSpill_nodata:gt(0), 0, max(0, volfin - maxVol)):save("constraint_max_volume");

local minVol_nodata = hydro.vmin_chronological_historical_scenarios_nodata;
local minVol = hydro.vmin_chronological_historical_scenarios;
ifelse(minSpill_nodata:gt(0), 0, max(0, -volfin + minVol)):save("constraint_min_volume");

local alertStorage_nodata = hydro.alert_storage_historical_scenarios_nodata;
local alertStorage = hydro.alert_storage_historical_scenarios;
ifelse(alertStorage_nodata:gt(0), 0, max(0, -volfin + alertStorage)):save("constraint_alert_storage");

local floodVol_nodata = hydro.flood_volume_historical_scenarios_nodata;
local floodVol = hydro.flood_volume_historical_scenarios;
ifelse(floodVol_nodata:gt(0), 0, max(0, -volfin + floodVol)):save("hydro_flood_volume");

local Target_nodata = hydro.target_storage_historical_scenarios_nodata;
local Target = hydro.target_storage_historical_scenarios;
local maxTarget = (1 + hydro.target_storage_tolerance) * Target;
local minTarget = (1 - hydro.target_storage_tolerance) * Target;
maxTarget = maxTarget:aggregate_blocks(BY_FIRST_VALUE());
minTarget = minTarget:aggregate_blocks(BY_FIRST_VALUE());
Target:save("hydro_max_targert_");
maxTarget:save("hydro_max_targert");
minTarget:save("hydro_min_targert");
ifelse(Target_nodata:gt(0), 0, ifelse(Target:gt(0), max(0, volfin - maxTarget), 0)):save("constraint_max_target");
ifelse(Target_nodata:gt(0), 0, ifelse(Target:gt(0), max(0, -volfin + minTarget), 0)):save("constraint_min_target");