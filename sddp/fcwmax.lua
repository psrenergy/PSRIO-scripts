function save_fcwmax()
    if fuelcontract == nil then fuelcontract = FuelContract(); end
    fuelcontract.max_offtake:save("fcwmax");
end