--[[  
    @title XAO Stock Bot
    @description Grow a Garden Discord Stock Bot
    https://www.roblox.com/games/126884695634066
]]

--// LOADING SCREEN
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "XAO_Loader"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local bg = Instance.new("Frame", gui)
bg.Size = UDim2.new(1,0,1,0)
bg.BackgroundColor3 = Color3.fromRGB(20,20,20)
bg.BorderSizePixel = 0

local title = Instance.new("TextLabel", bg)
title.Size = UDim2.new(1,0,1,0)
title.Text = "🔷 XPERIA XAO\nLoading..."
title.Font = Enum.Font.GothamBlack
title.TextSize = 36
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextStrokeTransparency = 0.5
title.TextStrokeColor3 = Color3.fromRGB(0,0,0)
title.TextWrapped = true
title.TextYAlignment = Enum.TextYAlignment.Center

task.wait(3)
gui:Destroy()

--// WAIT UNTIL GAME READY
repeat task.wait() until game:IsLoaded()
repeat task.wait() until player.Character
repeat task.wait() until player:FindFirstChild("PlayerGui")

--// CONFIG
_G.Configuration = {
    Enabled             = true,
    Webhook             = "https://discord.com/api/webhooks/....",  -- ganti webhook kamu
    ["Weather Reporting"]= true,
    ["Anti-AFK"]        = true,
    ["Auto-Reconnect"]  = true,
    ["Rendering Enabled"]= true,

    AlertLayouts = {
        Weather = {
            EmbedColor = Color3.fromRGB(0,176,255)
        },
        SeedsAndGears = {
            EmbedColor = Color3.fromRGB(0,255,0),
            Layout = {
                ["ROOT/SeedStock/Stocks"] = "🌱 SEED STOCK",
                ["ROOT/GearStock/Stocks"] = "⚙️ GEAR STOCK"
            }
        },
        EventShop = {
            EmbedColor = Color3.fromRGB(255,0,200),
            Layout = {
                ["ROOT/EventShopStock/Stocks"] = "🎁 EVENT STOCK"
            }
        },
        Eggs = {
            EmbedColor = Color3.fromRGB(255,255,0),
            Layout = {
                ["ROOT/PetEggStock/Stocks"] = "🥚 EGG STOCK"
            }
        },
        CosmeticStock = {
            EmbedColor = Color3.fromRGB(255,90,0),
            Layout = {
                ["ROOT/CosmeticStock/ItemStocks"] = "🎨 COSMETIC STOCK"
            }
        }
    }
}

--// SERVICES & REFERENCES
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local HttpService         = game:GetService("HttpService")
local VirtualUser         = cloneref(game:GetService("VirtualUser"))
local RunService          = game:GetService("RunService")
local GuiService          = game:GetService("GuiService")
local TeleportService     = game:GetService("TeleportService")

local DataStream          = ReplicatedStorage.GameEvents.DataStream
local WeatherEventStarted = ReplicatedStorage.GameEvents.WeatherEventStarted

local PlaceId = game.PlaceId
local JobId   = game.JobId

--// PREVENT MULTI-RUN
if _G.StockBot then return end
_G.StockBot = true

--// HELPERS
local function cfg(k) return _G.Configuration[k] end
RunService:Set3dRenderingEnabled(cfg("Rendering Enabled"))

local function ConvertColor(c)
    return tonumber(c:ToHex(),16)
end

local function GetPacket(data, key)
    for _,p in ipairs(data) do
        if p[1]==key then return p[2] end
    end
end

local function WebhookSend(typeName, fields)
    if not cfg("Enabled") then return end
    local layout = _G.Configuration.AlertLayouts[typeName]
    local color  = ConvertColor(layout.EmbedColor)
    local body = {
        embeds = {{
            color     = color,
            fields    = fields,
            footer    = { text = "🔷 XAO Stock Monitor" },
            timestamp = DateTime.now():ToIsoDate()
        }}
    }
    task.spawn(request,{
        Url     = cfg("Webhook"),
        Method  = "POST",
        Headers = {["Content-Type"]="application/json"},
        Body    = HttpService:JSONEncode(body)
    })
end

local function MakeStockString(stock)
    local s = ""
    for name,info in pairs(stock) do
        local amt = info.Stock
        local disp= info.EggName or name
        s..=string.format("%s **x%d**\n",disp,amt)
    end
    return s
end

local function ProcessPacket(data,typeName,layout)
    local flds={},lyt=layout.Layout
    if not lyt then return end
    for pkt,title in pairs(lyt) do
        local stock=GetPacket(data,pkt)
        if stock then
            table.insert(flds,{
                name   = title,
                value  = MakeStockString(stock),
                inline = true
            })
        end
    end
    WebhookSend(typeName,flds)
end

--// EVENTS
DataStream.OnClientEvent:Connect(function(t,profile,data)
    if t~="UpdateData" or not profile:find(player.Name) then return end
    for name,lyt in pairs(_G.Configuration.AlertLayouts) do
        ProcessPacket(data,name,lyt)
    end
end)

WeatherEventStarted.OnClientEvent:Connect(function(ev,len)
    if not cfg("Weather Reporting") then return end
    local endTs = math.round(workspace:GetServerTimeNow())+len
    WebhookSend("Weather",{{
        name  = "🌦️ WEATHER EVENT",
        value = string.format("%s\nEnds:<t:%d:R>",ev,endTs),
        inline= true
    }})
end)

player.Idled:Connect(function()
    if cfg("Anti-AFK")then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

GuiService.ErrorMessageChanged:Connect(function()
    if not cfg("Auto-Reconnect") then return end
    queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/ARMANSYAH112/Grow-a-garden-/main/xao_stock_bot.lua'))()")
    if #Players:GetPlayers()<=1 then
        TeleportService:Teleport(PlaceId,player)
    else
        TeleportService:TeleportToPlaceInstance(PlaceId,JobId,player)
    end
end)
