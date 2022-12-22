local study = Study();
local hydro = Hydro();

local suffix = "";
if study:is_genesys() then
    suffix ="__week";
end

local turbined_outflow = hydro:load("qturbi" .. suffix);
local spilled_outflow = hydro:load("qverti" .. suffix);
local final_storage = hydro:load("volfin" .. suffix);

local max_total_outflow_nodata = hydro.max_total_outflow_historical_scenarios_nodata;
local max_total_outflow = hydro.max_total_outflow_historical_scenarios;
ifelse(
    max_total_outflow_nodata:gt(0),
    0,
    max(0, turbined_outflow + spilled_outflow - max_total_outflow)
):convert("hm3"):save("constraint_max_total_outflow");

local min_total_outflow_nodata = hydro.min_total_outflow_historical_scenarios_nodata;
local min_total_outflow = hydro.min_total_outflow_historical_scenarios;
local minTODf = hydro.min_total_outflow_modification;
ifelse(
    min_total_outflow_nodata:gt(0),
    ifelse(
        minTODf:gt(0),
        max(0, -turbined_outflow - spilled_outflow + minTODf), 
        0
    ),
    max(0, -turbined_outflow - spilled_outflow + min_total_outflow)
):convert("hm3"):save("constraint_min_total_outflow");

local max_spillage_nodata = hydro.max_spillage_historical_scenarios_nodata;
local max_spillage = hydro.max_spillage_historical_scenarios;
ifelse(
    max_spillage_nodata:gt(0),
    0,
    max(0, spilled_outflow - max_spillage)
):convert("hm3"):save("constraint_max_spillage");

local min_spillage_nodata = hydro.min_spillage_historical_scenarios_nodata:to_block(BY_SUM());
local min_spillage = hydro.min_spillage_historical_scenarios:to_block(BY_SUM());
ifelse(
    min_spillage_nodata:gt(0),
    0,
    max(0, -spilled_outflow + min_spillage)
):convert("hm3"):save("constraint_min_spillage");

local min_turbining_outflow = hydro.min_turbining_outflow;
max(0, min_turbining_outflow - turbined_outflow):convert("hm3"):save("constraint_min_turbining");

final_storage:aggregate_blocks(BY_LAST_VALUE());
final_storage:save("volfin_");

-- local maxVol_nodata = hydro.max_operative_storage_historical_scenarios_nodata;
local maxVol = hydro.max_operative_storage_historical_scenarios;
ifelse(
    max_spillage_nodata:gt(0),
    0,
    max(0, final_storage - maxVol)
):save("constraint_max_volume");

-- local minVol_nodata = hydro.min_operative_storage_historical_scenarios_nodata;
local min_operative_storage = hydro.min_operative_storage_historical_scenarios;
ifelse(
    max_spillage_nodata:gt(0),
    0,
    max(0, min_operative_storage - final_storage)
):save("constraint_min_volume");

local min_bio_spillage_nodata = hydro.min_bio_spillage_historical_scenarios_nodata:to_block(BY_SUM());
local min_bio_spillage = hydro.min_bio_spillage_historical_scenarios:to_block(BY_SUM());
ifelse(
    min_bio_spillage_nodata:gt(0),
    0,
    max(0, (min_bio_spillage / 100) * turbined_outflow - (1 - min_bio_spillage / 100) * spilled_outflow)
):save("MinBioSpillage");

local alert_storage_nodata = hydro.alert_storage_historical_scenarios_nodata;
local alert_storage = hydro.alert_storage_historical_scenarios;
ifelse(
    alert_storage_nodata:gt(0),
    0,
    max(0, alert_storage - final_storage)
):save("constraint_alert_storage");

local flood_control_nodata = hydro.flood_control_historical_scenarios_nodata;
local flood_control = hydro.flood_control_historical_scenarios;
ifelse(
    flood_control_nodata:gt(0),
    0,
    max(0, flood_control - final_storage)
):save("hydro_flood_volume");

local target_storage_nodata = hydro.target_storage_historical_scenarios_nodata;
local target_storage = hydro.target_storage_historical_scenarios;
local max_target_storage = ((1 + hydro.target_storage_tolerance) * target_storage):aggregate_blocks(BY_FIRST_VALUE());
local min_target_storage = ((1 - hydro.target_storage_tolerance) * target_storage):aggregate_blocks(BY_FIRST_VALUE());
max_target_storage:save("hydro_max_target");
min_target_storage:save("hydro_min_target");
ifelse(target_storage_nodata:gt(0), 0, ifelse(target_storage:gt(0), max(0, final_storage - max_target_storage), 0)):save("constraint_max_target");
ifelse(target_storage_nodata:gt(0), 0, ifelse(target_storage:gt(0), max(0, min_target_storage - final_storage), 0)):save("constraint_min_target");