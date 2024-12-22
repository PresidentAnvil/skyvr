local script = Instance.new('LocalScript', VR_Model_Customization_GUI)
local global = (getgenv and getgenv()) or _G
global.skyvrsettings = {
	hatdrop = false,
	fullbody = false,
	headhats = {},
	leftarm = "",
	rightarm = "",
	toyhats = {leftarm = "",rightarm = ""}
}

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character
--------------------------------------------
local MainFrame = script.Parent.MainFrame
local Preview = script.Parent.PreviewFrame.Viewport
local Settings = script.Parent.Settings
local ExtraSettings = script.Parent.ExtraSettings
local Export = script.Parent.Export
local PreviewLimbs = script.Parent.the
local PreviewHatsFolder = script.Parent.hats
local Popup = script.PopupFrame
--------------------------------------------
local Tabs = MainFrame.Tabs.ScrollingFrame
local Selection = MainFrame.Selection.ScrollingFrame
local tempHat = Selection.Temp
--------------------------------------------
local zEq = -0.91438071487
local currentPage = "headhats"
local on = Color3.fromRGB(120, 233, 101)
local default = Color3.fromRGB(90, 142, 233)
local s=tostring
local irad=function(n) return math.floor(n/math.pi*180) end
local rarmcf = Vector3.new(0,0,0)
local larmcf = Vector3.new(0,0,0)
local copy = toclipboard or setclipboard
local camera = Instance.new("Camera")

function alert(title,desc,dur)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = title;
		Text = desc;
		Duration = dur;
	})
end
Preview.Parent.Visible=true
function ifind(t,a)
	for i,v in pairs(t) do
		if i==a then
			return i
		end
	end
	return false
end

function findMeshID(char,id)
	id = string.match(id,"%d+")
	for i,v in char:GetChildren() do
		if v:IsA("Accessory") then
			local handle = v.Handle

			if handle:IsA("MeshPart") then
				local pooped = string.match(handle.MeshId,"%d+")
				if handle.MeshId:find('assetdelivery') then
					pooped=string.match(string.sub(handle.MeshId,37,#handle.MeshId),"%d+")
				end
				if id == pooped then
					return v
				end
			else
				local mesh = handle:FindFirstChildOfClass("SpecialMesh")
				local pooped = string.match(mesh.MeshId,"%d+")
				if mesh.MeshId:find('assetdelivery') then
					pooped=string.match(string.sub(mesh.MeshId,37,#mesh.MeshId),"%d+")
				end
				if id == pooped then
					return v
				end
			end
		end
	end

	return nil
end

function dump(o)
	if typeof(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if typeof(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '}'
	else
		if typeof(o) == 'CFrame' then
			local x,y,z = s(o.X),s(o.Y),s(o.Z)
			local ox,oy,oz = o:ToOrientation()
			o = 'CFrame.new('..s(o.Position)..')'
			if ox ~= 0 and oy ~= 0 and oz ~= 0 then
				o = o..' * CFrame.Angles(math.rad('..irad(ox)..'),math.rad('..irad(oy)..'),math.rad('..irad(oz)..'))'
			end
		elseif typeof(o) == 'Vector3' then
			o = 'Vector3.new('..s(o)..')'
		elseif typeof(o) == 'string' then
			o = "'"..o.."'"
		end
		return tostring(o)
	end
end

if not Character then
	Player.CharacterAdded:Wait()
	Character = Player.Character
end

function updateList()
	for i,v in ipairs(Selection:GetChildren()) do if v.Name ~= "Temp" and v:IsA("Frame") then v:Destroy() end end

	for i,v in ipairs(Character:GetChildren()) do
		if not v:IsA("Accessory") then continue end
		local Handle = v.Handle:Clone()
		local newButton = tempHat:Clone()
		local MeshId

		if Handle:IsA("MeshPart") then
			MeshId = Handle.MeshId
		else
			MeshId = Handle:FindFirstChildOfClass("SpecialMesh").MeshId
		end

		--local isUsed = table.find(global.skyvrsettings.headhats, 'meshid:'..string.match(MeshId,"%d+")) and table.find(global.skyvrsettings, 'meshid:'..string.match(MeshId,"%d+")) and table.find(global.skyvrsettings.toyhats, 'meshid:'..string.match(MeshId,"%d+"))
		--print(isUsed)
		if string.find(MeshId,'assetdelivery') then
			MeshId = string.match(string.sub(MeshId,37,#MeshId),"%d+")
		else
			MeshId = string.match(MeshId,"%d+")
		end
		local saveasmeshid = not tempHat.Parent:FindFirstChild('meshid:'..MeshId)
		newButton.Parent = tempHat.Parent
		newButton.Name = (saveasmeshid and 'meshid:'..MeshId) or v.Name
		newButton.hatname.Text = v.Name
		newButton.meshid.Text = MeshId
		Handle.Parent = newButton.ViewportFrame
		Handle.CFrame = CFrame.new(0,0,(Handle.Size.X*zEq)-0.5)
		local connection = game:GetService("RunService").RenderStepped:Connect(function()
			Handle.CFrame *= CFrame.Angles(0,math.rad(2),0)
		end)
		Handle.Destroying:Connect(function()
			connection:Disconnect()
		end)
		newButton.Error.Visible = false
		if currentPage ~= "headhats" then
			newButton.Settings.Text = "Set as Right Arm"
			newButton.Settings2.Visible = true
			newButton.Settings2.Text = "Set as Left Arm"
			if currentPage == 'toyhats' then
				newButton.Settings.Text = "Set as Right Toy"
				newButton.Settings2.Text = "Set as Left Toy"
			end
			newButton.Settings2.MouseButton1Click:Connect(function()
				if newButton.Error.Visible == true then return end
				if currentPage == "armhats" then
					if global.skyvrsettings.leftarm ~= "" then
						Selection[global.skyvrsettings.leftarm].Settings.BackgroundColor3 = default
						Selection[global.skyvrsettings.leftarm].Settings2.BackgroundColor3 = default
					end
					if global.skyvrsettings.rightarm == v.Name then
						newButton.Settings.BackgroundColor3 = default
						global.skyvrsettings.rightarm = ""
					end
					if global.skyvrsettings.leftarm == newButton.Name then
						newButton.Settings2.BackgroundColor3 = default
						global.skyvrsettings.leftarm = ""
					else
						global.skyvrsettings.leftarm= newButton.Name
						newButton.Settings2.BackgroundColor3 = on
					end
				end
				if currentPage == "toyhats" then
					if global.skyvrsettings.toyhats.leftarm ~= "" then
						Selection[global.skyvrsettings.toyhats.leftarm].Settings.BackgroundColor3 = default
						Selection[global.skyvrsettings.toyhats.leftarm].Settings2.BackgroundColor3 = default
					end
					if global.skyvrsettings.toyhats.rightarm == newButton.Name then
						newButton.Settings.BackgroundColor3 = default
						global.skyvrsettings.toyhats.rightarm = ""
					end
					if global.skyvrsettings.toyhats.leftarm == newButton.Name then
						newButton.Settings2.BackgroundColor3 = default
						global.skyvrsettings.toyhats.leftarm = ""
					else
						global.skyvrsettings.toyhats.leftarm= newButton.Name
						newButton.Settings2.BackgroundColor3 = on
					end
				end
			end)
		end

		newButton.Error.TextLabel.Text = "Already used in: Arm Hats"
		if currentPage == "armhats" then
			if ifind(global.skyvrsettings.headhats, newButton.Name) then
				newButton.Error.TextLabel.Text = "Already used in: Head Hats"
				newButton.Error.Visible = true
			elseif global.skyvrsettings.toyhats.rightarm == newButton.Name or global.skyvrsettings.toyhats.leftarm == newButton.Name then
				newButton.Error.TextLabel.Text = "Already used in: Toy Hats"
				newButton.Error.Visible = true
			end
			if global.skyvrsettings.rightarm == newButton.Name then
				newButton.Settings.BackgroundColor3 = on
			else
				newButton.Settings.BackgroundColor3 = default
			end
			if global.skyvrsettings.leftarm == newButton.Name then
				newButton.Settings2.BackgroundColor3 = on
			else
				newButton.Settings2.BackgroundColor3 = default
			end
		elseif currentPage == "headhats" then
			if global.skyvrsettings.rightarm == newButton.Name or global.skyvrsettings.leftarm == newButton.Name then
				newButton.Error.Visible = true
			elseif global.skyvrsettings.toyhats.rightarm == newButton.Name or global.skyvrsettings.toyhats.leftarm == newButton.Name then
				newButton.Error.TextLabel.Text = "Already used in: Toy Hats"
				newButton.Error.Visible = true
			end
		elseif currentPage == "toyhats" then
			if ifind(global.skyvrsettings.headhats, 'meshid:'..MeshId) then
				newButton.Error.TextLabel.Text = "Already used in: Head Hats"
				newButton.Error.Visible = true
			end
			if global.skyvrsettings.rightarm == newButton.Name or global.skyvrsettings.leftarm == newButton.Name then
				newButton.Error.TextLabel.Text = "Already used in: Head Hats"
				newButton.Error.Visible = true
			end
			if global.skyvrsettings.toyhats.rightarm == newButton.Name then
				newButton.Settings.BackgroundColor3 = on
			else
				newButton.Settings.BackgroundColor3 = default
			end

			if global.skyvrsettings.toyhats.leftarm == newButton.Name then
				newButton.Settings2.BackgroundColor3 = on
			else
				newButton.Settings2.BackgroundColor3 = default
			end
		end

		newButton.Settings.MouseButton1Click:Connect(function()
			if newButton.Error.Visible == true then return end
			if currentPage == "headhats" then
				Settings.Visible = true
				MainFrame.Visible = false
				Settings.hatname.Text = v.Name
				Settings.meshid.Text = MeshId
				Settings.namebruh.Value = newButton.Name
				if ifind(global.skyvrsettings.headhats, newButton.Name) then
					local cf = global.skyvrsettings.headhats[newButton.Name]
					local X,Y,Z = cf:ToOrientation()

					Settings.Selection.label.toggle.BackgroundColor3 = Color3.fromRGB(0, 233, 19)
					Settings.Selection.hide.Visible = false
					Settings.Selection.cfpos.Text = s(cf.X)..','..s(cf.Y)..','..s(cf.Z)
					Settings.Selection.cfrot.Text = s(X)..','..s(Y)..','..s(Z)
				else
					Settings.Selection.label.toggle.BackgroundColor3 = Color3.fromRGB(233, 0, 0)
					Settings.Selection.hide.Visible = true
					Settings.Selection.cfpos.Text = '0,0,0'
					Settings.Selection.cfrot.Text = '0,0,0'
				end
			end
			if currentPage == "armhats" then
				if global.skyvrsettings.rightarm ~= "" then
					Selection[global.skyvrsettings.rightarm].Settings.BackgroundColor3 = default
					Selection[global.skyvrsettings.rightarm].Settings2.BackgroundColor3 = default
				end
				if global.skyvrsettings.leftarm == newButton.Name then
					newButton.Settings2.BackgroundColor3 = default
					global.skyvrsettings.leftarm = ""
				end
				if global.skyvrsettings.rightarm == newButton.Name then
					newButton.Settings.BackgroundColor3 = default
					global.skyvrsettings.rightarm = ""
				else
					newButton.Settings.BackgroundColor3 = on
					global.skyvrsettings.rightarm= newButton.Name
				end
			end
			if currentPage == "toyhats" then
				if global.skyvrsettings.toyhats.rightarm ~= "" then
					Selection[global.skyvrsettings.toyhats.rightarm].Settings.BackgroundColor3 = default
					Selection[global.skyvrsettings.toyhats.rightarm].Settings2.BackgroundColor3 = default
				end
				if global.skyvrsettings.toyhats.leftarm == newButton.Name then
					newButton.Settings2.BackgroundColor3 = default
					global.skyvrsettings.toyhats.leftarm = ""
				end
				if global.skyvrsettings.toyhats.rightarm == newButton.Name then
					newButton.Settings.BackgroundColor3 = default
					global.skyvrsettings.toyhats.rightarm = ""
				else
					global.skyvrsettings.toyhats.rightarm= newButton.Name
					newButton.Settings.BackgroundColor3 = on
				end
			end
		end)

		newButton.Visible = true
	end
end

for i,v in ipairs(Tabs:GetChildren()) do
	if v:IsA("ImageButton") then
		v.MouseButton1Click:Connect(function()
			currentPage = v.Name
			updateList()
		end)
	end
end

Export.x.MouseButton1Click:Connect(function()
	Export.Visible = false
end)

MainFrame.Hide.MouseButton1Click:Connect(function()
	alert("UI Hidden", "Press F to make the UI reappear.",10)
	MainFrame.Visible = false
end)

Settings.x.MouseButton1Click:Connect(function()
	Settings.Visible = false
	MainFrame.Visible = true
end)

ExtraSettings.x.MouseButton1Click:Connect(function()
	ExtraSettings.Visible = false
	MainFrame.Visible = true
end)

MainFrame.Settings.MouseButton1Click:Connect(function()
	ExtraSettings.Visible = true
	MainFrame.Visible = false
end)
Popup.hatdrop.MouseButton1Click:Connect(function()
	global.skyvrsettings.hatdrop = true
	Popup.hatdrop.BackgroundColor3 = on
	Popup.nohatdrop.BackgroundColor3 = default
end)
Popup.nohatdrop.BackgroundColor3 = on
Popup.nohatdrop.MouseButton1Click:Connect(function()
	global.skyvrsettings.hatdrop = false
	Popup.hatdrop.BackgroundColor3 = default
	Popup.nohatdrop.BackgroundColor3 = on
end)
Popup.regular.BackgroundColor3 = on
Popup.regular.MouseButton1Click:Connect(function()
	global.skyvrsettings.fullbody = false
	Popup.fullbody.BackgroundColor3 = default
	Popup.regular.BackgroundColor3 = on
end)
Popup.fullbody.MouseButton1Click:Connect(function()
	global.skyvrsettings.fullbody = true
	Popup.fullbody.BackgroundColor3 = on
	Popup.regular.BackgroundColor3 = default
end)
Popup.continue.MouseButton1Click:Connect(function()
	Popup.Visible=false
	MainFrame.Visible=true
end)
Settings.Selection.label.toggle.MouseButton1Click:Connect(function()
	local enabled = Settings.Selection.label.toggle.BackgroundColor3 == Color3.fromRGB(0, 233, 19)
	local MeshId = Settings.meshid.Text
	if enabled then
		Settings.Selection.label.toggle.BackgroundColor3 = Color3.fromRGB(233, 0, 0)
		Settings.Selection.cfpos.Text = '0,0,0'
		Settings.Selection.cfrot.Text = '0,0,0'
		global.skyvrsettings.headhats[Settings.namebruh.Value] = nil
		Settings.Selection.hide.Visible = true
	else
		global.skyvrsettings.headhats[Settings.namebruh.Value] = CFrame.new(0,0,0)

		Settings.Selection.label.toggle.BackgroundColor3 = Color3.fromRGB(0, 233, 19)
		Settings.Selection.hide.Visible = false
		Settings.Selection.cfpos.Text = '0,0,0'
		Settings.Selection.cfrot.Text = '0,0,0'
	end
end)

Settings.Selection.cfpos.FocusLost:Connect(function()
	local split = string.split(Settings.Selection.cfpos.Text,',')
	if #split == 3 and Settings.Selection.label.toggle.BackgroundColor3 == Color3.fromRGB(0, 233, 19) then
		global.skyvrsettings.headhats[Settings.namebruh.Value] = CFrame.new(table.unpack(split))
		Settings.Selection.cfpos.Text = Settings.Selection.cfpos.Text
	else
		Settings.Selection.cfpos.Text = '0,0,0'
	end
end)

Settings.Selection.cfrot.FocusLost:Connect(function()
	local split = string.split(Settings.Selection.cfrot.Text,',')
	local cf = global.skyvrsettings.headhats[Settings.namebruh.Value]
	if #split == 3 and Settings.Selection.label.toggle.BackgroundColor3 == Color3.fromRGB(0, 233, 19) then
		global.skyvrsettings.headhats[Settings.namebruh.Value] = CFrame.new(cf.Position) * CFrame.Angles(math.rad(split[1]),math.rad(split[2]),math.rad(split[3]))
		Settings.Selection.cfrot.Text = Settings.Selection.cfrot.Text
	else
		Settings.Selection.cfrot.Text = '0,0,0'
	end
end)

MainFrame.Export.MouseButton1Click:Connect(function()
	-- let's convert this to a useable table in the script
	local configs = global.skyvrsettings
	local headhats = configs.headhats
	local ldonething = 'Vector3.new('..s(larmcf)..')'
	local rdonething = 'Vector3.new('..s(rarmcf)..')'

	local generatedScript = 'getgenv().headhats = '..dump(headhats)..'\ngetgenv().right = "'..configs.rightarm..'"\ngetgenv().left = "'..configs.leftarm..'"\ngetgenv().HATDROP = '..tostring(global.skyvrsettings.hatdrop)..'\ngetgenv().fullbody = '..tostring(global.skyvrsettings.fullbody)..'\ngetgenv().options = {\n	dontfling = false,\n	outlinesEnabled = false, -- buggy-ish\n	righthandrotoffset = '..rdonething..',\n	lefthandrotoffset = '..ldonething..',\n	headscale = 3,\n	NetVelocity = Vector3.new(20,20,20), -- if your hands and head keep falling set these to higher numbers\n	controllerRotationOffset = Vector3.new(180,180,0),\n	HeadHatTransparency = 1,\n	leftToyBind = Enum.KeyCode.ButtonY, -- :D\n	rightToyBind = Enum.KeyCode.ButtonB, -- :D\n	leftToy = "'..configs.toyhats.leftarm..'", -- default is "" or nil\n	rightToy = "'..configs.toyhats.rightarm..'", -- default is "" or nil\n}\ngetgenv().skyVRversion = \''..skyvrversion..'\'\nloadstring(game:HttpGet(\'https://raw.githubusercontent.com/presidentanvil/skyvr/main/SkyVR.lua\'))();'

	Export.Visible = true
	Export.Script.Text = generatedScript
	copy(generatedScript)
end)
ExtraSettings.Selection.lcfrot.FocusLost:Connect(function()
	local split = string.split(ExtraSettings.Selection.lcfrot.Text,',')
	if #split == 3 then
		larmcf = Vector3.new(unpack(split))
	else
		ExtraSettings.Selection.lcfrot.Text = '0,0,0'
	end
end)

ExtraSettings.Selection.rcfrot.FocusLost:Connect(function()
	local split = string.split(ExtraSettings.Selection.rcfrot.Text,',')
	if #split == 3 then
		rarmcf = Vector3.new(unpack(split))
	else
		ExtraSettings.Selection.rcfrot.Text = '0,0,0'
	end
end)
game:GetService("RunService").RenderStepped:Connect(function()
	local accessoriesActive = {}

	--PreviewLimbs:SetPrimaryPartCFrame(CFrame.new(Player.Character.HumanoidRootPart.Position)*CFrame.new(0,7,5))

	for i,v in pairs(global.skyvrsettings.headhats) do
		if PreviewHatsFolder:FindFirstChild(i) then 
			local handleClone = PreviewHatsFolder[i]
			handleClone:BreakJoints()
			handleClone.CFrame = PreviewLimbs.head.CFrame * v
			accessoriesActive[i]=1
		else
			local accessory = findMeshID(Character,i) or Character[i]
			local handleClone = accessory.Handle:Clone()
			handleClone:BreakJoints()
			handleClone.Parent = PreviewHatsFolder
			handleClone.Name = i
			handleClone.Anchored = true
			handleClone.CFrame = PreviewLimbs.head.CFrame * v
			accessoriesActive[i]=1
		end
	end

	-- for anyone reading this, as a slight ego boost, i'm letting u know that i made leftarm check first :)

	if global.skyvrsettings.leftarm ~= "" then
		local i = global.skyvrsettings.leftarm
		if PreviewHatsFolder:FindFirstChild(i) then 
			local handleClone = PreviewHatsFolder[i]
			handleClone:BreakJoints()
			handleClone.CFrame = PreviewLimbs.larm.CFrame * CFrame.Angles(math.rad(larmcf.X+0),math.rad(larmcf.Y),math.rad(larmcf.Z))
			accessoriesActive[i]=1
		else
			local accessory = findMeshID(Character,i) or Character[i]
			local handleClone = accessory.Handle:Clone()
			handleClone:BreakJoints()
			handleClone.Parent = PreviewHatsFolder
			handleClone.Name = i
			handleClone.Anchored = true
			handleClone.CFrame = PreviewLimbs.larm.CFrame * CFrame.Angles(math.rad(larmcf.X+0),math.rad(larmcf.Y),math.rad(larmcf.Z))
			accessoriesActive[i]=1
		end
	end

	if global.skyvrsettings.rightarm ~= "" then
		local i = global.skyvrsettings.rightarm
		if PreviewHatsFolder:FindFirstChild(i) then 
			local handleClone = PreviewHatsFolder[i]

			handleClone.CFrame = PreviewLimbs.rarm.CFrame * CFrame.Angles(math.rad(rarmcf.X+0),math.rad(rarmcf.Y),math.rad(rarmcf.Z))
			accessoriesActive[i]=1
		else
			local accessory = findMeshID(Character,i) or Character[i]
			local handleClone = accessory.Handle:Clone()

			handleClone.Parent = PreviewHatsFolder
			handleClone.Name = i
			handleClone.Anchored = true
			handleClone.CFrame = PreviewLimbs.rarm.CFrame * CFrame.Angles(math.rad(rarmcf.X+0),math.rad(rarmcf.Y),math.rad(rarmcf.Z))
			accessoriesActive[i]=1
		end
	end



	for i,v in ipairs(PreviewHatsFolder:GetChildren()) do
			if not ifind(accessoriesActive,v.Name) then
				v:Destroy()
			end
	end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input,gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.F then
		MainFrame.Visible = true
	end
end)

PreviewLimbs.Parent = Preview
PreviewHatsFolder.Parent = Preview
Preview.CurrentCamera = camera
camera.CFrame = CFrame.new(-28.55,4,8) * CFrame.Angles(0,math.pi,0)
camera.Focus = CFrame.new(-28.698, 3.226, 11.112)
camera.HeadLocked = true
camera.CameraType = "Fixed"
camera.DiagonalFieldOfView = 88.877
camera.FieldOfView = 70
camera.FieldOfViewMode = "Vertical"
camera.MaxAxisFieldOfView = 70

updateList()
