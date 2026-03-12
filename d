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
local player = Players.LocalPlayer

task.spawn(function()
    while true do
        task.wait(0.1)

        if Toggles.InfStamina.Value then
            if player:FindFirstChild("Attributes") and player.Attributes:FindFirstChild("Stamina") then
                player.Attributes.Stamina.Value = 50
            end
        end

        if Toggles.InfStrength.Value then
            if player:FindFirstChild("Attributes") and player.Attributes:FindFirstChild("Strength") then
                player.Attributes.Strength.Value = 11
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
    local h = model:FindFirstChildOfClass("Highlight")
    if h then h:Destroy() end

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

local function setInvisible(character,bool)
    for _,part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            part.Transparency = bool and 1 or 0
        end
    end
end

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

        if not Toggles.AutoFarm.Value then continue end

        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")

        setInvisible(character,true)

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

ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
