local hydro = require("collection/hydro");

-- MinBioSpillage
local min_bio_spillage = hydro.min_bio_spillage_historical_scenarios
    :select_stages()
    :aggregate_blocks(BY_AVERAGE())
    :save_and_load("foca1");

local min_bio_spillage_nodata = hydro.min_bio_spillage_historical_scenarios_nodata
    :select_stages()
    :aggregate_blocks(BY_MAX())
    :save_and_load("foca1_nodata");

ifelse(min_bio_spillage_nodata:eq(1), -1, min_bio_spillage):save("foca1_onefile");

-- MinSpillage
local min_spillage = hydro.min_spillage_historical_scenarios
    :select_stages()
    :aggregate_blocks(BY_AVERAGE())
    :save_and_load("foca2");

local min_spillage_nodata = hydro.min_spillage_historical_scenarios_nodata
    :select_stages()
    :aggregate_blocks(BY_MAX())
    :save_and_load("foca2_nodata");

ifelse(min_spillage_nodata:eq(1), -1, min_spillage):save("foca2_onefile");

-- VolumeMaximum
hydro.vmax_chronological_historical_scenarios
    :select_stages()
    :aggregate_blocks(BY_LAST_VALUE())
    :save("foca3");

-- VolumeMaximum
hydro.vmax_chronological_historical_scenarios_nodata
    :select_stages()
    :aggregate_blocks(BY_LAST_VALUE())
    :save("foca3_nodata");

-- FloodControlStorage
hydro.flood_volume_historical_scenarios
    :select_stages()
    :aggregate_blocks(BY_LAST_VALUE())
    :save("foca4");
