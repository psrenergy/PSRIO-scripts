local generic = require("collection/generic");

generic:load("optgscen00"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg00");
generic:load("optgscen01"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg01");
generic:load("optgscen02"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg02");
generic:load("optgscen03"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg03");
generic:load("optgscen04"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg04");
generic:load("optgscen05"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg05");
generic:load("optgscen06"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg06");
generic:load("optgscen07"):aggregate_scenarios(BY_AVERAGE()):convert("M$"):save("optg07");