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
        en = [[
The convergence gap was not met according to Convergence chart in Policy tab; please consider the following options:

🠊 Increase the number of forward simulations in execution.
```
1. Go to Exection options -> Economic dispatch -> Study options.
2. Increase the number of forward series in corresponding text box.
```
🠊 Increase the number of iterations to be considered by the model.
```
1. Go to Exection options -> Economic dispatch -> Study options.
2. Increase the max number of iterations in corresponding text box.
```
]],
        es = [[
El espacio de convergencia no se cumplió; considere las siguientes opciones:            

🠊 Aumenta el número de simulaciones forward en tu ejecución.
```
1. Vaya a Opciones de ejecución -> Despacho económico -> Opciones de estudio.
2. Aumente el número de series forward en el cuadro de texto correspondiente.
```
🠊 Aumenta el número de iteraciones a considerar por el modelo.
```
1. Vaya a Opciones de ejecución -> Despacho económico -> Opciones de estudio.
2. Aumente el número máximo de iteraciones en el cuadro de texto correspondiente.
```
]],
        pt = [[
O gap de convergência não foi atendido; por favor, considere as seguintes opções:

🠊 Aumente o número de simulações forward em sua execução.
```
1. Vá para Opções de execução -> Despacho econômico -> Opções de estudo.
2. Aumente o número de séries forward na caixa de texto correspondente.
```
🠊 Aumente o número de iterações a serem consideradas pelo modelo.
```
1. Vá para Opções de execução -> Despacho econômico -> Opções de estudo.
2. Aumente o número máximo de iterações na caixa de texto correspondente.
```
]]
    },
    simulation_cost = {
        en = [[
The estimated cost in the operating policy does not match the simulation cost according to Policy x Final simulation objective functions chart in Policy tab; please consider the following options:

🠊 Consider nonlinearities during the calculation of the policy made by the model.
```
1. Go to Exection options -> Economic dispatch -> Solution strategy.
2. Select non-convexity representation in policy checkbox.
3. Define the iterations where the non-convexities should be considered in Initial iteration text box.
```
🠊 Consider the same production factor in the policy and in the simulation.
```
1. Go to Basic data -> Hydro plants configuration.
2. For each hydro plant, in Generator group subtab, set the same Production coefficient in operating 
policy calculation and Production coefficient in final simulation (in respectives dropdown boxes).
```
]],
        es = [[
El costo estimado en la política de operación no coincide con el costo de la simulación; considere las siguientes opciones:

🠊 Considere las no linealidades durante el cálculo de la política realizada por el modelo.
```
1. Vaya a Opciones de ejecución -> Despacho económico -> Estrategia de solución.
2. Seleccione la representación de no convexidad en la casilla de política.
3. Defina las iteraciones en las que se deben considerar las no convexidades en el cuadro de texto de Iteración inicial.
```
🠊 Considere el mismo factor de producción en la política y en la simulación.
```
1. Vaya a Datos básicos -> Configuración de plantas hidroeléctricas.
2. Para cada planta hidroeléctrica, en la subpestaña Grupo de generadores, configure el mismo coeficiente
 de producción en el cálculo de la política de operación y el coeficiente de producción en la simulación final (en las respectivas casillas desplegables).
```
]],
        pt = [[
O custo estimado na política de operação não condiz com o custo da simulação; por favor, considere as seguintes opções:

🠊 Considere as não linearidades durante o cálculo da política feita pelo modelo.
```
1. Vá para Opções de execução -> Despacho econômico -> Estratégia de solução.
2. Selecione a representação de não convexidade na caixa de seleção de política.
3. Defina as iterações onde as não linearidades devem ser consideradas na caixa de texto Iteração inicial.
```
🠊 Considere o mesmo fator de produção na política e na simulação.
```
1. Vá para Dados básicos -> Configuração de usinas hidrelétricas.
2. Para cada usina hidroelétrica, na subaba Grupo de geradores, configure o mesmo coeficiente 
de produção no cálculo da política de operação e no coeficiente de produção na simulação final (nas respectivas caixas de seleção).
```
]]
    },
    mip_convergence = {
        en = [[
The MIP gap was not met for some solutions, as indicated by the Solution Status per Stage and Scenario chart in the Simulation tab. Please consider the following options:

🠊 Increase the MIP maximum execution time
```
1. Navigate to Execution Options -> Economic Dispatch -> Solution Strategy.
2. In Optimization Parameters, increase the number of MIP maximum execution time (s) text boxes.
```
🠊 Reduce the Slice Duration
```
1. Navigate to Execution Options -> Economic Dispatch -> Solution Strategy.
2. In Intra-stage Representation, select the checkbox "Decompose stages in slice."
3. Decrease the Slice Duration (hour) text box value.
```
]],
        es = [[
La brecha MIP no se cumplió para algunas soluciones, según lo indica el gráfico de Estado de la Solución por Etapa y Escenario en la pestaña de Simulación. Considere las siguientes opciones:

🠊 Aumentar el tiempo máximo de ejecución de MIP
```
1. Vaya a Opciones de Ejecución -> Despacho Económico -> Estrategia de Solución.
2. En Parámetros de Optimización, incremente el número de cajas de texto "Tiempo máximo de ejecución de MIP (s)".
```
🠊 Reducir la Duración de la Fracción
```
1. Vaya a Opciones de Ejecución -> Despacho Económico -> Estrategia de Solución.
2. En Representación Intra-etapa, seleccione la casilla "Duración de las sub-etapas".
3. Disminuya el valor de la caja de texto "Duración de las sub-etapas (hora)".
```
]],
        pt = [[
A margem de otimização (MIP gap) não foi atendida para algumas soluções, conforme indicado pelo gráfico de Status da Solução por Estágio e Cenário na guia de Simulação. Considere as seguintes opções:

🠊 Aumentar o tempo máximo de execução do MIP
```
1. Acesse Opções de Execução -> Despacho Econômico -> Estratégia de Solução.
2. Em Parâmetros de Otimização, aumente o número de caixas de texto "Tempo máximo de execução do MIP (s)".
```
🠊 Reduzir a Duração da Fatia
```
1. Acesse Opções de Execução -> Despacho Econômico -> Estratégia de Solução.
2. Em Representação Intra-estágio, marque a caixa de seleção "Duração dos sub-subtágios".
3. Diminua o valor da caixa de texto "Duração dos sub-subtágios (hora)".
```
]]
    }
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
    return self;
end

function Advisor:push_error(id, level)
    table.insert(self.errors, {message = statements[id][LANGUAGE], 
                               level   = ( level or (1 / 0) ) });
end

function Advisor:push_warning(id, level)
    table.insert(self.warnings, {message = statements[id][LANGUAGE],
                                 level   = ( level or (1 / 0) ) });
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
