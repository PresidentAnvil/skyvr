local function createpart(size, name,h)
	local Part = Instance.new("Part")
	Part.Parent = workspace
	Part.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
	Part.Size = size
	Part.Transparency = 1
	Part.CanCollide = false
	Part.Anchored = true
	Part.Name = name
	return Part
end
local ps = game:GetService("RunService").PostSimulation
local input = game:GetService("UserInputService")
local fpdh = game.Workspace.FallenPartsDestroyHeight
local Player = game.Players.LocalPlayer
local options = getgenv().options

local lefthandpart = createpart(Vector3.new(2,1,1), "moveRH",true)
local righthandpart = createpart(Vector3.new(2,1,1), "moveRH",true)
local headpart = createpart(Vector3.new(1,1,1), "moveH",false)
local lefttoypart = createpart(Vector3.new(1,1,1), "LToy",true)
local righttoypart =  createpart(Vector3.new(1,1,1), "RToy",true)
local thirdperson = false
local lefttoyenable = false
local righttoyenable = false
local lfirst = true
local rfirst = true
local ltoypos = CFrame.new(1.15,0,0) * CFrame.Angles(0,math.rad(180),0)
local rtoypos = CFrame.new(1.15,0,0) * CFrame.Angles(0,math.rad(0),0)
local parts = {
    left=lefthandpart,
    right=righthandpart,
    headhats=headpart,
    leftToy=lefttoypart,
    rightToy=righttoypart,
}
_isnetworkowner = function(v)
    return v.ReceiveAge == 0 and not v.NetworkIsSleeping
end

game.Workspace.FallenPartsDestroyHeight=0/0

function filterMeshID(id)
	return (string.find(id,'assetdelivery')~=nil and string.match(string.sub(id,37,#id),"%d+")) or string.match(id,"%d+")
end

function findMeshID(id)
    for i,v in pairs(getgenv().headhats) do
        if i=="meshid:"..id then return true,"headhats" end
    end
    if getgenv().right=="meshid:"..id then return true,"right" end
    if getgenv().left=="meshid:"..id then return true,"left" end
    if options.leftToy=="meshid:"..id then return true,"leftToy" end
    if options.rightToy=="meshid:"..id then return true,"rightToy" end
    return false
end

function findHatName(id)
    for i,v in pairs(getgenv().headhats) do
        if i==id then return true,"headhats" end
    end
    if getgenv().right==id then return true,"right" end
    if getgenv().left==id then return true,"left" end
    if options.leftToy==id then return true,"leftToy" end
    if options.rightToy==id then return true,"rightToy" end
    return false
end

function Align(Part1,Part0,cf,isflingpart) 
    local up = isflingpart
    local con;con=ps:Connect(function()
        if up~=nil then up=not up end
        if not Part1:IsDescendantOf(workspace) then con:Disconnect() return end
        if not _isnetworkowner(Part1) then return end
        Part1.CanCollide=false
        Part1.CFrame=Part0.CFrame*cf
        Part1.Velocity = velocity or Vector3.new(20,20,20)
    end)

    return {SetVelocity = function(self,v) velocity=v end,SetCFrame = function(self,v) cf=v end,}
end

function getAllHats(Character)
    local allhats = {}
    local foundmeshids = {}
    for i,v in pairs(Character:GetChildren()) do
        if not v:IsA"Accessory" then continue end
        if not v.Handle:FindFirstChildOfClass("SpecialMesh") then continue end
        
        local is,d = findMeshID(filterMeshID(v.Handle:FindFirstChildOfClass("SpecialMesh").MeshId))
	    if foundmeshids["meshid:"..filterMeshID(v.Handle:FindFirstChildOfClass("SpecialMesh").MeshId)] then is = false else foundmeshids["meshid:"..filterMeshID(v.Handle:FindFirstChildOfClass("SpecialMesh").MeshId)] = true end
	
        if is then
            table.insert(allhats,{v,d,"meshid:"..filterMeshID(v.Handle:FindFirstChildOfClass("SpecialMesh").MeshId)})
        else
            local is,d = findHatName(v.Name)
	    if not is then continue end
            table.insert(allhats,{v,d,v.Name})
        end
    end
    return allhats
end

pcall(function()
	sethiddenproperty(hum, "InternalBodyScale", Vector3.new(9e9,9e9,9e9))
end)
pcall(function()
	sethiddenproperty(ws, "PhysicsSteppingMethod", Enum.PhysicsSteppingMethod.Fixed)
end)
pcall(function()
	ws.InterpolationThrottling = Enum.InterpolationThrottlingMode.Disabled
end)
pcall(function()
	ws.Retargeting = "Disabled"
end)
pcall(function()
	sethiddenproperty(ws, "SignalBehavior", "Immediate")
end)
pcall(function()
	game:GetService("PhysicsSettings").PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end)
pcall(function()
	game:GetService("PhysicsSettings").AllowSleep = false
end)
pcall(function()
	game:GetService("PhysicsSettings").ThrottleAdjustTime = math.huge
end)
pcall(function()
	game:GetService("PhysicsSettings").ForceCSGv2 = false
end)
pcall(function()
	game:GetService("PhysicsSettings").DisableCSGv2 = false
end)
pcall(function()
	game:GetService("PhysicsSettings").UseCSGv2 = false
end)
pcall(function()
	game:GetService("PhysicsSettings").UseCSGv2 = false
end)
pcall(function()
	setsimulationradius(math.huge)
end)
pcall(function()
	p.MaximumSimulationRadius = 9e9
	p.SimulationRadius = 9e9
end)

local function fullbreakvel(instance)
	local instance = instance or p.Character
	local part = instance and (instance:IsA("BasePart") and instance or instance:IsA("Model") and (instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart")) or instance:FindFirstChildWhichIsA("BasePart"))
	if not part then
		return
	end
	part.AssemblyAngularVelocity = Vector3.new()
	part.AssemblyLinearVelocity = Vector3.new()
	for i, v in part:GetConnectedParts(true) do
		v.AssemblyAngularVelocity = Vector3.new()
		v.AssemblyLinearVelocity = Vector3.new()
	end
end

function HatdropCallback(c, callback)
	ws = game:GetService("Workspace")
	G = ((getgenv and getgenv()) or _G)
	if not G.fpdh then
	    G.fpdh = ws.FallenPartsDestroyHeight
	end
	fpdh = G.fpdh or ws.FallenPartsDestroyHeight
	runservice = game:GetService("RunService")
	players = game:GetService("Players")
	p = players.LocalPlayer
	ws.FallenPartsDestroyHeight = 0/0
	local hum = c:WaitForChild("Humanoid")
	local hrp = c:WaitForChild("HumanoidRootPart")
	local head = c:WaitForChild("Head")
	if hum and hrp and head then
	    local r6 = hum.RigType == Enum.HumanoidRigType.R6
	    if r6 then
	        local anim = Instance.new("Animation")
	        anim.AnimationId = "rbxassetid://35154961"
	        local loadanim = hum:LoadAnimation(anim)
	        loadanim:Play(0, 100, 0)
	        loadanim.TimePosition = 3.24
	    end
	    hum:ChangeState(Enum.HumanoidStateType.Physics)
	    local old = hrp.CFrame
	    fullbreakvel(hrp)
	    local cf = r6 and CFrame.new(hrp.CFrame.Position.X, fpdh + 1, hrp.CFrame.Position.Z) * CFrame.Angles(math.rad(90), 0, 0) or CFrame.new(hrp.CFrame.Position.X, fpdh + 1, hrp.CFrame.Position.Z)
	    hrp.CFrame = cf
	    local con
	    con = runservice.PostSimulation:Connect(function()
	        fullbreakvel(hrp)
	        hrp.CFrame = cf
	    end)
	    coroutine.wrap(function()
	        for i, v in hum:GetAccessories() do
	            local han = v:FindFirstChild("Handle")
	            local weld = han and han:FindFirstChildWhichIsA("Weld")
	            if weld then
	                sethiddenproperty(v, "BackendAccoutrementState", 0)
	                local a = Instance.new("SelectionBox")
	                a.LineThickness = 0.15000000596046448 * han.Size.Y/50
	                a.Adornee = han
	                a.Parent = han
	                --weld:GetPropertyChangedSignal("Parent"):Wait()
	                han:BreakJoints()
	                han.AssemblyLinearVelocity = Vector3.new(0, 30, 0)
	                --han.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	                han.CFrame = old * CFrame.new(0, han.Size.Y/2, 0)
	                local con
	                con = runservice.PostSimulation:Connect(function()
	                    han.AssemblyLinearVelocity = Vector3.new(0, 30, 0)
	                    --han.AssemblyAngularVelocity = Vector3.new(9e9, 0, 9e9)
	                    --han.CFrame = old
	                end)
	                han:GetPropertyChangedSignal("CanCollide"):Wait()
	            end
	        end
	    end)()
	    task.wait(0.4)
	    con:Disconnect()
	    con = nil
	    callback(getAllHats(c))
	    hum:ChangeState(15)
	end
end


local cam = workspace.CurrentCamera

game:GetService("StarterGui"):SetCore("VREnableControllerModels", false)
local rightarmalign = nil
getgenv().con5 = input.UserCFrameChanged:connect(function(part,move)
    cam.CameraType = "Scriptable"
	cam.HeadScale = options.headscale
    if part == Enum.UserCFrame.Head then
        headpart.CFrame = cam.CFrame*(CFrame.new(move.p*(cam.HeadScale-1))*move)
        --thirdpersonpart.CFrame = cam.CFrame * (CFrame.new(move.p*(cam.HeadScale-1))*move) * CFrame.new(0,0,-10) * CFrame.Angles(math.rad(180),0,math.rad(180))
    elseif part == Enum.UserCFrame.LeftHand then
        lefthandpart.CFrame = cam.CFrame*(CFrame.new(move.p*(cam.HeadScale-1))*move*CFrame.Angles(math.rad(options.lefthandrotoffset.X),math.rad(options.lefthandrotoffset.Y),math.rad(options.lefthandrotoffset.Z)))
        if lefttoyenable then
            lefttoypart.CFrame = lefthandpart.CFrame * ltoypos
        end
    elseif part == Enum.UserCFrame.RightHand then
        righthandpart.CFrame = cam.CFrame*(CFrame.new(move.p*(cam.HeadScale-1))*move*CFrame.Angles(math.rad(options.righthandrotoffset.X),math.rad(options.righthandrotoffset.Y),math.rad(options.righthandrotoffset.Z)))
        if righttoyenable then
            righttoypart.CFrame = righthandpart.CFrame * rtoypos
        end
    end
end)

getgenv().con4 = input.InputBegan:connect(function(key)
	if key.KeyCode == options.thirdPersonButtonToggle then
		thirdperson = not thirdperson -- disabled?
	end
	if key.KeyCode == Enum.KeyCode.ButtonR1 then
		R1down = true
	end
    if key.KeyCode == options.leftToyBind then
		if not lfirst then
			ltoypos = lefttoypart.CFrame:ToObjectSpace(lefthandpart.CFrame):Inverse()
		end
		lfirst = false
        lefttoyenable = not lefttoyenable
    end
	if key.KeyCode == options.rightToyBind then
		if not rfirst then
			rtoypos = righttoypart.CFrame:ToObjectSpace(righthandpart.CFrame):Inverse()
		end
		rfirst = false
        righttoyenable = not righttoyenable
    end
    if key.KeyCode == Enum.KeyCode.ButtonR2 and rightarmalign~=nil then
        R2down = true
    end
end)

getgenv().con3 = input.InputEnded:connect(function(key)
	if key.KeyCode == Enum.KeyCode.ButtonR1 then
		R1down = false
	end
    if key.KeyCode == Enum.KeyCode.ButtonR2 and rightarmalign~=nil then
        R2down = false
    end
end)
local negitive = true
getgenv().con2 = game:GetService("RunService").RenderStepped:connect(function()
	-- righthandpart.CFrame*CFrame.Angles(-math.rad(options.righthandrotoffset.X),-math.rad(options.righthandrotoffset.Y),math.rad(180-options.righthandrotoffset.X))
	if R1down then
		cam.CFrame = cam.CFrame:Lerp(cam.CoordinateFrame + (righthandpart.CFrame * CFrame.Angles(math.rad(options.righthandrotoffset.X),math.rad(options.righthandrotoffset.Y),math.rad(options.righthandrotoffset.Z)):Inverse() * CFrame.Angles(math.rad(options.controllerRotationOffset.X),math.rad(options.controllerRotationOffset.Y),math.rad(options.controllerRotationOffset.Z))).LookVector * cam.HeadScale/2, 0.5)
	end
    if R2down and rightarmalign then
        negitive=not negitive
        rightarmalign:SetVelocity(Vector3.new(0,0,-99999999))
        rightarmalign:SetCFrame(CFrame.Angles(math.rad(options.righthandrotoffset.X),math.rad(options.righthandrotoffset.Y),math.rad(options.righthandrotoffset.Z)):Inverse()*CFrame.new(0,0,8*(negitive and -1 or 1)))
    elseif rightarmalign then
        rightarmalign:SetVelocity(Vector3.new(20,20,20))
        rightarmalign:SetCFrame(CFrame.new(0,0,0))
    end
end)

local s,e = pcall(function()
	HatdropCallback(Player.Character, function(allhats)
	    for i,v in pairs(allhats) do
	        if not v[1]:FindFirstChild("Handle") then continue end
	        if v[2]=="headhats" then v[1].Handle.Transparency = options.HeadHatTransparency or 1 end
	
	        local align = Align(v[1].Handle,parts[v[2]],((v[2]=="headhats")and getgenv()[v[2]][(v[3])]) or CFrame.identity)
	        rightarmalign = v[2]=="right" and align or rightarmalign
	    end
	end)
end)
if not s then print(e) end

getgenv().conn = Player.CharacterAdded:Connect(function(Character)
    HatdropCallback(Player.Character, function(allhats)
        for i,v in pairs(allhats) do
            if not v[1]:FindFirstChild("Handle") then continue end
            if v[2]=="headhats" then v[1].Handle.Transparency = options.HeadHatTransparency or 1 end

            local align = Align(v[1].Handle,parts[v[2]],((v[2]=="headhats")and getgenv()[v[2]][(v[3])]) or CFrame.identity)
            rightarmalign = v[2]=="right" and align or rightarmalign
        end
    end)
end)
