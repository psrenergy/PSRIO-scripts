local generic = Generic();
generic:load("optgscenct"):aggregate_stages(BY_SUM(), Profile.PER_YEAR):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optgct");