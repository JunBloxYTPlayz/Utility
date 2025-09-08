-- 🌌 Utility Hub (Hitbox + Jump + Inf Jump + Auto Escape)
-- Credits: SE EVICT

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Settings
local HITBOX_PART = "HumanoidRootPart"
local hitboxSize = Vector3.new(5, 5, 5)
local visualizerEnabled = true
local infJumpEnabled = false
local customJumpPower = 50
local EscapeLocation = Vector3.new(923.89, 125.09, 32852.62)
local EscapeHealth = 3500

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 270, 0, 220)
Frame.Position = UDim2.new(0.65, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- dark
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Visible = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "🌌 Utility Hub"
Title.TextColor3 = Color3.fromRGB(200, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

-- Scrolling Frame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -10, 1, -45)
Scroll.Position = UDim2.new(0, 5, 0, 40)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 400)
Scroll.ScrollBarThickness = 4
Scroll.BackgroundTransparency = 1
Scroll.Parent = Frame

local UIListLayout = Instance.new("UIListLayout", Scroll)
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Utility function: make button
local function makeButton(txt, color)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 30)
    Btn.BackgroundColor3 = color or Color3.fromRGB(45, 45, 45)
    Btn.Text = txt
    Btn.TextColor3 = Color3.new(1, 1, 1)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = Scroll
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    return Btn
end

-- Utility function: make textbox
local function makeBox(placeholder, default)
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -20, 0, 30)
    Box.PlaceholderText = placeholder
    Box.Text = default or ""
    Box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Box.TextColor3 = Color3.new(1, 1, 1)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Box.Parent = Scroll
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
    return Box
end

-- ========== HITBOX ==========
local HitboxBox = makeBox("Hitbox Size (e.g. 10)", "")
local ToggleVisualizer = makeButton("Visualizer: ON", Color3.fromRGB(60,200,120))

ToggleVisualizer.MouseButton1Click:Connect(function()
    visualizerEnabled = not visualizerEnabled
    ToggleVisualizer.Text = "Visualizer: " .. (visualizerEnabled and "ON" or "OFF")
    ToggleVisualizer.BackgroundColor3 = visualizerEnabled and Color3.fromRGB(60,200,120) or Color3.fromRGB(200,80,80)
end)

-- ========== JUMP ==========
local JumpBox = makeBox("Jump Power", tostring(customJumpPower))
local ToggleInfJump = makeButton("Inf Jump: OFF", Color3.fromRGB(200,80,80))

ToggleInfJump.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    ToggleInfJump.Text = "Inf Jump: " .. (infJumpEnabled and "ON" or "OFF")
    ToggleInfJump.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(60,200,120) or Color3.fromRGB(200,80,80)
end)

-- Mini Toggle Button
local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 50, 0, 50)
MiniBtn.Position = UDim2.new(0, 20, 0.7, 0)
MiniBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
MiniBtn.Text = "⚙️"
MiniBtn.TextColor3 = Color3.new(1,1,1)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 20
MiniBtn.Active = true
MiniBtn.Draggable = true
MiniBtn.Parent = ScreenGui
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(1,0)

MiniBtn.MouseButton1Click:Connect(function()
    Frame.Visible = not Frame.Visible
end)

-- ========= GAME LOGIC =========

-- Hitbox updater
local function applyHitbox(player)
    if player ~= LocalPlayer and player.Character then
        local part = player.Character:FindFirstChild(HITBOX_PART)
        if part and part:IsA("BasePart") then
            local num = tonumber(HitboxBox.Text)
            if num and num > 0 then
                hitboxSize = Vector3.new(num,num,num)
            end

            part.Size = hitboxSize
            part.CanCollide = false

            if visualizerEnabled then
                local adorn = part:FindFirstChild("HitboxVisualizer")
                if not adorn then
                    adorn = Instance.new("BoxHandleAdornment")
                    adorn.Name = "HitboxVisualizer"
                    adorn.Adornee = part
                    adorn.Size = hitboxSize
                    adorn.Transparency = 0.7
                    adorn.Color3 = Color3.fromRGB(255,50,100)
                    adorn.AlwaysOnTop = true
                    adorn.ZIndex = 5
                    adorn.Parent = part
                else
                    adorn.Size = hitboxSize
                end
            else
                local adorn = part:FindFirstChild("HitboxVisualizer")
                if adorn then adorn:Destroy() end
            end
        end
    end
end

-- Setup players
local function setupPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        applyHitbox(player)
    end)
    if player.Character then applyHitbox(player) end
end
for _,p in pairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)

-- Inf Jump
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Custom Jump Power persist
local function setJumpPower()
    local num = tonumber(JumpBox.Text)
    if num and num > 0 then
        customJumpPower = num
    end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower = true hum.JumpPower = customJumpPower end
end

local TPButton = makeButton("Escape Button", Color3.fromRGB(120,120,250))

TPButton.MouseButton1Click:Connect(function()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 180, 0, 80)
Frame.Position = UDim2.new(0.7, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundTransparency = 1
Title.Text = "🌌 Escape"
Title.TextColor3 = Color3.fromRGB(200,200,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = Frame

-- Escape Button
local EscapeBtn = Instance.new("TextButton")
EscapeBtn.Size = UDim2.new(1,-20,0,30)
EscapeBtn.Position = UDim2.new(0,10,0,40)
EscapeBtn.Text = "🚪 Teleport"
EscapeBtn.BackgroundColor3 = Color3.fromRGB(150,100,250)
EscapeBtn.TextColor3 = Color3.new(1,1,1)
EscapeBtn.Font = Enum.Font.GothamBold
EscapeBtn.TextSize = 14
EscapeBtn.Parent = Frame
Instance.new("UICorner", EscapeBtn).CornerRadius = UDim.new(0,8)

-- Teleport Logic
EscapeBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(923.89, 125.09, 32852.62)
    end
end)
end)

print("[🌌 Utility Hub Loaded | Credits: SE EVICT]")

local AimButton = makeButton("AlMBOT Button", Color3.fromRGB(120,120,250))
AimButton.MouseButton1Click:Connect(function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Totocoems/Ace/main/Ace"))()
end)
