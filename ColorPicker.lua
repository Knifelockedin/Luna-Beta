-- Services
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Constants for UI
local PICKER_SIZE = UDim2.new(0, 120, 0, 120)
local HUE_BAR_SIZE = UDim2.new(0, 20, 0, 120)
local PREVIEW_SIZE = UDim2.new(0, 30, 0, 30)

-- Utility Functions
local function createCorner(parent)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = parent
    return corner
end

local function dragify(frame)
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil

    local function updateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragToggle then
                updateInput(input)
            end
        end
    end)
end

-- Color Picker Class
local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(name, parent, defaultColor, callback)
    local self = setmetatable({}, ColorPicker)
    
    self.name = name
    self.callback = callback
    self.currentColor = defaultColor or Color3.fromRGB(255, 0, 0)
    self.isDragging = false
    self.isOpen = false
    
    -- Create main button
    self.button = Instance.new("TextButton")
    self.button.Name = name .. "ColorButton"
    self.button.Size = UDim2.new(0, 100, 0, 30)
    self.button.Position = UDim2.new(0, 0, 0, 0)
    self.button.BackgroundColor3 = self.currentColor
    self.button.Text = name .. " Color"
    self.button.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.button.AutoButtonColor = false
    self.button.Parent = parent
    createCorner(self.button)
    
    -- Create picker frame
    self.pickerGui = Instance.new("Frame")
    self.pickerGui.Name = name .. "ColorPicker"
    self.pickerGui.Size = UDim2.new(0, 170, 0, 200)
    self.pickerGui.Position = UDim2.new(1, 10, 0, 0)
    self.pickerGui.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    self.pickerGui.BorderSizePixel = 0
    self.pickerGui.Visible = false
    self.pickerGui.Parent = self.button
    createCorner(self.pickerGui)
    dragify(self.pickerGui)
    
    -- Create title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = name .. " Color Picker"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.SourceSansBold
    title.Parent = self.pickerGui
    
    -- Create color space
    self.colorSpace = Instance.new("ImageLabel")
    self.colorSpace.Name = "ColorSpace"
    self.colorSpace.Size = PICKER_SIZE
    self.colorSpace.Position = UDim2.new(0, 10, 0, 35)
    self.colorSpace.Image = "rbxassetid://4155801252"
    self.colorSpace.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    self.colorSpace.BorderSizePixel = 0
    self.colorSpace.Parent = self.pickerGui
    createCorner(self.colorSpace)
    
    -- Create hue bar
    self.hueBar = Instance.new("ImageLabel")
    self.hueBar.Name = "HueBar"
    self.hueBar.Size = HUE_BAR_SIZE
    self.hueBar.Position = UDim2.new(0, 140, 0, 35)
    self.hueBar.Image = "rbxassetid://3641079629"
    self.hueBar.BorderSizePixel = 0
    self.hueBar.Parent = self.pickerGui
    createCorner(self.hueBar)
    
    -- Create selector
    self.selector = Instance.new("Frame")
    self.selector.Name = "Selector"
    self.selector.Size = UDim2.new(0, 10, 0, 10)
    self.selector.AnchorPoint = Vector2.new(0.5, 0.5)
    self.selector.BorderSizePixel = 0
    self.selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.selector.Parent = self.colorSpace
    createCorner(self.selector)
    
    -- Create hue selector
    self.hueSelector = Instance.new("Frame")
    self.hueSelector.Name = "HueSelector"
    self.hueSelector.Size = UDim2.new(1, 0, 0, 4)
    self.hueSelector.AnchorPoint = Vector2.new(0, 0.5)
    self.hueSelector.BorderSizePixel = 0
    self.hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.hueSelector.Parent = self.hueBar
    createCorner(self.hueSelector)
    
    -- Create RGB inputs
    self.rgbInputs = {}
    local labels = {"R", "G", "B"}
    for i, label in ipairs(labels) do
        local inputFrame = Instance.new("Frame")
        inputFrame.Size = UDim2.new(0, 50, 0, 25)
        inputFrame.Position = UDim2.new(0, 10 + (i-1) * 55, 0, 165)
        inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        inputFrame.BorderSizePixel = 0
        inputFrame.Parent = self.pickerGui
        createCorner(inputFrame)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 15, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labels[i]
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        label.Parent = inputFrame
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0, 30, 1, 0)
        input.Position = UDim2.new(0, 20, 0, 0)
        input.BackgroundTransparency = 1
        input.Text = "255"
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.TextSize = 12
        input.Parent = inputFrame
        
        self.rgbInputs[label] = input
        
        input.FocusLost:Connect(function()
            local value = tonumber(input.Text)
            if value then
                value = math.clamp(value, 0, 255)
                input.Text = tostring(value)
                self:updateFromRGB()
            else
                input.Text = tostring(math.floor(self.currentColor[label] * 255))
            end
        end)
    end
    
    self:connectEvents()
    self:updateColor(self.currentColor)
    
    return self
end

function ColorPicker:connectEvents()
    -- Toggle picker visibility
    self.button.MouseButton1Click:Connect(function()
        self.isOpen = not self.isOpen
        self.pickerGui.Visible = self.isOpen
    end)
    
    -- Color space selection
    local function updateColorSpace(input)
        local relative = input.Position - self.colorSpace.AbsolutePosition
        local size = self.colorSpace.AbsoluteSize
        
        local x = math.clamp(relative.X, 0, size.X)
        local y = math.clamp(relative.Y, 0, size.Y)
        
        self.selector.Position = UDim2.new(0, x, 0, y)
        
        local saturation = x / size.X
        local value = 1 - (y / size.Y)
        local hue = self:getHue()
        
        self:updateColor(Color3.fromHSV(hue, saturation, value))
    end
    
    self.colorSpace.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.isDragging = true
            updateColorSpace(input)
        end
    end)
    
    self.colorSpace.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.isDragging = false
        end
    end)
    
    self.colorSpace.InputChanged:Connect(function(input)
        if self.isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateColorSpace(input)
        end
    end)
    
    -- Hue bar selection
    local function updateHue(input)
        local relative = input.Position - self.hueBar.AbsolutePosition
        local size = self.hueBar.AbsoluteSize
        
        local y = math.clamp(relative.Y, 0, size.Y)
        self.hueSelector.Position = UDim2.new(0, 0, 0, y - 2)
        
        local hue = y / size.Y
        local saturation = self.selector.Position.X.Scale
        local value = 1 - self.selector.Position.Y.Scale
        
        self.colorSpace.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        self:updateColor(Color3.fromHSV(hue, saturation, value))
    end
    
    self.hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.isDragging = true
            updateHue(input)
        end
    end)
    
    self.hueBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.isDragging = false
        end
    end)
    
    self.hueBar.InputChanged:Connect(function(input)
        if self.isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateHue(input)
        end
    end)
end

function ColorPicker:getHue()
    return self.hueSelector.Position.Y.Offset / self.hueBar.AbsoluteSize.Y
end

function ColorPicker:updateColor(color)
    self.currentColor = color
    self.button.BackgroundColor3 = color
    
    -- Update RGB inputs
    self.rgbInputs.R.Text = tostring(math.floor(color.R * 255))
    self.rgbInputs.G.Text = tostring(math.floor(color.G * 255))
    self.rgbInputs.B.Text = tostring(math.floor(color.B * 255))
    
    if self.callback then
        self.callback(color)
    end
end

function ColorPicker:updateFromRGB()
    local r = tonumber(self.rgbInputs.R.Text) / 255
    local g = tonumber(self.rgbInputs.G.Text) / 255
    local b = tonumber(self.rgbInputs.B.Text) / 255
    
    self:updateColor(Color3.new(r, g, b))
end

function ColorPicker:getCurrentColor()
    return self.currentColor
end

-- Return the ColorPicker class
return ColorPicker
