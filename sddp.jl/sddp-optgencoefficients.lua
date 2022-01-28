local generic = Generic();

generic:load("optgscen00"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg00", {csv = true});
generic:load("optgscen01"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg01", {csv = true});
generic:load("optgscen02"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg02", {csv = true});
generic:load("optgscen03"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg03", {csv = true});
generic:load("optgscen04"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg04", {csv = true});
generic:load("optgscen05"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg05", {csv = true});
generic:load("optgscen06"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg06", {csv = true});
generic:load("optgscen07"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg07", {csv = true});
generic:load("optgscen09"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg09", {csv = true});