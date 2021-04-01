function save_fcvmaxtp()
    if fuelcontract == nil then fuelcontract = FuelContract(); end
    fuelcontract.take_or_pay:save("fcvmaxtp");
end