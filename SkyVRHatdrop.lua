-- sourced from https://github.com/presidentanvil/hatdropreanimation
cfn=CFrame.new
cfa=CFrame.Angles
r=math.rad

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
function _isnetworkowner(Part)
	return Part.ReceiveAge == 0
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
    end)
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

function HatdropCallback(Character, callback)
    local AnimationInstance = Instance.new("Animation");AnimationInstance.AnimationId = "rbxassetid://35154961"

	workspace.FallenPartsDestroyHeight = 0/0
    local hrp = Character.HumanoidRootPart
    local torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("LowerTorso")
    local startCF = headpart.CFrame
    hrp.CFrame=startCF*cfn(math.random(-6,6),0,math.random(-6,6))
    task.wait(.1)
    local Track = Character.Humanoid.Animator:LoadAnimation(AnimationInstance)
    Track:Play()
    Track.TimePosition = 3.24
    Track:AdjustSpeed(0)
    
    local allhats = getAllHats(Character)
    
    local locks = {}
    for i,v in pairs(allhats) do
        table.insert(locks,v[1].Changed:Connect(function(p)
            if p == "BackendAccoutrementState" then
                sethiddenproperty(v[1],"BackendAccoutrementState",0)
            end
        end))
        sethiddenproperty(v[1],"BackendAccoutrementState",2)
    end
    
    local c;c=ps:Connect(function()
        if(not Character:FindFirstChild("HumanoidRootPart"))then c:Disconnect()return;end
        
        hrp.Velocity = Vector3.new(0,0,25)
        hrp.RotVelocity = Vector3.new(0,0,0)
        hrp.CFrame = cfn(startCF.X,fpdh+.25,startCF.Z) * cfa(math.rad(90),0,0)
    end)
    task.wait(.25)
    for i,v in pairs(allhats) do
        v[1].Handle:BreakJoints()
        local con;con=ps:Connect(function()
            if not v[1]:FindFirstChild"Handle" then con:Disconnect() return end
            v[1].Handle.Velocity = ((options.dontfling ~= true and v[2]:find("Toy")) and Vector3.new(99999,99999,99999)) or Vector3.new(20,20,20)
            v[1].Handle.RotVelocity = Vector3.zero
        end)
    end
    callback(allhats)
    Character.Humanoid:ChangeState(15)
    torso.AncestryChanged:wait()
    for i,v in pairs(locks) do
        v:Disconnect()
    end
    for i,v in pairs(allhats) do
        sethiddenproperty(v[1],"BackendAccoutrementState",4)
    end
end


local cam = workspace.CurrentCamera

game:GetService("StarterGui"):SetCore("VREnableControllerModels", false)

input.UserCFrameChanged:connect(function(part,move)
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

input.InputBegan:connect(function(key)
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
end)

input.InputEnded:connect(function(key)
	if key.KeyCode == Enum.KeyCode.ButtonR1 then
		R1down = false
	end
end)

game:GetService("RunService").RenderStepped:connect(function()
	-- righthandpart.CFrame*CFrame.Angles(-math.rad(options.righthandrotoffset.X),-math.rad(options.righthandrotoffset.Y),math.rad(180-options.righthandrotoffset.X))
	if R1down then
		cam.CFrame = cam.CFrame:Lerp(cam.CoordinateFrame + (righthandpart.CFrame * CFrame.Angles(math.rad(options.controllerRotationOffset.X),math.rad(options.controllerRotationOffset.Y),math.rad(options.controllerRotationOffset.Z))).LookVector * cam.HeadScale/2, 0.5)
	end
end)

HatdropCallback(Player.Character, function(allhats)
    for i,v in pairs(allhats) do
        if not v[1]:FindFirstChild("Handle") then continue end
        if v[2]=="headhats" then v[1].Handle.Transparency = options.HeadHatTransparency or 1 end

        Align(v[1].Handle,parts[v[2]],((v[2]=="headhats")and getgenv()[v[2]][v[3]])or CFrame.new())
    end
end)

getgenv().conn = Player.CharacterAdded:Connect(function(Character)
    task.wait(0.35)
    HatdropCallback(Player.Character, function(allhats)
        for i,v in pairs(allhats) do
            if not v[1]:FindFirstChild("Handle") then continue end
            if v[2]=="headhats" then v[1].Handle.Transparency = options.HeadHatTransparency or 1 end

            Align(v[1].Handle,parts[v[2]],((v[2]=="headhats")and getgenv()[v[2]][(v[3])])or CFrame.new())
        end
    end)
end)
