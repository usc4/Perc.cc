local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Trap N Bang - by Digz',
    Center = true,
    AutoShow = true,
    TabPadding = 8
})

local Tabs = {
    Farm = Window:AddTab('Farm'),
    Self = Window:AddTab('Self'),
    Gun = Window:AddTab('Gun'),
    Visuals = Window:AddTab('Visuals'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local FarmGroup = Tabs.Farm:AddLeftGroupbox('Auto Farm')

FarmGroup:AddToggle('AutoFarm',{
    Text='Auto Farm',
    Default=false
})

local SelfGroup = Tabs.Self:AddLeftGroupbox('Player')

SelfGroup:AddToggle('InfStamina',{
    Text='Inf Stamina',
    Default=false
})

SelfGroup:AddToggle('InfStrength',{
    Text='Inf Strength',
    Default=false
})

SelfGroup:AddToggle('InfSpeed',{
    Text='Inf Speed',
    Default=false
})

local GunGroup = Tabs.Gun:AddLeftGroupbox('Gun Mods')

GunGroup:AddToggle('NoRecoilSpread',{
    Text='No Recoil / No Spread',
    Default=false
})

local VisualGroup = Tabs.Visuals:AddLeftGroupbox('Visual')

VisualGroup:AddToggle('NittyESP',{
    Text='Nitty ESP',
    Default=false
})

VisualGroup:AddToggle('InstantPrompts',{
    Text='Instant Prompts',
    Default=false
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- NO RECOIL / NO SPREAD LOOP
task.spawn(function()

    while true do
        task.wait(1)

        if not Toggles.NoRecoilSpread.Value then
            continue
        end

        for _,v in pairs(getgc(true)) do
            if type(v) == "table" then
                
                if rawget(v,"Spread") then
                    if type(v.Spread) == "table" then
                        for k in pairs(v.Spread) do
                            v.Spread[k] = 0
                        end
                    else
                        v.Spread = 0
                    end
                end
                
                if rawget(v,"Recoil") then
                    if type(v.Recoil) == "table" then
                        for k in pairs(v.Recoil) do
                            v.Recoil[k] = 0
                        end
                    else
                        v.Recoil = 0
                    end
                end

            end
        end

    end

end)

RunService.Heartbeat:Connect(function()

    local attributes = player:FindFirstChild("Attributes")
    if attributes then

        if Toggles.InfStamina.Value then
            local stamina = attributes:FindFirstChild("Stamina")
            if stamina and stamina.Value ~= 50 then
                stamina.Value = 50
            end
        end

        if Toggles.InfStrength.Value then
            local strength = attributes:FindFirstChild("Strength")
            if strength and strength.Value ~= 11 then
                strength.Value = 11
            end
        end

        if Toggles.InfSpeed.Value then
            local speed = attributes:FindFirstChild("Speed")
            if speed and speed.Value ~= 10 then
                speed.Value = 10
            end
        end

    end

end)

local function setInstantPrompt(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
    end
end

Toggles.InstantPrompts:OnChanged(function()

    if Toggles.InstantPrompts.Value then

        for _,v in ipairs(workspace:GetDescendants()) do
            setInstantPrompt(v)
        end

        workspace.DescendantAdded:Connect(function(v)
            setInstantPrompt(v)
        end)

    end

end)

local Nittys = workspace:WaitForChild("Nittys")
local OUTLINE_COLOR = Color3.fromRGB(255,255,0)

local function removeHighlight(model)

    local highlight = model:FindFirstChildOfClass("Highlight")
    if highlight then highlight:Destroy() end

    local hrp = model:FindFirstChild("HumanoidRootPart")

    if hrp then
        local tag = hrp:FindFirstChild("NittyTag")
        if tag then tag:Destroy() end
    end

end

local function applyHighlight(model)

    if not model:IsA("Model") then return end
    if not Toggles.NittyESP.Value then return end

    removeHighlight(model)

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = OUTLINE_COLOR
    highlight.Adornee = model
    highlight.Parent = model

    local hrp = model:FindFirstChild("HumanoidRootPart")

    if hrp then

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "NittyTag"
        billboard.Size = UDim2.new(0,100,0,40)
        billboard.StudsOffset = Vector3.new(0,3,0)
        billboard.AlwaysOnTop = true
        billboard.Parent = hrp

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.Text = "Nitty"
        label.TextColor3 = OUTLINE_COLOR
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard

    end

end

Toggles.NittyESP:OnChanged(function()

    if Toggles.NittyESP.Value then

        for _,model in ipairs(Nittys:GetChildren()) do
            applyHighlight(model)
        end

    else

        for _,model in ipairs(Nittys:GetChildren()) do
            removeHighlight(model)
        end

    end

end)

Nittys.ChildAdded:Connect(function(model)

    if Toggles.NittyESP.Value then
        applyHighlight(model)
    end

end)

local function chopCarcass(rootPart)

    local carcass = workspace.ButchersJob.Step2:GetChildren()[2].Carcass
    local prompt = carcass:FindFirstChildWhichIsA("ProximityPrompt")

    rootPart.CFrame = carcass.CFrame * CFrame.new(0,-8,0)
    task.wait(0.3)

    if prompt then
        fireproximityprompt(prompt)
        task.wait(3)
    end

end

local function chopBoard(rootPart)

    local meat = workspace.ButchersJob.Step3.PlaceChopMeat.Meat
    local prompt = meat:FindFirstChildWhichIsA("ProximityPrompt")

    rootPart.CFrame = meat.CFrame * CFrame.new(0,-4,0)
    task.wait(0.3)

    if prompt then
        fireproximityprompt(prompt)
        task.wait(3)
    end

end

local function sellMeat(rootPart)

    local sellPart = workspace.ButchersJob.SellMeat.MeatSell
    local sellPrompt = sellPart:FindFirstChildWhichIsA("ProximityPrompt")

    rootPart.CFrame = sellPart.CFrame * CFrame.new(0,-4,0)
    task.wait(0.3)

    if sellPrompt then
        fireproximityprompt(sellPrompt)
        task.wait(3)
    end

end

task.spawn(function()

    while true do
        task.wait()

        if not Toggles.AutoFarm.Value then
            continue
        end

        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        chopCarcass(rootPart)
        chopBoard(rootPart)
        sellMeat(rootPart)

    end

end)

local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload',function()
    Library:Unload()
end)

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind',{
    Default='End',
    NoUI=true,
    Text='Menu keybind'
})

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})

ThemeManager:SetFolder('Digz')
SaveManager:SetFolder('Digz/Trap N Bang')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
