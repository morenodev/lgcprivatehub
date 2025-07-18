local HttpService = game:GetService("HttpService")
local KEYLIST_URL = "https://raw.githubusercontent.com/Saintssaaa/notfileupdate98./main/notfileupdate98.txt"

if not script_key or typeof(script_key) ~= "string" or script_key == "" then
    warn("[LGC HUB] No license key provided.")
    return
end

local function getRequestFunction()
    return (syn and syn.request)
        or (http and http.request)
        or request
        or http_request
end

local function keyIsValidOnline(key)
    local request = getRequestFunction()
    if not request then
        warn("[LGC HUB] HTTP request function not supported in this executor.")
        return false
    end

    local response
    local success, err = pcall(function()
        response = request({
            Url = KEYLIST_URL,
            Method = "GET"
        })
    end)

    if not success or not response or not response.Body then
        warn("[LGC HUB] Failed to fetch key list.")
        return false
    end

    for line in response.Body:gmatch("[^\r\n]+") do
        if line == key then
            return true
        end
    end

    return false
end

if not keyIsValidOnline(script_key) then
    warn("[LGC HUB] Invalid or unauthorized license key.")
    return
end

if getgenv then
    if getgenv().LGC_HUB_RUNNING then return end
    getgenv().LGC_HUB_RUNNING = true
end

local WORKSPACE_DIR, JSON_FILE = "LGC HUB", "LGC HUB/jobid.json"
if not isfolder(WORKSPACE_DIR) then makefolder(WORKSPACE_DIR) end
if not isfile(JSON_FILE) then
    writefile(JSON_FILE, HttpService:JSONEncode({jobid = ""}))
else
    local ok, content = pcall(readfile, JSON_FILE)
    local valid = false
    if ok and content then
        local suc, obj = pcall(HttpService.JSONDecode, HttpService, content)
        if suc and typeof(obj) == "table" and obj.jobid ~= nil then
            valid = true
        end
    end
    if not valid then
        writefile(JSON_FILE, HttpService:JSONEncode({jobid = ""}))
    end
end

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local PLACE_ID = 109983668079237
local THEME_MAIN = Color3.fromRGB(45, 48, 65)
local THEME_ACCENT = Color3.fromRGB(80, 160, 255)
local CHECK_INTERVAL = 1

local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "LGC_HUB_Terminal"
sg.ResetOnSpawn = false

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 340, 0, 180)
frame.Position = UDim2.new(0.05, 0, 0.1, 0)
frame.BackgroundColor3 = THEME_MAIN
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Active = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = THEME_ACCENT
stroke.Thickness = 2

local shadow = Instance.new("ImageLabel", frame)
shadow.Image = "rbxassetid://1316045217"
shadow.Size = UDim2.fromScale(1.18, 1.3)
shadow.Position = UDim2.fromScale(-0.09, -0.13)
shadow.BackgroundTransparency = 1
shadow.ImageTransparency = 0.6
shadow.ZIndex = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 32)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "LGC HUB"
title.TextColor3 = THEME_ACCENT
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextTransparency = 1

local notice = Instance.new("TextLabel", frame)
notice.Size = UDim2.new(1, -40, 0, 85)
notice.Position = UDim2.new(0, 18, 0, 35)
notice.BackgroundTransparency = 1
notice.Text = "Waiting for JobId update..."
notice.TextWrapped = true
notice.TextColor3 = Color3.new(1, 1, 1)
notice.TextSize = 18
notice.Font = Enum.Font.Gotham
notice.TextTransparency = 1

local footer = Instance.new("TextLabel", frame)
footer.Size = UDim2.new(1, 0, 0, 20)
footer.Position = UDim2.new(0, 0, 1, -20)
footer.BackgroundTransparency = 1
footer.Text = "discord.gg/XTWHvdfGAz"
footer.Font = Enum.Font.GothamMedium
footer.TextColor3 = THEME_ACCENT
footer.TextSize = 14
footer.TextWrapped = true
footer.TextTransparency = 1
TweenService:Create(footer, TweenInfo.new(0.8), {TextTransparency = 0}):Play()

TweenService:Create(frame, TweenInfo.new(0.8), {BackgroundTransparency = 0.06}):Play()
TweenService:Create(title, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
TweenService:Create(notice, TweenInfo.new(0.8), {TextTransparency = 0}):Play()

local function updateNotice(msg, color)
    notice.Text = msg
    notice.TextColor3 = color or Color3.fromRGB(255, 255, 255)
    notice.TextTransparency = 0.4
    TweenService:Create(notice, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
end

local dragging, dragStart, startPos = false, nil, nil
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

local function readJobId()
    local ok, result = pcall(function()
        return HttpService:JSONDecode(readfile(JSON_FILE)).jobid
    end)
    return ok and result or ""
end

local lastJobId = readJobId()

task.spawn(function()
    updateNotice("Waiting for JobId update...", Color3.new(1, 1, 1))
    while true do
        local jobId = readJobId()
        if jobId ~= "" and jobId ~= lastJobId then
            lastJobId = jobId
            updateNotice("Teleporting to new JobId:\n" .. jobId, THEME_ACCENT)
            TeleportService:TeleportToPlaceInstance(PLACE_ID, jobId, player)
        end
        task.wait(CHECK_INTERVAL)
    end
end)
