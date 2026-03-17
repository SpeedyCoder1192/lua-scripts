-- SpeedyCoder1192 // TeleportBehind
-- Toggle: LeftAlt (customizable)

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local TweenService     = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

-- =============================================
-- CONFIG
-- =============================================
local VALID_KEY     = "luascriptez:D"
local MAX_ATTEMPTS  = 5
local TOGGLE_KEY    = Enum.KeyCode.LeftAlt
local TELEPORT_KEY  = Enum.KeyCode.Q
local BEHIND_OFFSET = 3
-- =============================================

local attempts      = 0
local unlocked      = false
local teleportCD    = 0
local listeningFor  = nil
local guiVisible    = true
local shownHideHint = false

local C = {
    bg       = Color3.fromRGB(10,  12,  16),
    surface  = Color3.fromRGB(16,  20,  28),
    header   = Color3.fromRGB(13,  17,  23),
    border   = Color3.fromRGB(35,  45,  60),
    accent   = Color3.fromRGB(88,  166, 255),
    green    = Color3.fromRGB(63,  185, 80),
    yellow   = Color3.fromRGB(210, 170, 50),
    red      = Color3.fromRGB(220, 80,  80),
    textPri  = Color3.fromRGB(230, 237, 243),
    textSec  = Color3.fromRGB(110, 130, 155),
    textMono = Color3.fromRGB(165, 214, 255),
    btnBg    = Color3.fromRGB(22,  30,  44),
    inputBg  = Color3.fromRGB(13,  17,  23),
}

-- ============ SCREEN GUI ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SCA1192_Teleport"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ================================================================
--  KEY SYSTEM
-- ================================================================

local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlay.BackgroundTransparency = 0.45
overlay.BorderSizePixel = 0
overlay.ZIndex = 10
overlay.Parent = screenGui

local keyPanel = Instance.new("Frame")
keyPanel.Size = UDim2.new(0, 320, 0, 280)
keyPanel.Position = UDim2.new(0.5, -160, 0.5, -140)
keyPanel.BackgroundColor3 = C.bg
keyPanel.BorderSizePixel = 0
keyPanel.ClipsDescendants = true
keyPanel.ZIndex = 11
keyPanel.Parent = screenGui
Instance.new("UICorner", keyPanel).CornerRadius = UDim.new(0, 8)
local kpStroke = Instance.new("UIStroke", keyPanel)
kpStroke.Color = C.border
kpStroke.Thickness = 1

-- Key panel header
local kpHeader = Instance.new("Frame")
kpHeader.Size = UDim2.new(1, 0, 0, 44)
kpHeader.BackgroundColor3 = C.header
kpHeader.BorderSizePixel = 0
kpHeader.ZIndex = 11
kpHeader.Parent = keyPanel
Instance.new("UICorner", kpHeader).CornerRadius = UDim.new(0, 8)
local kpHeaderFix = Instance.new("Frame")
kpHeaderFix.Size = UDim2.new(1, 0, 0, 8)
kpHeaderFix.Position = UDim2.new(0, 0, 1, -8)
kpHeaderFix.BackgroundColor3 = C.header
kpHeaderFix.BorderSizePixel = 0
kpHeaderFix.ZIndex = 11
kpHeaderFix.Parent = kpHeader
local kpHeaderBorder = Instance.new("Frame")
kpHeaderBorder.Size = UDim2.new(1, 0, 0, 1)
kpHeaderBorder.Position = UDim2.new(0, 0, 1, -1)
kpHeaderBorder.BackgroundColor3 = C.border
kpHeaderBorder.BorderSizePixel = 0
kpHeaderBorder.ZIndex = 11
kpHeaderBorder.Parent = kpHeader

local function makeKpDot(color, xOff)
    local d = Instance.new("Frame")
    d.Size = UDim2.new(0, 10, 0, 10)
    d.Position = UDim2.new(0, xOff, 0.5, -5)
    d.BackgroundColor3 = color
    d.BorderSizePixel = 0
    d.ZIndex = 12
    d.Parent = kpHeader
    Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
end
makeKpDot(Color3.fromRGB(255, 95,  87),  12)
makeKpDot(Color3.fromRGB(255, 189, 46),  26)
makeKpDot(Color3.fromRGB(40,  200, 64),  40)

local kpTitle = Instance.new("TextLabel")
kpTitle.Size = UDim2.new(1, -60, 1, 0)
kpTitle.Position = UDim2.new(0, 58, 0, 0)
kpTitle.BackgroundTransparency = 1
kpTitle.Text = "SCA1192  //  key system"
kpTitle.TextColor3 = C.textSec
kpTitle.TextSize = 11
kpTitle.Font = Enum.Font.Code
kpTitle.ZIndex = 12
kpTitle.Parent = kpHeader

-- Body labels
local function kpLabel(text, y, size, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -24, 0, 18)
    l.Position = UDim2.new(0, 12, 0, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or C.textSec
    l.TextSize = size or 11
    l.Font = Enum.Font.Code
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 12
    l.Parent = keyPanel
    return l
end

kpLabel("SpeedyCoder1192  //  Teleport", 56, 14, C.textMono)
kpLabel("-- enter your key to continue",  78, 11, C.textSec)

local kpDivider = Instance.new("Frame")
kpDivider.Size = UDim2.new(1, -24, 0, 1)
kpDivider.Position = UDim2.new(0, 12, 0, 104)
kpDivider.BackgroundColor3 = C.border
kpDivider.BorderSizePixel = 0
kpDivider.ZIndex = 12
kpDivider.Parent = keyPanel

kpLabel("key", 112, 11, C.textSec)

-- Input frame
local inputFrame = Instance.new("Frame")
inputFrame.Size = UDim2.new(1, -24, 0, 36)
inputFrame.Position = UDim2.new(0, 12, 0, 130)
inputFrame.BackgroundColor3 = C.inputBg
inputFrame.BorderSizePixel = 0
inputFrame.ZIndex = 12
inputFrame.Parent = keyPanel
Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 5)
local inputStroke = Instance.new("UIStroke", inputFrame)
inputStroke.Color = C.border
inputStroke.Thickness = 1

local inputPrefix = Instance.new("TextLabel")
inputPrefix.Size = UDim2.new(0, 20, 1, 0)
inputPrefix.Position = UDim2.new(0, 8, 0, 0)
inputPrefix.BackgroundTransparency = 1
inputPrefix.Text = ">"
inputPrefix.TextColor3 = C.accent
inputPrefix.TextSize = 13
inputPrefix.Font = Enum.Font.Code
inputPrefix.ZIndex = 13
inputPrefix.Parent = inputFrame

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -36, 1, 0)
inputBox.Position = UDim2.new(0, 28, 0, 0)
inputBox.BackgroundTransparency = 1
inputBox.Text = ""
inputBox.PlaceholderText = "enter key here..."
inputBox.PlaceholderColor3 = Color3.fromRGB(55, 65, 80)
inputBox.TextColor3 = C.textMono
inputBox.TextSize = 13
inputBox.Font = Enum.Font.Code
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.ClearTextOnFocus = true
inputBox.ZIndex = 14
inputBox.Parent = inputFrame

-- Status bar
local kpStatusFrame = Instance.new("Frame")
kpStatusFrame.Size = UDim2.new(1, -24, 0, 28)
kpStatusFrame.Position = UDim2.new(0, 12, 0, 176)
kpStatusFrame.BackgroundColor3 = C.surface
kpStatusFrame.BorderSizePixel = 0
kpStatusFrame.ZIndex = 12
kpStatusFrame.Parent = keyPanel
Instance.new("UICorner", kpStatusFrame).CornerRadius = UDim.new(0, 5)
Instance.new("UIStroke", kpStatusFrame).Color = C.border

local kpStatusPrefix = Instance.new("TextLabel")
kpStatusPrefix.Size = UDim2.new(0, 20, 1, 0)
kpStatusPrefix.Position = UDim2.new(0, 8, 0, 0)
kpStatusPrefix.BackgroundTransparency = 1
kpStatusPrefix.Text = ">"
kpStatusPrefix.TextColor3 = C.accent
kpStatusPrefix.TextSize = 12
kpStatusPrefix.Font = Enum.Font.Code
kpStatusPrefix.ZIndex = 13
kpStatusPrefix.Parent = kpStatusFrame

local kpStatusTxt = Instance.new("TextLabel")
kpStatusTxt.Size = UDim2.new(1, -32, 1, 0)
kpStatusTxt.Position = UDim2.new(0, 28, 0, 0)
kpStatusTxt.BackgroundTransparency = 1
kpStatusTxt.Text = "awaiting key..."
kpStatusTxt.TextColor3 = C.textSec
kpStatusTxt.TextSize = 12
kpStatusTxt.Font = Enum.Font.Code
kpStatusTxt.TextXAlignment = Enum.TextXAlignment.Left
kpStatusTxt.ZIndex = 13
kpStatusTxt.Parent = kpStatusFrame

local attemptsLbl = kpLabel("-- attempts remaining: " .. MAX_ATTEMPTS, 214, 10, C.textSec)

-- Submit button
local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(1, -24, 0, 36)
submitBtn.Position = UDim2.new(0, 12, 0, 232)
submitBtn.BackgroundColor3 = C.btnBg
submitBtn.BorderSizePixel = 0
submitBtn.Text = "unlock  -->"
submitBtn.TextColor3 = C.textMono
submitBtn.TextSize = 13
submitBtn.Font = Enum.Font.Code
submitBtn.ZIndex = 12
submitBtn.Parent = keyPanel
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 5)
local submitStroke = Instance.new("UIStroke", submitBtn)
submitStroke.Color = C.border
submitStroke.Thickness = 1

-- Key system logic
local function flashInput(color)
    inputStroke.Color = color
    task.delay(0.4, function()
        TweenService:Create(inputStroke, TweenInfo.new(0.4), { Color = C.border }):Play()
    end)
end

local function lockOut()
    inputBox.TextEditable = false
    submitBtn.Active = false
    submitBtn.Text = "-- locked out"
    submitBtn.TextColor3 = C.red
    inputStroke.Color = C.red
    kpStatusTxt.Text = "too many attempts. rejoin."
    kpStatusTxt.TextColor3 = C.red
    attemptsLbl.Text = "-- attempts remaining: 0"
    attemptsLbl.TextColor3 = C.red
end

local mainPanel  -- forward declare, built after key success
local function buildMainGui() end  -- forward declare

local function onKeySuccess()
    unlocked = true
    inputStroke.Color = C.green
    submitStroke.Color = C.green
    kpStatusTxt.Text = "key accepted. loading..."
    kpStatusTxt.TextColor3 = C.green
    attemptsLbl.Text = "-- welcome, " .. localPlayer.Name
    attemptsLbl.TextColor3 = C.green
    submitBtn.Text = "✓  unlocked"
    submitBtn.TextColor3 = C.green

    task.delay(1.2, function()
        TweenService:Create(keyPanel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, -160, 0.5, -180),
            Size     = UDim2.new(0, 320, 0, 0),
        }):Play()
        TweenService:Create(overlay, TweenInfo.new(0.4), {
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.45, function()
            keyPanel:Destroy()
            overlay:Destroy()
            screenGui.DisplayOrder = 1
            buildMainGui()  -- now build the real GUI
        end)
    end)
end

local function onKeyFail()
    attempts += 1
    local remaining = MAX_ATTEMPTS - attempts
    attemptsLbl.Text = "-- attempts remaining: " .. remaining
    attemptsLbl.TextColor3 = remaining <= 2 and C.red or C.yellow
    flashInput(C.red)
    kpStatusTxt.Text = "invalid key. " .. remaining .. " attempt" .. (remaining == 1 and "" or "s") .. " left."
    kpStatusTxt.TextColor3 = C.red

    local origPos = keyPanel.Position
    for i = 1, 4 do
        task.delay(i * 0.05, function()
            local dir = (i % 2 == 0) and 6 or -6
            TweenService:Create(keyPanel, TweenInfo.new(0.05), {
                Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + dir, origPos.Y.Scale, origPos.Y.Offset)
            }):Play()
        end)
    end
    task.delay(0.28, function()
        TweenService:Create(keyPanel, TweenInfo.new(0.1), { Position = origPos }):Play()
    end)

    if attempts >= MAX_ATTEMPTS then lockOut() end
    inputBox.Text = ""
end

local function trySubmit()
    if unlocked or attempts >= MAX_ATTEMPTS then return end
    if inputBox.Text == VALID_KEY then
        onKeySuccess()
    else
        onKeyFail()
    end
end

submitBtn.MouseButton1Click:Connect(trySubmit)
inputBox.FocusLost:Connect(function(enter) if enter then trySubmit() end end)
inputBox.Focused:Connect(function()
    TweenService:Create(inputStroke, TweenInfo.new(0.2), { Color = C.accent }):Play()
end)
inputBox.FocusLost:Connect(function()
    if not unlocked then
        TweenService:Create(inputStroke, TweenInfo.new(0.2), { Color = C.border }):Play()
    end
end)

-- ================================================================
--  MAIN GUI (built only after key accepted)
-- ================================================================

buildMainGui = function()

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 260, 0, 250)
    panel.Position = UDim2.new(0, 16, 0.5, -125)
    panel.BackgroundColor3 = C.bg
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = screenGui
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 8)
    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color = C.border
    panelStroke.Thickness = 1

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 44)
    header.BackgroundColor3 = C.header
    header.BorderSizePixel = 0
    header.Parent = panel
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 8)
    headerFix.Position = UDim2.new(0, 0, 1, -8)
    headerFix.BackgroundColor3 = C.header
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header
    local headerBorder = Instance.new("Frame")
    headerBorder.Size = UDim2.new(1, 0, 0, 1)
    headerBorder.Position = UDim2.new(0, 0, 1, -1)
    headerBorder.BackgroundColor3 = C.border
    headerBorder.BorderSizePixel = 0
    headerBorder.Parent = header

    local function makeDot(color, xOff)
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0, 10, 0, 10)
        d.Position = UDim2.new(0, xOff, 0.5, -5)
        d.BackgroundColor3 = color
        d.BorderSizePixel = 0
        d.Parent = header
        Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
    end
    makeDot(Color3.fromRGB(255, 95,  87),  12)
    makeDot(Color3.fromRGB(255, 189, 46),  26)
    makeDot(Color3.fromRGB(40,  200, 64),  40)

    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, -60, 1, 0)
    headerTitle.Position = UDim2.new(0, 58, 0, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "SCA1192  //  teleport"
    headerTitle.TextColor3 = C.textSec
    headerTitle.TextSize = 11
    headerTitle.Font = Enum.Font.Code
    headerTitle.Parent = header

    -- Helpers
    local function makeLabel(parent, text, yPos)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -24, 0, 16)
        lbl.Position = UDim2.new(0, 12, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = C.textSec
        lbl.TextSize = 11
        lbl.Font = Enum.Font.Code
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = parent
        return lbl
    end

    local function makeStatusBar(parent, yPos)
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -24, 0, 28)
        bar.Position = UDim2.new(0, 12, 0, yPos)
        bar.BackgroundColor3 = C.surface
        bar.BorderSizePixel = 0
        bar.Parent = parent
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 5)
        local s = Instance.new("UIStroke", bar)
        s.Color = C.border
        s.Thickness = 1
        local prefix = Instance.new("TextLabel")
        prefix.Size = UDim2.new(0, 20, 1, 0)
        prefix.Position = UDim2.new(0, 8, 0, 0)
        prefix.BackgroundTransparency = 1
        prefix.Text = ">"
        prefix.TextColor3 = C.accent
        prefix.TextSize = 12
        prefix.Font = Enum.Font.Code
        prefix.Parent = bar
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, -32, 1, 0)
        txt.Position = UDim2.new(0, 28, 0, 0)
        txt.BackgroundTransparency = 1
        txt.Text = "ready"
        txt.TextColor3 = C.green
        txt.TextSize = 12
        txt.Font = Enum.Font.Code
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Parent = bar
        return txt
    end

    local function makeKeybindBtn(parent, key, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -24, 0, 32)
        btn.Position = UDim2.new(0, 12, 0, yPos)
        btn.BackgroundColor3 = C.btnBg
        btn.BorderSizePixel = 0
        btn.Text = "[ " .. key.Name .. " ]"
        btn.TextColor3 = C.textMono
        btn.TextSize = 13
        btn.Font = Enum.Font.Code
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        local s = Instance.new("UIStroke", btn)
        s.Color = C.border
        s.Thickness = 1
        return btn
    end

    local function makeNumRow(parent, labelText, value, yPos, minVal, maxVal, step)
        makeLabel(parent, labelText, yPos)
        local minus = Instance.new("TextButton")
        minus.Size = UDim2.new(0, 26, 0, 26)
        minus.Position = UDim2.new(1, -90, 0, yPos - 5)
        minus.BackgroundColor3 = C.btnBg
        minus.BorderSizePixel = 0
        minus.Text = "-"
        minus.TextColor3 = C.textMono
        minus.TextSize = 14
        minus.Font = Enum.Font.Code
        minus.Parent = parent
        Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 4)
        Instance.new("UIStroke", minus).Color = C.border
        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0, 36, 0, 26)
        valLbl.Position = UDim2.new(1, -62, 0, yPos - 5)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(value)
        valLbl.TextColor3 = C.accent
        valLbl.TextSize = 12
        valLbl.Font = Enum.Font.Code
        valLbl.TextXAlignment = Enum.TextXAlignment.Center
        valLbl.Parent = parent
        local plus = Instance.new("TextButton")
        plus.Size = UDim2.new(0, 26, 0, 26)
        plus.Position = UDim2.new(1, -30, 0, yPos - 5)
        plus.BackgroundColor3 = C.btnBg
        plus.BorderSizePixel = 0
        plus.Text = "+"
        plus.TextColor3 = C.textMono
        plus.TextSize = 14
        plus.Font = Enum.Font.Code
        plus.Parent = parent
        Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 4)
        Instance.new("UIStroke", plus).Color = C.border
        local current = value
        minus.MouseButton1Click:Connect(function()
            current = math.max(current - step, minVal)
            valLbl.Text = tostring(current)
        end)
        plus.MouseButton1Click:Connect(function()
            current = math.min(current + step, maxVal)
            valLbl.Text = tostring(current)
        end)
        return function() return current end
    end

    -- Build content
    local statusTxt = makeStatusBar(panel, 52)
    makeLabel(panel, "keybind  //  teleport", 92)
    local tpKeyBtn  = makeKeybindBtn(panel, TELEPORT_KEY, 108)
    local getOffset = makeNumRow(panel, "offset (studs)", BEHIND_OFFSET, 152, 1, 20, 1)
    makeLabel(panel, "toggle  //  gui", 194)
    local toggleKeyBtn = makeKeybindBtn(panel, TOGGLE_KEY, 210)

    local footer = Instance.new("TextLabel")
    footer.Size = UDim2.new(1, -24, 0, 14)
    footer.Position = UDim2.new(0, 12, 1, -18)
    footer.BackgroundTransparency = 1
    footer.Text = "-- click any keybind button to rebind"
    footer.TextColor3 = C.border
    footer.TextSize = 10
    footer.Font = Enum.Font.Code
    footer.TextXAlignment = Enum.TextXAlignment.Left
    footer.Parent = panel

    -- Drag
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = panel.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- GUI toggle
    local function setVisible(v)
        panel.Visible = v
        guiVisible = v
        if not v and not shownHideHint then
            shownHideHint = true
            pcall(function()
                StarterGui:SetCore("SendNotification", {
                    Title    = "Teleport GUI Hidden",
                    Text     = "Press " .. TOGGLE_KEY.Name .. " to reopen.",
                    Duration = 5,
                })
            end)
        end
    end

    -- Rebind
    local function startRebind(slot, btn)
        if listeningFor then return end
        listeningFor = slot
        btn.Text = "[ press any key... ]"
        btn.TextColor3 = C.yellow
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            local name = input.KeyCode.Name
            if slot == "teleport" then
                TELEPORT_KEY = input.KeyCode
                statusTxt.Text = "tp key → " .. name
            elseif slot == "toggle" then
                TOGGLE_KEY = input.KeyCode
                statusTxt.Text = "toggle → " .. name
            end
            btn.Text = "[ " .. name .. " ]"
            btn.TextColor3 = C.textMono
            statusTxt.TextColor3 = C.green
            listeningFor = nil
            conn:Disconnect()
        end)
    end

    tpKeyBtn.MouseButton1Click:Connect(function()    startRebind("teleport", tpKeyBtn)    end)
    toggleKeyBtn.MouseButton1Click:Connect(function() startRebind("toggle",  toggleKeyBtn) end)

    -- Teleport logic
    local function getRandomOtherPlayer()
        local others = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= localPlayer then table.insert(others, p) end
        end
        if #others == 0 then return nil end
        return others[math.random(1, #others)]
    end

    local function teleport()
        local now = tick()
        if now - teleportCD < 0.5 then return end
        teleportCD = now
        local myChar = localPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local target = getRandomOtherPlayer()
        if not target then
            statusTxt.Text = "no players found"
            statusTxt.TextColor3 = C.red
            return
        end
        local tRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if not tRoot then
            statusTxt.Text = "target unavailable"
            statusTxt.TextColor3 = C.yellow
            return
        end
        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, getOffset())
        statusTxt.Text = "→ " .. target.Name
        statusTxt.TextColor3 = C.green
    end

    -- Input handler
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == TOGGLE_KEY then
            setVisible(not guiVisible)
            return
        end
        if gameProcessed or listeningFor then return end
        if input.KeyCode == TELEPORT_KEY then teleport() end
    end)

    print("Teleport ready | toggle=" .. TOGGLE_KEY.Name .. " | tp=" .. TELEPORT_KEY.Name)
end

print("Teleport loaded | awaiting key...")
