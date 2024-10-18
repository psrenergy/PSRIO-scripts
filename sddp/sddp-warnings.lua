local dictionary<const> = {
    error_reports = {
        en = "Error reports",
        es = "Informes de errors",
        pt = "Relatórios de erros"
    },
    warnings_reports = {
        en = "Warnings reports",
        es = "Informes de advertencia",
        pt = "Relatórios de avisos"
    }
};

local statements<const> = {
    convergence_gap = {
        MAIN = {
            en = [[
The convergence gap was not met according to the "Convergence" chart in the "Policy" tab. Please, consider the following options:

🠊 Increase the number of iterations to be considered by the model.
```
1. Go to Execution options -> Economic dispatch -> Study options.
2. Increase the 'Maximum number of iterations' in the corresponding text box.
```
]],
            es = [[
El gap de convergencia no se cumplió, según lo indicado en el gráfico de "Convergencia" en la pestaña de "Política". Por favor, considere las siguientes opciones:            

🠊 Aumenta el número de iteraciones a considerar por el modelo.
```
1. Vaya a Opciones de ejecución -> Despacho económico -> Opciones de estudio.
2. Aumente el 'No. máximo de iteraciones' en el cuadro de texto correspondiente.
```
]],
            pt = [[
O gap de convergência não foi atendido, conforme indicado pelo gráfico de "Convergência" na guia de "Política". Por favor, considere as seguintes opções:

🠊 Aumente o número de iterações a serem consideradas pelo modelo.
```
1. Vá para Opções de execução -> Despacho econômico -> Opções de estudo.
2. Aumente o 'No. máximo de iterações' na caixa de texto correspondente.
```
]]
        },
        FORW = {

            en = [[
🠊 Increase the number of forward series in the study.
```
1. Go to Exection options -> Economic dispatch -> Study options.
2. Increase the 'Number of forward series' in the corresponding text box.
```
]],
            es = [[
🠊 Aumenta el número de series forward en tu estudio.
```
1. Vaya a Opciones de ejecución -> Despacho económico -> Opciones de estudio.
2. Aumenta el 'Número de series forward' en el cuadro de texto correspondiente.
```
]],
            pt = [[
🠊 Aumente o número de séries forward em seu estudo.
```
1. Vá para Opções de execução -> Despacho econômico -> Opções de estudo.
2. Aumente o 'Número de séries forward' na caixa de texto correspondente.
```
]]
        }
    },
    simulation_cost = {
        MAIN = {
            en = [[
The estimated cost in the operating policy does not match the simulation cost according to the "Objective function: Policy x Final simulation" chart in the "Policy" tab. Please, consider the following options:

🠊 Consider non-linearities during the calculation of the policy made by the model.
```
1. Go to Exection options -> Economic dispatch -> Solution strategy.
2. Select the 'Non-convexity representation in policy' checkbox.
3. Define the iterations where the non-convexities should be considered in 'Initial iteration' text box.
```
🠊 Consider the same production factor in the policy and in the simulation.
```
1. Go to Basic data -> Hydro plants configuration.
2. For each hydro plant, in 'Generator group subtab', set the same 'Production coefficient in operating 
policy calculation' and 'Production coefficient in final simulation' (in respectives dropdown boxes).
```
]],
            es = [[
El costo estimado en la política operativa no coincide con el costo de la simulación según el gráfico "Función objetivo: Política x Simulación Final" en la pestaña de "Política". Por favor, considere las siguientes opciones:

🠊 Considere las no linealidades durante el cálculo de la política realizada por el modelo.
```
1. Vaya a Opciones de ejecución -> Despacho económico -> Estrategia de solución.
2. Seleccione la casilla 'Representación de no convexidad en la política'.
3. Defina las iteraciones en las que se deben considerar las no convexidades en el cuadro de texto de 'Iteración inicial'.
```
🠊 Considere el mismo factor de producción en la política y en la simulación.
```
1. Vaya a Datos básicos -> Configuración de hidroeléctricas.
2. Para cada central hidroeléctrica, en la subpestaña 'Grupo generador', configure el mismo 'Coeficiente
 de producción en la política' y el 'Coeficiente de producción en la simulación final' (en las respectivas casillas desplegables).
```
]],
            pt = [[
O custo estimado na política operativa não condiz com o custo da simulação de acordo com o grafico "Função objetivo: Política x Simulação final" na guia de "Política"; por favor, considere as seguintes opções:

🠊 Considere as não linearidades durante o cálculo da política feita pelo modelo.
```
1. Vá para Opções de execução -> Despacho econômico -> Estratégia de solução.
2. Selecione a checkbox 'Representação de não convexidade na política'.
3. Defina as iterações onde as não linearidades devem ser consideradas na caixa de texto de 'Iteração inicial'.
```
🠊 Considere o mesmo fator de produção na política e na simulação.
```
1. Vá para Dados básicos -> Configuração de usinas hidrelétricas.
2. Para cada usina hidroelétrica, na subguia 'Grupo de geradores', configure o mesmo 'Coeficiente 
de produção na política' e no 'Coeficiente de produção na simulação final' (nas respectivas caixas de seleção).
```
]]
        }
    },
    mip_convergence = {
        MAIN = {
            en = [[
The MIP convergence gap was not met for some solutions, as indicated by the "Solution Status per Stage and Scenario" chart in the "Simulation" tab. Please consider the following options:

🠊 Increase the MIP maximum execution time
```
1. Go to Execution Options -> Economic Dispatch -> Solution Strategy.
2. In 'Optimization Parameters', increase the 'MIP maximum execution time (s)' text box value.
```
🠊 Reduce the Slice Duration
```
1. Go to Execution Options -> Economic Dispatch -> Solution Strategy.
2. In 'Intra-stage Representation', select the checkbox 'Decompose stages in slice'.
3. Decrease the 'Slice Duration (hour)' text box value.
```
]],
            es = [[
El gap de convergencia del MIP no se cumplió para algunas soluciones, según lo indicado en el gráfico de "Estado de la Solución por Etapa y Escenario" en la pestaña de "Simulación". Considere las siguientes opciones:

🠊 Aumentar el tiempo máximo de ejecución de MIP
```
1. Vaya a Opciones de Ejecución -> Despacho Económico -> Estrategia de Solución.
2. En 'Parámetros de Optimización', incremente el valor en la caja de texto 'Tiempo máximo de ejecución de MIP (s)'.
```
🠊 Reducir la Duración de las sub-etapas
```
1. Vaya a Opciones de Ejecución -> Despacho Económico -> Estrategia de Solución.
2. En 'Representación Intra-etapa', seleccione la casilla 'Decomponer etapas en sub-etapas'.
3. Disminuya el valor en la caja de texto 'Duración de las sub-etapas (hora)'.
```
]],
            pt = [[
O gap de convergência do MIP não foi atendido para algumas soluções, conforme indicado pelo gráfico de "Status da Solução por Estágio e Cenário" na guia de "Simulação". Considere as seguintes opções:

🠊 Aumentar o tempo máximo de execução do MIP
```
1. Vá para Opções de Execução -> Despacho Econômico -> Estratégia de Solução.
2. Em 'Parâmetros de Otimização', aumente o valor da caixa de texto 'Tempo máximo de execução do MIP (s)'.
```
🠊 Reduzir a Duração de intra-estágio
```
1. Vá para Opções de Execução -> Despacho Econômico -> Estratégia de Solução.
2. Em 'Representação Intra-estágio', marque a caixa de seleção "Decompor estágios em sub-subtágios".
3. Diminua o valor da caixa de texto "Duração dos sub-subtágios (hora)".
```
]]
        }
    },
    obj_costs = {
        MAIN = {
            en = [[
The costs associated with violations exceed 20% of the objective function cost in the simulation, as indicated by the "Breakdown of Total Operating Cost" chart within the "Simulation" tab. Please consider the following options:

🠊 Review the Violations tab to gain a clearer understanding of the most significant violations and identify the stages where penalties are more pronounced.
🠊 Evaluate if the constraints can be met or if they should be relaxed.
🠊 Evaluate if the values of penalties for each violation were correclty calibrated.
]],
            es = [[
Los costos asociados con las violaciones superan el 20% de el costo de la funcion objetivo en la simulacion, como se indica en el gráfico "Porciones de el costo operativo total" dentro de la pestaña de "Simulación". Por favor, considere las siguientes opciones:

🠊 Revise la pestaña de Violaciones para comprender mejor las violaciones más significativas e identificar las etapas donde las penalidades son más pronunciadas.
🠊 Evalúe si se pueden cumplir las restricciones o si deben ser relajadas.
🠊 Evalúe si los valores de las penalizaciones por cada violación fueron calibradas correctamente.
]],
            pt = [[
Os custos associados às violações excedem 20% do custo da função objetivo na simulação, conforme indicado pelo gráfico "Parcelas do custo operacional total" na guia de "Simulação". Por favor, considere as seguintes opções:

🠊 Analise a guia de Violações para entender melhor as violações mais significativas e identificar as etapas onde as penalidades são mais expressivas.
🠊 Avalie se as restrições podem ser atendidas ou se devem ser relaxadas.
🠊 Avalie se os valores das penalidades para cada violação foram calibradas corretamente.
]]
        }
    },
}

Advisor = {};
Advisor.__index = Advisor

setmetatable(
    Advisor, {
        __call = function(cls, ...)
            return cls.new(...)
        end
    }
);

function Advisor.new()
    local self = setmetatable({}, Advisor);
    self.errors = {};
    self.warnings = {};
    self.ids_list = {};
    return self;
end

function Advisor:push(info_vector,id, level, options)
    options = (options or {});
    if self.ids_list[id] then
        info( id .. " was already add")
    else
        local msg = statements[id]['MAIN'][LANGUAGE];
        for _,option in ipairs(options) do
            if statements[id][option][LANGUAGE] then
                msg = msg .. "\n" .. statements[id][option][LANGUAGE];
            end
        end
        self.ids_list[id] = 1;
        table.insert(info_vector, {message = msg,
                                   level   = ( level or (1 / 0) ) });
    end
end
function Advisor:push_error(id, level, options)
    self:push(self.errors,id, level, options)
end

function Advisor:push_warning(id, level, options)
    self:push(self.warnings,id, level, options)
end

function Advisor.sort_messages(val_a, val_b)
    return val_a.level < val_b.level
end

function Tab.push_advices(self, advisor)
    if advisor == nil then
        error("Input must not be nil");
    end

    if #advisor.errors > 0 then
        self:push("# " .. dictionary.error_reports[LANGUAGE] .. " ❌");
        table.sort(advisor.errors, Advisor.sort_messages)
        for i, statement in ipairs(advisor.errors) do
            self:push("### " .. i .. ") " .. statement.message);
        end
    end

    if #advisor.warnings > 0 then
        self:push("# " .. dictionary.warnings_reports[LANGUAGE] .. " ⚠️");
        table.sort(advisor.warnings, Advisor.sort_messages)
        for i, statement in ipairs(advisor.warnings) do
            self:push("### " .. i .. ") " .. statement.message);
        end
    end
end
