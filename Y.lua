-- ==========================================
-- الخدمات الأساسية
-- ==========================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- 1. إنشاء الواجهة الأساسية (ScreenGui)
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ProPlayerGUI_V2"
screenGui.ResetOnSpawn = false 
screenGui.Parent = playerGui

-- حاوية الـ ESP (لتنظيم العناصر)
local espContainer = Instance.new("Folder")
espContainer.Name = "ESP_Elements"
espContainer.Parent = screenGui

-- ==========================================
-- 2. إطار القائمة الرئيسية (Main Frame)
-- ==========================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 310)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ لوحة التحكم VIP"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

-- دالة مساعدة لإنشاء الأزرار
local function createButton(name, text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 220, 0, 45)
    btn.Position = UDim2.new(0.5, -110, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 15
    btn.AutoButtonColor = false
    btn.Parent = mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    return btn
end

-- إنشاء أزرار القائمة
local speedButton = createButton("SpeedBtn", "تفعيل السرعة (2x)", 50, Color3.fromRGB(0, 170, 255))
local tpModeButton = createButton("TpModeBtn", "إظهار زر الانتقال", 105, Color3.fromRGB(40, 40, 50))
local espButton = createButton("ESPBtn", "تفعيل ESP والخطوط", 160, Color3.fromRGB(40, 40, 50))
local aimbotButton = createButton("AimbotBtn", "تفعيل Aimbot", 215, Color3.fromRGB(40, 40, 50))

local hintLabel = Instance.new("TextLabel")
hintLabel.Size = UDim2.new(1, 0, 0, 30)
hintLabel.Position = UDim2.new(0, 0, 1, -35)
hintLabel.BackgroundTransparency = 1
hintLabel.Text = "Aimbot = اضغط كليك يمين"
hintLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
hintLabel.Font = Enum.Font.Gotham
hintLabel.TextSize = 12
hintLabel.Parent = mainFrame

-- ==========================================
-- 3. زر الانتقال (Draggable Center Button)
-- ==========================================
local executeTpButton = Instance.new("TextButton")
executeTpButton.Name = "ExecuteTpButton"
executeTpButton.Size = UDim2.new(0, 200, 0, 55)
executeTpButton.Position = UDim2.new(0.5, -100, 0.5, -27) -- يظهر في المنتصف تلقائياً
executeTpButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
executeTpButton.Text = "🎯 انتقال خلف الأقرب!"
executeTpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
executeTpButton.Font = Enum.Font.GothamBold
executeTpButton.TextSize = 18
executeTpButton.Visible = false
executeTpButton.Active = true
executeTpButton.Parent = screenGui

local executeTpCorner = Instance.new("UICorner")
executeTpCorner.CornerRadius = UDim.new(0, 27)
executeTpCorner.Parent = executeTpButton

-- ==========================================
-- 4. دوال سحب الواجهات (Draggable Logic)
-- ==========================================
local function makeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(mainFrame)
makeDraggable(executeTpButton) -- جعل زر الانتقال قابلاً للسحب أيضاً

-- ==========================================
-- 5. متغيرات النظام والدوال المساعدة
-- ==========================================
local isSpeedBoosted = false
local isTpModeActive = false
local isESPActive = false
local isAimbotActive = false

local aimbotFOV = 200 -- مسافة التقاط الايم بوت (بكسل)

local function tweenColor(guiObject, color)
    TweenService:Create(guiObject, TweenInfo.new(0.3), {BackgroundColor3 = color}):Play()
end

-- ==========================================
-- 6. أزرار التحكم (Toggle Logic)
-- ==========================================
speedButton.MouseButton1Click:Connect(function()
    isSpeedBoosted = not isSpeedBoosted
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = isSpeedBoosted and 32 or 16
        speedButton.Text = isSpeedBoosted and "إلغاء السرعة (1x)" or "تفعيل السرعة (2x)"
        tweenColor(speedButton, isSpeedBoosted and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(0, 170, 255))
    end
end)

tpModeButton.MouseButton1Click:Connect(function()
    isTpModeActive = not isTpModeActive
    executeTpButton.Visible = isTpModeActive
    tpModeButton.Text = isTpModeActive and "إخفاء زر الانتقال" or "إظهار زر الانتقال"
    tweenColor(tpModeButton, isTpModeActive and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(40, 40, 50))
end)

espButton.MouseButton1Click:Connect(function()
    isESPActive = not isESPActive
    espButton.Text = isESPActive and "تعطيل ESP" or "تفعيل ESP والخطوط"
    tweenColor(espButton, isESPActive and Color3.fromRGB(150, 50, 200) or Color3.fromRGB(40, 40, 50))
    if not isESPActive then espContainer:ClearAllChildren() end
end)

aimbotButton.MouseButton1Click:Connect(function()
    isAimbotActive = not isAimbotActive
    aimbotButton.Text = isAimbotActive and "تعطيل Aimbot" or "تفعيل Aimbot"
    tweenColor(aimbotButton, isAimbotActive and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(40, 40, 50))
end)

-- ==========================================
-- 7. منطق التنقل الآني (Teleport)
-- ==========================================
executeTpButton.MouseButton1Click:Connect(function()
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local nearest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local d = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist, nearest = d, p end
            end
        end
    end

    if nearest then
        local targetRoot = nearest.Character.HumanoidRootPart
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3) -- 3 أمتار للخلف
    end
end)

-- ==========================================
-- 8. منطق الـ ESP (صناديق، صحة، خطوط)
-- ==========================================
-- دالة لإنشاء خط (Tracer) باستخدام Frame
local function createLine()
    local line = Instance.new("Frame")
    line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    line.BorderSizePixel = 0
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.ZIndex = 0
    return line
end

local espObjects = {}

RunService.RenderStepped:Connect(function()
    if not isESPActive then return end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            -- تجهيز حاويات اللاعب في الجدول إذا لم تكن موجودة
            if not espObjects[p] then
                espObjects[p] = {
                    Box = Instance.new("Frame"),
                    HealthBG = Instance.new("Frame"),
                    HealthBar = Instance.new("Frame"),
                    Tracer = createLine()
                }
                
                espObjects[p].Box.BackgroundTransparency = 1
                espObjects[p].Box.BorderColor3 = Color3.fromRGB(255, 50, 50)
                espObjects[p].Box.BorderSizePixel = 2
                espObjects[p].Box.Parent = espContainer

                espObjects[p].HealthBG.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                espObjects[p].HealthBG.BorderSizePixel = 0
                espObjects[p].HealthBG.Parent = espContainer

                espObjects[p].HealthBar.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
                espObjects[p].HealthBar.BorderSizePixel = 0
                espObjects[p].HealthBar.Parent = espObjects[p].HealthBG
                
                espObjects[p].Tracer.Parent = espContainer
            end

            local objs = espObjects[p]
            local char = p.Character
            local isValid = false

            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Head") and char.Humanoid.Health > 0 then
                -- تحويل الإحداثيات ثلاثية الأبعاد إلى شاشة 2D
                local headPos, onScreen1 = camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0))
                local rootPos, onScreen2 = camera:WorldToViewportPoint(char.HumanoidRootPart.Position - Vector3.new(0, 3, 0))

                if onScreen1 or onScreen2 then
                    isValid = true
                    -- حساب حجم المربع
                    local height = math.abs(rootPos.Y - headPos.Y)
                    local width = height / 2

                    objs.Box.Size = UDim2.new(0, width, 0, height)
                    objs.Box.Position = UDim2.new(0, rootPos.X - width/2, 0, headPos.Y)

                    -- حساب شريط الصحة
                    local healthPct = char.Humanoid.Health / char.Humanoid.MaxHealth
                    objs.HealthBG.Size = UDim2.new(0, 4, 0, height)
                    objs.HealthBG.Position = UDim2.new(0, rootPos.X - width/2 - 8, 0, headPos.Y)
                    
                    objs.HealthBar.Size = UDim2.new(1, 0, healthPct, 0)
                    objs.HealthBar.Position = UDim2.new(0, 0, 1 - healthPct, 0)
                    objs.HealthBar.BackgroundColor3 = Color3.fromRGB(255 - (healthPct*255), healthPct*255, 50)

                    -- حساب السهم (Tracer) من أعلى منتصف الشاشة
                    local startPos = Vector2.new(camera.ViewportSize.X / 2, 0)
                    local endPos = Vector2.new(rootPos.X, rootPos.Y - (height/2))
                    local distance = (endPos - startPos).Magnitude

                    objs.Tracer.Size = UDim2.new(0, distance, 0, 1.5)
                    objs.Tracer.Position = UDim2.new(0, (startPos.X + endPos.X)/2, 0, (startPos.Y + endPos.Y)/2)
                    objs.Tracer.Rotation = math.deg(math.atan2(endPos.Y - startPos.Y, endPos.X - startPos.X))
                end
            end

            -- إخفاء العناصر إذا كان اللاعب ميت أو خارج الشاشة
            objs.Box.Visible = isValid
            objs.HealthBG.Visible = isValid
            objs.Tracer.Visible = isValid
        end
    end
end)

-- تنظيف الـ ESP عند خروج لاعب
Players.PlayerRemoving:Connect(function(p)
    if espObjects[p] then
        espObjects[p].Box:Destroy()
        espObjects[p].HealthBG:Destroy()
        espObjects[p].Tracer:Destroy()
        espObjects[p] = nil
    end
end)

-- ==========================================
-- 9. منطق الـ Aimbot الخارق
-- ==========================================
-- دالة لجلب أقرب لاعب لمؤشر الماوس
local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDist = aimbotFOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closestPlayer = p
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- تثبيت الكاميرا عند الضغط المستمر
RunService.RenderStepped:Connect(function()
    if isAimbotActive and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestPlayerToCursor()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- ثبات خارق وسريع: توجيه الكاميرا مباشرة نحو رأس الهدف
            camera.CFrame = CFrame.new(camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
