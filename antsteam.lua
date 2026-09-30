-- ================================================================
--  ANTS TEAM CHEAT | STEAL AN EGG
--  Anti-Hit | Egg ESP | Player ESP | Rank ESP | Speed Anti-Detect
--  Delta Executor Compatible
-- ================================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================================================================
-- STATE
-- ================================================================
local S = {
    AntiHit      = false,
    EggESP       = false,
    PlayerESP    = false,
    RankESP      = false,
    SpeedHack    = false,
    InfJump      = false,
    AutoSteal    = false,
    Visible      = true,
    BaseSpeed    = 16,
    TargetSpeed  = 24,
    SpeedStep    = 0,
}

-- ================================================================
-- UTIL
-- ================================================================
local function GetChar()  return LP.Character or LP.CharacterAdded:Wait() end
local function GetHRP()   local c=GetChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum()   local c=GetChar() return c and c:FindFirstChildOfClass("Humanoid") end

local function GetMoney()
    local ls = LP:FindFirstChild("leaderstats") or LP:FindFirstChild("PlayerData")
    if ls then
        for _, n in ipairs({"Money","Cash","Coins","Gold","Gems","Eggs","Score"}) do
            local v = ls:FindFirstChild(n)
            if v then return v.Value, n end
        end
    end
    return 0, "Money"
end

local function GetRank()
    local ls = LP:FindFirstChild("leaderstats") or LP:FindFirstChild("PlayerData")
    if ls then
        for _, n in ipairs({"Rank","Level","Stage","Prestige","Tier"}) do
            local v = ls:FindFirstChild(n)
            if v then return tostring(v.Value), n end
        end
    end
    return "?", "Rank"
end

local function GetPlayerRank(plr)
    local ls = plr:FindFirstChild("leaderstats") or plr:FindFirstChild("PlayerData")
    if ls then
        for _, n in ipairs({"Rank","Level","Stage","Prestige","Tier","Money","Cash","Coins"}) do
            local v = ls:FindFirstChild(n)
            if v then return n..": "..tostring(v.Value) end
        end
    end
    return "Rank: ?"
end

local function WorldToViewport(pos)
    local vp, vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(vp.X, vp.Y), vis, vp.Z
end

local function IsOnScreen(pos)
    local _, vis, depth = WorldToViewport(pos)
    return vis and depth > 0
end

-- ================================================================
-- CLEANUP OLD GUI
-- ================================================================
pcall(function()
    local target = gethui and gethui() or LP.PlayerGui
    local old = target:FindFirstChild("ANTS_TEAM_GUI")
    if old then old:Destroy() end
end)

-- ================================================================
-- SCREEN GUI
-- ================================================================
local SG = Instance.new("ScreenGui")
SG.Name            = "ANTS_TEAM_GUI"
SG.ResetOnSpawn    = false
SG.DisplayOrder    = 999
SG.IgnoreGuiInset  = true
SG.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
pcall(function()
    SG.Parent = gethui and gethui() or LP.PlayerGui
end)
if not SG.Parent then SG.Parent = LP.PlayerGui end

-- ================================================================
-- MAIN FRAME
-- ================================================================
local MF = Instance.new("Frame", SG)
MF.Name             = "MainFrame"
MF.Size             = UDim2.new(0, 320, 0, 440)
MF.Position         = UDim2.new(0, 20, 0.5, -220)
MF.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
MF.BorderSizePixel  = 0
MF.Active           = true
MF.Draggable        = true
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 12)

-- Glow stroke
local Stroke = Instance.new("UIStroke", MF)
Stroke.Color       = Color3.fromRGB(255, 50, 50)
Stroke.Thickness   = 1.8
Stroke.Transparency = 0.15

-- Subtle gradient
local Grad = Instance.new("UIGradient", MF)
Grad.Color    = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(18, 18, 26)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(10, 10, 16)),
})
Grad.Rotation = 90

-- ================================================================
-- TITLE BAR
-- ================================================================
local TB = Instance.new("Frame", MF)
TB.Name             = "TitleBar"
TB.Size             = UDim2.new(1, 0, 0, 42)
TB.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TB.BorderSizePixel  = 0
Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 12)

-- Logo dot
local Dot = Instance.new("Frame", TB)
Dot.Size              = UDim2.new(0, 10, 0, 10)
Dot.Position          = UDim2.new(0, 14, 0.5, -5)
Dot.BackgroundColor3  = Color3.fromRGB(255, 50, 50)
Dot.BorderSizePixel   = 0
Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

-- Pulse dot animation
local dotTween = TweenService:Create(Dot,
    TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {BackgroundColor3 = Color3.fromRGB(255, 130, 130)}
)
dotTween:Play()

local TitleLbl = Instance.new("TextLabel", TB)
TitleLbl.Size               = UDim2.new(1, -90, 1, 0)
TitleLbl.Position           = UDim2.new(0, 30, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text               = "🐜  ANTS TEAM"
TitleLbl.TextColor3         = Color3.fromRGB(255, 255, 255)
TitleLbl.TextSize           = 15
TitleLbl.Font               = Enum.Font.GothamBold
TitleLbl.TextXAlignment     = Enum.TextXAlignment.Left

local SubLbl = Instance.new("TextLabel", TB)
SubLbl.Size               = UDim2.new(1, -90, 0, 12)
SubLbl.Position           = UDim2.new(0, 30, 1, -13)
SubLbl.BackgroundTransparency = 1
SubLbl.Text               = "Steal An Egg  •  v2.4"
SubLbl.TextColor3         = Color3.fromRGB(255, 80, 80)
SubLbl.TextSize           = 9
SubLbl.Font               = Enum.Font.Gotham
SubLbl.TextXAlignment     = Enum.TextXAlignment.Left

-- Minimize
local MinBtn = Instance.new("TextButton", TB)
MinBtn.Size             = UDim2.new(0, 26, 0, 20)
MinBtn.Position         = UDim2.new(1, -58, 0.5, -10)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
MinBtn.Text             = "–"
MinBtn.TextColor3       = Color3.fromRGB(200, 200, 200)
MinBtn.TextSize         = 15
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.BorderSizePixel  = 0
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Close
local CloseBtn = Instance.new("TextButton", TB)
CloseBtn.Size             = UDim2.new(0, 26, 0, 20)
CloseBtn.Position         = UDim2.new(1, -28, 0.5, -10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize         = 12
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- ================================================================
-- TAB BAR
-- ================================================================
local TabBar = Instance.new("Frame", MF)
TabBar.Name             = "TabBar"
TabBar.Size             = UDim2.new(1, -20, 0, 28)
TabBar.Position         = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TabBar.BorderSizePixel  = 0
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection       = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
TabLayout.Padding             = UDim.new(0, 4)

-- ================================================================
-- CONTENT SCROLL
-- ================================================================
local Content = Instance.new("Frame", MF)
Content.Name              = "Content"
Content.Size              = UDim2.new(1, -20, 1, -90)
Content.Position          = UDim2.new(0, 10, 0, 82)
Content.BackgroundTransparency = 1
Content.ClipsDescendants  = true

-- ================================================================
-- TAB SYSTEM
-- ================================================================
local Pages      = {}
local TabBtns    = {}
local ActivePage = nil

local function NewPage(name)
    local sf = Instance.new("ScrollingFrame", Content)
    sf.Name                  = name
    sf.Size                  = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel       = 0
    sf.ScrollBarThickness    = 2
    sf.ScrollBarImageColor3  = Color3.fromRGB(255, 60, 60)
    sf.CanvasSize            = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    sf.Visible               = false

    local ll = Instance.new("UIListLayout", sf)
    ll.Padding             = UDim.new(0, 5)
    ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ll.SortOrder           = Enum.SortOrder.LayoutOrder

    local pad = Instance.new("UIPadding", sf)
    pad.PaddingTop    = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)

    Pages[name] = sf
    return sf
end

local function SwitchTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(TabBtns) do
        if n == name then
            TweenService:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(220, 45, 45),
                TextColor3       = Color3.fromRGB(255, 255, 255),
            }):Play()
        else
            TweenService:Create(b, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(28, 28, 38),
                TextColor3       = Color3.fromRGB(140, 140, 160),
            }):Play()
        end
    end
    ActivePage = name
end

local function NewTabBtn(name, icon, label)
    local btn = Instance.new("TextButton", TabBar)
    btn.Name             = name
    btn.Size             = UDim2.new(0, 72, 0, 20)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    btn.Text             = icon.." "..label
    btn.TextColor3       = Color3.fromRGB(140, 140, 160)
    btn.TextSize         = 10
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabBtns[name] = btn
    return btn
end

-- ================================================================
-- WIDGET BUILDERS
-- ================================================================
local function Divider(parent, order)
    local f = Instance.new("Frame", parent)
    f.Size              = UDim2.new(1, -10, 0, 1)
    f.BackgroundColor3  = Color3.fromRGB(255, 50, 50)
    f.BackgroundTransparency = 0.75
    f.BorderSizePixel   = 0
    f.LayoutOrder       = order
    return f
end

local function SectionHead(parent, text, order)
    local lbl = Instance.new("TextLabel", parent)
    lbl.Size              = UDim2.new(1, -10, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text              = "  ◈ "..text
    lbl.TextColor3        = Color3.fromRGB(255, 80, 80)
    lbl.TextSize          = 10
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextXAlignment    = Enum.TextXAlignment.Left
    lbl.LayoutOrder       = order
    return lbl
end

-- Toggle returns {button, getValue}
local function NewToggle(parent, icon, labelText, order, cb)
    local row = Instance.new("Frame", parent)
    row.Size              = UDim2.new(1, -10, 0, 36)
    row.BackgroundColor3  = Color3.fromRGB(18, 18, 26)
    row.BorderSizePixel   = 0
    row.LayoutOrder       = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local iconL = Instance.new("TextLabel", row)
    iconL.Size              = UDim2.new(0, 24, 1, 0)
    iconL.Position          = UDim2.new(0, 8, 0, 0)
    iconL.BackgroundTransparency = 1
    iconL.Text              = icon
    iconL.TextColor3        = Color3.fromRGB(255, 255, 255)
    iconL.TextSize          = 14

    local lbl = Instance.new("TextLabel", row)
    lbl.Size              = UDim2.new(1, -90, 1, 0)
    lbl.Position          = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = labelText
    lbl.TextColor3        = Color3.fromRGB(200, 200, 210)
    lbl.TextSize          = 11
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left

    -- Pill toggle
    local pill = Instance.new("Frame", row)
    pill.Size             = UDim2.new(0, 42, 0, 20)
    pill.Position         = UDim2.new(1, -52, 0.5, -10)
    pill.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    pill.BorderSizePixel  = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(120, 120, 140)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local on = false

    local hitbox = Instance.new("TextButton", row)
    hitbox.Size               = UDim2.new(1, 0, 1, 0)
    hitbox.BackgroundTransparency = 1
    hitbox.Text               = ""
    hitbox.ZIndex             = 5

    hitbox.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(pill, TweenInfo.new(0.18), {
                BackgroundColor3 = Color3.fromRGB(220, 45, 45)
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.18), {
                Position         = UDim2.new(1, -17, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            }):Play()
        else
            TweenService:Create(pill, TweenInfo.new(0.18), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.18), {
                Position         = UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(120, 120, 140),
            }):Play()
        end
        cb(on)
    end)

    return row, function() return on end
end

-- Stat row (label + live value)
local ValueLabels = {}
local function NewStatRow(parent, icon, labelText, order)
    local row = Instance.new("Frame", parent)
    row.Size              = UDim2.new(1, -10, 0, 32)
    row.BackgroundColor3  = Color3.fromRGB(18, 18, 26)
    row.BorderSizePixel   = 0
    row.LayoutOrder       = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local iconL = Instance.new("TextLabel", row)
    iconL.Size              = UDim2.new(0, 24, 1, 0)
    iconL.Position          = UDim2.new(0, 8, 0, 0)
    iconL.BackgroundTransparency = 1
    iconL.Text              = icon
    iconL.TextSize          = 13

    local lbl = Instance.new("TextLabel", row)
    lbl.Size              = UDim2.new(0.5, 0, 1, 0)
    lbl.Position          = UDim2.new(0, 36, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = labelText
    lbl.TextColor3        = Color3.fromRGB(150, 150, 170)
    lbl.TextSize          = 10
    lbl.Font              = Enum.Font.Gotham
    lbl.TextXAlignment    = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", row)
    val.Size              = UDim2.new(0.5, -12, 1, 0)
    val.Position          = UDim2.new(0.5, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text              = "..."
    val.TextColor3        = Color3.fromRGB(255, 160, 60)
    val.TextSize          = 11
    val.Font              = Enum.Font.GothamBold
    val.TextXAlignment    = Enum.TextXAlignment.Right

    local pad = Instance.new("UIPadding", val)
    pad.PaddingRight = UDim.new(0, 10)

    ValueLabels[labelText] = val
    return val
end

-- ================================================================
-- BUILD PAGES
-- ================================================================
NewTabBtn("Combat",  "⚔",  "Combat")
NewTabBtn("ESP",     "👁",  "ESP")
NewTabBtn("Stats",   "📊",  "Stats")

local PCombat = NewPage("Combat")
local PESP    = NewPage("ESP")
local PStats  = NewPage("Stats")

-- ── COMBAT ──────────────────────────────────────────────────
SectionHead(PCombat, "ANTI HIT", 1)

NewToggle(PCombat, "🛡", "Anti-Hit (Godmode)", 2, function(on)
    S.AntiHit = on
    RunService:UnbindFromRenderStep("AntiHit")
    if on then
        RunService:BindToRenderStep("AntiHit", 200, function()
            local h = GetHum()
            if h and h.Health < h.MaxHealth then
                h.Health = h.MaxHealth
            end
        end)
    else
        local h = GetHum()
        if h then h.Health = h.MaxHealth end
    end
end)

Divider(PCombat, 3)
SectionHead(PCombat, "MOVEMENT", 4)

NewToggle(PCombat, "⚡", "Speed Anti-Detect", 5, function(on)
    S.SpeedHack = on
    RunService:UnbindFromRenderStep("SpeedRamp")
    if on then
        S.SpeedStep = 0
        -- Ramp speed gradually to avoid kick detection
        RunService:BindToRenderStep("SpeedRamp", 100, function()
            local h = GetHum()
            if not h then return end
            if S.SpeedHack then
                if S.SpeedStep < S.TargetSpeed then
                    S.SpeedStep = math.min(S.SpeedStep + 0.3, S.TargetSpeed)
                    h.WalkSpeed = S.SpeedStep
                end
                -- Randomize ±0.5 each frame to break pattern detection
                h.WalkSpeed = S.SpeedStep + (math.random() - 0.5) * 0.4
            end
        end)
    else
        local h = GetHum()
        if h then h.WalkSpeed = S.BaseSpeed end
        S.SpeedStep = 0
    end
end)

NewToggle(PCombat, "🚫", "No-Clip", 6, function(on)
    S.NoClip = on
    RunService:UnbindFromRenderStep("NoClip")
    if on then
        RunService:BindToRenderStep("NoClip", 200, function()
            local c = GetChar()
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end
end)

NewToggle(PCombat, "🌙", "Infinite Jump", 7, function(on)
    S.InfJump = on
end)

-- Infinite jump hook (runs once)
UserInputService.JumpRequest:Connect(function()
    if S.InfJump then
        local h = GetHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Divider(PCombat, 8)
SectionHead(PCombat, "EGG STEAL", 9)

NewToggle(PCombat, "🥚", "Auto Steal Nearest Egg", 10, function(on)
    S.AutoSteal = on
    RunService:UnbindFromRenderStep("AutoSteal")
    if on then
        RunService:BindToRenderStep("AutoSteal", 300, function()
            if not S.AutoSteal then return end
            local hrp = GetHRP()
            if not hrp then return end

            local best, bd = nil, math.huge
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():match("egg") then
                    local d = (obj.Position - hrp.Position).Magnitude
                    if d < bd then bd = d; best = obj end
                end
            end

            if best and bd < 80 then
                hrp.CFrame = CFrame.new(best.Position + Vector3.new(0, 3.5, 0))
                local pp = best:FindFirstChildOfClass("ProximityPrompt")
                    or (best.Parent and best.Parent:FindFirstChildOfClass("ProximityPrompt"))
                if pp then
                    pcall(function() fireproximityprompt(pp) end)
                    pcall(function() pp.Triggered:Fire(LP) end)
                end
            end
        end)
    end
end)

NewToggle(PCombat, "🔄", "Auto Farm Loop", 11, function(on)
    S.AutoFarm = on
end)

-- ── ESP ─────────────────────────────────────────────────────
SectionHead(PESP, "EGG ESP", 1)

local EggESPObjects    = {}
local PlayerESPObjects = {}

-- EGG ESP LOGIC
local function BuildEggESP()
    for _, v in pairs(EggESPObjects) do pcall(function() v:Destroy() end) end
    EggESPObjects = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():match("egg") then
            -- Highlight
            local hl = Instance.new("SelectionBox")
            hl.Adornee       = obj
            hl.Color3        = Color3.fromRGB(255, 220, 50)
            hl.LineThickness = 0.06
            hl.SurfaceTransparency = 0.7
            hl.SurfaceColor3 = Color3.fromRGB(255, 220, 50)
            hl.Parent        = Camera

            -- Billboard
            local bb = Instance.new("BillboardGui")
            bb.Adornee     = obj
            bb.AlwaysOnTop = true
            bb.Size        = UDim2.new(0, 110, 0, 42)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.Parent      = Camera

            local nameLbl = Instance.new("TextLabel", bb)
            nameLbl.Size              = UDim2.new(1, 0, 0.55, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text              = "🥚 " .. obj.Name
            nameLbl.TextColor3        = Color3.fromRGB(255, 220, 50)
            nameLbl.TextSize          = 12
            nameLbl.Font              = Enum.Font.GothamBold
            nameLbl.TextStrokeTransparency = 0.3

            local distLbl = Instance.new("TextLabel", bb)
            distLbl.Name              = "Dist"
            distLbl.Size              = UDim2.new(1, 0, 0.45, 0)
            distLbl.Position          = UDim2.new(0, 0, 0.55, 0)
            distLbl.BackgroundTransparency = 1
            distLbl.TextColor3        = Color3.fromRGB(255, 255, 255)
            distLbl.TextSize          = 10
            distLbl.Font              = Enum.Font.Gotham
            distLbl.TextStrokeTransparency = 0.4

            -- live distance update
            local ref = obj
            RunService.Heartbeat:Connect(function()
                if not ref or not ref.Parent then
                    pcall(function() bb:Destroy() end)
                    pcall(function() hl:Destroy() end)
                    return
                end
                local hrp = GetHRP()
                if hrp then
                    local d = math.floor((ref.Position - hrp.Position).Magnitude)
                    distLbl.Text = "[ "..d.." st ]"
                end
            end)

            table.insert(EggESPObjects, bb)
            table.insert(EggESPObjects, hl)
        end
    end
end

local function ClearEggESP()
    for _, v in pairs(EggESPObjects) do pcall(function() v:Destroy() end) end
    EggESPObjects = {}
end

NewToggle(PESP, "🥚", "Egg ESP (Highlight + Tag)", 2, function(on)
    S.EggESP = on
    if on then BuildEggESP()
    else ClearEggESP() end
end)

NewToggle(PESP, "🔴", "Live Update Egg ESP", 3, function(on)
    S.EggLive = on
    RunService:UnbindFromRenderStep("EggLiveRebuild")
    if on then
        RunService:BindToRenderStep("EggLiveRebuild", 5, function()
            if S.EggESP and S.EggLive then
                BuildEggESP()
            end
        end)
    end
end)

Divider(PESP, 4)
SectionHead(PESP, "PLAYER ESP", 5)

-- PLAYER ESP LOGIC
local function BuildPlayerESP()
    for _, v in pairs(PlayerESPObjects) do pcall(function() v:Destroy() end) end
    PlayerESPObjects = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            -- Highlight box
            local hl = Instance.new("SelectionBox")
            hl.Adornee       = char
            hl.Color3        = Color3.fromRGB(255, 50, 50)
            hl.LineThickness = 0.05
            hl.SurfaceTransparency = 0.82
            hl.SurfaceColor3 = Color3.fromRGB(255, 50, 50)
            hl.Parent        = Camera

            -- Billboard
            local bb = Instance.new("BillboardGui")
            bb.Adornee     = hrp
            bb.AlwaysOnTop = true
            bb.Size        = UDim2.new(0, 130, 0, 56)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.Parent      = Camera

            local bg = Instance.new("Frame", bb)
            bg.Size              = UDim2.new(1, 0, 1, 0)
            bg.BackgroundColor3  = Color3.fromRGB(10, 10, 16)
            bg.BackgroundTransparency = 0.35
            bg.BorderSizePixel   = 0
            Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 5)

            local plrName = Instance.new("TextLabel", bg)
            plrName.Size              = UDim2.new(1, 0, 0.38, 0)
            plrName.BackgroundTransparency = 1
            plrName.Text              = "👤 "..plr.Name
            plrName.TextColor3        = Color3.fromRGB(255, 90, 90)
            plrName.TextSize          = 11
            plrName.Font              = Enum.Font.GothamBold
            plrName.TextStrokeTransparency = 0.3

            local rankLbl = Instance.new("TextLabel", bg)
            rankLbl.Name              = "Rank"
            rankLbl.Size              = UDim2.new(1, 0, 0.32, 0)
            rankLbl.Position          = UDim2.new(0, 0, 0.38, 0)
            rankLbl.BackgroundTransparency = 1
            rankLbl.TextColor3        = Color3.fromRGB(255, 200, 60)
            rankLbl.TextSize          = 10
            rankLbl.Font              = Enum.Font.Gotham
            rankLbl.TextStrokeTransparency = 0.4

            local distLbl = Instance.new("TextLabel", bg)
            distLbl.Name              = "Dist"
            distLbl.Size              = UDim2.new(1, 0, 0.30, 0)
            distLbl.Position          = UDim2.new(0, 0, 0.70, 0)
            distLbl.BackgroundTransparency = 1
            distLbl.TextColor3        = Color3.fromRGB(160, 160, 180)
            distLbl.TextSize          = 9
            distLbl.Font              = Enum.Font.Gotham
            distLbl.TextStrokeTransparency = 0.4

            -- Live update distance + rank
            local refHRP = hrp
            local refPlr = plr
            RunService.Heartbeat:Connect(function()
                if not refHRP or not refHRP.Parent then
                    pcall(function() bb:Destroy() end)
                    pcall(function() hl:Destroy() end)
                    return
                end
                local myHRP = GetHRP()
                if myHRP then
                    local d = math.floor((refHRP.Position - myHRP.Position).Magnitude)
                    distLbl.Text = "[ "..d.." st ]"
                end
                rankLbl.Text = "⭐ "..GetPlayerRank(refPlr)
            end)

            table.insert(PlayerESPObjects, bb)
            table.insert(PlayerESPObjects, hl)
        end
    end
end

local function ClearPlayerESP()
    for _, v in pairs(PlayerESPObjects) do pcall(function() v:Destroy() end) end
    PlayerESPObjects = {}
end

NewToggle(PESP, "👤", "Player ESP (Rank + Dist)", 6, function(on)
    S.PlayerESP = on
    if on then BuildPlayerESP()
    else ClearPlayerESP() end
end)

NewToggle(PESP, "🔴", "Auto Rebuild Player ESP", 7, function(on)
    S.PlayerESPLive = on
    RunService:UnbindFromRenderStep("PlayerESPRebuild")
    if on then
        RunService:BindToRenderStep("PlayerESPRebuild", 5, function()
            if S.PlayerESP and S.PlayerESPLive then
                BuildPlayerESP()
            end
        end)
    end
end)

Divider(PESP, 8)
SectionHead(PESP, "CHAMS", 9)

NewToggle(PESP, "🎨", "Player Chams (Red Fill)", 10, function(on)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if on then
                            p.Material       = Enum.Material.Neon
                            p.Color          = Color3.fromRGB(255, 50, 50)
                        else
                            p.Material       = Enum.Material.SmoothPlastic
                            p.Color          = Color3.fromRGB(163, 162, 165)
                        end
                    end
                end
            end
        end
    end
end)

-- ── STATS ───────────────────────────────────────────────────
SectionHead(PStats, "YOUR STATS", 1)

local vMoney     = NewStatRow(PStats, "💰", "Money Now",       2)
local vRank      = NewStatRow(PStats, "⭐", "Rank / Level",    3)
local vEarned    = NewStatRow(PStats, "📈", "Earned (session)",4)
local vSession   = NewStatRow(PStats, "⏱", "Session Time",    5)
local vPlayers   = NewStatRow(PStats, "👥", "Players Online",  6)
local vFPS       = NewStatRow(PStats, "🎮", "FPS",            7)
local vPing      = NewStatRow(PStats, "📡", "Ping (ms)",      8)

Divider(PStats, 9)
SectionHead(PStats, "SERVER INFO", 10)
local vJobID     = NewStatRow(PStats, "🔑", "Job ID (short)",  11)
local vMapName   = NewStatRow(PStats, "🗺", "Map / Place",    12)
local vEggCount  = NewStatRow(PStats, "🥚", "Eggs in Map",    13)

-- ================================================================
-- STATS LIVE UPDATE
-- ================================================================
local lastFPSUpdate = 0
local fpsCounter    = 0
local fpsMeasure    = 0

RunService.Heartbeat:Connect(function(dt)
    fpsCounter += 1
    fpsMeasure += dt
    if fpsMeasure >= 0.5 then
        S.FPS        = math.floor(fpsCounter / fpsMeasure)
        fpsCounter   = 0
        fpsMeasure   = 0
    end
end)

-- Stats tick (every 0.5s)
local lastStatTick = 0
RunService.RenderStepped:Connect(function()
    local now = tick()
    if now - lastStatTick < 0.5 then return end
    lastStatTick = now

    local money, mName = GetMoney()
    local rank, rName  = GetRank()
    local sessionSecs  = math.floor(now - S.SessionStart)

    if S.MoneyStart == 0 and money ~= 0 then S.MoneyStart = money end
    S.MoneyNow    = money
    S.MoneyEarned = math.max(0, money - S.MoneyStart)

    vMoney.Text   = tostring(money)
    vRank.Text    = rank
    vEarned.Text  = "+"..tostring(S.MoneyEarned)
    vSession.Text = FormatTime(sessionSecs)
    vPlayers.Text = tostring(#Players:GetPlayers()).." / "..tostring(Players.MaxPlayers)
    vFPS.Text     = (S.FPS and tostring(S.FPS) or "...").." fps"

    pcall(function()
        vPing.Text = tostring(math.floor(LP:GetNetworkPing() * 1000)).." ms"
    end)

    pcall(function()
        local jid = game.JobId
        vJobID.Text = jid ~= "" and string.sub(jid, 1, 12).."..." or "Studio"
    end)

    vMapName.Text = game.PlaceName ~= "" and game.PlaceName or tostring(game.PlaceId)

    -- count eggs
    local eggCount = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():match("egg") then
            eggCount += 1
        end
    end
    vEggCount.Text = tostring(eggCount).." eggs"
end)

-- FormatTime (already used above, define here if needed)
function FormatTime(secs)
    local m = math.floor(secs / 60)
    local s = math.floor(secs % 60)
    return string.format("%02d:%02d", m, s)
end

-- ================================================================
-- TITLEBAR BUTTONS
-- ================================================================
local minimized = false
local fullHeight = 440

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(MF, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
        Size = minimized
            and UDim2.new(0, 320, 0, 42)
            or  UDim2.new(0, 320, 0, fullHeight)
    }):Play()
    MinBtn.Text = minimized and "▲" or "–"
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MF, TweenInfo.new(0.2), {
        Size             = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }):Play()
    task.delay(0.25, function() SG:Destroy() end)
end)

-- ================================================================
-- KEYBIND: RightShift = toggle visibility
-- ================================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        S.Visible = not S.Visible
        MF.Visible = S.Visible
    end
end)

-- ================================================================
-- CHARACTER RESPAWN: rebind anti-hit + speed
-- ================================================================
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    if S.AntiHit then
        RunService:BindToRenderStep("AntiHit", 200, function()
            local h = GetHum()
            if h then h.Health = h.MaxHealth end
        end)
    end
    if S.SpeedHack then
        local h = GetHum()
        if h then h.WalkSpeed = S.TargetSpeed end
    end
end)

-- ================================================================
-- INIT
-- ================================================================
SwitchTab("Combat")

-- Notification
local Notif = Instance.new("Frame", SG)
Notif.Size             = UDim2.new(0, 240, 0, 38)
Notif.Position         = UDim2.new(0.5, -120, 0, -50)
Notif.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Notif.BorderSizePixel  = 0
Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 8)
local NSt = Instance.new("UIStroke", Notif)
NSt.Color = Color3.fromRGB(255, 60, 60); NSt.Thickness = 1.2

local NLbl = Instance.new("TextLabel", Notif)
NLbl.Size               = UDim2.new(1, 0, 1, 0)
NLbl.BackgroundTransparency = 1
NLbl.Text               = "🐜  ANTS TEAM loaded  |  RShift = hide"
NLbl.TextColor3         = Color3.fromRGB(255, 255, 255)
NLbl.TextSize           = 11
NLbl.Font               = Enum.Font.GothamBold

TweenService:Create(Notif, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
    Position = UDim2.new(0.5, -120, 0, 12)
}):Play()
task.delay(3, function()
    TweenService:Create(Notif, TweenInfo.new(0.3), {
        Position             = UDim2.new(0.5, -120, 0, -50),
        BackgroundTransparency = 1,
    }):Play()
    task.delay(0.35, function() Notif:Destroy() end)
end)

-- ================================================================
-- DONE
-- ================================================================
print("🐜 ANTS TEAM | Steal An Egg loaded | RShift = toggle UI")