local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "XperiaXao"
gui.ResetOnSpawn = false

-- Frame Utama
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 260)
frame.Position = UDim2.new(0.5, -150, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.Active = true
frame.Draggable = true

-- Judul
local title = Instance.new("TextLabel", frame)
title.Text = "XPERIA XAO"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24

-- Tombol Tab
local tabSell = Instance.new("TextButton", frame)
tabSell.Text = "AUTO SELL"
tabSell.Size = UDim2.new(0.5, 0, 0, 30)
tabSell.Position = UDim2.new(0, 0, 0, 40)
tabSell.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tabSell.TextColor3 = Color3.new(1, 1, 1)

local tabRemove = Instance.new("TextButton", frame)
tabRemove.Text = "AUTO REMOVE"
tabRemove.Size = UDim2.new(0.5, 0, 0, 30)
tabRemove.Position = UDim2.new(0.5, 0, 0, 40)
tabRemove.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
tabRemove.TextColor3 = Color3.new(1, 1, 1)

-- Frame SELL
local sellFrame = Instance.new("Frame", frame)
sellFrame.Position = UDim2.new(0, 0, 0, 70)
sellFrame.Size = UDim2.new(1, 0, 1, -70)
sellFrame.BackgroundTransparency = 1

-- Frame REMOVE
local removeFrame = Instance.new("Frame", frame)
removeFrame.Position = UDim2.new(0, 0, 0, 70)
removeFrame.Size = UDim2.new(1, 0, 1, -70)
removeFrame.BackgroundTransparency = 1
removeFrame.Visible = false

-- SELL Menu
local buahInput = Instance.new("TextBox", sellFrame)
buahInput.PlaceholderText = "Masukkan nama buah..."
buahInput.Size = UDim2.new(1, -20, 0, 30)
buahInput.Position = UDim2.new(0, 10, 0, 10)
buahInput.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
buahInput.TextColor3 = Color3.new(1, 1, 1)

local mutasiInput = Instance.new("TextBox", sellFrame)
mutasiInput.PlaceholderText = "Mutasi (opsional)..."
mutasiInput.Size = UDim2.new(1, -20, 0, 30)
mutasiInput.Position = UDim2.new(0, 10, 0, 50)
mutasiInput.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
mutasiInput.TextColor3 = Color3.new(1, 1, 1)

local toggleSell = Instance.new("TextButton", sellFrame)
toggleSell.Text = "ON"
toggleSell.Size = UDim2.new(0.5, -15, 0, 35)
toggleSell.Position = UDim2.new(0, 10, 0, 95)
toggleSell.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
toggleSell.TextColor3 = Color3.new(1, 1, 1)

local selling = false

toggleSell.MouseButton1Click:Connect(function()
	selling = not selling
	toggleSell.Text = selling and "ON" or "OFF"
	toggleSell.BackgroundColor3 = selling and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(100, 100, 100)
	
	if selling then
		spawn(function()
			while selling do
				local buah = buahInput.Text
				local mutasi = mutasiInput.Text
				print("▶ AutoSell aktif! Buah:", buah, "Mutasi:", mutasi)
				-- Ganti ini dengan fungsi asli servermu
				-- contohnya: game.ReplicatedStorage.Sell:FireServer(buah, mutasi)
				wait(5)
			end
		end)
	end
end)

-- REMOVE Menu
local treeInput = Instance.new("TextBox", removeFrame)
treeInput.PlaceholderText = "Masukkan nama pohon..."
treeInput.Size = UDim2.new(1, -20, 0, 30)
treeInput.Position = UDim2.new(0, 10, 0, 10)
treeInput.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
treeInput.TextColor3 = Color3.new(1, 1, 1)

local toggleRemove = Instance.new("TextButton", removeFrame)
toggleRemove.Text = "ON"
toggleRemove.Size = UDim2.new(0.5, -15, 0, 35)
toggleRemove.Position = UDim2.new(0, 10, 0, 50)
toggleRemove.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
toggleRemove.TextColor3 = Color3.new(1, 1, 1)

local removing = false

toggleRemove.MouseButton1Click:Connect(function()
	removing = not removing
	toggleRemove.Text = removing and "ON" or "OFF"
	toggleRemove.BackgroundColor3 = removing and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(100, 100, 100)

	if removing then
		spawn(function()
			while removing do
				local pohon = treeInput.Text
				print("▶ AutoRemove aktif! Pohon:", pohon)
				-- Ganti ini dengan fungsi asli
				-- contoh: game.ReplicatedStorage.Remove:FireServer(pohon)
				wait(5)
			end
		end)
	end
end)

-- Tab Switcher
tabSell.MouseButton1Click:Connect(function()
	sellFrame.Visible = true
	removeFrame.Visible = false
end)

tabRemove.MouseButton1Click:Connect(function()
	sellFrame.Visible = false
	removeFrame.Visible = true
end)
