-- variaveis gamers
local TailwindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Raulmmn/hacksforroblox/refs/heads/main/tailwindui.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local myUserId = LocalPlayer.UserId
local plotsFolder = Workspace:FindFirstChild("Plots")
local mapFolder = Workspace:FindFirstChild("Map")
local basesFolder = mapFolder and mapFolder:FindFirstChild("Bases")
local brainrotsFolder = Workspace:FindFirstChild("Brainrots")
local baseZonesFolder = Workspace:FindFirstChild("BaseZones")

local ui = TailwindUI.new("autofarm", "gray")
local mainsession = ui:AddSession("Main")
local basessession = ui:AddSession("Bases")
local configsession = ui:AddSession("Config")
local debugsession = ui:AddSession("Debug")
getgenv().autoCollecting = false

local myPlot = nil
if plotsFolder then
    for indice, plot in ipairs(plotsFolder:GetChildren()) do
        local ownerId = plot:GetAttribute("Owner")
        if ownerId == myUserId then
            myPlot = plot
            print("plot encontrado:", myPlot)
            break
        end
    end
end
if not myPlot then
    print("plot nao encontrado com id", myUserId)
end

local podiumsFolder = myPlot and myPlot:FindFirstChild("Podiums")

local function recalculate()
    LocalPlayer = Players.LocalPlayer
    character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    rootPart = character:WaitForChild("HumanoidRootPart")
end

local function getMoney(state)
    recalculate()
    getgenv().autoCollecting = state
    if state and podiumsFolder then
        while state do
            for indice, podium in ipairs(podiumsFolder:GetChildren()) do
                if not getgenv().autoCollecting then break end
                local podiumCollect = podium:FindFirstChild("Collect")
                if podiumCollect then
                    local collectCFrame = podiumCollect.CFrame
                    local originCFrame = rootPart.CFrame

                    rootPart.CFrame = collectCFrame
                    task.wait(0.001)
                    rootPart.CFrame = originCFrame
                end
            end
            if not getgenv().autoCollecting then break end
            task.wait(0.3)
        end
    end
end

local function teleport(toCFrame, shouldReturn, returnDelay)
    recalculate()
    shouldReturn = shouldReturn or false
    returnDelay = returnDelay or 0.1
    local originCFrame = rootPart.CFrame

    rootPart.CFrame = toCFrame

    if shouldReturn then
        task.spawn(function()
            task.wait(returnDelay)
            if rootPart then
                rootPart.CFrame = originCFrame
            end
        end)
    end
end

-- Função de automação completa ao clicar no Brainrot (com delay ajustado para 0.5s - 0.7s)
local function executarAcaoBrainrot(brainrotInstance, nomeBase)
    recalculate()
    task.spawn(function()
        recalculate()
        if not rootPart then return end
        
        print("Iniciando rotina para o brainrot na base:", nomeBase)
        
        -- 1. Teleportar para a área de corrida
        local raceArea = Workspace:FindFirstChild("Misc"):FindFirstChild("ConveyorStart")
        if raceArea then
            if raceArea:IsA("BasePart") then
                rootPart.CFrame = raceArea.CFrame
            elseif raceArea:IsA("Model") then
                rootPart.CFrame = raceArea:GetPivot()
            end
        else
            warn("Área de corrida não encontrada no Workspace.")
        end
        
        -- 2. Esperar 0.1s e teleportar para a zona de captura (baseZonesFolder)
        task.wait(0.1)
        local targetZone = nil
        if baseZonesFolder then
            for _, zone in ipairs(baseZonesFolder:GetChildren()) do
                if zone.Name:lower() == nomeBase:lower() or zone.Name:lower():find(nomeBase:lower()) then
                    targetZone = zone
                    break
                end
            end
        end
        
        if targetZone then
            if targetZone:IsA("BasePart") then
                rootPart.CFrame = targetZone.CFrame
            elseif targetZone:IsA("Model") then
                rootPart.CFrame = targetZone:GetPivot()
            end
            print("Teleportado para a zona de captura da base:", nomeBase)
        else
            warn("Zona de captura não encontrada para a base:", nomeBase)
        end
        
        -- Aguardar o tempo necessário (aprox. 5 segundos no total)
        task.wait(7.3)
        
        -- 3. Teleportar no brainrot escolhido
        if brainrotInstance and brainrotInstance.Parent then
            local targetCFrame = nil
            if brainrotInstance:IsA("BasePart") then
                targetCFrame = brainrotInstance.CFrame
            elseif brainrotInstance:IsA("Model") then
                targetCFrame = brainrotInstance:GetPivot()
            end
            
            if targetCFrame then
                rootPart.CFrame = targetCFrame + Vector3.new(0, 3, 0)
                print("Teleportado para o Brainrot.")
            end
        else
            warn("Brainrot não existe mais ou foi coletado.")
            return
        end
        
        -- 4. Esperar de 0.5 a 0.7 segundos para garantir o carregamento antes de interagir com 'E'
        local tempoEsperaInicio = math.random(100, 125) / 1000
        task.wait(tempoEsperaInicio)
        
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        local tempoInteracao = math.random(500, 600) / 1000 -- Pressiona por 0.3 a 0.5s
        task.wait(tempoInteracao)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        print("Interação concluída ('E' pressionado por", tempoInteracao, "s)")
        
        -- 5. Teleportar de volta para a base do jogador
        task.wait(0.5)
        if myPlot then
            local spawnObj = myPlot:FindFirstChild("Spawn")
            if spawnObj then
                rootPart.CFrame = spawnObj.CFrame
                print("Retornado para a base principal.")
            end
        end
    end)
end

-- Função para popular a aba Bases utilizando BaseName, Index, Rarity, Level e filtro estrito <= 7
local function montarSessaoBases()
    if not brainrotsFolder then
        warn("Pasta Brainrots não encontrada!")
        return
    end

    -- Limpa os elementos visuais antigos da sessão de bases na UI antes de recriar
    basessession:Clear()

    -- Adiciona o botão de atualizar no topo da aba Bases sempre que recriar
    basessession:AddButton("🔄 Atualizar Listas de Bases", function()
        montarSessaoBases()
    end)

    local basesAgrupadas = {}

    for _, child in ipairs(brainrotsFolder:GetChildren()) do
        local nomeBase = child:GetAttribute("BaseName")
        local slotRef = child:GetAttribute("SlotRef")
        
        local numeroSlot = nil
        if type(slotRef) == "string" then
            numeroSlot = tonumber(slotRef:match("Slot(%d+)"))
        elseif typeof(slotRef) == "Instance" then
            numeroSlot = tonumber(slotRef.Name:match("%d+"))
        end

        if numeroSlot and numeroSlot <= 7 and nomeBase then
            if not basesAgrupadas[nomeBase] then
                basesAgrupadas[nomeBase] = {}
            end
            
            local rarityAttr = child:GetAttribute("Rarity") or "Comum"
            local indexAttr = child:GetAttribute("Index") or child.Name
            local levelAttr = child:GetAttribute("Level") or 1
            local mutationAttr = child:GetAttribute("Mutation") or "Normal"
            
            local nomeExibicao = string.format("[%s] %s (Lv. %s) %s", tostring(rarityAttr), tostring(indexAttr), tostring(levelAttr), tostring(mutationAttr))
            
            table.insert(basesAgrupadas[nomeBase], { nomeExibicao, child })
        end
    end

    local listaBasesOrdenadas = {}
    for nomeBase, _ in pairs(basesAgrupadas) do
        table.insert(listaBasesOrdenadas, nomeBase)
    end

    table.sort(listaBasesOrdenadas, function(a, b)
        local numA = tonumber(a:match("%d+")) or 0
        local numB = tonumber(b:match("%d+")) or 0
        return numA < numB
    end)

    for _, nomeBase in ipairs(listaBasesOrdenadas) do
        local itens = basesAgrupadas[nomeBase]
        local numeroBase = nomeBase:match("%d+")
        local tituloLista = numeroBase and ("Base " .. numeroBase) or nomeBase

        basessession:AddList(tituloLista, itens, function(brainrotEscolhido)
            if typeof(brainrotEscolhido) == "Instance" then
                executarAcaoBrainrot(brainrotEscolhido, nomeBase)
            end
        end, "Mostrar Brainrots ⬇")
    end
    print("Sessão de Bases montada e atualizada com sucesso!")
end

local antiAfkConnection
local function toggleAntiAFK(state)
    if state then
        antiAfkConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    else
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end
end

local function toggle3DRendering(state)
    RunService:Set3dRenderingEnabled(not state)
end

local function turnSuperAntiLag()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 2

    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") then
            v.Enabled = false
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") then
            obj.Enabled = false
        elseif obj:IsA("Explosion") then
            obj.Visible = false
        end
    end
end

-- Botões e Sessões
mainsession:AddToggle("Auto Collect", function(state)
    getMoney(state)
end)

mainsession:AddButton("Teleport to Your Base", function()
    if myPlot then
        local spawnObject = myPlot:FindFirstChild("Spawn")
        if spawnObject then
            teleport(spawnObject.CFrame, false, 0)
        end
    end
end)

debugsession:AddButton("Carregar/Atualizar Listas de Bases", function()
    montarSessaoBases()
end)

configsession:AddToggle("Anti AFK", function(state)
    toggleAntiAFK(state) 
end)

configsession:AddToggle("Desabilitar Renderização 3D", function(state)
    toggle3DRendering(state)
end)

configsession:AddButton("Ativar AntiLag", function()
    turnSuperAntiLag()
end)

-- Carrega as bases na inicialização
task.spawn(function()
    task.wait(1)
    montarSessaoBases()
end)