local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Data checkpoint
local CheckPoints = {
    {name = "CheckPoint 1", position = Vector3.new(5, 12, -404)},
    {name = "CheckPoint 2", position = Vector3.new(-184, 128, 409)},
    {name = "CheckPoint 3", position = Vector3.new(-165, 229, 653)},
    {name = "CheckPoint 4", position = Vector3.new(-38, 406, 616)},
    {name = "CheckPoint 5", position = Vector3.new(130, 651, 614)},
    {name = "CheckPoint 6", position = Vector3.new(-247, 665, 735)},
    {name = "CheckPoint 7", position = Vector3.new(-685, 640, 868)},
    {name = "CheckPoint 8", position = Vector3.new(-658, 688, 1458)},
    {name = "CheckPoint 9", position = Vector3.new(-508, 902, 1868)},
    {name = "CheckPoint 10", position = Vector3.new(61, 949, 2088)},
    {name = "CheckPoint 11", position = Vector3.new(52, 981, 2451)},
    {name = "CheckPoint 12", position = Vector3.new(73, 1096, 2458)},
    {name = "CheckPoint 13", position = Vector3.new(263, 1270, 2038)},
    {name = "CheckPoint 14", position = Vector3.new(-419, 1302, 2395)},
    {name = "CheckPoint 15", position = Vector3.new(-773, 1313, 2665)},
    {name = "CheckPoint 16", position = Vector3.new(-838, 1474, 2626)},
    {name = "CheckPoint 17", position = Vector3.new(-469, 1465, 2769)},
    {name = "CheckPoint 18", position = Vector3.new(-468, 1537, 2837)},
    {name = "CheckPoint 19", position = Vector3.new(-385, 1640, 2794)},
    {name = "CheckPoint 20", position = Vector3.new(-209, 1665, 2749)},
    {name = "CheckPoint 21", position = Vector3.new(-232, 1742, 2792)},
    {name = "CheckPoint 22", position = Vector3.new(-425, 1740, 2799)},
    {name = "CheckPoint 23", position = Vector3.new(-424, 1712, 3421)},
    {name = "CheckPoint 24", position = Vector3.new(71, 1718, 3427)},
    {name = "CheckPoint 25", position = Vector3.new(436, 1720, 3430)},
    {name = "CheckPoint 26", position = Vector3.new(626, 1799, 3433)},
    {name = "Puncak", position = Vector3.new(823, 2146, 3899)}
}

-- Fungsi untuk teleport
local function TeleportTo(position)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(position)
    end
end

-- Fungsi untuk rejoin server
local function RejoinServer()
    Rayfield:Notify({
        Title = "Auto Rejoin",
        Content = "Akan rejoin ke server baru dalam 3 detik...",
        Duration = 3,
        Image = 4483362458
    })
    
    wait(3)
    
    local TeleportService = game:GetService("TeleportService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    local success, errorMsg = pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
    
    if not success then
        Rayfield:Notify({
            Title = "Error",
            Content = "Gagal rejoin: " .. errorMsg,
            Duration = 5,
            Image = 4483362458
        })
    end
end

-- Fungsi untuk SpeedHack
local function SetSpeed(value)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = value
    end
end

-- Membuat window
local Window = Rayfield:CreateWindow({
    Name = "Vip Script: Mt.Atin",
    LoadingTitle = "Teleport System Sedang Dimuat",
    LoadingSubtitle = "by Noire",
    ConfigurationSaving = {
        Enabled = true
    }
})

-- Membuat tab
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local SettingsTab = Window:CreateTab("Pengaturan", 4483362458)
local CreatorTab = Window:CreateTab("Creator", 4483362458)

-- Membuat section
local CheckpointSection = TeleportTab:CreateSection("Checkpoint Teleport")

-- Membuat button untuk setiap checkpoint
for i, checkpoint in ipairs(CheckPoints) do
    TeleportTab:CreateButton({
        Name = checkpoint.name,
        Callback = function()
            TeleportTo(checkpoint.position)
            Rayfield:Notify({
                Title = "Teleport",
                Content = "Berhasil teleport ke " .. checkpoint.name,
                Duration = 3,
                Image = 4483362458
            })
        end
    })
end

-- Section untuk auto teleport
local AutoSection = TeleportTab:CreateSection("Auto Teleport")

-- Variabel untuk kontrol auto teleport
local autoTeleportEnabled = false
local currentCheckpoint = 1
local teleportDelay = 1 -- delay dalam detik
local autoRejoinEnabled = false -- fitur auto rejoin

-- Function untuk auto teleport
local function StartAutoTeleport()
    if autoTeleportEnabled then return end
    
    autoTeleportEnabled = true
    Rayfield:Notify({
        Title = "Auto Teleport",
        Content = "Auto Teleport diaktifkan",
        Duration = 3,
        Image = 4483362458
    })
    
    -- Create a new thread for auto teleport
    spawn(function()
        while autoTeleportEnabled and currentCheckpoint <= #CheckPoints do
            TeleportTo(CheckPoints[currentCheckpoint].position)
            Rayfield:Notify({
                Title = "Auto Teleport",
                Content = "Teleport ke " .. CheckPoints[currentCheckpoint].name,
                Duration = 1,
                Image = 4483362458
            })
            
            -- Cek jika sudah sampai di puncak dan auto rejoin diaktifkan
            if currentCheckpoint == #CheckPoints and autoRejoinEnabled then
                autoTeleportEnabled = false
                RejoinServer()
                break
            end
            
            currentCheckpoint = currentCheckpoint + 1
            wait(teleportDelay)
            
            -- Jika sudah sampai akhir, matikan auto teleport
            if currentCheckpoint > #CheckPoints then
                autoTeleportEnabled = false
                Rayfield:Notify({
                    Title = "Auto Teleport",
                    Content = "Semua checkpoint telah dikunjungi",
                    Duration = 5,
                    Image = 4483362458
                })
                break
            end
        end
    end)
end

-- Toggle untuk auto teleport
TeleportTab:CreateToggle({
    Name = "Aktifkan Auto Teleport",
    CurrentValue = false,
    Flag = "AutoTeleportToggle",
    Callback = function(Value)
        if Value then
            StartAutoTeleport()
        else
            autoTeleportEnabled = false
            Rayfield:Notify({
                Title = "Auto Teleport",
                Content = "Auto Teleport dimatikan",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Membuat section di tab Pengaturan
local GeneralSettings = SettingsTab:CreateSection("Pengaturan Umum")

-- Toggle untuk auto rejoin
SettingsTab:CreateToggle({
    Name = "Auto Rejoin di Puncak",
    CurrentValue = false,
    Flag = "AutoRejoinToggle",
    Callback = function(Value)
        autoRejoinEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "Auto Rejoin",
                Content = "Auto Rejoin akan diaktifkan setelah mencapai puncak",
                Duration = 3,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Auto Rejoin",
                Content = "Auto Rejoin dimatikan",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Slider untuk mengatur delay teleport
SettingsTab:CreateSlider({
    Name = "Delay Teleport (detik)",
    Range = {0.5, 5},
    Increment = 0.5,
    Suffix = "s",
    CurrentValue = 1,
    Flag = "TeleportDelaySlider",
    Callback = function(Value)
        teleportDelay = Value
    end
})

-- Tombol reset checkpoint
SettingsTab:CreateButton({
    Name = "Reset ke Checkpoint Awal",
    Callback = function()
        currentCheckpoint = 1
        autoTeleportEnabled = false
        Rayfield:Notify({
            Title = "Reset",
            Content = "Auto Teleport direset ke checkpoint awal",
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- Tombol manual rejoin
SettingsTab:CreateButton({
    Name = "Rejoin Server Sekarang",
    Callback = function()
        RejoinServer()
    end
})

-- Section untuk Speed Hack di tab Pengaturan
local SpeedHackSection = SettingsTab:CreateSection("Speed Hack")

-- Variabel untuk WalkSpeed
local currentWalkSpeed = 16
local walkSpeedEnabled = false

-- Slider untuk WalkSpeed
SettingsTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 100},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 16,
    Flag = "WalkSpeedSlider",
    Callback = function(Value)
        currentWalkSpeed = Value
        if walkSpeedEnabled then
            SetSpeed(Value)
        end
    end
})

-- Toggle untuk WalkSpeed
SettingsTab:CreateToggle({
    Name = "Aktifkan Walk Speed",
    CurrentValue = false,
    Flag = "WalkSpeedToggle",
    Callback = function(Value)
        walkSpeedEnabled = Value
        if Value then
            SetSpeed(currentWalkSpeed)
            Rayfield:Notify({
                Title = "Speed Hack",
                Content = "Walk Speed diaktifkan: " .. currentWalkSpeed .. " studs",
                Duration = 3,
                Image = 4483362458
            })
        else
            SetSpeed(16) -- Reset ke default
            Rayfield:Notify({
                Title = "Speed Hack",
                Content = "Walk Speed dimatikan",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

-- Membuat section di tab Creator
local CreatorSection = CreatorTab:CreateSection("Tentang Pembuat")

-- Label untuk informasi YouTube
CreatorTab:CreateLabel("Youtube: XuKrost OFC")

-- Label untuk informasi TikTok
CreatorTab:CreateLabel("Tiktok: noiree")

-- Label untuk informasi Instagram
CreatorTab:CreateLabel("Instagram: @snn2ndd_")

-- Bisa juga ditambahkan tombol untuk membuka link sosial media jika diinginkan
CreatorTab:CreateButton({
    Name = "Salin Info Creator",
    Callback = function()
        setclipboard("Youtube: XuKrost OFC\nTiktok: noiree\nInstagram: @snn2ndd_")
        Rayfield:Notify({
            Title = "Creator Info",
            Content = "Info creator telah disalin ke clipboard",
            Duration = 3,
            Image = 4483362458
        })
    end
})

-- Load Rayfield
Rayfield:LoadConfiguration()
