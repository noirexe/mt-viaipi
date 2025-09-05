local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create the main window once
local Window = Rayfield:CreateWindow({
    Name = "Vip Script: Mt.Hauk",
    LoadingTitle = "Teleport System Sedang Dimuat",
    LoadingSubtitle = "by Noire",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "XuKrost",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false, -- Disabled key system
})

Rayfield:Notify({
    Title = "Script Dimuat",
    Content = "Script berhasil dimuat tanpa key system..",
    Duration = 6.5,
    Image = 4483362458,
    Actions = {
        Ignore = {
            Name = "Oke",
            Callback = function()
                print("Pengguna mengkonfirmasi notifikasi")
            end
        },
    },
})

-- Services
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

-- Player reference
local LocalPlayer = Players.LocalPlayer

-- Updated Locations table with new coordinates
local Locations = {
    ["Spawn"] = Vector3.new(-33, 5, -24),
    ["CheckPoint 1"] = Vector3.new(525, 40, 8),
    ["CheckPoint 2"] = Vector3.new(900, 109, 22),
    ["CheckPoint 3"] = Vector3.new(651, 127, 400),
    ["CheckPoint 4"] = Vector3.new(427, 127, 438),
    ["CheckPoint 5"] = Vector3.new(-174, 137, 547),
    ["CheckPoint 6"] = Vector3.new(-580, 175, 923),
    ["CheckPoint 7"] = Vector3.new(-943, 197, 901),
    ["CheckPoint 8"] = Vector3.new(-1059, 406, 969),
    ["CheckPoint 9"] = Vector3.new(-1217, 499, 1056),
    ["CheckPoint 10"] = Vector3.new(-1560, 511, 1116),
    ["CheckPoint 11"] = Vector3.new(-1739, 609, 912),
    ["CheckPoint 12"] = Vector3.new(-1868, 663, 854),
    ["CheckPoint 13"] = Vector3.new(-1901, 719, 871),
    ["Puncak"] = Vector3.new(-2858, 1510, -579),
}

-- Variables for auto teleport control
local AutoTeleporting = false
local LoopMode = false
local CurrentTeleportIndex = 1
local TeleportDelay = 5 -- Default delay time in seconds

-- Variables for Anti-AFK
local AntiAFKEnabled = false

-- Variables for Speedhack
local SpeedhackEnabled = false
local CurrentWalkSpeed = 16

-- Teleport order for auto teleport
local TeleportOrder = {
    "CheckPoint 1", 
    "CheckPoint 2", 
    "CheckPoint 3", 
    "CheckPoint 4", 
    "CheckPoint 5",
    "CheckPoint 6",
    "CheckPoint 7",
    "CheckPoint 8",
    "CheckPoint 9",
    "CheckPoint 10",
    "CheckPoint 11",
    "CheckPoint 12",
    "CheckPoint 13",
    "Puncak"
}

-- Notification cooldown system
local lastNotificationTime = 0
local NOTIFICATION_COOLDOWN = 5 -- seconds between notifications (increased from 3 to 5)

-- Function to show notifications with cooldown
local function ShowNotification(title, content, duration, image)
    local currentTime = tick()
    if currentTime - lastNotificationTime >= NOTIFICATION_COOLDOWN then
        lastNotificationTime = currentTime
        Rayfield:Notify({
            Title = title,
            Content = content,
            Duration = duration or 5, -- Increased default duration from 3 to 5
            Image = image or 4483362458,
        })
        return true
    end
    return false
end

-- Function to safely get the player's character
local function GetCharacter()
    local character = LocalPlayer.Character
    if not character then
        LocalPlayer.CharacterAdded:Wait()
        character = LocalPlayer.Character
    end
    return character
end

-- Function to safely get the player's humanoid root part
local function GetHumanoidRootPart(character)
    character = character or GetCharacter()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    return humanoidRootPart
end

-- Function to get the player's humanoid
local function GetHumanoid(character)
    character = character or GetCharacter()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid
end

-- Function to join a new server with better error handling
local function JoinNewServer()
    local placeId = game.PlaceId
    local currentJobId = game.JobId
    
    ShowNotification("Mencari Server Baru", "Sedang mencari server yang tersedia...", 5)
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        ))
    end)
    
    if success and result and result.data then
        local availableServers = {}
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= currentJobId then
                table.insert(availableServers, server.id)
            end
        end
        
        if #availableServers > 0 then
            local randomServer = availableServers[math.random(1, #availableServers)]
            TeleportService:TeleportToPlaceInstance(placeId, randomServer)
        else
            TeleportService:Teleport(placeId)
        end
    else
        TeleportService:Teleport(placeId)
    end
end

-- Function to kill player with safety checks
local function KillPlayer()
    local character = GetCharacter()
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
            return true
        end
    end
    return false
end

-- Function for teleportation with improved error handling - CHANGED TO USE CFrame.new
local function TeleportTo(locationName)
    local location = Locations[locationName]
    if not location then
        ShowNotification("Error", "Lokasi tidak ditemukan: " .. tostring(locationName), 5)
        return false
    end
    
    local character = GetCharacter()
    local humanoidRootPart = GetHumanoidRootPart(character)
    
    if humanoidRootPart then
        -- Changed to use CFrame.new instead of directly setting position with Vector3
        humanoidRootPart.CFrame = CFrame.new(location.X, location.Y, location.Z)
        
        ShowNotification("Teleport Berhasil", "Kamu telah di-teleport ke " .. locationName, 5)
        return true
    else
        ShowNotification("Error", "HumanoidRootPart tidak ditemukan!", 5)
        return false
    end
end

-- Function for auto teleport with delay and improved logic
local function StartAutoTeleport(loop)
    if AutoTeleporting then 
        ShowNotification("Info", "Auto teleport sudah berjalan", 5)
        return 
    end
    
    AutoTeleporting = true
    LoopMode = loop or false
    CurrentTeleportIndex = 1
    
    -- Process teleport in sequence with delay
    local teleportCoroutine = coroutine.create(function()
        repeat
            for i = CurrentTeleportIndex, #TeleportOrder do
                if not AutoTeleporting then break end
                
                local locationName = TeleportOrder[i]
                local success = TeleportTo(locationName)
                
                if not success then
                    AutoTeleporting = false
                    break
                end
                
                -- Show progress notification (only if not on cooldown)
                if ShowNotification(LoopMode and "Auto Teleport (Looping)" or "Auto Teleport", 
                                   "Menuju " .. locationName .. " (" .. i .. "/" .. #TeleportOrder .. ")", 5) then
                    -- If notification was shown, add a small delay
                    wait(0.5)
                end
                
                -- Use the TeleportDelay value from the slider
                local waitTime = TeleportDelay
                
                if locationName == "Puncak" then
                    ShowNotification("⛰️ Summit Terhitung!", "Tunggu " .. waitTime .. " detik di puncak untuk menyelesaikan tantangan", 5)
                end
                
                -- Wait with the ability to cancel
                local startTime = tick()
                while tick() - startTime < waitTime and AutoTeleporting do
                    if locationName == "Puncak" and tick() - startTime > waitTime - 3 then
                        local remaining = math.ceil(waitTime - (tick() - startTime))
                        -- Don't show notification for countdown to avoid spam
                    end
                    RunService.Heartbeat:Wait()
                end
                
                -- Kill player after waiting at the peak (only in loop mode)
                if LoopMode and locationName == "Puncak" and AutoTeleporting then
                    ShowNotification("⛰️ Selesai di Puncak", "Membunuh player untuk memulai ulang dari Spawn...", 5)
                    
                    -- Kill the player
                    if KillPlayer() then
                        -- Wait for respawn
                        LocalPlayer.CharacterAdded:Wait()
                        RunService.Heartbeat:Wait() -- Wait one frame
                        
                        -- Teleport to Spawn after respawn
                        TeleportTo("Spawn")
                        
                        -- Set next index to CheckPoint 1
                        for idx, name in ipairs(TeleportOrder) do
                            if name == "CheckPoint 1" then
                                CurrentTeleportIndex = idx
                                break
                            end
                        end
                        break -- Break out of the for loop to restart from CheckPoint 1
                    end
                end
                
                CurrentTeleportIndex = i + 1
            end
            
            if AutoTeleporting and LoopMode and CurrentTeleportIndex > #TeleportOrder then
                CurrentTeleportIndex = 1  -- Reset to start if we've completed the loop
                ShowNotification("Auto Teleport Looping", "Memulai rute teleport lagi dari awal...", 5)
            end
        until not LoopMode or not AutoTeleporting
        
        AutoTeleporting = false
        ShowNotification("Auto Teleport Selesai", LoopMode and "Proses auto teleport telah dihentikan" or "Semua lokasi telah dikunjungi", 5)
    end)
    
    coroutine.resume(teleportCoroutine)
end

-- Function to stop auto teleport
local function StopAutoTeleport()
    if AutoTeleporting then
        AutoTeleporting = false
        LoopMode = false
        ShowNotification("Auto Teleport Dihentikan", "Proses auto teleport telah dihentikan", 5)
    end
end

-- Function to toggle Anti-AFK
local function ToggleAntiAFK(value)
    AntiAFKEnabled = value
    
    if AntiAFKEnabled then
        -- Connect to the Idled event
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
        ShowNotification("Anti-AFK Diaktifkan", "Kamu tidak akan lagi dikick karena AFK", 5)
    else
        ShowNotification("Anti-AFK Dimatikan", "Kamu bisa dikick karena AFK", 5)
    end
end

-- Function to apply speedhack settings
local function ApplySpeedhack()
    local character = GetCharacter()
    local humanoid = GetHumanoid(character)
    
    if humanoid then
        if SpeedhackEnabled then
            humanoid.WalkSpeed = CurrentWalkSpeed
        else
            humanoid.WalkSpeed = 16 -- Default speed
        end
    end
end

-- Function to toggle speedhack
local function ToggleSpeedhack(value)
    SpeedhackEnabled = value
    ApplySpeedhack()
    
    if SpeedhackEnabled then
        ShowNotification("Speedhack Diaktifkan", "WalkSpeed: " .. CurrentWalkSpeed .. " studs", 5)
    else
        ShowNotification("Speedhack Dimatikan", "WalkSpeed dikembalikan ke normal", 5)
    end
end

-- Function to set walkspeed
local function SetWalkSpeed(value)
    CurrentWalkSpeed = value
    if SpeedhackEnabled then
        ApplySpeedhack()
        ShowNotification("WalkSpeed Diubah", "WalkSpeed: " .. CurrentWalkSpeed .. " studs", 3)
    end
end

-- Function to set teleport delay
local function SetTeleportDelay(value)
    TeleportDelay = value
    ShowNotification("Delay Diubah", "Delay teleport: " .. TeleportDelay .. " detik", 3)
end

-- Create main tab
local MainTab = Window:CreateTab("Teleport", 4483362458)

-- Create section for teleport
local TeleportSection = MainTab:CreateSection("Lokasi Awal")
MainTab:CreateButton({
    Name = "🚩 Spawn",
    Callback = function()
        TeleportTo("Spawn")
    end
})

-- Checkpoints section
local CheckpointSection = MainTab:CreateSection("Checkpoints")
for i = 1, 13 do
    local checkpointName = "CheckPoint " .. i
    MainTab:CreateButton({
        Name = "📍 " .. checkpointName,
        Callback = function()
            TeleportTo(checkpointName)
        end
    })
end

-- Final destination section
local FinalSection = MainTab:CreateSection("Tujuan Akhir")
MainTab:CreateButton({
    Name = "🏔️ Puncak",
    Callback = function()
        TeleportTo("Puncak")
    end
})

-- Auto Teleport section
local AutoSection = MainTab:CreateSection("Auto Teleport")

-- Add delay slider to the Auto Teleport section
MainTab:CreateSlider({
    Name = "Delay Teleport",
    Range = {30, 220},
    Increment = 1,
    Suffix = "detik",
    CurrentValue = 5,
    Flag = "TeleportDelay",
    Callback = function(Value)
        SetTeleportDelay(Value)
    end,
})

MainTab:CreateButton({
    Name = "▶️ Auto Teleport (1x)",
    Callback = function()
        StartAutoTeleport(false)
    end
})

MainTab:CreateButton({
    Name = "🔁 Auto Teleport (Looping)",
    Callback = function()
        StartAutoTeleport(true)
    end
})

MainTab:CreateButton({
    Name = "⏹️ Stop Auto Teleport",
    Callback = function()
        StopAutoTeleport()
    end
})

-- Create Speedhack tab
local SpeedTab = Window:CreateTab("Speedhack", 7733692467)

-- Speedhack section
SpeedTab:CreateSection("Speed Hack Settings")

-- WalkSpeed slider
SpeedTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 65},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 16,
    Flag = "WalkSpeedValue",
    Callback = function(Value)
        SetWalkSpeed(Value)
    end,
})

-- WalkSpeed toggle
SpeedTab:CreateToggle({
    Name = "Enable Speedhack",
    CurrentValue = false,
    Flag = "SpeedhackEnabled",
    Callback = function(Value)
        ToggleSpeedhack(Value)
    end,
})

-- Reset button
SpeedTab:CreateButton({
    Name = "Reset to Default",
    Callback = function()
        SetWalkSpeed(16)
        ToggleSpeedhack(false)
        ShowNotification("Speedhack Direset", "Pengaturan speedhack telah direset ke default", 5)
    end,
})

-- Create information tab
local InfoTab = Window:CreateTab("Informasi", 7733960981)

-- Create information section
local InfoSection = InfoTab:CreateSection("Cara Penggunaan")
InfoTab:CreateParagraph({
    Title = "Panduan Lengkap Wajib Dibaca",
    Content = "- Klik 'Mulai Auto Teleport' untuk memulai perjalanan otomatis\n- Sistem akan mengunjungi semua lokasi secara berurutan\n- Gunakan slider 'Delay Teleport' untuk mengatur waktu tunggu antar teleport\n- Khusus di puncak, jeda sesuai dengan pengaturan delay agar summit bisa terhitung\n- Dalam mode looping, player akan mati otomatis di puncak dan mulai lagi dari Spawn\n- Gunakan 'Hentikan Auto Teleport' untuk menghentikan proses"
})

InfoTab:CreateParagraph({
    Title = "Feature",
    Content = "- (AutoTeleport Looping)\n- (AutoTeleport 1x)\n- (Anti-AFK System)\n- (Speedhack System)\n- (Adjustable Delay)"
})

local WarningSection = InfoTab:CreateSection("Perhatian")
InfoTab:CreateLabel("Push summit lebih baik dijam-jam tertentu (07:00PM - 10:00PM) atau (12:30AM - 05:00AM).\nLebih baik menggunakan (Private Server) jika ada.\nJika tidak mempunyai (Private Server) cari server yang lumayan sepi")

-- Settings tab
local SettingsTab = Window:CreateTab("Extra", 9753762463)

-- Anti-AFK section
SettingsTab:CreateSection("Anti-AFK")
SettingsTab:CreateToggle({
    Name = "Aktifkan Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        ToggleAntiAFK(Value)
    end,
})

SettingsTab:CreateButton({
    Name = "Pindah Server Sekarang",
    Callback = function()
        ShowNotification("Memindahkan Server", "Mencari server baru...", 5)
        JoinNewServer()
    end,
})

-- Add a section for debugging
SettingsTab:CreateSection("Debugging")
SettingsTab:CreateButton({
    Name = "Reset Karakter",
    Callback = function()
        if LocalPlayer.Character then
            LocalPlayer.Character:BreakJoints()
            ShowNotification("Karakter Direset", "Karakter telah direset", 5)
        else
            ShowNotification("Error", "Tidak ada karakter yang bisa direset", 5)
        end
    end,
})

-- Auto apply speedhack ketika karakter respawn
LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    ApplySpeedhack()
end)

Rayfield:LoadConfiguration()

Rayfield:Notify({
    Title = "Speedhack Dimuat",
    Content = "Fitur speedhack berhasil ditambahkan!",
    Duration = 3,
    Image = 4483362458,
})

print("Script loaded successfully without key system!")