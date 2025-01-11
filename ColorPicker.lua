local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")


local PICKER_SIZE = UDim2.new(0, 120, 0, 120)
local HUE_BAR_SIZE = UDim2.new(0, 20, 0, 120)
local PREVIEW_SIZE = UDim2.new(0, 30, 0, 30)


local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(name, parent, defaultColor, callback)
    local self = setmetatable({}, ColorPicker)
    
    self.name = name
    self.callback = callback
    self.currentColor = defaultColor or Color3.fromRGB(255, 0, 0)
    self.isOpen = false
    
   
    self.button = Instance.new("TextButton")
    self.button.Name = name .. "ColorButton"
    self.button.Size = UDim2.new(0, 100, 0, 30)
    self.button.BackgroundColor3 = self.currentColor
    self.button.Text = name .. " Color"
    self.button.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.button.Parent = parent
    
   
    self.pickerGui = Instance.new("Frame")
    self.pickerGui.Name = name .. "ColorPicker"
    self.pickerGui.Size = UDim2.new(0, 150, 0, 180)
    self.pickerGui.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    self.pickerGui.BorderSizePixel = 0
    self.pickerGui.Visible = false
    self.pickerGui.Parent = self.button
    
 
    self.colorSpace = Instance.new("ImageLabel")
    self.colorSpace.Name = "ColorSpace"
    self.colorSpace.Size = PICKER_SIZE
    self.colorSpace.Position = UDim2.new(0, 5, 0, 5)
    self.colorSpace.Image = "rbxassetid://4155801252"
    self.colorSpace.BackgroundColor3 = self.currentColor
    self.colorSpace.Parent = self.pickerGui
    
  
    self.hueBar = Instance.new("ImageLabel")
    self.hueBar.Name = "HueBar"
    self.hueBar.Size = HUE_BAR_SIZE
    self.hueBar.Position = UDim2.new(0, 125, 0, 5)
    self.hueBar.Image = "rbxassetid://3641079629"
    self.hueBar.Parent = self.pickerGui
    

    self.selector = Instance.new("Frame")
    self.selector.Name = "Selector"
    self.selector.Size = UDim2.new(0, 4, 0, 4)
    self.selector.BorderSizePixel = 0
    self.selector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.selector.Parent = self.colorSpace
    

    self.hueSelector = Instance.new("Frame")
    self.hueSelector.Name = "HueSelector"
    self.hueSelector.Size = UDim2.new(1, 0, 0, 2)
    self.hueSelector.BorderSizePixel = 0
    self.hueSelector.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    self.hueSelector.Parent = self.hueBar
    

    self:connectEvents()
    
    return self
end

function ColorPicker:connectEvents()

    self.button.MouseButton1Click:Connect(function()
        self.isOpen = not self.isOpen
        self.pickerGui.Visible = self.isOpen
    end)
    

    local function updateColorSpace(input)
        local relative = input.Position - self.colorSpace.AbsolutePosition
        local x = math.clamp(relative.X, 0, self.colorSpace.AbsoluteSize.X)
        local y = math.clamp(relative.Y, 0, self.colorSpace.AbsoluteSize.Y)
        
        self.selector.Position = UDim2.new(0, x - 2, 0, y - 2)
        
        local hue = self:getHue()
        local saturation = x / self.colorSpace.AbsoluteSize.X
        local value = 1 - (y / self.colorSpace.AbsoluteSize.Y)
        
        self.currentColor = Color3.fromHSV(hue, saturation, value)
        self:updateColor()
    end
    
    self.colorSpace.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                    return
                end
                updateColorSpace(input)
            end)
        end
    end)
    

    local function updateHue(input)
        local relative = input.Position - self.hueBar.AbsolutePosition
        local y = math.clamp(relative.Y, 0, self.hueBar.AbsoluteSize.Y)
        
        self.hueSelector.Position = UDim2.new(0, 0, 0, y - 1)
        
        local hue = y / self.hueBar.AbsoluteSize.Y
        self.colorSpace.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        
        local saturation = (self.selector.Position.X.Offset + 2) / self.colorSpace.AbsoluteSize.X
        local value = 1 - ((self.selector.Position.Y.Offset + 2) / self.colorSpace.AbsoluteSize.Y)
        
        self.currentColor = Color3.fromHSV(hue, saturation, value)
        self:updateColor()
    end
    
    self.hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    connection:Disconnect()
                    return
                end
                updateHue(input)
            end)
        end
    end)
end

function ColorPicker:getHue()
    return self.hueSelector.Position.Y.Scale
end

function ColorPicker:updateColor()
    self.button.BackgroundColor3 = self.currentColor
    if self.callback then
        self.callback(self.currentColor)
    end
end

function ColorPicker:getCurrentColor()
    return self.currentColor
end


return ColorPicker
