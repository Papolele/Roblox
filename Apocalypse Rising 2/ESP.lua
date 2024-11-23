-- PAPOL AR2 ESP (FLSV on Discord) --

-- Services
local run_service = game:GetService("RunService")
local camera = workspace.CurrentCamera
local localplayer = game:GetService("Players").LocalPlayer
local players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Tables
local settings = {
    location = {enabled = true, color = Color3.new(1, 1, 1), distance = 3000},
    zombie = {enabled = false, color = Color3.new(1, 0, 0), distance = 1000},
    player = {enabled = true, color = Color3.new(255, 0, 0), distance = 2500},
    randomevents = {enabled = true, color = Color3.new(255, 255, 0), distance = 1000},
    vehicles = {enabled = true, color = Color3.new(0, 255, 0), distance = 1500},
    corpses = {enabled = true, color = Color3.new(128, 0, 128), distance = 2500}
}

local location_drawings = {}
local zombie_drawings = {}
local player_drawings = {}
local randomevent_drawings = {}
local vehicle_drawings = {}
local corpses_drawings = {}

-- Distance display text
local distanceText = Drawing.new("Text")
distanceText.Size = 20
distanceText.Font = 2
distanceText.Color = Color3.new(1, 1, 1)
distanceText.Position = Vector2.new(50, 50) -- Left middle side of the screen
distanceText.Outline = true
distanceText.Visible = true -- Ensure the text is always visible

-- Functions
function draw(instance, properties)
    local drawing = Drawing.new(instance)
    for i, v in pairs(properties) do
        drawing[i] = v
    end
    return drawing
end

function createtext(type, table)
    if not table[type] then
        local mainText = draw('Text', {Size = 13, Font = 2, Center = true, Outline = true, Color = Color3.new(1, 1, 1)})
        local descText = draw('Text', {Size = 10, Font = 2, Center = true, Outline = true, Color = Color3.new(1, 1, 1)})
        table[type] = {main = mainText, desc = descText}
    end
end

function removetext(type, table)
    if table[type] then
        table[type].main:Remove()
        table[type].desc:Remove()
        table[type] = nil
    end
end

-- Initialization
local function initializeDrawings()
    for _, v in next, workspace.Locations:GetChildren() do
        createtext(v, location_drawings)
    end

    for _, v in next, workspace.Zombies.Mobs:GetChildren() do
        createtext(v, zombie_drawings)
    end

    for _, v in next, workspace.Characters:GetChildren() do 
        createtext(v, player_drawings)
    end

    for _, v in next, workspace.Map.Shared.Randoms:GetChildren() do 
        createtext(v, randomevent_drawings)
    end

    for _, v in next, workspace.Vehicles.Spawned:GetChildren() do
        createtext(v, vehicle_drawings)
    end

    for _, v in next, workspace.Corpses:GetChildren() do
        if v.Name ~= "Zombie" then
            createtext(v, corpses_drawings)
        end
    end
end

initializeDrawings()

-- Event connections
workspace.Zombies.Mobs.ChildAdded:Connect(function(v) createtext(v, zombie_drawings) end)
workspace.Zombies.Mobs.ChildRemoved: Connect(function(v) removetext(v, zombie_drawings) end)
workspace.Characters.ChildAdded:Connect(function(v) createtext(v, player_drawings) end)
workspace.Characters.ChildRemoved:Connect(function(v) removetext(v, player_drawings) end)
workspace.Map.Shared.Randoms.ChildAdded:Connect(function(v) createtext(v, randomevent_drawings) end)
workspace.Map.Shared.Randoms.ChildRemoved:Connect(function(v) removetext(v, randomevent_drawings) end)
workspace.Vehicles.Spawned.ChildAdded:Connect(function(v) createtext(v, vehicle_drawings) end)
workspace.Vehicles.Spawned.ChildRemoved:Connect(function(v) removetext(v, vehicle_drawings) end)
workspace.Corpses.ChildAdded:Connect(function(v) createtext(v, corpses_drawings) end)
workspace.Corpses.ChildRemoved:Connect(function(v) removetext(v, corpses_drawings) end)

-- Function to update distance
local function updateDistance(change)
    settings.player.distance = settings.player.distance + change
    distanceText.Text = "Distance = " .. settings.player.distance
end

-- Key press event
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.PageUp then
            updateDistance(1000) -- Increase distance by 1000
        elseif input.KeyCode == Enum.KeyCode.PageDown then
            updateDistance(-1000) -- Decrease distance by 1000
        end
    end
end)

-- RunService loop
local frameCount = 0
run_service.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    if frameCount % 2 == 0 then -- Update every other frame
        local cameraCFrame = camera.CFrame
        local localCharacter = localplayer.Character

        for _, v in next, location_drawings do
            local pos, visible = camera:WorldToViewportPoint(_.CFrame.p)
            local mag = math.floor((_.CFrame.p - cameraCFrame.p).magnitude)
            v.Visible = visible and settings.location.enabled and (mag <= settings.location.distance) and localCharacter ~= nil
            if v.Visible then
                v.Position = Vector2.new(pos.X, pos.Y)
                v.Text = tostring(_.Name .. ' [' .. mag .. ' studs]')
                v.Color = settings.location.color
            end
        end

        for _, v in next, zombie_drawings do
            if _:FindFirstChild("HumanoidRootPart") then
                local hrp = _.HumanoidRootPart.Parent.Name
                local pos, visible = camera:WorldToViewportPoint(_.HumanoidRootPart.Position)
                local mag = math.floor((_.HumanoidRootPart.Position - cameraCFrame.p).magnitude)
                v.Visible = visible and settings.zombie.enabled and (mag <= settings.zombie.distance) and localCharacter ~= nil
                if v.Visible then
                    v.Position = Vector2.new(pos.X, pos.Y)
                    v.Text = tostring(hrp .. ' [' .. mag .. ' studs]')
                    v.Color = settings.zombie.color
                end
            end
        end

        for _, v in next, player_drawings do 
            if _:FindFirstChild("HumanoidRootPart") then
                local pos, visible = camera:WorldToViewportPoint(_.HumanoidRootPart.Position)
                local playerIdentify = _.HumanoidRootPart.Parent
                local playerID = players:GetPlayerFromCharacter(playerIdentify)
                local playername = playerID and playerID.Name or "Opposition"
                local mag = math.floor((_.HumanoidRootPart.Position - cameraCFrame.p).magnitude)
                v.main.Visible = visible and settings.player.enabled and (mag <= settings.player.distance) and localCharacter ~= nil

                if v.main.Visible and playerID ~= localplayer then
                    v.main.Position = Vector2.new(pos.X, pos.Y)
                    v.main.Text = tostring(playername .. ' [' .. mag .. ' studs]')
                    v.main.Color = settings.player.color

                    if playerID then
                        local playerStats = playerID:FindFirstChild("Stats")
                        if playerStats and playerStats:FindFirstChild("Primary") then
                            v.desc.Visible = true
                            v.desc.Position = Vector2.new(pos.X, pos.Y - 15)
                            v.desc.Text = tostring(playerStats.Primary.Value)
                            v.desc.Color = settings.player.color
                        else
                            v.desc.Visible = false
                        end
                    else
                        v.desc.Visible = false
                    end
                else
                    v.desc.Visible = false
                end
            end
        end

        for _, v in next, randomevent_drawings do
            local pos, visible = camera:WorldToViewportPoint(_.Value.Position)
            local mag = math.floor((_.Value.Position - cameraCFrame.p).magnitude)
            v.Visible = visible and settings.randomevents.enabled and (mag <= settings.randomevents.distance) and localCharacter ~= nil
            if v.Visible then
                v.Position = Vector2.new(pos.X, pos.Y)
                v.Text = tostring(_.Name .. ' [' .. mag .. ' studs]')
                v.Color = settings.randomevents.color
            end
        end

        for _, v in next, vehicle_drawings do
            if _:FindFirstChild("Base") then
                local pos, visible = camera:WorldToViewportPoint(_.Base.CFrame.Position)
                local mag = math.floor((_.Base.CFrame.Position - cameraCFrame.p).magnitude)
                v.Visible = visible and settings.vehicles.enabled and (mag <= settings.vehicles.distance) and localCharacter ~= nil
                if v.Visible then
                    v.Position = Vector2.new(pos.X, pos.Y)
                    v.Text = tostring(_.Name .. ' [' .. mag .. ' studs]')
                    v.Color = settings.vehicles.color
                end
            end
        end

        for _, v in next, corpses_drawings do
            if _:FindFirstChild("Head") and _.Name ~= "Zombie" then
                local pos, visible = camera:WorldToViewportPoint(_.UpperTorso.Position)
                local mag = math.floor((_.Head.Position - cameraCFrame.p).magnitude)
                v.Visible = visible and settings.corpses.enabled and (mag <= settings.corpses.distance) and localCharacter ~= nil
                if v.Visible then
                    v.Position = Vector2.new(pos.X, pos.Y)
                    v.Text = tostring(_.Name .. " corpse [" .. mag .. " studs]")
                    v.Color = settings.corpses.color
                end
            end
        end

        -- Update the distance text on the screen
        distanceText.Text = "Distance = " .. settings.player.distance
    end
end)