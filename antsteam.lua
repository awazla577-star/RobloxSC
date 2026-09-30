-- ================================================================
--  🐜 ANTS TEAM v3.0 | STEAL AN EGG
--  Delta Executor | Tabs Kiri | Full Featured
-- ================================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse  = LP:GetMouse()

-- ================================================================
-- STATE
-- ================================================================
local S = {
    AntiHit       = false,  AntiHitRange = 30,
    FreezeMister  = false,
    Godmode       = false,
    AntiTouch     = false,
    SpeedHack     = false,  SpeedValue   = 24,
    CurrentSpeed  = 16,     TargetSpeed  = 16,
    NoClip        = false,
    InfJump       = false,
    AutoTP        = false,
    AutoSteal     = false,
    EggESP        = false,  EggESPLive   = false,
    MisterESP     = false,  MisterESPLive= false,
    LowGfx        = false,
    Visible       = true,
    EggsStart     = 0,
    SessionStart  = tick(),
}

-- ================================================================
-- UTILS
-- ================================================================
local function GetChar() return LP.Character or LP.CharacterAdded:Wait() end
local function GetHRP()  local c=GetChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum()  local c=GetChar() return c and c:FindFirstChildOfClass("Humanoid") end

local function GetEggs()
    local ls = LP:FindFirstChild("leaderstats") or LP:FindFirstChild("PlayerData")
    if ls then
        for _, n in ipairs({"Eggs","Money","Cash","Coins","Score","Points","Gold"}) do
            local v = ls:FindFirstChild(n)
            if v then return v.Value, n end
        end
    end
    return 0, "Eggs"
end

local function GetRank()
    local ls = LP:FindFirstChild("leaderstats") or LP:FindFirstChild("PlayerData")
    if ls then
        for _, n in ipairs({"Rank","Level","Stage","Prestige","Tier"}) do
            local v = ls:FindFirstChild(n)
            if v then return tostring(v.Value) end
        end
    end
    return "?"
end

local function FormatTime(s)
    return string.format("%02d:%02d", math.floor(s/60), math.floor(s%60))
end

local function FindMisters()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if obj:IsA("Model") and (n:find("mister") or n:find("mr%.") or n:find("enemy") or n:find("boss") or n:find("chaser")) then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                table.insert(list, {model=obj, hrp=hrp, hum=hum})
            end
        end
    end
    return list
end

local function FindEggParts()
    local list = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("egg") then
            table.insert(list, obj)
        end
    end
    return list
end

local function FindBase()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if obj:IsA("BasePart") and (n:find("base") or n:find("home") or n:find("nest") or n:find("drop") or n:find("deliver")) then
            return obj
        end
    end
    return workspace:FindFirstChildOfClass("SpawnLocation")
end

-- ================================================================
-- CLEANUP OLD GUI
-- ================================================================
pcall(function()
    local t = (gethui and gethui()) or LP.PlayerGui
    local old = t:FindFirstChild("ANTS_V3")
    if old then old:Destroy() end
end)

-- ================================================================
-- SCREEN GUI
-- ================================================================
local SG = Instance.new("ScreenGui")
SG.Name           = "ANTS_V3"
SG.ResetOnSpawn   = false
SG.DisplayOrder   = 999
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = (gethui and gethui()) or LP.PlayerGui end)
if not SG.Parent then SG.Parent = LP.PlayerGui end

-- ================================================================
-- SIZES
-- ================================================================
local MW  = 400   -- total width
local MH  = 470   -- total height
local SW  = 90    -- sidebar width
local CW  = MW - SW - 14  -- content width

-- ================================================================
-- MAIN FRAME
-- ================================================================
local MF = Instance.new("Frame", SG)
MF.Name             = "Main"
MF.Size             = UDim2.new(0, MW, 0, MH)
MF.Position         = UDim2.new(0, -MW - 20, 0.5, -MH/2)
MF.BackgroundColor3 = Color3.fromRGB(9, 9, 15)
MF.BorderSizePixel  = 0
MF.Active           = true
MF.Draggable        = true
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 14)

local MFStroke = Instance.new("UIStroke", MF)
MFStroke.Color       = Color3.fromRGB(230, 35, 35)
MFStroke.Thickness   = 1.6
MFStroke.Transparency = 0.18

-- ================================================================
-- SIDEBAR
-- ================================================================
local SB = Instance.new("Frame", MF)
SB.Name             = "Sidebar"
SB.Size             = UDim2.new(0, SW, 1, 0)
SB.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
SB.BorderSizePixel  = 0
Instance.new("UICorner", SB).CornerRadius = UDim.new(0, 14)

-- Fill right side of sidebar (remove right corners visually)
local SBFix = Instance.new("Frame", SB)
SBFix.Size             = UDim2.new(0, 16, 1, 0)
SBFix.Position         = UDim2.new(1, -16, 0, 0)
SBFix.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
SBFix.BorderSizePixel  = 0

-- Divider line sidebar
local SBLine = Instance.new("Frame", MF)
SBLine.Size             = UDim2.new(0, 1, 0.9, 0)
SBLine.Position         = UDim2.new(0, SW, 0.05, 0)
SBLine.BackgroundColor3 = Color3.fromRGB(230, 35, 35)
SBLine.BackgroundTransparency = 0.7
SBLine.BorderSizePixel  = 0

-- Logo area
local LogoArea = Instance.new("Frame", SB)
LogoArea.Size               = UDim2.new(1, 0, 0, 78)
LogoArea.BackgroundTransparency = 1

local LogoEmoji = Instance.new("TextLabel", LogoArea)
LogoEmoji.Size              = UDim2.new(1, 0, 0, 44)
LogoEmoji.Position          = UDim2.new(0, 0, 0, 8)
LogoEmoji.BackgroundTransparency = 1
LogoEmoji.Text              = "🐜"
LogoEmoji.TextSize          = 30
LogoEmoji.TextXAlignment    = Enum.TextXAlignment.Center

local LogoName = Instance.new("TextLabel", LogoArea)
LogoName.Size               = UDim2.new(1, 0, 0, 16)
LogoName.Position           = UDim2.new(0, 0, 0, 54)
LogoName.BackgroundTransparency = 1
LogoName.Text               = "ANTS TEAM"
LogoName.TextColor3         = Color3.fromRGB(230, 40, 40)
LogoName.TextSize           = 9
LogoName.Font               = Enum.Font.GothamBold
LogoName.TextXAlignment     = Enum.TextXAlignment.Center

-- Separator under logo
local LogoSep = Instance.new("Frame", SB)
LogoSep.Size               = UDim2.new(0.65, 0, 0, 1)
LogoSep.Position           = UDim2.new(0.175, 0, 0, 78)
LogoSep.BackgroundColor3   = Color3.fromRGB(230, 35, 35)
LogoSep.BackgroundTransparency = 0.55
LogoSep.BorderSizePixel    = 0

-- Tab button container
local SBTabs = Instance.new("Frame", SB)
SBTabs.Size               = UDim2.new(1, 0, 1, -85)
SBTabs.Position           = UDim2.new(0, 0, 0, 84)
SBTabs.BackgroundTransparency = 1

local SBLayout = Instance.new("UIListLayout", SBTabs)
SBLayout.FillDirection       = Enum.FillDirection.Vertical
SBLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SBLayout.Padding             = UDim.new(0, 4)

local SBPad = Instance.new("UIPadding", SBTabs)
SBPad.PaddingTop = UDim.new(0, 4)

-- ================================================================
-- CONTENT AREA
-- ================================================================
local CA = Instance.new("Frame", MF)
CA.Name               = "Content"
CA.Size               = UDim2.new(0, CW, 1, -10)
CA.Position           = UDim2.new(0, SW + 8, 0, 5)
CA.BackgroundTransparency = 1
CA.ClipsDescendants   = true

-- Close button (top right corner)
local CloseBtn = Instance.new("TextButton", MF)
CloseBtn.Size             = UDim2.new(0, 22, 0, 17)
CloseBtn.Position         = UDim2.new(1, -28, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(195, 32, 32)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize         = 10
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
CloseBtn.ZIndex           = 20
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

-- ================================================================
-- TAB / PAGE SYSTEM
-- ================================================================
local Pages   = {}
local TabBtns = {}

local function NewPage(name)
    local sf = Instance.new("ScrollingFrame", CA)
    sf.Name                 = name
    sf.Size                 = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel      = 0
    sf.ScrollBarThickness   = 2
    sf.ScrollBarImageColor3 = Color3.fromRGB(210, 35, 35)
    sf.CanvasSize           = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    sf.Visible              = false

    local ll = Instance.new("UIListLayout", sf)
    ll.Padding             = UDim.new(0, 5)
    ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ll.SortOrder           = Enum.SortOrder.LayoutOrder

    local pd = Instance.new("UIPadding", sf)
    pd.PaddingTop    = UDim.new(0, 8)
    pd.PaddingBottom = UDim.new(0, 10)
    pd.PaddingRight  = UDim.new(0, 4)

    Pages[name] = sf
    return sf
end

local function SwitchTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(TabBtns) do
        local active = (n == name)
        TweenService:Create(b.bg, TweenInfo.new(0.16), {
            BackgroundColor3 = active and Color3.fromRGB(210, 35, 35) or Color3.fromRGB(20, 20, 30)
        }):Play()
        b.ico.TextColor3  = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(110,110,130)
        b.lbl.TextColor3  = active and Color3.fromRGB(255,255,255) or Color3.fromRGB(95,95,115)
    end
end

local function NewTabBtn(name, icon, label)
    local btn = Instance.new("TextButton", SBTabs)
    btn.Name              = name
    btn.Size              = UDim2.new(0, SW - 12, 0, 56)
    btn.BackgroundTransparency = 1
    btn.Text              = ""
    btn.BorderSizePixel   = 0

    local bg = Instance.new("Frame", btn)
    bg.Size               = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3   = Color3.fromRGB(20, 20, 30)
    bg.BorderSizePixel    = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 10)

    local ico = Instance.new("TextLabel", bg)
    ico.Size              = UDim2.new(1, 0, 0, 30)
    ico.Position          = UDim2.new(0, 0, 0, 7)
    ico.BackgroundTransparency = 1
    ico.Text              = icon
    ico.TextSize          = 20
    ico.TextColor3        = Color3.fromRGB(110, 110, 130)
    ico.TextXAlignment    = Enum.TextXAlignment.Center

    local lbl = Instance.new("TextLabel", bg)
    lbl.Size              = UDim2.new(1, 0, 0, 14)
    lbl.Position          = UDim2.new(0, 0, 1, -16)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.TextColor3        = Color3.fromRGB(95, 95, 115)
    lbl.TextSize          = 9
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextXAlignment    = Enum.TextXAlignment.Center

    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
    TabBtns[name] = {bg=bg, ico=ico, lbl=lbl}
    return btn
end

-- ================================================================
-- WIDGET FACTORIES
-- ================================================================
local function SecHead(parent, text, order)
    local f = Instance.new("Frame", parent)
    f.Size              = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.LayoutOrder       = order

    local l = Instance.new("TextLabel", f)
    l.Size              = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text              = "  ▸ " .. text
    l.TextColor3        = Color3.fromRGB(230, 45, 45)
    l.TextSize          = 10
    l.Font              = Enum.Font.GothamBold
    l.TextXAlignment    = Enum.TextXAlignment.Left
end

local function Divider(parent, order)
    local f = Instance.new("Frame", parent)
    f.Size              = UDim2.new(1, -6, 0, 1)
    f.BackgroundColor3  = Color3.fromRGB(230, 35, 35)
    f.BackgroundTransparency = 0.78
    f.BorderSizePixel   = 0
    f.LayoutOrder       = order
end

local function NewToggle(parent, ico, label, order, cb)
    local row = Instance.new("Frame", parent)
    row.Size              = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3  = Color3.fromRGB(15, 15, 22)
    row.BorderSizePixel   = 0
    row.LayoutOrder       = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local icoL = Instance.new("TextLabel", row)
    icoL.Size             = UDim2.new(0, 26, 1, 0)
    icoL.Position         = UDim2.new(0, 7, 0, 0)
    icoL.BackgroundTransparency = 1
    icoL.Text             = ico
    icoL.TextSize         = 15

    local lblL = Instance.new("TextLabel", row)
    lblL.Size             = UDim2.new(1, -88, 1, 0)
    lblL.Position         = UDim2.new(0, 35, 0, 0)
    lblL.BackgroundTransparency = 1
    lblL.Text             = label
    lblL.TextColor3       = Color3.fromRGB(190, 190, 205)
    lblL.TextSize         = 11
    lblL.Font             = Enum.Font.Gotham
    lblL.TextXAlignment   = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame", row)
    pill.Size             = UDim2.new(0, 40, 0, 20)
    pill.Position         = UDim2.new(1, -47, 0.5, -10)
    pill.BackgroundColor3 = Color3.fromRGB(33, 33, 47)
    pill.BorderSizePixel  = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.Size             = UDim2.new(0, 14, 0, 14)
    knob.Position         = UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(85, 85, 105)
    knob.BorderSizePixel  = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local on = false
    local hb = Instance.new("TextButton", row)
    hb.Size               = UDim2.new(1, 0, 1, 0)
    hb.BackgroundTransparency = 1
    hb.Text               = ""
    hb.ZIndex             = 5

    hb.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(pill,  TweenInfo.new(0.16), {BackgroundColor3 = Color3.fromRGB(210,35,35)}):Play()
            TweenService:Create(knob,  TweenInfo.new(0.16), {
                Position = UDim2.new(1,-17,0.5,-7),
                BackgroundColor3 = Color3.fromRGB(255,255,255),
            }):Play()
        else
            TweenService:Create(pill,  TweenInfo.new(0.16), {BackgroundColor3 = Color3.fromRGB(33,33,47)}):Play()
            TweenService:Create(knob,  TweenInfo.new(0.16), {
                Position = UDim2.new(0,3,0.5,-7),
                BackgroundColor3 = Color3.fromRGB(85,85,105),
            }):Play()
        end
        cb(on)
    end)
end

local function NewSlider(parent, ico, label, order, minV, maxV, def, cb)
    local row = Instance.new("Frame", parent)
    row.Size              = UDim2.new(1, 0, 0, 54)
    row.BackgroundColor3  = Color3.fromRGB(15, 15, 22)
    row.BorderSizePixel   = 0
    row.LayoutOrder       = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local icoL = Instance.new("TextLabel", row)
    icoL.Size             = UDim2.new(0, 24, 0, 24)
    icoL.Position         = UDim2.new(0, 8, 0, 4)
    icoL.BackgroundTransparency = 1
    icoL.Text             = ico
    icoL.TextSize         = 14

    local lblL = Instance.new("TextLabel", row)
    lblL.Size             = UDim2.new(0.58, 0, 0, 24)
    lblL.Position         = UDim2.new(0, 34, 0, 4)
    lblL.BackgroundTransparency = 1
    lblL.Text             = label
    lblL.TextColor3       = Color3.fromRGB(190, 190, 205)
    lblL.TextSize         = 11
    lblL.Font             = Enum.Font.Gotham
    lblL.TextXAlignment   = Enum.TextXAlignment.Left

    local valL = Instance.new("TextLabel", row)
    valL.Size             = UDim2.new(0.38, -6, 0, 24)
    valL.Position         = UDim2.new(0.62, 0, 0, 4)
    valL.BackgroundTransparency = 1
    valL.Text             = tostring(def)
    valL.TextColor3       = Color3.fromRGB(255, 145, 55)
    valL.TextSize         = 13
    valL.Font             = Enum.Font.GothamBold
    valL.TextXAlignment   = Enum.TextXAlignment.Right

    local vpad = Instance.new("UIPadding", valL)
    vpad.PaddingRight = UDim.new(0, 8)

    -- Track
    local track = Instance.new("Frame", row)
    track.Size            = UDim2.new(1, -18, 0, 6)
    track.Position        = UDim2.new(0, 9, 0, 38)
    track.BackgroundColor3 = Color3.fromRGB(28, 28, 42)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local pct0 = (def - minV) / (maxV - minV)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new(pct0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(210, 35, 35)
    fill.BorderSizePixel  = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", track)
    thumb.Size            = UDim2.new(0, 14, 0, 14)
    thumb.Position        = UDim2.new(pct0, -7, 0.5, -7)
    thumb.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    thumb.BorderSizePixel = 0
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local curVal   = def

    local function Apply(x)
        local a = track.AbsolutePosition.X
        local w = track.AbsoluteSize.X
        local p = math.clamp((x - a) / w, 0, 1)
        curVal  = math.floor(minV + (maxV - minV) * p)
        fill.Size     = UDim2.new(p, 0, 1, 0)
        thumb.Position = UDim2.new(p, -7, 0.5, -7)
        valL.Text     = tostring(curVal)
        cb(curVal)
    end

    local hb = Instance.new("TextButton", row)
    hb.Size               = UDim2.new(1, 0, 1, 0)
    hb.BackgroundTransparency = 1
    hb.Text               = ""
    hb.ZIndex             = 5

    hb.MouseButton1Down:Connect(function()
        dragging = true
        Apply(Mouse.X)
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            Apply(Mouse.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return function() return curVal end
end

local StatVals = {}
local function NewStat(parent, ico, label, order)
    local row = Instance.new("Frame", parent)
    row.Size              = UDim2.new(1, 0, 0, 30)
    row.BackgroundColor3  = Color3.fromRGB(15, 15, 22)
    row.BorderSizePixel   = 0
    row.LayoutOrder       = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local icoL = Instance.new("TextLabel", row)
    icoL.Size             = UDim2.new(0, 22, 1, 0)
    icoL.Position         = UDim2.new(0, 7, 0, 0)
    icoL.BackgroundTransparency = 1
    icoL.Text             = ico
    icoL.TextSize         = 12

    local lblL = Instance.new("TextLabel", row)
    lblL.Size             = UDim2.new(0.52, 0, 1, 0)
    lblL.Position         = UDim2.new(0, 30, 0, 0)
    lblL.BackgroundTransparency = 1
    lblL.Text             = label
    lblL.TextColor3       = Color3.fromRGB(120, 120, 145)
    lblL.TextSize         = 10
    lblL.Font             = Enum.Font.Gotham
    lblL.TextXAlignment   = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", row)
    val.Size              = UDim2.new(0.48, -10, 1, 0)
    val.Position          = UDim2.new(0.52, 0, 0, 0)
    val.BackgroundTransparency = 1
    val.Text              = "..."
    val.TextColor3        = Color3.fromRGB(255, 160, 55)
    val.TextSize          = 11
    val.Font              = Enum.Font.GothamBold
    val.TextXAlignment    = Enum.TextXAlignment.Right

    local rp = Instance.new("UIPadding", val)
    rp.PaddingRight = UDim.new(0, 8)

    StatVals[label] = val
    return val
end

-- ================================================================
-- BUILD TABS
-- ================================================================
NewTabBtn("Home",   "🏠", "Home")
NewTabBtn("Combat", "⚔️",  "Combat")
NewTabBtn("ESP",    "👁",  "ESP")
NewTabBtn("Move",   "🚀", "Move")
NewTabBtn("Misc",   "⚙️",  "Misc")

local PHome   = NewPage("Home")
local PCombat = NewPage("Combat")
local PESP    = NewPage("ESP")
local PMove   = NewPage("Move")
local PMisc   = NewPage("Misc")

-- ================================================================
-- HOME PAGE
-- ================================================================
-- Header banner
local Banner = Instance.new("Frame", PHome)
Banner.Size             = UDim2.new(1, 0, 0, 62)
Banner.BackgroundColor3 = Color3.fromRGB(16, 7, 7)
Banner.BorderSizePixel  = 0
Banner.LayoutOrder      = 1
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 10)
local BS = Instance.new("UIStroke", Banner)
BS.Color = Color3.fromRGB(210,35,35); BS.Thickness = 1; BS.Transparency = 0.55

local BTitle = Instance.new("TextLabel", Banner)
BTitle.Size               = UDim2.new(1, 0, 0, 34)
BTitle.Position           = UDim2.new(0, 0, 0, 6)
BTitle.BackgroundTransparency = 1
BTitle.Text               = "🐜  ANTS TEAM"
BTitle.TextColor3         = Color3.fromRGB(255, 255, 255)
BTitle.TextSize           = 17
BTitle.Font               = Enum.Font.GothamBold

local BSub = Instance.new("TextLabel", Banner)
BSub.Size                 = UDim2.new(1, 0, 0, 16)
BSub.Position             = UDim2.new(0, 0, 0, 40)
BSub.BackgroundTransparency = 1
BSub.Text                 = "Steal An Egg  ·  v3.0  ·  Delta Executor"
BSub.TextColor3           = Color3.fromRGB(210, 40, 40)
BSub.TextSize             = 10
BSub.Font                 = Enum.Font.Gotham

SecHead(PHome, "EGG INCOME", 2)
local vEN  = NewStat(PHome, "🥚", "Eggs Sekarang",    3)
local vEE  = NewStat(PHome, "📈", "Dikumpul (sesi)",  4)
local vRK  = NewStat(PHome, "⭐", "Rank / Level",     5)
local vST  = NewStat(PHome, "⏱", "Waktu Sesi",       6)

Divider(PHome, 7)
SecHead(PHome, "SERVER INFO", 8)
local vPL  = NewStat(PHome, "👥", "Players",          9)
local vFPS = NewStat(PHome, "🎮", "FPS",              10)
local vPNG = NewStat(PHome, "📡", "Ping",             11)
local vEGM = NewStat(PHome, "🗺", "Egg di Map",      12)
local vMST = NewStat(PHome, "👹", "Mister Aktif",    13)

-- ================================================================
-- COMBAT PAGE
-- ================================================================
SecHead(PCombat, "ANTI HIT — MISTER", 1)

NewToggle(PCombat, "👻", "Anti-Hit (Auto Dodge Mister)", 2, function(on)
    S.AntiHit = on
    RunService:UnbindFromRenderStep("AntiHit")
    if on then
        RunService:BindToRenderStep("AntiHit", 200, function()
            if not S.AntiHit then return end
            local hrp = GetHRP()
            if not hrp then return end
            for _, m in ipairs(FindMisters()) do
                if m.hrp and m.hrp.Parent then
                    local dist = (m.hrp.Position - hrp.Position).Magnitude
                    if dist < S.AntiHitRange then
                        local dir = (hrp.Position - m.hrp.Position).Unit
                        local push = S.AntiHitRange - dist + 18
                        hrp.CFrame = hrp.CFrame + dir * push
                    end
                end
            end
        end)
    end
end)

NewToggle(PCombat, "🧊", "Freeze Mister (No Chase)", 3, function(on)
    S.FreezeMister = on
    RunService:UnbindFromRenderStep("FreezeMister")
    if on then
        RunService:BindToRenderStep("FreezeMister", 150, function()
            if not S.FreezeMister then return end
            for _, m in ipairs(FindMisters()) do
                pcall(function()
                    m.hum.WalkSpeed  = 0
                    m.hum.JumpPower  = 0
                    m.hrp.Anchored   = true
                end)
            end
        end)
    else
        for _, m in ipairs(FindMisters()) do
            pcall(function()
                m.hum.WalkSpeed  = 16
                m.hum.JumpPower  = 50
                m.hrp.Anchored   = false
            end)
        end
    end
end)

Divider(PCombat, 4)
SecHead(PCombat, "PLAYER", 5)

NewToggle(PCombat, "🛡", "Godmode (HP Loop)", 6, function(on)
    S.Godmode = on
    RunService:UnbindFromRenderStep("Godmode")
    if on then
        RunService:BindToRenderStep("Godmode", 200, function()
            local h = GetHum()
            if h and h.Health < h.MaxHealth then h.Health = h.MaxHealth end
        end)
    end
end)

NewToggle(PCombat, "🚫", "Anti Sentuh (No Damage)", 7, function(on)
    S.AntiTouch = on
    RunService:UnbindFromRenderStep("AntiTouch")
    if on then
        RunService:BindToRenderStep("AntiTouch", 200, function()
            local c = GetChar()
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanTouch = false end
                end
            end
        end)
    else
        local c = GetChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanTouch = true end
            end
        end
    end
end)

Divider(PCombat, 8)
SecHead(PCombat, "AUTO STEAL", 9)

NewToggle(PCombat, "🔄", "Auto Steal Egg Terdekat", 10, function(on)
    S.AutoSteal = on
    RunService:UnbindFromRenderStep("AutoSteal")
    if on then
        RunService:BindToRenderStep("AutoSteal", 400, function()
            if not S.AutoSteal then return end
            local hrp = GetHRP()
            if not hrp then return end
            local best, bd = nil, math.huge
            for _, obj in ipairs(FindEggParts()) do
                local d = (obj.Position - hrp.Position).Magnitude
                if d < bd then bd = d; best = obj end
            end
            if best and bd < 90 then
                hrp.CFrame = CFrame.new(best.Position + Vector3.new(0,4,0))
                local pp = best:FindFirstChildOfClass("ProximityPrompt")
                    or (best.Parent and best.Parent:FindFirstChildOfClass("ProximityPrompt"))
                if pp then pcall(function() fireproximityprompt(pp) end) end
            end
        end)
    end
end)

-- ================================================================
-- ESP PAGE
-- ================================================================
local EggObjs    = {}
local MisterObjs = {}

local function ClearEggESP()
    for _, v in pairs(EggObjs) do pcall(function() v:Destroy() end) end
    EggObjs = {}
end

local function ClearMisterESP()
    for _, v in pairs(MisterObjs) do pcall(function() v:Destroy() end) end
    MisterObjs = {}
end

local function BuildEggESP()
    ClearEggESP()
    for _, obj in ipairs(FindEggParts()) do
        -- Gold selection box
        local hl = Instance.new("SelectionBox")
        hl.Adornee              = obj
        hl.Color3               = Color3.fromRGB(255, 210, 0)
        hl.LineThickness        = 0.09
        hl.SurfaceTransparency  = 0.65
        hl.SurfaceColor3        = Color3.fromRGB(255, 210, 0)
        hl.Parent               = Camera

        -- Billboard
        local bb = Instance.new("BillboardGui")
        bb.Adornee     = obj
        bb.AlwaysOnTop = true
        bb.Size        = UDim2.new(0, 96, 0, 38)
        bb.StudsOffset = Vector3.new(0, 2.8, 0)
        bb.Parent      = Camera

        local bg = Instance.new("Frame", bb)
        bg.Size                   = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3       = Color3.fromRGB(8, 8, 10)
        bg.BackgroundTransparency = 0.28
        bg.BorderSizePixel        = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 5)
        local bgs = Instance.new("UIStroke", bg)
        bgs.Color = Color3.fromRGB(255,200,0); bgs.Thickness=1; bgs.Transparency=0.5

        local nL = Instance.new("TextLabel", bg)
        nL.Size                   = UDim2.new(1, 0, 0.55, 0)
        nL.BackgroundTransparency = 1
        nL.Text                   = "🥚 " .. obj.Name
        nL.TextColor3             = Color3.fromRGB(255, 210, 0)
        nL.TextSize               = 12
        nL.Font                   = Enum.Font.GothamBold
        nL.TextStrokeTransparency = 0.15

        local dL = Instance.new("TextLabel", bg)
        dL.Size                   = UDim2.new(1, 0, 0.45, 0)
        dL.Position               = UDim2.new(0, 0, 0.55, 0)
        dL.BackgroundTransparency = 1
        dL.TextColor3             = Color3.fromRGB(215, 215, 215)
        dL.TextSize               = 10
        dL.Font                   = Enum.Font.Gotham
        dL.TextStrokeTransparency = 0.3

        local ref = obj
        RunService.Heartbeat:Connect(function()
            if not ref or not ref.Parent then
                pcall(function() bb:Destroy(); hl:Destroy() end)
                return
            end
            local hrp = GetHRP()
            if hrp then
                dL.Text = "[ " .. math.floor((ref.Position - hrp.Position).Magnitude) .. " st ]"
            end
        end)

        table.insert(EggObjs, bb)
        table.insert(EggObjs, hl)
    end
end

local function BuildMisterESP()
    ClearMisterESP()
    for _, m in ipairs(FindMisters()) do
        local hl = Instance.new("SelectionBox")
        hl.Adornee              = m.model
        hl.Color3               = Color3.fromRGB(255, 35, 35)
        hl.LineThickness        = 0.08
        hl.SurfaceTransparency  = 0.75
        hl.SurfaceColor3        = Color3.fromRGB(255, 35, 35)
        hl.Parent               = Camera

        local bb = Instance.new("BillboardGui")
        bb.Adornee     = m.hrp
        bb.AlwaysOnTop = true
        bb.Size        = UDim2.new(0, 108, 0, 52)
        bb.StudsOffset = Vector3.new(0, 4, 0)
        bb.Parent      = Camera

        local bg = Instance.new("Frame", bb)
        bg.Size                   = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3       = Color3.fromRGB(12, 4, 4)
        bg.BackgroundTransparency = 0.22
        bg.BorderSizePixel        = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
        local bgs = Instance.new("UIStroke", bg)
        bgs.Color = Color3.fromRGB(255,40,40); bgs.Thickness=1; bgs.Transparency=0.45

        local nL = Instance.new("TextLabel", bg)
        nL.Size                   = UDim2.new(1, 0, 0.4, 0)
        nL.BackgroundTransparency = 1
        nL.Text                   = "👹 " .. m.model.Name
        nL.TextColor3             = Color3.fromRGB(255, 60, 60)
        nL.TextSize               = 12
        nL.Font                   = Enum.Font.GothamBold
        nL.TextStrokeTransparency = 0.15

        local hL = Instance.new("TextLabel", bg)
        hL.Size                   = UDim2.new(1, 0, 0.32, 0)
        hL.Position               = UDim2.new(0, 0, 0.4, 0)
        hL.BackgroundTransparency = 1
        hL.TextColor3             = Color3.fromRGB(80, 255, 100)
        hL.TextSize               = 10
        hL.Font                   = Enum.Font.Gotham
        hL.TextStrokeTransparency = 0.3

        local dL = Instance.new("TextLabel", bg)
        dL.Size                   = UDim2.new(1, 0, 0.28, 0)
        dL.Position               = UDim2.new(0, 0, 0.72, 0)
        dL.BackgroundTransparency = 1
        dL.TextColor3             = Color3.fromRGB(200, 200, 200)
        dL.TextSize               = 9
        dL.Font                   = Enum.Font.Gotham
        dL.TextStrokeTransparency = 0.35

        local refH = m.hrp
        local refHum = m.hum
        RunService.Heartbeat:Connect(function()
            if not refH or not refH.Parent then
                pcall(function() bb:Destroy(); hl:Destroy() end)
                return
            end
            local hrp = GetHRP()
            if hrp then
                dL.Text = "[ " .. math.floor((refH.Position - hrp.Position).Magnitude) .. " st ]"
            end
            if refHum and refHum.Parent then
                hL.Text = "❤ " .. math.floor(refHum.Health) .. " / " .. math.floor(refHum.MaxHealth)
            end
        end)

        table.insert(MisterObjs, bb)
        table.insert(MisterObjs, hl)
    end
end

SecHead(PESP, "EGG ESP", 1)

NewToggle(PESP, "🥚", "Egg ESP (Kotak + Jarak)", 2, function(on)
    S.EggESP = on
    if on then BuildEggESP() else ClearEggESP() end
end)

NewToggle(PESP, "🔄", "Auto Refresh Egg ESP (3s)", 3, function(on)
    S.EggESPLive = on
    RunService:UnbindFromRenderStep("EggESPRef")
    if on then
        local last = 0
        RunService:BindToRenderStep("EggESPRef", 2, function()
            local n = tick()
            if n - last > 3 then last = n
                if S.EggESP then BuildEggESP() end
            end
        end)
    end
end)

Divider(PESP, 4)
SecHead(PESP, "MISTER ESP", 5)

NewToggle(PESP, "👹", "Mister ESP (HP + Jarak)", 6, function(on)
    S.MisterESP = on
    if on then BuildMisterESP() else ClearMisterESP() end
end)

NewToggle(PESP, "🔄", "Auto Refresh Mister ESP (2s)", 7, function(on)
    S.MisterESPLive = on
    RunService:UnbindFromRenderStep("MisESPRef")
    if on then
        local last = 0
        RunService:BindToRenderStep("MisESPRef", 2, function()
            local n = tick()
            if n - last > 2 then last = n
                if S.MisterESP then BuildMisterESP() end
            end
        end)
    end
end)

-- ================================================================
-- MOVE PAGE
-- ================================================================
SecHead(PMove, "SPEED — ANTI DETECT", 1)

local getSpeedVal = NewSlider(PMove, "⚡", "Kecepatan Target", 2, 16, 120, 24, function(v)
    S.SpeedValue = v
    if S.SpeedHack then S.TargetSpeed = v end
end)

NewToggle(PMove, "⚡", "Aktifkan Speed Bypass", 3, function(on)
    S.SpeedHack = on
    RunService:UnbindFromRenderStep("SpeedBypass")
    if on then
        S.TargetSpeed  = S.SpeedValue
        S.CurrentSpeed = 16
        local t = 0

        RunService:BindToRenderStep("SpeedBypass", 100, function()
            if not S.SpeedHack then return end
            local h = GetHum()
            if not h then return end

            -- Gradual ramp: +0.7 per frame until target
            if S.CurrentSpeed < S.TargetSpeed then
                S.CurrentSpeed = math.min(S.CurrentSpeed + 0.7, S.TargetSpeed)
            elseif S.CurrentSpeed > S.TargetSpeed then
                S.CurrentSpeed = math.max(S.CurrentSpeed - 1.2, S.TargetSpeed)
            end

            -- Sinusoidal noise to break server pattern detection
            t += 0.08
            local noise = math.sin(t * 2.1) * 0.28 + math.cos(t * 1.6) * 0.18
            h.WalkSpeed = S.CurrentSpeed + noise
        end)
    else
        local h = GetHum()
        if h then h.WalkSpeed = 16 end
        S.CurrentSpeed = 16
    end
end)

Divider(PMove, 4)
SecHead(PMove, "GERAK", 5)

NewToggle(PMove, "🚫", "No-Clip (Tembus Dinding)", 6, function(on)
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

NewToggle(PMove, "🌙", "Infinite Jump", 7, function(on)
    S.InfJump = on
end)

UserInputService.JumpRequest:Connect(function()
    if S.InfJump then
        local h = GetHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Divider(PMove, 8)
SecHead(PMove, "AUTO TP KE BASE", 9)

NewToggle(PMove, "🏠", "Auto TP Base (kalau pegang telur)", 10, function(on)
    S.AutoTP = on
    RunService:UnbindFromRenderStep("AutoTP")
    if on then
        RunService:BindToRenderStep("AutoTP", 300, function()
            if not S.AutoTP then return end
            local c  = GetChar()
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Detect egg in character or backpack
            local hasEgg = false
            for _, obj in ipairs(c:GetDescendants()) do
                if obj.Name:lower():find("egg") then hasEgg = true; break end
            end
            if not hasEgg then
                for _, obj in ipairs(LP.Backpack:GetDescendants()) do
                    if obj.Name:lower():find("egg") then hasEgg = true; break end
                end
            end

            if hasEgg then
                local base = FindBase()
                if base then
                    hrp.CFrame = CFrame.new(base.Position + Vector3.new(0, 5.5, 0))
                    -- Try fire proximity prompt at base
                    pcall(function()
                        local pp = base:FindFirstChildOfClass("ProximityPrompt")
                        if pp then fireproximityprompt(pp) end
                    end)
                end
            end
        end)
    end
end)

NewToggle(PMove, "📍", "TP ke Base Sekarang", 11, function(on)
    if on then
        local base = FindBase()
        local hrp  = GetHRP()
        if base and hrp then
            hrp.CFrame = CFrame.new(base.Position + Vector3.new(0, 5.5, 0))
        end
    end
end)

-- ================================================================
-- MISC PAGE
-- ================================================================
SecHead(PMisc, "GRAFIS", 1)

NewToggle(PMisc, "🎨", "Low Graphics (Boost FPS)", 2, function(on)
    S.LowGfx = on
    if on then
        S._origGS   = Lighting.GlobalShadows
        S._origBr   = Lighting.Brightness
        S._origFog  = Lighting.FogEnd
        S._origAmb  = Lighting.Ambient
        pcall(function() S._origQ = settings().Rendering.QualityLevel end)

        pcall(function() settings().Rendering.QualityLevel = 1 end)
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 9e9
        Lighting.Brightness    = 2.5
        Lighting.Ambient       = Color3.fromRGB(178, 178, 178)

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire")
            or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Trail") then
                obj.Enabled = false
            end
            if obj:IsA("BasePart") then
                obj.CastShadow = false
                pcall(function() obj.Material = Enum.Material.SmoothPlastic end)
            end
        end
    else
        Lighting.GlobalShadows = S._origGS  or true
        Lighting.Brightness    = S._origBr  or 2
        Lighting.FogEnd        = S._origFog or 100000
        if S._origAmb then Lighting.Ambient = S._origAmb end
        pcall(function() settings().Rendering.QualityLevel = S._origQ or 10 end)
    end
end)

NewToggle(PMisc, "🌑", "Hapus Shadow", 3, function(on)
    Lighting.GlobalShadows = not on
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then obj.CastShadow = not on end
    end
end)

NewToggle(PMisc, "🌫", "Hapus Efek Lighting", 4, function(on)
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("ColorCorrectionEffect")
        or e:IsA("SunRaysEffect") or e:IsA("BloomEffect")
        or e:IsA("DepthOfFieldEffect") then
            e.Enabled = not on
        end
    end
end)

Divider(PMisc, 5)
SecHead(PMisc, "KETERANGAN SPEED BYPASS", 6)

-- Info box
local IB = Instance.new("Frame", PMisc)
IB.Size             = UDim2.new(1, 0, 0, 82)
IB.BackgroundColor3 = Color3.fromRGB(12, 8, 8)
IB.BorderSizePixel  = 0
IB.LayoutOrder      = 7
Instance.new("UICorner", IB).CornerRadius = UDim.new(0, 8)
local IBS = Instance.new("UIStroke", IB)
IBS.Color = Color3.fromRGB(180,35,35); IBS.Thickness=1; IBS.Transparency=0.6

local IL = Instance.new("TextLabel", IB)
IL.Size               = UDim2.new(1, -14, 1, -10)
IL.Position           = UDim2.new(0, 7, 0, 5)
IL.BackgroundTransparency = 1
IL.Text               = "⚠ Speed pakai gradual ramp (+0.7/frame) + noise sinusoidal agar tidak terdeteksi. Aman: 16–55. Di atas 60 risiko kick.\n\nFreeze Mister = Mister tidak bisa gerak sama sekali (anchored). Anti-Hit = player auto dodge tiap Mister dalam radius 30 st."
IL.TextColor3         = Color3.fromRGB(195, 155, 155)
IL.TextSize           = 9
IL.Font               = Enum.Font.Gotham
IL.TextWrapped        = true
IL.TextXAlignment     = Enum.TextXAlignment.Left
IL.TextYAlignment     = Enum.TextYAlignment.Top

Divider(PMisc, 8)
SecHead(PMisc, "UI", 9)

NewToggle(PMisc, "💬", "Sembunyikan Chat", 10, function(on)
    pcall(function()
        local ch = LP.PlayerGui:FindFirstChild("Chat")
        if ch then ch.Enabled = not on end
    end)
end)

-- ================================================================
-- STATS LIVE UPDATE
-- ================================================================
local fpsN = 60; local fpsC = 0; local fpsT = 0

RunService.Heartbeat:Connect(function(dt)
    fpsC += 1; fpsT += dt
    if fpsT >= 0.5 then
        fpsN = math.floor(fpsC / fpsT)
        fpsC = 0; fpsT = 0
    end
end)

local lastStat = 0
RunService.RenderStepped:Connect(function()
    local now = tick()
    if now - lastStat < 0.4 then return end
    lastStat = now

    local eggs = GetEggs()
    if S.EggsStart == 0 and eggs ~= 0 then S.EggsStart = eggs end
    local earned = math.max(0, eggs - S.EggsStart)

    if vEN  then vEN.Text   = tostring(eggs) end
    if vEE  then vEE.Text   = "+" .. tostring(earned) end
    if vRK  then vRK.Text   = GetRank() end
    if vST  then vST.Text   = FormatTime(now - S.SessionStart) end
    if vPL  then vPL.Text   = #Players:GetPlayers() .. "/" .. Players.MaxPlayers end
    if vFPS then vFPS.Text  = fpsN .. " fps" end
    if vPNG then pcall(function() vPNG.Text = math.floor(LP:GetNetworkPing()*1000).." ms" end) end
    if vEGM then vEGM.Text  = #FindEggParts() .. " eggs" end
    if vMST then vMST.Text  = #FindMisters()  .. " aktif" end
end)

-- ================================================================
-- RESPAWN REBIND
-- ================================================================
LP.CharacterAdded:Connect(function()
    task.wait(0.6)
    if S.SpeedHack then
        local h = GetHum()
        if h then h.WalkSpeed = S.SpeedValue end
    end
    if S.Godmode then
        RunService:BindToRenderStep("Godmode", 200, function()
            local h = GetHum()
            if h then h.Health = h.MaxHealth end
        end)
    end
    if S.AntiHit then
        RunService:BindToRenderStep("AntiHit", 200, function()
            local hrp = GetHRP()
            if not hrp then return end
            for _, m in ipairs(FindMisters()) do
                if m.hrp and m.hrp.Parent then
                    local d = (m.hrp.Position - hrp.Position).Magnitude
                    if d < S.AntiHitRange then
                        local dir = (hrp.Position - m.hrp.Position).Unit
                        hrp.CFrame = hrp.CFrame + dir * (S.AntiHitRange - d + 18)
                    end
                end
            end
        end)
    end
end)

-- ================================================================
-- KEYBIND: RightShift toggle UI
-- ================================================================
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        S.Visible  = not S.Visible
        MF.Visible = S.Visible
    end
end)

-- ================================================================
-- CLOSE BUTTON
-- ================================================================
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MF, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size     = UDim2.new(0, MW, 0, 0),
        Position = UDim2.new(MF.Position.X.Scale, MF.Position.X.Offset, 0.5, 0),
    }):Play()
    task.delay(0.25, function() SG:Destroy() end)
end)

-- ================================================================
-- INIT — Slide in dari kiri
-- ================================================================
SwitchTab("Home")

task.spawn(function()
    task.wait(0.05)
    TweenService:Create(MF, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 20, 0.5, -MH/2),
    }):Play()
end)

-- Toast
task.spawn(function()
    local toast = Instance.new("Frame", SG)
    toast.Size             = UDim2.new(0, 228, 0, 32)
    toast.Position         = UDim2.new(0.5, -114, 1, 14)
    toast.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
    toast.BorderSizePixel  = 0
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)
    local ts = Instance.new("UIStroke", toast)
    ts.Color = Color3.fromRGB(210,35,35); ts.Thickness=1; ts.Transparency=0.45
    local tl = Instance.new("TextLabel", toast)
    tl.Size                   = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text                   = "🐜  ANTS TEAM v3.0 loaded  ·  RShift = hide"
    tl.TextColor3             = Color3.fromRGB(215, 215, 215)
    tl.TextSize               = 11
    tl.Font                   = Enum.Font.GothamBold

    TweenService:Create(toast, TweenInfo.new(0.32, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -114, 1, -42),
    }):Play()
    task.wait(3.2)
    TweenService:Create(toast, TweenInfo.new(0.26), {
        Position = UDim2.new(0.5, -114, 1, 14),
    }):Play()
    task.delay(0.3, function() toast:Destroy() end)
end)

print("🐜 ANTS TEAM v3.0 | Loaded | RShift = toggle UI")