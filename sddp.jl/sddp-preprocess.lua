local hydro = require("collection/hydro");

-- MinBioSpillage
hydro.min_bio_spillage_historical_scenarios
    :select_stages()
    :aggregate_blocks(BY_AVERAGE())
    :save("foca1");
    
-- MinSpillage
hydro.min_spillage_historical_scenarios
    :select_stages()
    :aggregate_blocks(BY_AVERAGE())
    :save("foca2");

hydro.min_spillage_historical_scenarios_nodata
    :select_scenarios(1)
    :select_stages()
    :save("foca2_nodata");

-- VolumeMaximum
hydro.vmax_chronological_historical_scenarios
    :select_stages()
    :aggregate_blocks(BY_LAST_VALUE())
    :save("foca3");

-- FloodControlStorage
hydro.flood_volume_historical_scenarios
    :select_stages()
    :aggregate_blocks(BY_LAST_VALUE())
    :save("foca4");
