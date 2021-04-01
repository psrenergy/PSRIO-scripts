function save_fcvmax()
    if fuelcontract == nil then fuelcontract = FuelContract(); end
    fuelcontract.amount:save("fcvmax");
end