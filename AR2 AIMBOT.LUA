-- PAPOL AIMBOT (FLSV / PAPOL#0066) --

-- Settings
local Settings = {
    Aimbot = {
        AimbotKey = Enum.KeyCode.LeftControl,
        FOVRadius = 150,
        SmoothnessX = 1,
        SmoothnessY = 1,
        TeamCheck = false,
        VisibleCheck = false,
        FOVUsed = false,
        AimbotPart = "Head",
        FOVColor = Color3.fromRGB(255,255,255)
    }
}


-- Services
local zzWorkspace = game:GetService("Workspace")
local zzRunService = game:GetService("RunService")
local zzUIS = game:GetService("UserInputService")
local zzPlayers = game:GetService("Players")
local zzCamera = zzWorkspace.CurrentCamera
local zzLPlayer = zzPlayers.LocalPlayer
local zzMouse = zzLPlayer:GetMouse()


-- FOV
local FOV = Drawing.new("Circle")
FOV.Color = Settings.Aimbot.FOVColor
FOV.Thickness = 1
FOV.Filled = false
FOV.Radius = Settings.Aimbot.FOVRadius
FOV.Transparency = 1
FOV.Visible = Settings.Aimbot.FOVUsed
FOV.NumSides = 1000


-- Aimbot
function GetPart(v)
    if Settings.Aimbot.AimbotPart == "Torso/UpperTorso" then
        return tostring(v:FindFirstChild("Torso") or v:FindFirstChild("UpperTorso"))
    end
    return "Head"
end

function IsVisible(Pos, List)
    return #zzCamera:GetPartsObscuringTarget({zzLPlayer.Character.Head.Position, Pos}, List) == 0 and true or false
end

function getTarget()
    local closestDist = math.huge
    local targetPlayer = nil

    for _, player in pairs(zzPlayers:GetPlayers()) do 
        if player ~= zzLPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then 
            local distance = (player.Character.HumanoidRootPart.Position - zzLPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance <= 1000 then
                if not Settings.Aimbot.TeamCheck or (Settings.Aimbot.TeamCheck and player.Team ~= zzLPlayer.Team) then
                    local Pos, onScreen = zzCamera:WorldToScreenPoint(player.Character[GetPart(player.Character)].Position) 
                    if onScreen then
                        local mouseDist = (Vector2.new(zzMouse.X, zzMouse.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude 
                        if (not Settings.Aimbot.FOVUsed and mouseDist < closestDist) or 
                           (Settings.Aimbot.FOVUsed and mouseDist < closestDist and mouseDist < Settings.Aimbot.FOVRadius) then
                            if not Settings.Aimbot.VisibleCheck or 
                               (Settings.Aimbot.VisibleCheck and IsVisible(player.Character[GetPart(player.Character)].Position, {player.Character, zzLPlayer.Character, zzCamera})) then 
                                closestDist = mouseDist
                                targetPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end
    return targetPlayer 
end

local Aiming = false

local AimPlayer = getTarget()
zzRunService.RenderStepped:Connect(function()
    local MousePos = zzUIS:GetMouseLocation()
    FOV.Position = Vector2.new(MousePos.X, MousePos.Y)
    
    AimPlayer = getTarget()
    if Aiming then
        if AimPlayer then
            local Pos = zzCamera:WorldToViewportPoint(AimPlayer.Character[GetPart(AimPlayer.Character)].Position)
            mousemoverel((Pos.X - MousePos.X) / Settings.Aimbot.SmoothnessX, (Pos.Y - MousePos.Y) / Settings.Aimbot.SmoothnessY)
        end
    end
end)

zzUIS.InputBegan:Connect(function(v)
    if v.UserInputType == Enum.UserInputType.Keyboard and v.KeyCode == Enum.KeyCode.LeftControl then
        Aiming = true
    end
end)

zzUIS.InputEnded:Connect(function(v)
    if v.UserInputType == Enum.UserInputType.Keyboard and v.KeyCode == Enum.KeyCode.LeftControl then
        Aiming = false
    end
end)