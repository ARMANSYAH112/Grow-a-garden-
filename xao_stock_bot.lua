--[[  
    @title XAO Stock Bot
    @description Grow a Garden Discord Stock Bot
]]

--// FIXED: Loading GUI XAO
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Buat GUI
local gui = Instance.new("ScreenGui")
gui.Name = "XAO_Loader"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- Background fullscreen
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.Position = UDim2.new(0, 0, 0, 0)
bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- hitam gelap
bg.BorderSizePixel = 0
bg.Parent = gui

-- Teks loading tengah
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.Text = "🔷 XPERIA XAO\nLoading..."
title.Font = Enum.Font.GothamBlack
title.TextSize = 36
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.TextStrokeTransparency = 0.5
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
title.TextWrapped = true
title.TextYAlignment = Enum.TextYAlignment.Center
title.Parent = bg

task.wait(3)
gui:Destroy()

--// CONFIG
_G.Configuration = {
    ["Enabled"] = true,
    ["Webhook"] = "https://discord.com/api/webhooks/....", -- Ganti dengan webhook kamu
    ["Weather Reporting"] = true,
    ["Anti-AFK"] = true,
    ["Auto-Reconnect"] = true,
    ["Rendering Enabled"] = false,

    ["AlertLayouts"] = {
        ["Weather"] = {
            EmbedColor = Color3.fromRGB(0, 176, 255)
        },
        ["SeedsAndGears"] = {
            EmbedColor = Color3.fromRGB(0, 255, 0),
            Layout = {
                ["ROOT/SeedStock/Stocks"] = "🌱 SEED STOCK",
                ["ROOT/GearStock/Stocks"] = "⚙️ GEAR STOCK"
            }
        },
        ["EventShop"] = {
            EmbedColor = Color3.fromRGB(255, 0, 200),
            Layout = {
                ["ROOT/EventShopStock/Stocks"] = "🎁 EVENT STOCK"
            }
        },
        ["Eggs"] = {
            EmbedColor = Color3.fromRGB(255, 255, 0),
            Layout = {
                ["ROOT/PetEggStock/Stocks"] = "🥚 EGG STOCK"
            }
        },
        ["CosmeticStock"] = {
            EmbedColor = Color3.fromRGB(255, 90, 0),
            Layout = {
                ["ROOT/CosmeticStock/ItemStocks"] = "🎨 COSMETIC STOCK"
            }
        }
    }
}

--// SERVICES
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")

local DataStream = ReplicatedStorage.GameEvents.DataStream
local WeatherEventStarted = ReplicatedStorage.GameEvents.WeatherEventStarted

local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local JobId = game.JobId

if _G.StockBot then return end 
_G.StockBot = true

local function GetConfigValue(Key)
	return _G.Configuration[Key]
end

RunService:Set3dRenderingEnabled(GetConfigValue("Rendering Enabled"))

local function ConvertColor3(Color)
	local Hex = Color:ToHex()
	return tonumber(Hex, 16)
end

local function GetDataPacket(Data, Target)
	for _, Packet in Data do
		if Packet[1] == Target then
			return Packet[2]
		end
	end
end

local function GetLayout(Type)
	return GetConfigValue("AlertLayouts")[Type]
end

local function WebhookSend(Type, Fields)
	if not GetConfigValue("Enabled") then return end
	local Webhook = GetConfigValue("Webhook")
	local Layout = GetLayout(Type)
	local Color = ConvertColor3(Layout.EmbedColor)

	local TimeStamp = DateTime.now():ToIsoDate()
	local Body = {
		embeds = {{
			color = Color,
			fields = Fields,
			footer = { text = "🔷 XAO Stock Monitor" },
			timestamp = TimeStamp
		}}
	}

	local RequestData = {
        Url = Webhook,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(Body)
    }

	task.spawn(request, RequestData)
end

local function MakeStockString(Stock)
	local Result = ""
	for Name, Data in Stock do 
		local Amount = Data.Stock
		local DisplayName = Data.EggName or Name
		Result ..= `{DisplayName} **x{Amount}**\n`
	end
	return Result
end

local function ProcessPacket(Data, Type, Layout)
	local Fields = {}
	local FieldsLayout = Layout.Layout
	if not FieldsLayout then return end

	for Packet, Title in FieldsLayout do 
		local Stock = GetDataPacket(Data, Packet)
		if not Stock then continue end

		local Field = {
			name = Title,
			value = MakeStockString(Stock),
			inline = true
		}
		table.insert(Fields, Field)
	end

	WebhookSend(Type, Fields)
end

DataStream.OnClientEvent:Connect(function(Type, Profile, Data)
	if Type ~= "UpdateData" or not Profile:find(LocalPlayer.Name) then return end
	for Name, Layout in GetConfigValue("AlertLayouts") do
		ProcessPacket(Data, Name, Layout)
	end
end)

WeatherEventStarted.OnClientEvent:Connect(function(Event, Length)
	if not GetConfigValue("Weather Reporting") then return end
	local EndUnix = math.round(workspace:GetServerTimeNow()) + Length
	WebhookSend("Weather", {{
		name = "🌦️ WEATHER EVENT",
		value = `{Event}\nEnds: <t:{EndUnix}:R>`,
		inline = true
	}})
end)

LocalPlayer.Idled:Connect(function()
	if not GetConfigValue("Anti-AFK") then return end
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

GuiService.ErrorMessageChanged:Connect(function()
	if not GetConfigValue("Auto-Reconnect") then return end
	queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/ARMANSYAH112/Grow-a-garden-/main/xao_stock_bot.lua'))()")
	
	if #Players:GetPlayers() <= 1 then
		TeleportService:Teleport(PlaceId, LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
	end
end)
