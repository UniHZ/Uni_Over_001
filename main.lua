-- Menyimpan source code ke variabel untuk di-queue saat teleport
local script_source = [==[
-- Anti-Detection: Delay acak sebelum eksekusi
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.1 + math.random() * 0.5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- FITUR PERSISTENCE (Anti-Wipe)
if getgenv().UniSc_Persistent then
    if getgenv().UniSc_GUI and not getgenv().UniSc_GUI.Parent then
        getgenv().UniSc_GUI.Parent = getGuiParent()
    end
    return
end
getgenv().UniSc_Persistent = true
getgenv().UniSc_CustomTargets = getgenv().UniSc_CustomTargets or {}

-- ==========================================
-- KONFIGURASI ARRAY & JARAK
-- ==========================================
local BossNames = {
    "ironvale sentinel", "black ice", "dragon lord", "the warden"
}
local EnemyNames = {
    "ironvale drone", "ice ghost", "enemy", "mob", "helix trooper",
    "razorback", "boss" -- Ditambahkan untuk target Auto Ops
}
local MAX_DISTANCE = 130 -- Batas jarak kill dalam studs

-- Memuat nama kustom dari input sebelumnya (jika ada)
for _, customName in ipairs(getgenv().UniSc_CustomTargets) do
    table.insert(BossNames, customName)
    table.insert(EnemyNames, customName)
end
-- ==========================================

local function getGuiParent()
    local success, hui = pcall(function() return gethui() end)
    if success and hui then return hui end
    local success2, core = pcall(function() return game:GetService("CoreGui") end)
    if success2 and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local AutoKillBossEnabled = false
local AutoKillEnemyEnabled = false
local AutoOpsEnabled = false
local AutoRaidEnabled = false
local AutoChestEnabled = false
local isAlive = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberUniversalInstaKill"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiParent()
getgenv().UniSc_GUI = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 395) -- +35 untuk Auto Replay Raid
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -198)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 50, 50)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 4)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -75, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "[ OPS FARMER ]"
TitleText.TextColor3 = Color3.fromRGB(255, 50, 50)
TitleText.Font = Enum.Font.Code
TitleText.TextSize = 13
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 32, 1, 0)
MinBtn.Position = UDim2.new(1, -68, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinBtn.Font = Enum.Font.Code
MinBtn.TextSize = 14
MinBtn.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 1, 0)
CloseBtn.Position = UDim2.new(1, -32, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Font = Enum.Font.Code
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -45)
ContentFrame.Position = UDim2.new(0, 10, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Indikator Jarak
local RangeInfo = Instance.new("TextLabel")
RangeInfo.Size = UDim2.new(1, 0, 0, 15)
RangeInfo.Position = UDim2.new(0, 0, 0, 0)
RangeInfo.BackgroundTransparency = 1
RangeInfo.Text = "RANGE LIMIT: " .. MAX_DISTANCE .. " STUDS"
RangeInfo.TextColor3 = Color3.fromRGB(255, 165, 0)
RangeInfo.Font = Enum.Font.Code
RangeInfo.TextSize = 10
RangeInfo.TextXAlignment = Enum.TextXAlignment.Left
RangeInfo.Parent = ContentFrame

local ToggleBossBtn = Instance.new("TextButton")
ToggleBossBtn.Size = UDim2.new(1, 0, 0, 30)
ToggleBossBtn.Position = UDim2.new(0, 0, 0, 20)
ToggleBossBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBossBtn.BorderSizePixel = 0
ToggleBossBtn.Text = "INSTANT KILL BOSS : OFF"
ToggleBossBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBossBtn.Font = Enum.Font.Code
ToggleBossBtn.TextSize = 11
ToggleBossBtn.Parent = ContentFrame

local ToggleEnemyBtn = Instance.new("TextButton")
ToggleEnemyBtn.Size = UDim2.new(1, 0, 0, 30)
ToggleEnemyBtn.Position = UDim2.new(0, 0, 0, 55)
ToggleEnemyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleEnemyBtn.BorderSizePixel = 0
ToggleEnemyBtn.Text = "INSTANT KILL NPC : OFF"
ToggleEnemyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleEnemyBtn.Font = Enum.Font.Code
ToggleEnemyBtn.TextSize = 11
ToggleEnemyBtn.Parent = ContentFrame

-- BUTTON AUTO OPS
local ToggleOpsBtn = Instance.new("TextButton")
ToggleOpsBtn.Size = UDim2.new(1, 0, 0, 30)
ToggleOpsBtn.Position = UDim2.new(0, 0, 0, 90)
ToggleOpsBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleOpsBtn.BorderSizePixel = 0
ToggleOpsBtn.Text = "AUTO START OPS : OFF"
ToggleOpsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleOpsBtn.Font = Enum.Font.Code
ToggleOpsBtn.TextSize = 11
ToggleOpsBtn.Parent = ContentFrame

-- BUTTON AUTO REPLAY RAID
local ToggleRaidBtn = Instance.new("TextButton")
ToggleRaidBtn.Size = UDim2.new(1, 0, 0, 30)
ToggleRaidBtn.Position = UDim2.new(0, 0, 0, 125)
ToggleRaidBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleRaidBtn.BorderSizePixel = 0
ToggleRaidBtn.Text = "AUTO REPLAY RAID : OFF"
ToggleRaidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleRaidBtn.Font = Enum.Font.Code
ToggleRaidBtn.TextSize = 11
ToggleRaidBtn.Parent = ContentFrame

-- BUTTON AUTO OPEN CHEST
local ToggleChestBtn = Instance.new("TextButton")
ToggleChestBtn.Size = UDim2.new(1, 0, 0, 30)
ToggleChestBtn.Position = UDim2.new(0, 0, 0, 160)
ToggleChestBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleChestBtn.BorderSizePixel = 0
ToggleChestBtn.Text = "AUTO OPEN CHEST : OFF"
ToggleChestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleChestBtn.Font = Enum.Font.Code
ToggleChestBtn.TextSize = 11
ToggleChestBtn.Parent = ContentFrame

-- KOLOM INPUT KUSTOM
local InputLabel = Instance.new("TextLabel")
InputLabel.Size = UDim2.new(1, 0, 0, 15)
InputLabel.Position = UDim2.new(0, 0, 0, 195)
InputLabel.BackgroundTransparency = 1
InputLabel.Text = "ADD CUSTOM TARGET NAME:"
InputLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
InputLabel.Font = Enum.Font.Code
InputLabel.TextSize = 10
InputLabel.TextXAlignment = Enum.TextXAlignment.Left
InputLabel.Parent = ContentFrame

local TargetInput = Instance.new("TextBox")
TargetInput.Size = UDim2.new(0.65, 0, 0, 25)
TargetInput.Position = UDim2.new(0, 0, 0, 215)
TargetInput.BackgroundColor3 = Color3.fromRGB(20, 24, 30)
TargetInput.BorderSizePixel = 1
TargetInput.BorderColor3 = Color3.fromRGB(50, 60, 75)
TargetInput.PlaceholderText = "Input name..."
TargetInput.Text = ""
TargetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetInput.Font = Enum.Font.Code
TargetInput.TextSize = 11
TargetInput.Parent = ContentFrame

local AddBtn = Instance.new("TextButton")
AddBtn.Size = UDim2.new(0.3, 0, 0, 25)
AddBtn.Position = UDim2.new(0.7, 0, 0, 215)
AddBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
AddBtn.BorderSizePixel = 0
AddBtn.Text = "ADD"
AddBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddBtn.Font = Enum.Font.Code
AddBtn.TextSize = 12
AddBtn.Parent = ContentFrame

local InfoText = Instance.new("TextLabel")
InfoText.Size = UDim2.new(1, 0, 0, 40)
InfoText.Position = UDim2.new(0, 0, 0, 250)
InfoText.BackgroundTransparency = 1
InfoText.Text = "STATUS: STANDBY"
InfoText.TextColor3 = Color3.fromRGB(0, 255, 255)
InfoText.Font = Enum.Font.Code
InfoText.TextSize = 10
InfoText.TextXAlignment = Enum.TextXAlignment.Left
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.Parent = ContentFrame

ToggleBossBtn.MouseButton1Click:Connect(function()
    AutoKillBossEnabled = not AutoKillBossEnabled
    ToggleBossBtn.Text = "INSTANT KILL BOSS : " .. (AutoKillBossEnabled and "ON" or "OFF")
    ToggleBossBtn.BackgroundColor3 = AutoKillBossEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

ToggleEnemyBtn.MouseButton1Click:Connect(function()
    AutoKillEnemyEnabled = not AutoKillEnemyEnabled
    ToggleEnemyBtn.Text = "INSTANT KILL NPC : " .. (AutoKillEnemyEnabled and "ON" or "OFF")
    ToggleEnemyBtn.BackgroundColor3 = AutoKillEnemyEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

ToggleOpsBtn.MouseButton1Click:Connect(function()
    AutoOpsEnabled = not AutoOpsEnabled
    ToggleOpsBtn.Text = "AUTO START OPS : " .. (AutoOpsEnabled and "ON" or "OFF")
    ToggleOpsBtn.BackgroundColor3 = AutoOpsEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

ToggleRaidBtn.MouseButton1Click:Connect(function()
    AutoRaidEnabled = not AutoRaidEnabled
    ToggleRaidBtn.Text = "AUTO REPLAY RAID : " .. (AutoRaidEnabled and "ON" or "OFF")
    ToggleRaidBtn.BackgroundColor3 = AutoRaidEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

ToggleChestBtn.MouseButton1Click:Connect(function()
    AutoChestEnabled = not AutoChestEnabled
    ToggleChestBtn.Text = "AUTO OPEN CHEST : " .. (AutoChestEnabled and "ON" or "OFF")
    ToggleChestBtn.BackgroundColor3 = AutoChestEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

AddBtn.MouseButton1Click:Connect(function()
    local newName = string.lower(TargetInput.Text):match("^%s*(.-)%s*$")
    if newName ~= "" then
        table.insert(BossNames, newName)
        table.insert(EnemyNames, newName)
        table.insert(getgenv().UniSc_CustomTargets, newName)
        InfoText.Text = "STATUS: ADDED TARGET\nNAME: " .. newName
        TargetInput.Text = ""
    else
        InfoText.Text = "STATUS: INPUT EMPTY"
    end
end)

MinBtn.MouseButton1Click:Connect(function()
    if MainFrame.Size == UDim2.new(0, 250, 0, 395) then
        MainFrame.Size = UDim2.new(0, 250, 0, 32)
        ContentFrame.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 250, 0, 395)
        ContentFrame.Visible = true
    end
end)

local function Cleanup()
    isAlive = false
    if ScreenGui then ScreenGui:Destroy() end
    getgenv().UniSc_Persistent = nil
    getgenv().UniSc_GUI = nil
end

CloseBtn.MouseButton1Click:Connect(Cleanup)

-- ==========================================
-- LOGIKA AUTO START OPS (FAST POLLING)
-- ==========================================
task.spawn(function()
    local FIRE_COOLDOWN = 2.5       -- Interval minimum antar-fire
    local FORCE_FIRE_TIMEOUT = 12   -- Force fire kalau boss stuck
    local lastFire = 0

    -- Cek boss aktif di Workspace (direct children only, murah)
    local function isBossAlive()
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.ClassName == "Model" then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local nameLower = string.lower(obj.Name)
                    for _, bName in ipairs(BossNames) do
                        if string.find(nameLower, bName, 1, true) then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    while isAlive and ScreenGui and ScreenGui.Parent do
        if AutoOpsEnabled then
            local now = tick()
            local elapsed = now - lastFire

            if elapsed >= FIRE_COOLDOWN then
                local bossAlive = isBossAlive()
                -- Fire kalau: boss tidak ada ATAU sudah kelamaan (stuck/out of range)
                if not bossAlive or elapsed >= FORCE_FIRE_TIMEOUT then
                    pcall(function()
                        local OpsRemote = ReplicatedStorage:FindFirstChild("OD_Remotes")
                            and ReplicatedStorage.OD_Remotes:FindFirstChild("Ops")
                        if OpsRemote then
                            local args = {
                                [1] = "create",
                                [2] = {
                                    ["location"] = "CorpSpire",
                                    ["conditions"] = {
                                        [1] = "GlassBody",
                                        [2] = "NoImplants"
                                    },
                                    ["directive"] = "Boss"
                                }
                            }
                            OpsRemote:FireServer(unpack(args))
                            InfoText.Text = "STATUS: REQUESTING OPS...\nWAITING FOR BOSS"
                        end
                    end)
                    lastFire = now
                else
                    -- Boss masih hidup, tunggu di-kill sebelum fire lagi
                    InfoText.Text = "STATUS: BOSS ACTIVE\nWAITING FOR KILL..."
                end
            end
            task.wait(0.75) -- Polling ringan
        else
            task.wait(1)
        end
    end
end)

-- ==========================================
-- LOGIKA AUTO REPLAY RAID
-- ==========================================
task.spawn(function()
    local FIRE_COOLDOWN = 3 -- Fire "again" tiap 3 detik (server akan ignore kalau raid belum selesai)
    local lastFire = 0

    while isAlive and ScreenGui and ScreenGui.Parent do
        if AutoRaidEnabled then
            local now = tick()
            if now - lastFire >= FIRE_COOLDOWN then
                pcall(function()
                    local RaidChoiceRemote = ReplicatedStorage:FindFirstChild("OD_Remotes")
                        and ReplicatedStorage.OD_Remotes:FindFirstChild("RaidChoice")
                    if RaidChoiceRemote then
                        RaidChoiceRemote:FireServer("again")
                        InfoText.Text = "STATUS: REPLAYING RAID..."
                    end
                end)
                lastFire = now
            end
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

-- ==========================================
-- LOGIKA AUTO OPEN CHEST
-- ==========================================
task.spawn(function()
    while isAlive and ScreenGui and ScreenGui.Parent do
        if AutoChestEnabled then
            pcall(function()
                local OD_Remotes = ReplicatedStorage:FindFirstChild("OD_Remotes")
                local CrateRemote = OD_Remotes and OD_Remotes:FindFirstChild("Crate")
                if CrateRemote then
                    -- Loop index 1-10 untuk memastikan semua chest ter-open
                    for i = 1, 10 do
                        CrateRemote:FireServer("chest", i)
                    end
                    InfoText.Text = "STATUS: OPENING CHEST..."
                end
            end)
            task.wait(0.5) -- Interval antar request
        else
            task.wait(1)
        end
    end
end)

-- ==========================================
-- LOGIKA INSTANT KILL (OPTIMIZED - ANTI FPS DROP)
-- ==========================================
task.spawn(function()
    local SCAN_INTERVAL = 0.22 -- Dikit lebih cepat dari 0.25, tapi masih aman
    local cachedChar = nil
    local cachedRoot = nil
    local lastStatus = ""

    while isAlive and ScreenGui and ScreenGui.Parent do
        task.wait(SCAN_INTERVAL + math.random() * 0.06)

        if not (AutoKillBossEnabled or AutoKillEnemyEnabled) then
            -- Reset cache saat mode off biar hemat
            cachedChar = nil
            cachedRoot = nil
            task.wait(0.5)
        else
            -- Refresh cache HANYA kalau character berubah / root hilang
            if cachedChar ~= LocalPlayer.Character or (cachedRoot and not cachedRoot.Parent) then
                cachedChar = LocalPlayer.Character
                cachedRoot = cachedChar and cachedChar:FindFirstChild("HumanoidRootPart")
            end

            if cachedRoot then
                local myPos = cachedRoot.Position
                local found = false

                -- Fungsi inline: cek 1 objek, kill kalau target
                local function tryKill(obj)
                    if obj.ClassName ~= "Model" then return false end

                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    if not hum or hum.Health <= 0 then return false end

                    local nameLower = string.lower(obj.Name)
                    local targetType = nil

                    -- Plain text find (lebih cepat dari pattern match)
                    if AutoKillBossEnabled then
                        for _, bName in ipairs(BossNames) do
                            if string.find(nameLower, bName, 1, true) then
                                targetType = "BOSS"
                                break
                            end
                        end
                    end
                    if not targetType and AutoKillEnemyEnabled then
                        for _, eName in ipairs(EnemyNames) do
                            if string.find(nameLower, eName, 1, true) then
                                targetType = "NPC"
                                break
                            end
                        end
                    end
                    if not targetType then return false end

                    local targetRoot = obj:FindFirstChild("HumanoidRootPart")
                        or obj.PrimaryPart
                        or obj:FindFirstChild("Head")
                    if not targetRoot then return false end

                    local distance = (targetRoot.Position - myPos).Magnitude
                    if distance > MAX_DISTANCE then return false end

                    -- Kill
                    pcall(function() hum.Health = 0 end)
                    pcall(function() hum:TakeDamage(999999999) end)
                    pcall(function()
                        local tool = cachedChar:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end)

                    InfoText.Text = "STATUS: KILLED " .. targetType .. "\nTARGET: " .. obj.Name .. "\nDIST: " .. math.floor(distance) .. " STUDS"
                    return true
                end

                -- Scan RINGAN: direct children Workspace + 1 level untuk Folder
                -- Skip folder kosong (hemat iterasi)
                for _, obj in ipairs(Workspace:GetChildren()) do
                    local className = obj.ClassName
                    if className == "Model" then
                        if tryKill(obj) then found = true; break end
                    elseif className == "Folder" then
                        local children = obj:GetChildren()
                        if #children > 0 then
                            for _, sub in ipairs(children) do
                                if sub.ClassName == "Model" and tryKill(sub) then
                                    found = true
                                    break
                                end
                            end
                        end
                        if found then break end
                    end
                end

                if not found and not AutoOpsEnabled then
                    local newStatus = "STATUS: SCANNING (<= " .. MAX_DISTANCE .. " STUDS)...\nNO TARGETS IN RANGE"
                    if lastStatus ~= newStatus then -- Cegah UI reflow tiap loop
                        InfoText.Text = newStatus
                        lastStatus = newStatus
                    end
                end
            end
        end
    end
end)

-- Animasi UI
local gradientColors = {Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 50, 50)}
local currentColorIndex = 1
local nextColorIndex = 2
local colorLerp = 0

RunService.Heartbeat:Connect(function()
    if not isAlive or not ScreenGui or not ScreenGui.Parent then return end
    local animatedColor = gradientColors[currentColorIndex]:Lerp(gradientColors[nextColorIndex], colorLerp)
    pcall(function() UIStroke.Color = animatedColor end)
    colorLerp = colorLerp + 0.02
    if colorLerp >= 1 then
        colorLerp = 0
        currentColorIndex = nextColorIndex
        nextColorIndex = nextColorIndex + 1
        if nextColorIndex > #gradientColors then nextColorIndex = 1 end
    end
end)
]==]

-- AUTO EXECUTE SAAT TELEPORT (Delta Executor)
pcall(function()
    queue_on_teleport(script_source)
end)

-- EKSEKUSI UTAMA
local func, err = loadstring(script_source)
if func then
    func()
else
    warn("[UniSc] Gagal load script: " .. tostring(err))
end
