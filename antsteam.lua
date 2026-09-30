-- ================================================================
--  🐜 ANTS TEAM v4.1 | ANDROID EDITION
--  Close = Minimize (bukan exit) | Floating icon untuk open/close
-- ================================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================================================================
-- STATE
-- ================================================================
local S = {
    AntiHit=false, AntiHitRange=30,
    FreezeMister=false, Godmode=false, AntiTouch=false,
    SpeedHack=false, SpeedValue=24, CurrentSpeed=16, TargetSpeed=16,
    NoClip=false, InfJump=false, AutoTP=false, AutoSteal=false,
    EggESP=false, MisterESP=false,
    LowGfx=false, Visible=true,
    ReachEnabled=true,
    EggsStart=0, SessionStart=tick(),
    Minimized=false,
}

-- ================================================================
-- CLEANUP
-- ================================================================
pcall(function()
    local t = (gethui and gethui()) or LP.PlayerGui
    local old = t:FindFirstChild("ANTS_V41")
    if old then old:Destroy() end
end)

-- ================================================================
-- CACHE
-- ================================================================
local Cache = {Eggs={}, Misters={}, Base=nil, EggT=0, MisT=0, BaseT=0}

local function ScanEggs()
    if tick() - Cache.EggT < 2 then return Cache.Eggs end
    Cache.EggT = tick()
    local l = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") and o.Name:lower():find("egg") then table.insert(l, o) end
    end
    Cache.Eggs = l
    return l
end

local function ScanMisters()
    if tick() - Cache.MisT < 1.5 then return Cache.Misters end
    Cache.MisT = tick()
    local l = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        local n = o.Name:lower()
        if o:IsA("Model") and (n:find("mister") or n:find("mr%.") or n:find("enemy") or n:find("boss") or n:find("chaser")) then
            local hrp = o:FindFirstChild("HumanoidRootPart")
            local hum = o:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                table.insert(l, {model=o, hrp=hrp, hum=hum})
            end
        end
    end
    Cache.Misters = l
    return l
end

local function ScanBase()
    if Cache.Base and Cache.Base.Parent and tick() - Cache.BaseT < 5 then return Cache.Base end
    Cache.BaseT = tick()
    for _, o in ipairs(workspace:GetDescendants()) do
        local n = o.Name:lower()
        if o:IsA("BasePart") and (n:find("base") or n:find("home") or n:find("nest") or n:find("drop") or n:find("deliver")) then
            Cache.Base = o; return o
        end
    end
    Cache.Base = workspace:FindFirstChildOfClass("SpawnLocation")
    return Cache.Base
end

-- ================================================================
-- UTILS
-- ================================================================
local function GetChar() return LP.Character end
local function GetHRP() local c=LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum() local c=LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end

local function GetEggs()
    local ls = LP:FindFirstChild("leaderstats") or LP:FindFirstChild("PlayerData")
    if ls then
        for _, n in ipairs({"Eggs","Money","Cash","Coins","Score","Points","Gold"}) do
            local v = ls:FindFirstChild(n)
            if v then return v.Value end
        end
    end
    return 0
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

-- ================================================================
-- PROXIMITY PROMPT (steal dari jauh)
-- ================================================================
local function FindPrompt(obj)
    if not obj then return nil end
    local pp = obj:FindFirstChildOfClass("ProximityPrompt")
    if pp then return pp end
    if obj.Parent then
        pp = obj.Parent:FindFirstChildOfClass("ProximityPrompt")
        if pp then return pp end
        for _, c in ipairs(obj.Parent:GetChildren()) do
            pp = c:FindFirstChildOfClass("ProximityPrompt")
            if pp then return pp end
        end
    end
    for _, c in ipairs(obj:GetChildren()) do
        pp = c:FindFirstChildOfClass("ProximityPrompt")
        if pp then return pp end
    end
    return nil
end

local function FirePrompt(pp)
    if not pp then return false end
    pcall(function()
        pcall(function() pp.MaxActivationDistance = 9999 end)
        pcall(function() pp.HoldDuration = 0 end)
        pcall(function() pp.RequiresLineOfSight = false end)
        if fireproximityprompt then
            fireproximityprompt(pp, 0)
        end
    end)
    return true
end

-- ================================================================
-- GUI
-- ================================================================
local SG = Instance.new("ScreenGui")
SG.Name           = "ANTS_V41"
SG.ResetOnSpawn   = false
SG.DisplayOrder   = 999
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() SG.Parent = (gethui and gethui()) or LP.PlayerGui end)
if not SG.Parent then SG.Parent = LP.PlayerGui end

-- Palette
local C = {
    Bg      = Color3.fromRGB(15, 15, 15),
    BgDark  = Color3.fromRGB(10, 10, 10),
    Panel   = Color3.fromRGB(24, 24, 24),
    Panel2  = Color3.fromRGB(32, 32, 32),
    Panel3  = Color3.fromRGB(40, 40, 40),
    Border  = Color3.fromRGB(58, 58, 58),
    Accent  = Color3.fromRGB(200, 30, 30),
    Accent2 = Color3.fromRGB(255, 60, 60),
    Text    = Color3.fromRGB(230, 230, 230),
    TextDim = Color3.fromRGB(150, 150, 150),
    TextMut = Color3.fromRGB(90, 90, 90),
}

-- Ukuran khusus Android (compact)
local MW, MH, SW = 400, 380, 110
local CW = MW - SW

-- ================================================================
-- MAIN FRAME
-- ================================================================
local MF = Instance.new("Frame", SG)
MF.Size             = UDim2.new(0, MW, 0, MH)
MF.Position         = UDim2.new(0, -MW - 30, 0.5, -MH/2)
MF.BackgroundColor3 = C.BgDark
MF.BorderSizePixel  = 0
MF.Active           = true
MF.Visible          = false -- start hidden, animate in
Instance.new("UICorner", MF).CornerRadius = UDim.new(0, 4)

local MFB = Instance.new("UIStroke", MF)
MFB.Color = C.Border; MFB.Thickness = 1

-- ================================================================
-- FLOATING ICON (Open/Close toggle) — Android friendly
-- ================================================================
local IconBtn = Instance.new("TextButton", SG)
IconBtn.Size             = UDim2.new(0, 46, 0, 46)
IconBtn.Position         = UDim2.new(0, 20, 0.5, -23)
IconBtn.BackgroundColor3 = C.BgDark
IconBtn.Text             = "🐜"
IconBtn.TextSize         = 24
IconBtn.Font             = Enum.Font.GothamBold
IconBtn.BorderSizePixel  = 0
IconBtn.AutoButtonColor  = false
IconBtn.ZIndex           = 100
Instance.new("UICorner", IconBtn).CornerRadius = UDim.new(1, 0)

local IconStroke = Instance.new("UIStroke", IconBtn)
IconStroke.Color = C.Accent; IconStroke.Thickness = 2

-- Icon drag (Android touch friendly)
do
    local dragging, dragStart, startPos, moved
    IconBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = IconBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            if math.abs(d.X) > 5 or math.abs(d.Y) > 5 then moved = true end
            IconBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and not moved then
                -- Tap → toggle panel
                TogglePanel()
            end
            dragging = false
        end
    end)
end

-- ================================================================
-- TITLE BAR
-- ================================================================
local TitleBar = Instance.new("Frame", MF)
TitleBar.Size             = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = C.Bg
TitleBar.BorderSizePixel  = 0
TitleBar.ZIndex           = 5
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 4)

local Accent = Instance.new("Frame", TitleBar)
Accent.Size             = UDim2.new(1, 0, 0, 2)
Accent.Position         = UDim2.new(0, 0, 1, -2)
Accent.BackgroundColor3 = C.Accent
Accent.BorderSizePixel  = 0
Accent.ZIndex           = 6

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size             = UDim2.new(0.75, 0, 1, 0)
TitleLbl.Position         = UDim2.new(0, 12, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text             = "🐜 ANTS TEAM  ::  v4.1"
TitleLbl.TextColor3       = C.Accent2
TitleLbl.TextSize         = 13
TitleLbl.Font             = Enum.Font.GothamBold
TitleLbl.TextXAlignment   = Enum.TextXAlignment.Left
TitleLbl.ZIndex           = 7

-- Minimize button (bukan close/exit)
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size             = UDim2.new(0, 34, 0, 22)
MinBtn.Position         = UDim2.new(1, -40, 0, 3)
MinBtn.BackgroundColor3 = C.Panel2
MinBtn.Text             = "—"
MinBtn.TextColor3       = C.Text
MinBtn.TextSize         = 16
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.BorderSizePixel  = 0
MinBtn.ZIndex           = 8
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 3)

-- ================================================================
-- DRAG PANEL (title bar only biar ga bentrok scrolling)
-- ================================================================
do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MF.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            MF.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ================================================================
-- SIDEBAR
-- ================================================================
local SB = Instance.new("Frame", MF)
SB.Size             = UDim2.new(0, SW, 1, -28)
SB.Position         = UDim2.new(0, 0, 0, 28)
SB.BackgroundColor3 = C.Bg
SB.BorderSizePixel  = 0
SB.ZIndex           = 3

local SBLine = Instance.new("Frame", SB)
SBLine.Size             = UDim2.new(0, 1, 1, 0)
SBLine.Position         = UDim2.new(1, -1, 0, 0)
SBLine.BackgroundColor3 = C.Border
SBLine.BorderSizePixel  = 0
SBLine.ZIndex           = 3

-- Logo header
local LogoArea = Instance.new("Frame", SB)
LogoArea.Size             = UDim2.new(1, 0, 0, 52)
LogoArea.BackgroundColor3 = C.BgDark
LogoArea.BorderSizePixel  = 0
LogoArea.ZIndex           = 4

local LOGO_ASSET = "rbxassetid://12640721857" -- ganti dengan ID logo kamu
local LogoImg = Instance.new("ImageLabel", LogoArea)
LogoImg.Size                = UDim2.new(0, 32, 0, 32)
LogoImg.Position            = UDim2.new(0, 10, 0.5, -16)
LogoImg.BackgroundTransparency = 1
LogoImg.Image               = LOGO_ASSET
LogoImg.ScaleType           = Enum.ScaleType.Fit
LogoImg.ZIndex              = 5

local LogoFallback = Instance.new("TextLabel", LogoArea)
LogoFallback.Size             = UDim2.new(0, 32, 0, 32)
LogoFallback.Position         = UDim2.new(0, 10, 0.5, -16)
LogoFallback.BackgroundTransparency = 1
LogoFallback.Text             = "🐜"
LogoFallback.TextSize         = 22
LogoFallback.Visible          = false
LogoFallback.ZIndex           = 5

LogoImg.ImageFailed:Connect(function()
    LogoImg.Visible = false; LogoFallback.Visible = true
end)

local LogoName = Instance.new("TextLabel", LogoArea)
LogoName.Size             = UDim2.new(1, -50, 0, 16)
LogoName.Position         = UDim2.new(0, 48, 0, 10)
LogoName.BackgroundTransparency = 1
LogoName.Text             = "ANTS TEAM"
LogoName.TextColor3       = C.Text
LogoName.TextSize         = 12
LogoName.Font             = Enum.Font.GothamBold
LogoName.TextXAlignment   = Enum.TextXAlignment.Left
LogoName.ZIndex           = 5

local LogoSub = Instance.new("TextLabel", LogoArea)
LogoSub.Size             = UDim2.new(1, -50, 0, 12)
LogoSub.Position         = UDim2.new(0, 48, 0, 28)
LogoSub.BackgroundTransparency = 1
LogoSub.Text             = "steal an egg"
LogoSub.TextColor3       = C.TextMut
LogoSub.TextSize         = 10
LogoSub.Font             = Enum.Font.Gotham
LogoSub.TextXAlignment   = Enum.TextXAlignment.Left
LogoSub.ZIndex           = 5

local Sep = Instance.new("Frame", SB)
Sep.Size             = UDim2.new(1, 0, 0, 1)
Sep.Position         = UDim2.new(0, 0, 0, 52)
Sep.BackgroundColor3 = C.Border
Sep.BorderSizePixel  = 0
Sep.ZIndex           = 4

-- Tab container (scrollable buat layar kecil)
local TabScroll = Instance.new("ScrollingFrame", SB)
TabScroll.Size             = UDim2.new(1, 0, 1, -52)
TabScroll.Position         = UDim2.new(0, 0, 0, 52)
TabScroll.BackgroundTransparency = 1
TabScroll.BorderSizePixel  = 0
TabScroll.ScrollBarThickness = 2
TabScroll.ScrollBarImageColor3 = C.Accent
TabScroll.CanvasSize       = UDim2.new(0, 0, 0, 0)
TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabScroll.ZIndex           = 4

local TLayout = Instance.new("UIListLayout", TabScroll)
TLayout.Padding = UDim.new(0, 0)
TLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ================================================================
-- CONTENT
-- ================================================================
local CA = Instance.new("Frame", MF)
CA.Size             = UDim2.new(0, CW, 1, -28)
CA.Position         = UDim2.new(0, SW, 0, 28)
CA.BackgroundColor3 = C.BgDark
CA.BorderSizePixel  = 0
CA.ClipsDescendants = true
CA.ZIndex           = 2

-- ================================================================
-- TAB SYSTEM
-- ================================================================
local Pages, TabBtns = {}, {}

local function NewPage(name)
    local sf = Instance.new("ScrollingFrame", CA)
    sf.Name                 = name
    sf.Size                 = UDim2.new(1, 0, 1, 0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel      = 0
    sf.ScrollBarThickness   = 3
    sf.ScrollBarImageColor3 = C.Accent
    sf.CanvasSize           = UDim2.new(0, 0, 0, 0)
    sf.AutomaticCanvasSize  = Enum.AutomaticSize.Y
    sf.Visible              = false
    sf.ZIndex               = 2
    sf.ElasticBehavior      = Enum.ElasticBehavior.WhenScrollable

    local ll = Instance.new("UIListLayout", sf)
    ll.Padding             = UDim.new(0, 4)
    ll.HorizontalAlignment = Enum.HorizontalAlignment.Left
    ll.SortOrder           = Enum.SortOrder.LayoutOrder

    local pd = Instance.new("UIPadding", sf)
    pd.PaddingTop    = UDim.new(0, 8)
    pd.PaddingBottom = UDim.new(0, 14)
    pd.PaddingLeft   = UDim.new(0, 10)
    pd.PaddingRight  = UDim.new(0, 8)

    Pages[name] = sf
    return sf
end

local function SwitchTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(TabBtns) do
        local active = (n == name)
        b.bg.BackgroundColor3 = active and C.Panel2 or C.Bg
        b.bar.Visible         = active
        b.lbl.TextColor3      = active and C.Text or C.TextDim
        b.ico.TextColor3      = active and C.Accent2 or C.TextDim
    end
end

local function NewTabBtn(name, icon, label)
    local btn = Instance.new("TextButton", TabScroll)
    btn.Size             = UDim2.new(1, 0, 0, 36)
    btn.BackgroundTransparency = 1
    btn.Text             = ""
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 5
    btn.LayoutOrder      = #TabBtns
    btn.AutoButtonColor  = false

    local bg = Instance.new("Frame", btn)
    bg.Size             = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = C.Bg
    bg.BorderSizePixel  = 0
    bg.ZIndex           = 5

    local bar = Instance.new("Frame", bg)
    bar.Size             = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = C.Accent
    bar.BorderSizePixel  = 0
    bar.Visible          = false
    bar.ZIndex           = 6

    local ico = Instance.new("TextLabel", bg)
    ico.Size             = UDim2.new(0, 26, 1, 0)
    ico.Position         = UDim2.new(0, 10, 0, 0)
    ico.BackgroundTransparency = 1
    ico.Text             = icon
    ico.TextSize         = 15
    ico.TextColor3       = C.TextDim
    ico.Font             = Enum.Font.GothamBold
    ico.ZIndex           = 6

    local lbl = Instance.new("TextLabel", bg)
    lbl.Size             = UDim2.new(1, -46, 1, 0)
    lbl.Position         = UDim2.new(0, 42, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = label
    lbl.TextColor3       = C.TextDim
    lbl.TextSize         = 12
    lbl.Font             = Enum.Font.Gotham
    lbl.TextXAlignment   = Enum.TextXAlignment.Left
    lbl.ZIndex           = 6

    btn.Activated:Connect(function() SwitchTab(name) end)

    TabBtns[name] = {bg=bg, bar=bar, ico=ico, lbl=lbl}
    return btn
end

-- ================================================================
-- WIDGETS
-- ================================================================
local function SectionLabel(parent, text, order)
    local f = Instance.new("Frame", parent)
    f.Size             = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.LayoutOrder      = order

    local line = Instance.new("Frame", f)
    line.Size             = UDim2.new(0, 3, 0, 12)
    line.Position         = UDim2.new(0, 0, 0.5, -6)
    line.BackgroundColor3 = C.Accent
    line.BorderSizePixel  = 0

    local l = Instance.new("TextLabel", f)
    l.Size             = UDim2.new(1, -12, 1, 0)
    l.Position         = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text             = string.upper(text)
    l.TextColor3       = C.Accent2
    l.TextSize         = 11
    l.Font             = Enum.Font.GothamBold
    l.TextXAlignment   = Enum.TextXAlignment.Left
end

local function Spacer(parent, h, order)
    local f = Instance.new("Frame", parent)
    f.Size             = UDim2.new(1, 0, 0, h or 4)
    f.BackgroundTransparency = 1
    f.LayoutOrder      = order
end

-- ANDROID CHECKBOX (tap area lebih besar)
local function NewCheckbox(parent, label, order, default, cb)
    local row = Instance.new("Frame", parent)
    row.Size             = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = C.Panel
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

    local box = Instance.new("Frame", row)
    box.Size             = UDim2.new(0, 18, 0, 18)
    box.Position         = UDim2.new(0, 8, 0.5, -9)
    box.BackgroundColor3 = C.Panel2
    box.BorderSizePixel  = 1
    box.BorderColor3     = C.Border
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)

    local check = Instance.new("Frame", box)
    check.Size             = UDim2.new(0, 12, 0, 12)
    check.Position         = UDim2.new(0.5, -6, 0.5, -6)
    check.BackgroundColor3 = C.Accent
    check.BorderSizePixel  = 0
    check.Visible          = default or false
    Instance.new("UICorner", check).CornerRadius = UDim.new(0, 2)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size             = UDim2.new(1, -40, 1, 0)
    lbl.Position         = UDim2.new(0, 34, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text             = label
    lbl.TextColor3       = C.Text
    lbl.TextSize         = 12
    lbl.Font             = Enum.Font.Gotham
    lbl.TextXAlignment   = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", row)
    btn.Size             = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text             = ""
    btn.ZIndex           = 5
    btn.AutoButtonColor  = false

    local on = default or false

    btn.Activated:Connect(function()
        on = not on
        check.Visible = on
        if on then
            box.BackgroundColor3 = C.Accent
            box.BorderColor3     = C.Accent
        else
            box.BackgroundColor3 = C.Panel2
            box.BorderColor3     = C.Border
        end
        cb(on)
    end)

    -- Init visual state
    if on then
        box.BackgroundColor3 = C.Accent
        box.BorderColor3     = C.Accent
    end

    return function() return on end
end

-- ANDROID SLIDER (touch friendly, thumb lebih besar)
local function NewSlider(parent, label, order, minV, maxV, def, cb)
    local row = Instance.new("Frame", parent)
    row.Size             = UDim2.new(1, 0, 0, 46)
    row.BackgroundColor3 = C.Panel
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size             = UDim2.new(0.6, 0, 0, 16)
    lbl.Position         = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text             = label
    lbl.TextColor3       = C.Text
    lbl.TextSize         = 12
    lbl.Font             = Enum.Font.Gotham
    lbl.TextXAlignment   = Enum.TextXAlignment.Left

    local valL = Instance.new("TextLabel", row)
    valL.Size             = UDim2.new(0.4, -10, 0, 16)
    valL.Position         = UDim2.new(0.6, 0, 0, 6)
    valL.BackgroundTransparency = 1
    valL.Text             = tostring(def)
    valL.TextColor3       = C.Accent2
    valL.TextSize         = 13
    valL.Font             = Enum.Font.GothamBold
    valL.TextXAlignment   = Enum.TextXAlignment.Right

    -- Track lebih tebal & thumb besar (buat jari)
    local track = Instance.new("Frame", row)
    track.Size             = UDim2.new(1, -24, 0, 6)
    track.Position         = UDim2.new(0, 12, 0, 30)
    track.BackgroundColor3 = C.Panel2
    track.BorderSizePixel  = 0
    track.ZIndex           = 2
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local pct0 = (def - minV) / (maxV - minV)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new(pct0, 0, 1, 0)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 3
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", track)
    thumb.Size             = UDim2.new(0, 20, 0, 20)
    thumb.Position         = UDim2.new(pct0, -10, 0.5, -10)
    thumb.BackgroundColor3 = C.Text
    thumb.BorderSizePixel  = 0
    thumb.ZIndex           = 4
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local cur = def

    local btn = Instance.new("TextButton", row)
    btn.Size             = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text             = ""
    btn.ZIndex           = 6
    btn.AutoButtonColor  = false

    local function apply(mx)
        local a = track.AbsolutePosition.X
        local w = track.AbsoluteSize.X
        local p = math.clamp((mx - a) / w, 0, 1)
        cur = math.floor(minV + (maxV - minV) * p + 0.5)
        fill.Size      = UDim2.new(p, 0, 1, 0)
        thumb.Position = UDim2.new(p, -10, 0.5, -10)
        valL.Text      = tostring(cur)
        cb(cur)
    end

    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            apply(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            apply(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return function() return cur end
end

local function InfoLine(parent, key, order)
    local row = Instance.new("Frame", parent)
    row.Size             = UDim2.new(1, 0, 0, 26)
    row.BackgroundColor3 = C.Panel
    row.BorderSizePixel  = 0
    row.LayoutOrder      = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 3)

    local k = Instance.new("TextLabel", row)
    k.Size             = UDim2.new(0.55, -10, 1, 0)
    k.Position         = UDim2.new(0, 10, 0, 0)
    k.BackgroundTransparency = 1
    k.Text             = key
    k.TextColor3       = C.TextDim
    k.TextSize         = 11
    k.Font             = Enum.Font.Gotham
    k.TextXAlignment   = Enum.TextXAlignment.Left

    local v = Instance.new("TextLabel", row)
    v.Size             = UDim2.new(0.45, -10, 1, 0)
    v.Position         = UDim2.new(0.55, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text             = "..."
    v.TextColor3       = C.Accent2
    v.TextSize         = 12
    v.Font             = Enum.Font.GothamBold
    v.TextXAlignment   = Enum.TextXAlignment.Right

    return v
end

-- ================================================================
-- TABS
-- ================================================================
NewTabBtn("Home",   "H", "Dashboard")
NewTabBtn("Combat", "C", "Combat")
NewTabBtn("Steal",  "S", "Auto Steal")
NewTabBtn("ESP",    "E", "Visuals")
NewTabBtn("Move",   "M", "Movement")
NewTabBtn("Misc",   "X", "Misc")

local PHome   = NewPage("Home")
local PCombat = NewPage("Combat")
local PSteal  = NewPage("Steal")
local PESP    = NewPage("ESP")
local PMove   = NewPage("Move")
local PMisc   = NewPage("Misc")

-- HOME
SectionLabel(PHome, "Session", 1)
local vEggs    = InfoLine(PHome, "Eggs", 2)
local vEarned  = InfoLine(PHome, "Earned", 3)
local vRank    = InfoLine(PHome, "Rank", 4)
local vTime    = InfoLine(PHome, "Time", 5)
Spacer(PHome, 4, 6)
SectionLabel(PHome, "Server", 7)
local vPlayers = InfoLine(PHome, "Players", 8)
local vFPS     = InfoLine(PHome, "FPS", 9)
local vPing    = InfoLine(PHome, "Ping", 10)
local vEggsMap = InfoLine(PHome, "Eggs on Map", 11)
local vMisters = InfoLine(PHome, "Misters", 12)

-- COMBAT
SectionLabel(PCombat, "Anti Hit", 1)
NewCheckbox(PCombat, "Anti-Hit (auto dodge)", 2, false, function(on)
    S.AntiHit = on
    RunService:UnbindFromRenderStep("AntiHit")
    if on then
        RunService:BindToRenderStep("AntiHit", 200, function()
            if not S.AntiHit then return end
            local hrp = GetHRP(); if not hrp then return end
            for _, m in ipairs(ScanMisters()) do
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

NewCheckbox(PCombat, "Freeze Mister", 3, false, function(on)
    S.FreezeMister = on
    RunService:UnbindFromRenderStep("FreezeMister")
    if on then
        RunService:BindToRenderStep("FreezeMister", 150, function()
            if not S.FreezeMister then return end
            for _, m in ipairs(ScanMisters()) do
                pcall(function() m.hum.WalkSpeed=0; m.hum.JumpPower=0; m.hrp.Anchored=true end)
            end
        end)
    else
        for _, m in ipairs(ScanMisters()) do
            pcall(function() m.hum.WalkSpeed=16; m.hum.JumpPower=50; m.hrp.Anchored=false end)
        end
    end
end)

Spacer(PCombat, 4, 4)
SectionLabel(PCombat, "Player", 5)

NewCheckbox(PCombat, "Godmode", 6, false, function(on)
    S.Godmode = on
    RunService:UnbindFromRenderStep("Godmode")
    if on then
        RunService:BindToRenderStep("Godmode", 200, function()
            local h = GetHum(); if h and h.Health < h.MaxHealth then h.Health = h.MaxHealth end
        end)
    end
end)

NewCheckbox(PCombat, "Anti Touch", 7, false, function(on)
    S.AntiTouch = on
    RunService:UnbindFromRenderStep("AntiTouch")
    if on then
        RunService:BindToRenderStep("AntiTouch", 200, function()
            local c = GetChar(); if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanTouch = false end
            end
        end)
    else
        local c = GetChar(); if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanTouch = true end
        end
    end
end)

-- STEAL (FITUR UTAMA)
SectionLabel(PSteal, "Auto Steal Egg", 1)

NewCheckbox(PSteal, "Auto Steal Terdekat", 2, false, function(on)
    S.AutoSteal = on
    RunService:UnbindFromRenderStep("AutoSteal")
    if on then
        RunService:BindToRenderStep("AutoSteal", 400, function()
            if not S.AutoSteal then return end
            local hrp = GetHRP(); if not hrp then return end
            local best, bd = nil, math.huge
            for _, obj in ipairs(ScanEggs()) do
                if obj.Parent then
                    local d = (obj.Position - hrp.Position).Magnitude
                    if d < bd then bd = d; best = obj end
                end
            end
            if best then
                hrp.CFrame = CFrame.new(best.Position + Vector3.new(0, 4, 0))
                task.wait(0.05)
                local pp = FindPrompt(best)
                if pp then FirePrompt(pp) end
            end
        end)
    end
end)

NewCheckbox(PSteal, "Reach (steal dari jauh)", 3, true, function(on)
    S.ReachEnabled = on
    -- Metatable patch
    local mt = getrawmetatable and getrawmetatable(game)
    if mt and setreadonly then
        if not S._mtPatched then
            S._mtPatched = true
            local oldIdx = mt.__index
            setreadonly(mt, false)
            mt.__index = newcclosure(function(self, k)
                if S.ReachEnabled and k == "MaxActivationDistance" and typeof(self) == "Instance" and self:IsA("ProximityPrompt") then
                    return 32
                end
                return oldIdx(self, k)
            end)
            setreadonly(mt, true)
        end
    end
end)

Spacer(PSteal, 4, 4)
SectionLabel(PSteal, "Auto TP Base", 5)

NewCheckbox(PSteal, "Auto TP Base (bawa egg)", 6, false, function(on)
    S.AutoTP = on
    RunService:UnbindFromRenderStep("AutoTP")
    if on then
        RunService:BindToRenderStep("AutoTP", 300, function()
            if not S.AutoTP then return end
            local c = GetChar(); if not c then return end
            local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end

            local hasEgg = false
            for _, obj in ipairs(c:GetDescendants()) do
                if obj.Name:lower():find("egg") then hasEgg = true; break end
            end
            if not hasEgg and LP.Backpack then
                for _, obj in ipairs(LP.Backpack:GetDescendants()) do
                    if obj.Name:lower():find("egg") then hasEgg = true; break end
                end
            end

            if hasEgg then
                local base = ScanBase()
                if base and base.Parent then
                    hrp.CFrame = CFrame.new(base.Position + Vector3.new(0, 5.5, 0))
                    task.wait(0.1)
                    local pp = FindPrompt(base)
                    if pp then FirePrompt(pp) end
                end
            end
        end)
    end
end)

NewCheckbox(PSteal, "TP ke Base Sekarang", 7, false, function(on)
    if on then
        local base = ScanBase()
        local hrp = GetHRP()
        if base and hrp then
            hrp.CFrame = CFrame.new(base.Position + Vector3.new(0, 5.5, 0))
            task.wait(0.05)
            local pp = FindPrompt(base)
            if pp then FirePrompt(pp) end
        end
    end
end)

Spacer(PSteal, 8, 8)
SectionLabel(PSteal, "Info", 9)
local InfoTxt = Instance.new("TextLabel", PSteal)
InfoTxt.Size             = UDim2.new(1, -4, 0, 76)
InfoTxt.BackgroundColor3 = C.Panel
InfoTxt.BorderSizePixel  = 0
InfoTxt.Text             = "  Auto Steal:\n  1. Cari egg terdekat\n  2. TP ke atas egg\n  3. Fire prompt (bypass jarak)\n\n  Reach 32 = ambil dari jauh."
InfoTxt.TextColor3       = C.TextMut
InfoTxt.TextSize         = 10
InfoTxt.Font             = Enum.Font.Gotham
InfoTxt.TextWrapped      = true
InfoTxt.TextXAlignment   = Enum.TextXAlignment.Left
InfoTxt.TextYAlignment   = Enum.TextYAlignment.Top
InfoTxt.LayoutOrder      = 10
Instance.new("UICorner", InfoTxt).CornerRadius = UDim.new(0, 3)

-- ESP
local EggESPList, MisterESPList = {}, {}

local function ClearESP(list)
    for _, v in ipairs(list) do pcall(function() v:Destroy() end) end
    for i = #list, 1, -1 do list[i] = nil end
end

local function BuildEggESP()
    ClearESP(EggESPList)
    for _, obj in ipairs(ScanEggs()) do
        if obj.Parent then
            local hl = Instance.new("BoxHandleAdornment")
            hl.Adornee = obj
            hl.Size = obj.Size + Vector3.new(0.3,0.3,0.3)
            hl.Color3 = Color3.fromRGB(255, 210, 0)
            hl.Transparency = 0.55
            hl.AlwaysOnTop = true
            hl.ZIndex = 5
            hl.Parent = SG
            table.insert(EggESPList, hl)
        end
    end
end

local function BuildMisterESP()
    ClearESP(MisterESPList)
    for _, m in ipairs(ScanMisters()) do
        if m.hrp.Parent then
            local hl = Instance.new("Highlight")
            hl.Adornee = m.model
            hl.FillColor = Color3.fromRGB(255, 40, 40)
            hl.OutlineColor = Color3.fromRGB(255, 200, 200)
            hl.FillTransparency = 0.55
            hl.OutlineTransparency = 0.1
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = SG
            table.insert(MisterESPList, hl)
        end
    end
end

SectionLabel(PESP, "Egg ESP", 1)
NewCheckbox(PESP, "Egg ESP (kotak emas)", 2, false, function(on)
    S.EggESP = on
    RunService:UnbindFromRenderStep("EggESPLoop")
    if on then
        BuildEggESP()
        local last = 0
        RunService:BindToRenderStep("EggESPLoop", 2, function()
            if tick() - last > 3 then last = tick(); BuildEggESP() end
        end)
    else
        ClearESP(EggESPList)
    end
end)

Spacer(PESP, 3, 3)
SectionLabel(PESP, "Mister ESP", 4)
NewCheckbox(PESP, "Mister ESP (highlight)", 5, false, function(on)
    S.MisterESP = on
    RunService:UnbindFromRenderStep("MisESPLoop")
    if on then
        BuildMisterESP()
        local last = 0
        RunService:BindToRenderStep("MisESPLoop", 2, function()
            if tick() - last > 2 then last = tick(); BuildMisterESP() end
        end)
    else
        ClearESP(MisterESPList)
    end
end)

-- MOVE
SectionLabel(PMove, "Speed", 1)
NewSlider(PMove, "Target Speed", 2, 16, 120, 24, function(v)
    S.SpeedValue = v
    if S.SpeedHack then S.TargetSpeed = v end
end)

NewCheckbox(PMove, "Speed Bypass", 3, false, function(on)
    S.SpeedHack = on
    RunService:UnbindFromRenderStep("SpeedBypass")
    if on then
        S.TargetSpeed = S.SpeedValue
        S.CurrentSpeed = 16
        local t = 0
        RunService:BindToRenderStep("SpeedBypass", 100, function()
            if not S.SpeedHack then return end
            local h = GetHum(); if not h then return end
            if S.CurrentSpeed < S.TargetSpeed then
                S.CurrentSpeed = math.min(S.CurrentSpeed + 0.7, S.TargetSpeed)
            elseif S.CurrentSpeed > S.TargetSpeed then
                S.CurrentSpeed = math.max(S.CurrentSpeed - 1.2, S.TargetSpeed)
            end
            t += 0.08
            h.WalkSpeed = S.CurrentSpeed + math.sin(t*2.1)*0.28 + math.cos(t*1.6)*0.18
        end)
    else
        local h = GetHum(); if h then h.WalkSpeed = 16 end
        S.CurrentSpeed = 16
    end
end)

Spacer(PMove, 4, 4)
SectionLabel(PMove, "Movement", 5)

NewCheckbox(PMove, "No-Clip", 6, false, function(on)
    S.NoClip = on
    RunService:UnbindFromRenderStep("NoClip")
    if on then
        RunService:BindToRenderStep("NoClip", 200, function()
            local c = GetChar(); if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end
end)

NewCheckbox(PMove, "Infinite Jump", 7, false, function(on) S.InfJump = on end)

UserInputService.JumpRequest:Connect(function()
    if S.InfJump then
        local h = GetHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- MISC
SectionLabel(PMisc, "Graphics", 1)
NewCheckbox(PMisc, "Low Graphics (FPS Boost)", 2, false, function(on)
    S.LowGfx = on
    if on then
        S._origGS = Lighting.GlobalShadows
        S._origBr = Lighting.Brightness
        S._origFog = Lighting.FogEnd
        pcall(function() S._origQ = settings().Rendering.QualityLevel end)
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 2.5
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke")
            or obj:IsA("Sparkles") or obj:IsA("Trail") then obj.Enabled = false end
            if obj:IsA("BasePart") then obj.CastShadow = false end
        end
    else
        Lighting.GlobalShadows = S._origGS or true
        Lighting.Brightness = S._origBr or 2
        Lighting.FogEnd = S._origFog or 100000
        pcall(function() settings().Rendering.QualityLevel = S._origQ or 10 end)
    end
end)

NewCheckbox(PMisc, "Remove Shadows", 3, false, function(on)
    Lighting.GlobalShadows = not on
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then obj.CastShadow = not on end
    end
end)

NewCheckbox(PMisc, "Hide Chat", 4, false, function(on)
    pcall(function()
        local ch = LP.PlayerGui:FindFirstChild("Chat")
        if ch then ch.Enabled = not on end
    end)
end)

-- ================================================================
-- STATS LOOP
-- ================================================================
local fpsN, fpsC, fpsT = 60, 0, 0
RunService.Heartbeat:Connect(function(dt)
    fpsC += 1; fpsT += dt
    if fpsT >= 0.5 then fpsN = math.floor(fpsC/fpsT); fpsC = 0; fpsT = 0 end
end)

task.spawn(function()
    while SG.Parent do
        local eggs = GetEggs()
        if S.EggsStart == 0 and eggs ~= 0 then S.EggsStart = eggs end
        if vEggs    then vEggs.Text    = tostring(eggs) end
        if vEarned  then vEarned.Text  = "+"..tostring(math.max(0, eggs - S.EggsStart)) end
        if vRank    then vRank.Text    = GetRank() end
        if vTime    then vTime.Text    = FormatTime(tick() - S.SessionStart) end
        if vPlayers then vPlayers.Text = #Players:GetPlayers().."/"..Players.MaxPlayers end
        if vFPS     then vFPS.Text     = fpsN.." fps" end
        if vPing    then pcall(function() vPing.Text = math.floor(LP:GetNetworkPing()*1000).." ms" end) end
        if vEggsMap then vEggsMap.Text = #ScanEggs().." eggs" end
        if vMisters then vMisters.Text = #ScanMisters().." alive" end
        task.wait(0.5)
    end
end)

-- ================================================================
-- TOGGLE PANEL (MINIMIZE / RESTORE) — bukan exit
-- ================================================================
function TogglePanel()
    S.Minimized = not S.Minimized
    if S.Minimized then
        -- Hide panel, show icon
        TweenService:Create(MF, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
            Position = UDim2.new(MF.Position.X.Scale, MF.Position.X.Offset, MF.Position.Y.Scale, MF.Position.Y.Offset + 200),
        }):Play()
        task.delay(0.22, function() MF.Visible = false end)
        IconBtn.Visible = true
        IconBtn.Text = "🐜"
    else
        MF.Visible = true
        TweenService:Create(MF, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(MF.Position.X.Scale, MF.Position.X.Offset, MF.Position.Y.Scale, MF.Position.Y.Offset - 200),
        }):Play()
        IconBtn.Visible = false
    end
end

-- Minimize button
MinBtn.Activated:Connect(function()
    S.Minimized = true
    MF.Visible = false
    IconBtn.Visible = true
end)

-- ================================================================
-- INIT
-- ================================================================
SwitchTab("Home")

-- Panel mulai tersembunyi, icon terlihat
MF.Position = UDim2.new(0, 20, 0.5, -MH/2)
MF.Visible = false
IconBtn.Visible = true

-- Auto show panel pertama kali
task.spawn(function()
    task.wait(0.3)
    MF.Visible = true
    IconBtn.Visible = false
    MF.Position = UDim2.new(0, -MW - 30, 0.5, -MH/2)
    TweenService:Create(MF, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 20, 0.5, -MH/2),
    }):Play()
end)

-- Toast
task.spawn(function()
    local toast = Instance.new("Frame", SG)
    toast.Size             = UDim2.new(0, 260, 0, 28)
    toast.Position         = UDim2.new(0.5, -130, 1, 14)
    toast.BackgroundColor3 = C.Bg
    toast.BorderSizePixel  = 0
    toast.ZIndex           = 100
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 4)
    local ts = Instance.new("UIStroke", toast)
    ts.Color = C.Accent; ts.Thickness = 1
    local tl = Instance.new("TextLabel", toast)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = "🐜 ANTS v4.1 loaded · tap icon untuk hide"
    tl.TextColor3 = C.Text
    tl.TextSize = 12
    tl.Font = Enum.Font.GothamBold
    tl.ZIndex = 101

    TweenService:Create(toast, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, -130, 1, -44),
    }):Play()
    task.wait(2.8)
    TweenService:Create(toast, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5, -130, 1, 14),
    }):Play()
    task.delay(0.25, function() toast:Destroy() end)
end)

print("[ANTS v4.1] Android edition loaded · Tap icon 🐜 untuk toggle")