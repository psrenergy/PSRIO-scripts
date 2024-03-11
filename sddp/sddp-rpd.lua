-- local generic = Generic();

-- local dprdash_psrio = generic:load("dprdashboard"):force_hourly():force_unit("");
-- local initial_year = dprdash_psrio:initial_year();
-- local final_year = dprdash_psrio:final_year();
-- local n_years = final_year - initial_year + 1;

-- local dashboard = Dashboard();

-- local chart = Chart("DPR");
-- chart:enable_controls();
-- for stage = 1, dprdash_psrio:last_stage() do
--     chart:add_line(dprdash_psrio:select_stage(stage), { sequence = stage});
-- end
-- local tab = Tab("DPR");
-- tab:push(chart);
-- dashboard:push(tab);
-- dashboard:save("dash_RPD")



local generic = Generic();

local dprdash_psrio = generic:load("dprdashboard",true,true):force_hourly():force_unit("");
local last_stage = dprdash_psrio:last_stage();


local dkjson = require("dkjson")
local tab = Tab("DPR")

local titles = {}
-- Gerar títulos
for i = 1, last_stage do
    table.insert(titles, "Stage " .. i)
end
local json_titles = dkjson.encode(titles)

local html = [[
<h1 id="dynamicTitle" style="font-size: 24px; font-family: Arial, sans-serif; font-weight: bold; text-align: left;">Título Dinâmico</h1>
<script>
// Script para atualizar o título a cada 2 segundos
var titles = ]] .. json_titles .. [[;
var currentIndex = 0;

function updateTitle() {
    document.getElementById('dynamicTitle').innerText = titles[currentIndex];
    currentIndex = (currentIndex + 1) % titles.length;
}

updateTitle(); // Chamando a função uma vez para definir o título inicial
setInterval(updateTitle, 2000); // Atualizar a cada 2 segundos
</script>
<script>
// Alter which tab will be open by default, based on id redirect
const splitted = window.location.href.split('#');
let section_id = "";
if (splitted.length > 1) {
    section_id = splitted[1];
    if (section_id.length > 0) {
        var tabs = document.getElementsByClassName("tab-pane");
        var current_tab = document.getElementsByClassName("tab-pane fade show active")[0];
        for (let i = 0; i < tabs.length; i++) {
            let anchors = tabs[i].getElementsByTagName("a");
            for (let j = 0; j < anchors.length; j++) {
                let tab_anchor = anchors[j];
                if (tab_anchor.id === section_id) {
                    current_tab.className = current_tab.className.replace(/(?:^|\s)show(?!\S)/g, '').replace(/(?:^|\s)active(?!\S)/g, '');
                    var current_nav = document.querySelectorAll('[href="#' + current_tab.id + '"]')[0];
                    if (!current_nav || current_nav.length === 0) {
                        current_nav = document.querySelectorAll('[data-bs-target="#' + current_tab.id + '"]')[0];
                    }
                    current_nav.className = current_nav.className.replace(/(?:^|\s)active(?!\S)/g, '');
                    tabs[i].className += " show active";
                    var right_nav = document.querySelectorAll('[href="#' + tabs[i].id + '"]')[0];
                    if (!right_nav || right_nav.length === 0) {
                        right_nav = document.querySelectorAll('[data-bs-target="#' + tabs[i].id + '"]')[0];
                    }
                    right_nav.className += " active";
                    break;
                }
            }
        }
    }
}
// remove loading overlay
document.getElementById("loadingBlocker").style.display = 'none';
// move user to the correct position in screen
if (section_id.length > 0) {
    window.location.href = window.location.href;
}
</script>
    

]]

-- tab:push(html)

local chart = Chart();
chart:enable_controls();
for stage = 1, dprdash_psrio:last_stage() do
    chart:add_line(dprdash_psrio:select_stage(stage), { sequence = stage});
end
tab:push(chart);

-- tab:push([[
-- <script>
-- document.addEventListener('DOMContentLoaded', function() {
--     // Adiciona event listener ao botão de play
--     document.querySelector('.highcharts-exporting-group .highcharts-button-symbol[title="Play"]').addEventListener('click', function() {
--         // Seu código para lidar com o clique no botão de play aqui
--         console.log('Botão Play clicado!');
--     });

--     // Adiciona event listener ao botão de pausa
--     document.querySelector('.highcharts-exporting-group .highcharts-button-symbol[title="Pause"]').addEventListener('click', function() {
--         // Seu código para lidar com o clique no botão de pausa aqui
--         console.log('Botão Pause clicado!');
--     });
-- });

-- </script>
-- ]]);

local dashboard = Dashboard()
dashboard:push(tab)
dashboard:save("dash_RPD")
