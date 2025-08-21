--// NgNhi Hub Zombie
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ZombiesFolder = workspace:WaitForChild("Zombies")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Trạng thái
local ESPEnabled = false
local AutoFarm = false

------------------------------------------------------
-- ANTI
------------------------------------------------------

-- Anti Kick
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" then
        return nil -- chặn kick
    end
    return oldNamecall(self, ...)
end)

-- Anti Report (block RemoteEvent tên report, log, ban,...)
for _,v in pairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        local name = v.Name:lower()
        if string.find(name,"report") or string.find(name,"ban") or string.find(name,"log") then
            v:Destroy()
        end
    end
end

-- Anti AFK
player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

------------------------------------------------------
-- ESP
------------------------------------------------------
local function addESP(zombie)
    if zombie:FindFirstChild("HumanoidRootPart") then
        local hl = Instance.new("Highlight")
        hl.Name = "ESP_Highlight"
        hl.FillColor = Color3.fromRGB(0,255,0)
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.Parent = zombie

        local bb = Instance.new("BillboardGui", zombie)
        bb.Name = "ESP_Billboard"
        bb.Size = UDim2.new(0,100,0,30)
        bb.Adornee = zombie.HumanoidRootPart
        bb.AlwaysOnTop = true
        local txt = Instance.new("TextLabel", bb)
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.fromRGB(255,0,0)
        txt.TextScaled = true
        txt.Text = "Zombie"
    end
end

for _,z in pairs(ZombiesFolder:GetChildren()) do
    addESP(z)
end
ZombiesFolder.ChildAdded:Connect(addESP)

------------------------------------------------------
-- AUTO FARM
------------------------------------------------------
local function getClosestZombie()
    local closest, dist = nil, math.huge
    for _, z in pairs(ZombiesFolder:GetChildren()) do
        local hrpZ = z:FindFirstChild("HumanoidRootPart")
        local hum = z:FindFirstChildOfClass("Humanoid")
        if hrpZ and hum and hum.Health > 0 then
            local mag = (hrp.Position - hrpZ.Position).Magnitude
            if mag < dist then
                closest = z
                dist = mag
            end
        end
    end
    return closest
end

task.spawn(function()
    while task.wait(0.2) do
        if AutoFarm and hrp and char and char:FindFirstChildOfClass("Humanoid") then
            local target = getClosestZombie()
            if target then
                local hrpZ = target:FindFirstChild("HumanoidRootPart")
                if hrpZ then
                    -- Dịch chuyển sát zombie
                    hrp.CFrame = hrpZ.CFrame * CFrame.new(0,0,-3)
                    -- Đánh (nếu có tool cầm)
                    for _, tool in pairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            tool:Activate()
                        end
                    end
                end
            end
        end
    end
end)

------------------------------------------------------
-- UI Mobile
------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,160,0,100)
Frame.Position = UDim2.new(0.05,0,0.25,0)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.BackgroundTransparency = 0.2
Frame.Active = true
Frame.Draggable = true

local ESPBtn = Instance.new("TextButton", Frame)
ESPBtn.Size = UDim2.new(1,0,0.5,0)
ESPBtn.Text = "ESP: OFF"
ESPBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
ESPBtn.TextColor3 = Color3.fromRGB(255,255,255)
ESPBtn.Font = Enum.Font.SourceSansBold
ESPBtn.TextSize = 18

ESPBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPBtn.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
    for _, zombie in pairs(ZombiesFolder:GetChildren()) do
        local hl = zombie:FindFirstChild("ESP_Highlight")
        local bb = zombie:FindFirstChild("ESP_Billboard")
        if hl then hl.Enabled = ESPEnabled end
        if bb then bb.Enabled = ESPEnabled end
    end
end)

local FarmBtn = Instance.new("TextButton", Frame)
FarmBtn.Size = UDim2.new(1,0,0.5,0)
FarmBtn.Position = UDim2.new(0,0,0.5,0)
FarmBtn.Text = "AutoFarm: OFF"
FarmBtn.BackgroundColor3 = Color3.fromRGB(90,30,30)
FarmBtn.TextColor3 = Color3.fromRGB(255,255,255)
FarmBtn.Font = Enum.Font.SourceSansBold
FarmBtn.TextSize = 18

FarmBtn.MouseButton1Click:Connect(function()
    AutoFarm = not AutoFarm
    FarmBtn.Text = AutoFarm and "AutoFarm: ON" or "AutoFarm: OFF"
end)
