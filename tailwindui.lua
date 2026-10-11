local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local TailwindUI = {}
TailwindUI.__index = TailwindUI

-- Temas pre-setados inspirados no TailwindCSS
local Themes = {
    dark = {
        bg = Color3.fromRGB(15, 23, 42),       -- Slate 900
        card = Color3.fromRGB(30, 41, 59),     -- Slate 800
        text = Color3.fromRGB(248, 250, 252),  -- Slate 50
        subtext = Color3.fromRGB(148, 163, 184),-- Slate 400
        border = Color3.fromRGB(51, 65, 85),    -- Slate 700
        accent = Color3.fromRGB(59, 130, 246)  -- Blue 500
    },
    black = {
        bg = Color3.fromRGB(0, 0, 0),          -- True Black
        card = Color3.fromRGB(18, 18, 18),     -- Zinc 900
        text = Color3.fromRGB(255, 255, 255),
        subtext = Color3.fromRGB(160, 160, 160),
        border = Color3.fromRGB(38, 38, 38),
        accent = Color3.fromRGB(37, 99, 235)
    },
    gray = {
        bg = Color3.fromRGB(38, 38, 38),       -- Neutral 800
        card = Color3.fromRGB(64, 64, 64),     -- Neutral 700
        text = Color3.fromRGB(255, 255, 255),
        subtext = Color3.fromRGB(212, 212, 212),
        border = Color3.fromRGB(82, 82, 82),
        accent = Color3.fromRGB(99, 102, 241)  -- Indigo 500
    },
    white = {
        bg = Color3.fromRGB(241, 245, 249),   -- Slate 100
        card = Color3.fromRGB(255, 255, 255),  -- White
        text = Color3.fromRGB(15, 23, 42),     -- Slate 900
        subtext = Color3.fromRGB(100, 116, 139),
        border = Color3.fromRGB(226, 232, 240),
        accent = Color3.fromRGB(37, 99, 235)
    }
}

function TailwindUI.new(titleText, themeName)
    local self = setmetatable({}, TailwindUI)
    self.theme = Themes[themeName] or Themes.dark
    self.activeThreads = {} -- Guarda tarefas/loops em execução para matar ao fechar
    self.sessions = {}
    
    -- ScreenGui Principal
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "TailwindAssistant"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.Parent = PlayerGui
    
    -- Janela Principal
    self.window = Instance.new("Frame")
    self.window.Size = UDim2.new(0, 520, 0, 360)
    self.window.Position = UDim2.new(0.5, -260, 0.5, -180)
    self.window.BackgroundColor3 = self.theme.bg
    self.window.BorderSizePixel = 0
    self.window.Parent = self.screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.window
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = self.theme.border
    stroke.Thickness = 1.5
    stroke.Parent = self.window
    
    -- Top Bar
    self.topBar = Instance.new("Frame")
    self.topBar.Size = UDim2.new(1, 0, 0, 42)
    self.topBar.BackgroundColor3 = self.theme.card
    self.topBar.BorderSizePixel = 0
    self.topBar.Parent = self.window
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 12)
    topCorner.Parent = self.topBar
    
    -- Ajuste para nivelar os cantos inferiores da barra superior
    local fixBar = Instance.new("Frame")
    fixBar.Size = UDim2.new(1, 0, 0, 10)
    fixBar.Position = UDim2.new(0, 0, 1, -10)
    fixBar.BackgroundColor3 = self.theme.card
    fixBar.BorderSizePixel = 0
    fixBar.Parent = self.topBar
    
    -- Título
    self.title = Instance.new("TextLabel")
    self.title.Size = UDim2.new(0, 250, 1, 0)
    self.title.Position = UDim2.new(0, 15, 0, 0)
    self.title.BackgroundTransparency = 1
    self.title.Font = Enum.Font.GothamBold
    self.title.Text = titleText or "Painel de Controle"
    self.title.TextColor3 = self.theme.text
    self.title.TextSize = 14
    self.title.TextXAlignment = Enum.TextXAlignment.Left
    self.title.Parent = self.topBar
    
    -- Controles (Minimizar / Fechar)
    self.controls = Instance.new("Frame")
    self.controls.Size = UDim2.new(0, 70, 1, 0)
    self.controls.Position = UDim2.new(1, -75, 0, 0)
    self.controls.BackgroundTransparency = 1
    self.controls.Parent = self.topBar
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = self.controls
    
    -- Botão Fechar (Vermelho)
    self.closeBtn = Instance.new("TextButton")
    self.closeBtn.Size = UDim2.new(0, 24, 0, 24)
    self.closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    self.closeBtn.Text = "✕"
    self.closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.closeBtn.TextSize = 11
    self.closeBtn.Font = Enum.Font.GothamBold
    self.closeBtn.Parent = self.controls
    
    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(1, 0)
    c1.Parent = self.closeBtn
    
    -- Botão Minimizar (Amarelo)
    self.minimizeBtn = Instance.new("TextButton")
    self.minimizeBtn.Size = UDim2.new(0, 24, 0, 24)
    self.minimizeBtn.BackgroundColor3 = Color3.fromRGB(234, 179, 8)
    self.minimizeBtn.Text = "🗕"
    self.minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.minimizeBtn.TextSize = 10
    self.minimizeBtn.Font = Enum.Font.GothamBold
    self.minimizeBtn.Parent = self.controls
    
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(1, 0)
    c2.Parent = self.minimizeBtn
    
    -- Barra Lateral de Sessões (Abas)
    self.sidebar = Instance.new("ScrollingFrame")
    self.sidebar.Size = UDim2.new(0, 130, 1, -52)
    self.sidebar.Position = UDim2.new(0, 10, 0, 48)
    self.sidebar.BackgroundTransparency = 1
    self.sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.sidebar.ScrollBarThickness = 2
    self.sidebar.Parent = self.window
    
    local sideLayout = Instance.new("UIListLayout")
    sideLayout.FillDirection = Enum.FillDirection.Vertical
    sideLayout.Padding = UDim.new(0, 6)
    sideLayout.Parent = self.sidebar
    
    -- Container do Conteúdo das Sessões
    self.contentCard = Instance.new("Frame")
    self.contentCard.Size = UDim2.new(1, -150, 1, -58)
    self.contentCard.Position = UDim2.new(0, 145, 0, 48)
    self.contentCard.BackgroundColor3 = self.theme.card
    self.contentCard.BorderSizePixel = 0
    self.contentCard.Parent = self.window
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = self.contentCard
    
    -- Animação de Minimizar
    local minimized = false
    self.minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized and UDim2.new(0, 520, 0, 42) or UDim2.new(0, 520, 0, 360)
        TweenService:Create(self.window, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        self.sidebar.Visible = not minimized
        self.contentCard.Visible = not minimized
    end)
    
    -- Animação de Fechar e Encerramento de Tarefas
    self.closeBtn.MouseButton1Click:Connect(function()
        -- Cancela e encerra todas as threads/códigos ativos registrados
        for _, thread in ipairs(self.activeThreads) do
            if coroutine.status(thread) ~= "dead" then
                task.cancel(thread)
            end
        end
        
        -- Animação de sumir
        local tw = TweenService:Create(self.window, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        tw:Play()
        task.wait(0.2)
        self.screenGui:Destroy()
    end)
    
    -- Arrastar Janela pela TopBar
    local dragging, dragInput, dragStart, startPos
    self.topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    self.topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            self.window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    return self
end

-- Adicionar Sessão (Aba)
function TailwindUI:AddSession(sessionName)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 32)
    tabBtn.BackgroundColor3 = self.theme.card
    tabBtn.TextColor3 = self.theme.subtext
    tabBtn.Text = sessionName
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 13
    tabBtn.Parent = self.sidebar
    
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 6)
    bc.Parent = tabBtn
    
    local sessionPage = Instance.new("ScrollingFrame")
    sessionPage.Size = UDim2.new(1, 0, 1, 0)
    sessionPage.BackgroundTransparency = 1
    sessionPage.Visible = false
    sessionPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    sessionPage.ScrollBarThickness = 2
    sessionPage.Parent = self.contentCard
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = sessionPage
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = sessionPage
    
    table.insert(self.sessions, {btn = tabBtn, page = sessionPage})
    
    -- Ativa a primeira aba por padrão
    if #self.sessions == 1 then
        sessionPage.Visible = true
        tabBtn.BackgroundColor3 = self.theme.accent
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    -- Alternância com Animação
    tabBtn.MouseButton1Click:Connect(function()
        for _, s in ipairs(self.sessions) do
            if s.page == sessionPage then
                s.page.Visible = true
                TweenService:Create(s.btn, TweenInfo.new(0.2), {BackgroundColor3 = self.theme.accent, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            else
                s.page.Visible = false
                TweenService:Create(s.btn, TweenInfo.new(0.2), {BackgroundColor3 = self.theme.card, TextColor3 = self.theme.subtext}):Play()
            end
        end
    end)
    
    local builder = {}
    
    -- Adicionar Botão de Toggle (Vermelho para Verde animado)
    function builder:AddToggle(text, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.92, 0, 0, 40)
        frame.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
        frame.Parent = sessionPage
        
        local fc = Instance.new("UICorner")
        fc.CornerRadius = UDim.new(0, 6)
        fc.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Gotham
        label.Text = text
        label.TextColor3 = Color3.fromRGB(240, 240, 240)
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 44, 0, 22)
        toggleBtn.Position = UDim2.new(1, -54, 0.5, -11)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68) -- Vermelho OFF
        toggleBtn.Text = ""
        toggleBtn.Parent = frame
        
        local tc = Instance.new("UICorner")
        tc.CornerRadius = UDim.new(1, 0)
        tc.Parent = toggleBtn
        
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 16, 0, 16)
        circle.Position = UDim2.new(0, 3, 0.5, -8)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.Parent = toggleBtn
        
        local cc = Instance.new("UICorner")
        cc.CornerRadius = UDim.new(1, 0)
        cc.Parent = circle
        
        local toggled = false
        toggleBtn.MouseButton1Click:Connect(function()
            toggled = not toggled
            local targetColor = toggled and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(239, 68, 68) -- Verde ON / Vermelho OFF
            local targetPos = toggled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            
            TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
            
            if callback then callback(toggled) end
        end)
    end
    
    -- Adicionar Botão de Ação Comum
    function builder:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.92, 0, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
        btn.Font = Enum.Font.GothamMedium
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Parent = sessionPage
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            if callback then
                -- Executa e registra a thread para poder ser cancelada ao fechar o painel
                local thread = task.spawn(callback)
                -- Se necessário, podemos adicionar na tabela pai: table.insert(self.activeThreads, thread)
            end
        end)
    end
    
    return builder
end

return TailwindUI
