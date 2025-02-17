-- Verifying format option
local is_csv = Study():get_parameter("BINF",0) == 0;

-- Verifying the suffixes
local suffixes = { { suffix = "" } };
if Study():get_parameter("GENE", -1) == 1 then
  suffixes = {
      { suffix = "_week" },
      { suffix = "_day" },
      { suffix = "_hour" },
      { suffix = "_trueup" }
  };
end

for _, item in pairs(suffixes) do
  -- ENEMBP - Percentual of stored energy by reservatory
  local enembp = require("sddp/enembp")(item.suffix);
  if enembp:is_hourly() then
    enembp:save("enembp" .. item.suffix, {variable_by_block=2, csv=is_csv});
  else
    enembp:save("enembp" .. item.suffix, {csv=is_csv});
  end

  -- USERNW - Renewable dispatch factor
  local usernw = require("sddp/usernw")(item.suffix);
  usernw:save("usernw" .. item.suffix, {variable_by_block=2, csv=is_csv});

  -- VERE15 - Expected value of the percentage of rationing with respect to the load
  local vere15 = require("sddp/vere15")(item.suffix);
  vere15:save("vere15" .. item.suffix,{csv=is_csv});

  -- POTCSP - CSP capacity scenario
  csp = ConcentratedSolarPower();
  cspscen = csp:load("cspscen" .. item.suffix);
  capacity = csp:load_vector("PotInst", "MW");
  potcsp = cspscen * capacity;
  if potcsp:is_hourly() then
    potcsp:save("potcsp" .. item.suffix, {variable_by_block=2, csv=is_csv});
  else
    potcsp:save("potcsp" .. item.suffix, {csv=is_csv});
  end

  -- OEMGND - Renewable O&M unitary cost
  -- TODO: Check if this is right
  renewable = Renewable();
  oemgnd = renewable.om_cost;
  oemgnd:save("oemgnd" .. item.suffix,{csv=is_csv});

  -- PBATSTG - Percentual of battery storage
  battery = Battery();
  batstg = battery:load("batstg" .. item.suffix):convert("MW");
  if batstg:loaded() then
    max_storage = battery.max_storage;
    pbatstg = safe_divide(batstg,max_storage):convert("%");
    if pbatstg:is_hourly() then
      pbatstg:save("pbatstg" .. item.suffix, {variable_by_block=2, csv=is_csv});
    else
      pbatstg:save("pbatstg" .. item.suffix, {csv=is_csv});
    end
  end

  -- COSSHUT - Shutdown cost of commitment thermal plants
  thermal = Thermal();
  trshdw = thermal:load("trshdw" .. item.suffix);
  if trshdw:loaded() then
    cosshut = thermal.shutdown_cost * trshdw;
    if cosshut:is_hourly() then
      cosshut:save("cosshut" .. item.suffix, {variable_by_block=2, csv=is_csv});
    else
      cosshut:save("cosshut" .. item.suffix, {csv=is_csv});
    end
  end

  -- GASEMI - total gas emission
  emission = GasEmission();
  generic = Generic();
  local emiValues = generic:load("teremi" .. item.suffix);
  if emiValues:loaded() then
    local emiNames = emission:labels();
    local emiAux   = {}
    for _, iName in ipairs(emiNames) do
      table.insert(emiAux, emiValues:select_agents_by_regex(iName .. "(.*)"):aggregate_agents(BY_SUM(), iName))
    end
    gasemi = concatenate(emiAux):select_agents(Collection.GAS_EMISSION);
    if gasemi:is_hourly() then
      gasemi:save("gasemi" .. item.suffix, {variable_by_block=2, csv=is_csv});
    else
      gasemi:save("gasemi" .. item.suffix, {csv=is_csv});
    end
  end

  -- OEMBATUN - battery o&m cost
  -- TODO: Check if this is right
  battery = Battery();
  local oembatun = battery.om_cost;
  oembatun:save("oembatun" .. item.suffix, {csv=is_csv});

  -- gerterMW - thermal MW generation
  thermal = Thermal();
  gerter = thermal:load("gerter" .. item.suffix);
  if gerter:loaded() then
    if gerter:is_hourly() then
      gerter:convert("MW"):save("gerterMW" .. item.suffix, {variable_by_block=2, csv=is_csv});
    else
      gerter:convert("MW"):save("gerterMW" .. item.suffix, {csv=is_csv});
    end
  end

  -- RENMXRSER - Renewable max reserve
  -- TODO: Check if this is right
  renewable = Renewable();
  local renewable_reserv = renewable.max_reserve;
  if renewable_reserv:is_hourly() then
    renewable_reserv:save("renmxreser" .. item.suffix, {variable_by_block=2, csv=is_csv});
  else
    renewable_reserv:save("renmxreser" .. item.suffix, {csv=is_csv});
  end

  -- RENBDPRC - Renewable bid price
  -- TODO: Check if this is right
  renewable = Renewable();
  local renewable_bid = renewable.bid_price;
  if renewable_bid:is_hourly() then
    renewable_bid:save("renbdprc" .. item.suffix, {variable_by_block=2, csv=is_csv});
  else
    renewable_bid:save("renbdprc" .. item.suffix, {csv=is_csv});
  end

  -- BATMXRSER - Battery max reserve
  -- TODO: Check if this is right
  battery = Battery();
  local battery_reserv = battery.max_reserve;
  if battery_reserv:is_hourly() then
    battery_reserv:save("batmxreser" .. item.suffix, {variable_by_block=2, csv=is_csv});
  else
    battery_reserv:save("batmxreser" .. item.suffix, {csv=is_csv});
  end

  -- BATBDPRC - Battery bid price
  -- TODO: Check if this is right
  battery = Battery();
  local battery_bid = battery.bid_price;
  if battery_bid:is_hourly() then
    battery_bid:save("batbdprc" .. item.suffix, {variable_by_block=2, csv=is_csv});
  else
    battery_bid:save("batbdprc" .. item.suffix, {csv=is_csv});
  end

  -- HIDMXRSER - Hydro max reserve
  -- TODO: Check if this is right
  hydro = Hydro();
  local hydro_reserv = hydro.max_reserve;
  if hydro_reserv:loaded() then
    local reserve_unit = hydro:load_parameter("MaxSecondaryReserveUnit","");
    local nominal_capacity_hydro_agents = reserve_unit:eq(2);
    local mw_capacity_hydro_agents = reserve_unit:eq(3);
    local avalailable_capacity_hydro_agents = reserve_unit:eq(14);

    local nominal_capacity_hydro_reserv = hydro_reserv:force_unit("%") * nominal_capacity_hydro_agents * hydro.max_generation;
    local avalailable_capacity_hydro_reserv = hydro_reserv:force_unit("%") * avalailable_capacity_hydro_agents * hydro.max_generation_available;
    local avalailable_capacity_mw_reserv = (hydro_reserv * mw_capacity_hydro_agents):force_unit("MW");
    if hydro_reserv:is_hourly() then
      (avalailable_capacity_mw_reserv + nominal_capacity_hydro_reserv + avalailable_capacity_hydro_reserv):save("hidmxreser" .. item.suffix, {variable_by_block=2, csv=true});
    else
      (avalailable_capacity_mw_reserv + nominal_capacity_hydro_reserv + avalailable_capacity_hydro_reserv):save("hidmxreser" .. item.suffix, {csv=true});
    end
  end

  -- HIDBDPRC - Hydro bid price
  -- TODO: Check if this is right
  hydro = Hydro();
  local hydro_bid = hydro.bid_price;
  if hydro_bid:is_hourly() then
    hydro_bid:save("hidbdprc" .. item.suffix, {variable_by_block=2, csv=is_csv});
  else
    hydro_bid:save("hidbdprc" .. item.suffix, {csv=is_csv});
  end

  -- TERMXRSER - Thermal max reserve
  -- TODO: Check if this is right
  thermal = Thermal();
  local thermal_reserv = thermal.max_reserve;
  if thermal_reserv:loaded() then
    local reserve_unit = thermal:load_parameter("MaxSecondaryReserveUnit","");
    local nominal_capacity_thermal_agents = reserve_unit:eq(2);
    local mw_capacity_thermal_agents = reserve_unit:eq(3);
    local avalailable_capacity_thermal_agents = reserve_unit:eq(14);

    local nominal_capacity_thermal_reserv = thermal_reserv:force_unit("%") * nominal_capacity_thermal_agents * thermal.max_generation;
    local avalailable_capacity_thermal_reserv = thermal_reserv:force_unit("%") * avalailable_capacity_thermal_agents * thermal.max_generation_available;
    local avalailable_capacity_mw_reserv = (thermal_reserv * mw_capacity_thermal_agents):force_unit("MW");
    if thermal_reserv:is_hourly() then
      (avalailable_capacity_mw_reserv + nominal_capacity_thermal_reserv + avalailable_capacity_thermal_reserv):save("termxreser" .. item.suffix, {variable_by_block=2, csv=true});
    else
      (avalailable_capacity_mw_reserv + nominal_capacity_thermal_reserv + avalailable_capacity_thermal_reserv):save("termxreser" .. item.suffix, {csv=true});
    end
  end

  -- TERBDPRC - Thermal bid price
  -- TODO: Check if this is right
  thermal = Thermal();
  local thermal_bid = thermal.bid_price;
  if thermal_bid:is_hourly() then
    thermal_bid:save("terbdprc" .. item.suffix, {variable_by_block=2, csv=is_csv});
  else
    thermal_bid:save("terbdprc" .. item.suffix, {csv=is_csv});
  end
end