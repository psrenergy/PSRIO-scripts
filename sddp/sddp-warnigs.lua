-- D:\SDDP_1\sddp\psrio\windows\psrio.exe -v 3 --model sddp -o "D:\SDDP_1\sddp\psrio-scripts\sddp\results" -r "D:\SDDP_1\sddp\psrio-scripts\sddp\sddp-warnnigs.lua" "C:\PSR\Sddp17.2\Example\12_stages\Case20"
local language = "en";
--=================================================--
-- Dictionaries of Names
--=================================================--
local error_dictionary_reports<const> = {
    title = {
        en = "# Error reports ❌",
        es = "# Informes de errors ❌",
        pt = "# Relatórios de erros ❌"
    };
};

local warning_dictionary_reports<const> = {
    title = {
        en = "# Warnings reports ⚠️",
        es = "# Informes de advertencia ⚠️",
        pt = "# Relatórios de avisos ⚠️"
    },
    convergence_gap = {
        en = "### The convergence gap was not met; please consider the following options:",
        es = "### El espacio de convergencia no se cumplió; considere las siguientes opciones:",
        pt = "### O gap de convergência não foi atendido; por favor, considere as seguintes opções:"
    },
    simulation_cost = {
        en = "### The estimated cost in the operating policy does not match the simulation cost; please consider the following options:",
        es = "### El costo estimado en la política de operación no coincide con el costo de la simulación; considere las siguientes opciones:",
        pt = "### O custo estimado na política de operação não condiz com o custo da simulação; por favor, considere as seguintes opções:"
    }
};

local options_reports<const> = {
    convergence_gap = {
        en = [[

            🠊 Increase the number of forward simulations in your execution.
            🠊 Increase the number of iterations to be considered by the model.
        ]],
        es = [[

            🠊 Aumenta el número de simulaciones forward en tu ejecución.
            🠊 Aumenta el número de iteraciones a considerar por el modelo.
        ]],
        pt = [[

            🠊 Aumente o número de simulações forward em sua execução.
            🠊 Aumente o número de iterações a serem consideradas pelo modelo.
        ]]
    },
    simulation_cost = {
        en = [[

            🠊 Consider nonlinearities during the calculation of the policy made by the model.
            🠊 Consider the same production factor in the policy and in the simulation.
        ]],
        es = [[

            🠊 Considere las no linealidades durante el cálculo de la política realizada por el modelo.
            🠊 Considere el mismo factor de producción en la política y en la simulación.
        ]],
        pt = [[

            🠊 Considere as não linearidades durante o cálculo da política feita pelo modelo.
            🠊 Considere o mesmo fator de produção na política e na simulação.
        ]];
    };
};

local reports<const> = {
    CONVERGENCE_GAP = {
        error = warning_dictionary_reports.convergence_gap[language] .. options_reports.convergence_gap[language],
        severity = "WARNING",
        },
    SIMULATION_COST = {
        error = warning_dictionary_reports.simulation_cost[language] .. options_reports.simulation_cost[language],
        severity = "WARNING",
        },
};

local dash = Dashboard();
local tab = Tab("teste");
tab:push(warning_dictionary_reports.title[language]);
tab:push(reports.CONVERGENCE_GAP["error"]);
tab:push(reports.SIMULATION_COST["error"]);
dash:push(tab);
dash:save("teste");

