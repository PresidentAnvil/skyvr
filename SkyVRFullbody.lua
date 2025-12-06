if getgenv().HATDROP then loadstring(game:HttpGet("https://raw.githubusercontent.com/presidentanvil/skyvr/main/SkyVRFullbodyHatdrop.lua"))() end
loadstring(game:HttpGet("https://raw.githubusercontent.com/PresidentAnvil/HatdropReanimation/main/Valuable%20Dependencies/thething.lua"))()
local StudsOffset = 0.1
local ChatEnabled = true
local ChatLocalRange = 70
local ViewportEnabled = true
local ViewportRange = 30
local AccurateHandPosition = false
getgenv().options.lefthandrotoffset = CFrame.Angles(math.rad(getgenv().options.lefthandrotoffset.X),math.rad(getgenv().options.lefthandrotoffset.Y),math.rad(getgenv().options.lefthandrotoffset.Z))
getgenv().options.leftlegrotoffset = CFrame.Angles(math.rad(getgenv().options.leftlegrotoffset.X),math.rad(getgenv().options.leftlegrotoffset.Y),math.rad(getgenv().options.leftlegrotoffset.Z))
getgenv().options.righthandrotoffset = CFrame.Angles(math.rad(getgenv().options.righthandrotoffset.X),math.rad(getgenv().options.righthandrotoffset.Y),math.rad(getgenv().options.righthandrotoffset.Z))
getgenv().options.rightlegrotoffset = CFrame.Angles(math.rad(getgenv().options.rightlegrotoffset.X),math.rad(getgenv().options.rightlegrotoffset.Y),math.rad(getgenv().options.rightlegrotoffset.Z))
local AccessorySettings ={Torso={};LeftArm={getgenv().right};RightArm={getgenv().left};LeftLeg={getgenv().options.leftleg};RightLeg={getgenv().options.rightleg};LimbOffset=CFrame.Angles(math.pi/2,0,0);}
getgenv().accoffsets =   {Torso={};LeftArm={getgenv().options.lefthandrotoffset};RightArm={getgenv().options.righthandrotoffset};LeftLeg={getgenv().options.leftlegrotoffset};RightLeg={getgenv().options.rightlegrotoffset};}

local count = 0
for i,v in pairs(getgenv().headhats) do
	count+=1
	AccessorySettings.Torso[count]=i
	getgenv().accoffsets.Torso[count]=v
end
local FootPlacementSettings = {
	RightOffset = Vector3.new(.5, 0, 0),
	LeftOffset = Vector3.new(-.5, 0, 0),
}


local Script = nil;
local limbCFs = {}
local VirtualBody
local VirtualRig
local righttoyalign
Script = function()

local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local Character = Client.Character or Client.CharacterAdded:Wait()
local WeldBase = Character:WaitForChild("HumanoidRootPart")
local Mouse = Client:GetMouse()
local Camera = workspace.CurrentCamera

local VRService = game:GetService("VRService")
local VRReady = VRService.VREnabled

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local Point1 = false;
local Point2 = false;

VirtualRig = game:GetObjects("rbxassetid://4468539481")[1]
VirtualBody = game:GetObjects("rbxassetid://4464983829")[1]

local Anchor = Instance.new("Part")

Anchor.Anchored = true
Anchor.Transparency = 1
Anchor.CanCollide = false
Anchor.Parent = workspace

righttoypart = Instance.new("Part")
lefttoypart = Instance.new("Part")

righttoypart.Parent = workspace
righttoypart.CFrame = WeldBase.CFrame
righttoypart.Size = Vector3.new(1,1,1)
righttoypart.Transparency = 1
righttoypart.CanCollide = false
righttoypart.Anchored = true
righttoypart.Name = "rtoy"
lefttoypart.Parent = workspace
lefttoypart.CFrame = WeldBase.CFrame
lefttoypart.Size = Vector3.new(1,1,1)
lefttoypart.Transparency = 1
lefttoypart.CanCollide = false
lefttoypart.Anchored = true
lefttoypart.Name = "ltoy"

StarterGui:SetCore("VRLaserPointerMode", 3)

local CharacterCFrame = WeldBase.CFrame

function Tween(Object, Style, Direction, Time, Goal)
    local tweenInfo = TweenInfo.new(Time, Enum.EasingStyle[Style], Enum.EasingDirection[Direction])
    local tween = game:GetService("TweenService"):Create(Object, tweenInfo, Goal)

	tween.Completed:Connect(function()
		tween:Destroy()
	end)
	
    tween:Play()

    return tween
end

local function GetMotorForLimb(Limb)
	for _, Motor in next, Character:GetDescendants() do
		if Motor:IsA("Motor6D") and Motor.Part1 == Limb then
			return Motor
		end
	end
end

local function CreateAlignment(Limb, Part0)
	local Attachment0 = Instance.new("Attachment", Part0 or Anchor)
	local Attachment1 = Instance.new("Attachment", Limb)
	
	local Orientation = Instance.new("AlignOrientation")
	local Position = Instance.new("AlignPosition")
	
	Orientation.Attachment0 = Attachment1
	Orientation.Attachment1 = Attachment0
	Orientation.RigidityEnabled = false
	Orientation.MaxTorque = 20000
	Orientation.Responsiveness = 40
	Orientation.Parent = Character.HumanoidRootPart
	
	Position.Attachment0 = Attachment1
	Position.Attachment1 = Attachment0
	Position.RigidityEnabled = false
	Position.MaxForce = 40000
	Position.Responsiveness = 40
	Position.Parent = Character.HumanoidRootPart
	
	Limb.Massless = false
	
	local Motor = GetMotorForLimb(Limb)
	if Motor then
		Motor:Destroy()
	end
	
	return function(CF, Local)
		if Local then
			Attachment0.CFrame = CF
		else
			Attachment0.WorldCFrame = CF
		end
	end;
end

local function GetExtraTool()
	for _, Tool in next, Character:GetChildren() do
		if Tool:IsA("Tool") and not Tool.Name:match("LIMB_TOOL") then
			return Tool
		end
	end
end

local function GetGripForHandle(Handle)
	for _, Weld in next, Character:GetDescendants() do
		if Weld:IsA("Weld") and (Weld.Part0 == Handle or Weld.Part1 == Handle) then
			return Weld
		end
	end
	
	wait(.2)
	
	for _, Weld in next, Character:GetDescendants() do
		if Weld:IsA("Weld") and (Weld.Part0 == Handle or Weld.Part1 == Handle) then
			return Weld
		end
	end
end

local function CreateRightGrip(Handle)

end

VirtualRig.Name = "VirtualRig"
VirtualRig.RightFoot.BodyPosition.Position = CharacterCFrame.p
VirtualRig.LeftFoot.BodyPosition.Position = CharacterCFrame.p
VirtualRig.Parent = workspace
VirtualRig:SetPrimaryPartCFrame(CharacterCFrame)

VirtualRig.Humanoid.Health = 0
VirtualRig:BreakJoints()

VirtualBody.Parent = workspace
VirtualBody.Name = "VirtualBody"
VirtualBody.Humanoid.WalkSpeed = 8
VirtualBody.Humanoid.CameraOffset = Vector3.new(0, StudsOffset, 0)
VirtualBody:SetPrimaryPartCFrame(CharacterCFrame)
--

Camera.CameraSubject = VirtualBody.Humanoid
game:GetService("RunService").PostSimulation:Connect(function()
	Players.LocalPlayer.CameraMaxZoomDistance = VRReady and 0.1 or 20
	Players.LocalPlayer.CameraMinZoomDistance = 0.1
	workspace.CurrentCamera.HeadScale=1
    if workspace.CurrentCamera.CameraSubject == VirtualBody.Humanoid then
		workspace.CurrentCamera.HeadScale=1
        oldcam = workspace.CurrentCamera.CFrame
    end
    game.Players.LocalPlayer.CharacterAdded:Wait()
    workspace.CurrentCamera.CameraSubject=VirtualBody.Humanoid
	workspace.CurrentCamera.HeadScale=1
	Camera.CFrame = oldcam
	Camera:GetPropertyChangedSignal("CFrame"):Wait()
	Camera.CameraSubject=VirtualBody.Humanoid
	workspace.CurrentCamera.HeadScale=1
	Camera.CFrame = oldcam
	Players.LocalPlayer.CameraMaxZoomDistance = VRReady and 0.1 or 20
	Players.LocalPlayer.CameraMinZoomDistance = 0.1
end)

Character.Humanoid.WalkSpeed = 0
Character.Humanoid.JumpPower = 1
RunService.Stepped:Connect(function()
	if not VRReady then 
		--limbCFs.Head = workspace.CurrentCamera.CFrame
	end
end)
for _, Part in next, VirtualBody:GetChildren() do
	if Part:IsA("BasePart") then
		Part.Transparency = 1
	end
end

for _, Part in next, VirtualRig:GetChildren() do
	if Part:IsA("BasePart") then
		Part.Transparency = 1
	end
end

if not VRReady then
	VirtualRig.RightUpperArm.ShoulderConstraint.RigidityEnabled = true
	VirtualRig.LeftUpperArm.ShoulderConstraint.RigidityEnabled = true
end


local LVecPart = Instance.new("Part", workspace) 
LVecPart.CanCollide = false 
LVecPart.Transparency = 1
local walk = Instance.new("Animation",VirtualBody)
walk.AnimationId = "http://www.roblox.com/asset/?id=123"
local walka = VirtualBody.Humanoid:LoadAnimation(walk)
local jump = Instance.new("Animation",VirtualBody)
jump.AnimationId = "http://www.roblox.com/asset/?id=123"
local jumpa = VirtualBody.Humanoid:LoadAnimation(jump)
local CONVEC
local function VECTORUNIT()
    if HumanDied then CONVEC:Disconnect(); return end
    local lookVec = workspace.Camera.CFrame.lookVector
    local Root = VirtualBody["HumanoidRootPart"]
    LVecPart.Position = Root.Position
    LVecPart.CFrame = CFrame.new(LVecPart.Position, Vector3.new(lookVec.X * 9999, lookVec.Y, lookVec.Z * 9999))
end
CONVEC = game:GetService("RunService").Heartbeat:Connect(VECTORUNIT)
local CONDOWN
local WDown, ADown, SDown, DDown, SpaceDown = false, false, false, false, false
local function KEYDOWN(_,Processed) 
    if HumanDied then CONDOWN:Disconnect(); return end
    if Processed ~= true then
        local Key = _.KeyCode
        if Key == Enum.KeyCode.W then
            WDown = true end
        if Key == Enum.KeyCode.A then
            ADown = true end
        if Key == Enum.KeyCode.S then
            SDown = true end
        if Key == Enum.KeyCode.D then
            DDown = true end
        if Key == Enum.KeyCode.Space then
            SpaceDown = true 
        end 
    end 
end
CONDOWN = game:GetService("UserInputService").InputBegan:Connect(KEYDOWN)

local CONUP
local function KEYUP(_,a)
    if a then return end
    if HumanDied then CONUP:Disconnect(); return end
    local Key = _.KeyCode
    if Key == Enum.KeyCode.W then
        WDown = false end
    if Key == Enum.KeyCode.A then
        ADown = false end
    if Key == Enum.KeyCode.S then
        SDown = false end
    if Key == Enum.KeyCode.D then
        DDown = false end
    if Key == Enum.KeyCode.Space then
        SpaceDown = false end 
end
CONUP = game:GetService("UserInputService").InputEnded:Connect(KEYUP)

local function MoveClone(X,Y,Z)
    LVecPart.CFrame = LVecPart.CFrame * CFrame.new(-X,Y,-Z)
    VirtualBody.Humanoid.WalkToPoint = LVecPart.Position
end

coroutine.wrap(function()
	if VRReady then return end
    while true do game:GetService("RunService").RenderStepped:Wait()
        if HumanDied then break end
        if WDown then  MoveClone(0,0,1e4) if walka.IsPlaying ~= true then walka:Play() end end
        if ADown then MoveClone(1e4,0,0) if walka.IsPlaying ~= true then walka:Play() end end
        if SDown then MoveClone(0,0,-1e4) if walka.IsPlaying ~= true then walka:Play() end end
        if DDown then MoveClone(-1e4,0,0) if walka.IsPlaying ~= true then walka:Play() end end
        if SpaceDown then VirtualBody["Humanoid"].Jump = true if jumpa.IsPlaying ~= true then jumpa:Play() end end
        if WDown ~= true and ADown ~= true and SDown ~= true and DDown ~= true and SpaceDown ~= true then
            walka:Stop()
            VirtualBody.Humanoid.WalkToPoint = VirtualBody.HumanoidRootPart.Position end
    end 
end)()

UserInputService.InputChanged:Connect(function(inputObject)
	if inputObject.KeyCode == Enum.KeyCode.Thumbstick1 then
		lastjoystickPosition = joystickPosition
	  joystickPosition = inputObject.Position
	end
end)

local rtoypos = CFrame.new()
rfirst=true
holdingright=false
UserInputService.InputBegan:Connect(function(input,gpe)
	if input.KeyCode == Enum.KeyCode.ButtonA then
		VirtualBody.Humanoid.Jump = true
	end
	if input.KeyCode == Enum.KeyCode.ButtonB then
		if not rfirst then
			rtoypos = righttoypart.CFrame:ToObjectSpace(limbCFs.RightArm):Inverse()
		end
		rfirst = false
		holdingright = not holdingright
	end
end)
VirtualBody.Humanoid.WalkSpeed = 18

if VRReady then 
	RunService.Stepped:Connect(function()
		if not lastjoystickPosition then return end
		if not joystickPosition then return end
		if lastjoystickPosition.Magnitude == joystickPosition.Magnitude then VirtualBody.Humanoid:Move(Vector3.zero) return end
		lastjoystickPosition = joystickPosition
		local headCFrame = limbCFs.Head
		local joystickDirection = Vector3.new(-joystickPosition.X, 0, joystickPosition.Y)
		if joystickDirection.Magnitude<=0.6 then VirtualBody.Humanoid:Move(Vector3.zero)  return end
		local rotatedDirection = headCFrame:VectorToWorldSpace(joystickDirection)
		VirtualBody.Humanoid:Move(-rotatedDirection)
	end) 
end

local FootUpdateDebounce = tick()

local function FloorRay(Part, Distance)
	local Position = Part.CFrame.p
	local Target = Position - Vector3.new(0, Distance, 0)
	local Line = Ray.new(Position, (Target - Position).Unit * Distance)
	
	local FloorPart, FloorPosition, FloorNormal = workspace:FindPartOnRayWithIgnoreList(Line, {VirtualRig, VirtualBody, Character})
	
	if FloorPart then
		return FloorPart, FloorPosition, FloorNormal, (FloorPosition - Position).Magnitude
	else
		return nil, Target, Vector3.new(), Distance
	end
end

local function Flatten(CF)
	local X,Y,Z = CF.X,CF.Y,CF.Z
	local LX,LZ = CF.lookVector.X,CF.lookVector.Z
	
	return CFrame.new(X,Y,Z) * CFrame.Angles(0,math.atan2(LX,LZ),0)
end

local FootTurn = 1

local function FootReady(Foot, Target)
	local MaxDist
	
	if Character.Humanoid.MoveDirection.Magnitude > 0 then
		MaxDist = .5
	else
		MaxDist = 1
	end
	
	local PastThreshold = (Foot.Position - Target.Position).Magnitude > MaxDist
	local PastTick = tick() - FootUpdateDebounce >= 2
	
	if PastThreshold or PastTick then
		FootUpdateDebounce = tick()
	end
	
	return
		PastThreshold
	or
		PastTick
end

local function FootYield()
	local RightFooting = VirtualRig.RightFoot.BodyPosition
	local LeftFooting = VirtualRig.LeftFoot.BodyPosition
	local LowerTorso = VirtualRig.LowerTorso
	
	local Timer = 0.15
	local Yield = tick()
	
	repeat
		RunService.Stepped:Wait()
		if
			(LowerTorso.Position - RightFooting.Position).Y > 4
		or
			(LowerTorso.Position - LeftFooting.Position).Y > 4
		or
			((LowerTorso.Position - RightFooting.Position) * Vector3.new(1, 0, 1)).Magnitude > 4
		or
			((LowerTorso.Position - LeftFooting.Position) * Vector3.new(1, 0, 1)).Magnitude > 4
		then
			break
		end
	until tick() - Yield >= Timer
end

local function UpdateFooting()
	if not VirtualRig:FindFirstChild("LowerTorso") then
		wait()
		return
	end
	
	local Floor, FloorPosition, FloorNormal, Dist = FloorRay(VirtualRig.LowerTorso, 3)
	
	Dist = math.clamp(Dist, 0, 5)
	
	local FootTarget = 
		VirtualRig.LowerTorso.CFrame *
		CFrame.new(FootPlacementSettings.RightOffset) -
		Vector3.new(0, Dist, 0) +
		Character.Humanoid.MoveDirection * (VirtualBody.Humanoid.WalkSpeed / 8) * 2
		
	if FootReady(VirtualRig.RightFoot, FootTarget) then
		VirtualRig.RightFoot.BodyPosition.Position = FootTarget.p
		VirtualRig.RightFoot.BodyGyro.CFrame = Flatten(VirtualRig.LowerTorso.CFrame)
	end
	
	FootYield()
	
	local FootTarget = 
		VirtualRig.LowerTorso.CFrame *
		CFrame.new(FootPlacementSettings.LeftOffset) -
		Vector3.new(0, Dist, 0) +
		Character.Humanoid.MoveDirection * (VirtualBody.Humanoid.WalkSpeed / 8) * 2
	
	if FootReady(VirtualRig.LeftFoot, FootTarget) then
		VirtualRig.LeftFoot.BodyPosition.Position = FootTarget.p
		VirtualRig.LeftFoot.BodyGyro.CFrame = Flatten(VirtualRig.LowerTorso.CFrame)
	end
end

local function UpdateLegPosition()

end

warn("VRReady is", VRReady)

local function OnUserCFrameChanged(UserCFrame, Positioning, IgnoreTorso)
	Positioning = Camera.CFrame * Positioning
	limbCFs.Torso = VirtualRig.UpperTorso.CFrame * CFrame.new(0, -0.25, 0) * AccessorySettings.LimbOffset
	limbCFs.RightLeg = VirtualRig.RightFoot.CFrame * CFrame.new(0, 0.5, 0) * AccessorySettings.LimbOffset
	limbCFs.LeftLeg = VirtualRig.LeftLowerLeg.CFrame:Lerp(VirtualRig.LeftFoot.CFrame, 0.5)* CFrame.new(0, 0.5, 0) * AccessorySettings.LimbOffset
	if UserCFrame == Enum.UserCFrame.Head then
		limbCFs.Head = Positioning
	elseif UserCFrame == Enum.UserCFrame.RightHand and AccessorySettings.RightArm then
		walklookvec = Positioning.lookVector
		local HandPosition = Positioning
		local LocalPositioning = Positioning
		
		if AccurateHandPosition then
			HandPosition = HandPosition * CFrame.new(0, 0, 1)
		else
			HandPosition = HandPosition * CFrame.new(0, 0, .5)
		end
		
		if not VRReady then
			local HeadRotation = Camera.CFrame - Camera.CFrame.p
			
			HandPosition = VirtualRig.RightLowerArm.CFrame * AccessorySettings.LimbOffset
			
			--LocalPositioning = (HeadRotation + (HandPosition * CFrame.new(0, 0, 1)).p) * CFrame.Angles(math.rad(-45), 0, 0)
			LocalPositioning = HandPosition * CFrame.new(0, 0, 1) * CFrame.Angles(math.rad(-180), 0, 0)
			
			if Point2 then
				VirtualRig.RightUpperArm.Aim.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				VirtualRig.RightUpperArm.Aim.CFrame = Camera.CFrame * AccessorySettings.LimbOffset
			elseif VirtualRig.RightUpperArm.Aim.MaxTorque ~= Vector3.new(0, 0, 0) then
				VirtualRig.RightUpperArm.Aim.MaxTorque = Vector3.new(0, 0, 0)
			end
		end
		limbCFs.RightArm = HandPosition
	elseif UserCFrame == Enum.UserCFrame.LeftHand and AccessorySettings.LeftArm then
		local HandPosition = Positioning
		
		if AccurateHandPosition then
			HandPosition = HandPosition * CFrame.new(0, 0, 1)
		end
		
		if not VRReady then
			HandPosition = VirtualRig.LeftUpperArm.CFrame:Lerp(VirtualRig.LeftLowerArm.CFrame, 0.5) * AccessorySettings.LimbOffset
			--warn("Setting HandPosition to hands")
			if Point1 then
				VirtualRig.LeftUpperArm.Aim.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				VirtualRig.LeftUpperArm.Aim.CFrame = Camera.CFrame * AccessorySettings.LimbOffset
			elseif VirtualRig.LeftUpperArm.Aim.MaxTorque ~= Vector3.new(0, 0, 0) then
				VirtualRig.LeftUpperArm.Aim.MaxTorque = Vector3.new(0, 0, 0)
			end
		end
		
		limbCFs.LeftArm = HandPosition
	end
	
	if UserCFrame == Enum.UserCFrame.Head then
		VirtualRig.Head.CFrame = Positioning
		
	elseif UserCFrame == Enum.UserCFrame.RightHand and VRReady then
		VirtualRig.RightHand.CFrame = Positioning
		if holdingright then
			righttoypart.CFrame = Positioning * rtoypos
		end
	elseif UserCFrame == Enum.UserCFrame.LeftHand and VRReady then
		VirtualRig.LeftHand.CFrame = Positioning
	end
	
	if not VRReady and VirtualRig.LeftHand.Anchored then
		VirtualRig.RightHand.Anchored = false
		VirtualRig.LeftHand.Anchored = false
	elseif VRReady and not VirtualRig.LeftHand.Anchored then
		VirtualRig.RightHand.Anchored = true
		VirtualRig.LeftHand.Anchored = true
	end
end

local CFrameChanged = VRService.UserCFrameChanged:Connect(OnUserCFrameChanged)

local OnStepped = RunService.Stepped:Connect(function()
	for _, Part in pairs(VirtualRig:GetChildren()) do
		if Part:IsA("BasePart") then
			Part.CanCollide = false
		end
	end
	for _, Player in pairs(Players:GetPlayers()) do
		if Player ~= Client and Player.Character then
			local Descendants = Player.Character:GetDescendants()
			for i = 1, #Descendants do
				local Part = Descendants[i]
				if Part:IsA("BasePart") then
					Part.CanCollide = false
					Part.Velocity = Vector3.new()
					Part.RotVelocity = Vector3.new()
				end
			end
		end
	end
end)

local OnRenderStepped = RunService.Stepped:Connect(function()
	Camera.CameraSubject = VirtualBody.Humanoid

	if not VRReady then
		OnUserCFrameChanged(Enum.UserCFrame.Head, CFrame.new(0, 0, 0))
		
		OnUserCFrameChanged(Enum.UserCFrame.RightHand, CFrame.new(0, 0, 0), true)
		OnUserCFrameChanged(Enum.UserCFrame.LeftHand, CFrame.new(0, 0, 0), true)
	end
end)
spawn(function( )
	while true do
		task.wait()
		FootYield()
		UpdateFooting()
	end
end)

--[[
	Non-VR Support + VR Mechanics
--]]

local OnInput = UserInputService.InputBegan:Connect(function(Input, Processed)
	if not Processed then
		if Input.KeyCode == Enum.KeyCode.LeftControl or Input.KeyCode == Enum.KeyCode.ButtonL2 then
			Tween(VirtualBody.Humanoid, "Elastic", "Out", 1, {
				CameraOffset = Vector3.new(0, StudsOffset - 1.5, 0)
			})
		end
		
		if Input.KeyCode == Enum.KeyCode.C then
			VirtualBody:MoveTo(Mouse.Hit.p)
			VirtualRig:MoveTo(Mouse.Hit.p)
		end
	end
		
	if Input.KeyCode == Enum.KeyCode.LeftShift or Input.KeyCode == Enum.KeyCode.ButtonR2 then
		dowalk=true
	end
	
	if not VRReady and Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Point1 = true
	end
	
	if not VRReady and Input.UserInputType == Enum.UserInputType.MouseButton2 then
		Point2 = true
	end
end)

local OnInputEnded = UserInputService.InputEnded:Connect(function(Input, Processed)
	if not Processed then
		if Input.KeyCode == Enum.KeyCode.LeftControl or Input.KeyCode == Enum.KeyCode.ButtonL2 then
			Tween(VirtualBody.Humanoid, "Elastic", "Out", 1, {
				CameraOffset = Vector3.new(0, StudsOffset, 0)
			})
		end
	end
		
	if Input.KeyCode == Enum.KeyCode.LeftShift or Input.KeyCode == Enum.KeyCode.ButtonR2 then
dowalk=false
	end
	
	if not VRReady and Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Point1 = false
	end
	
	if not VRReady and Input.UserInputType == Enum.UserInputType.MouseButton2 then
		Point2 = false
	end
end)

--[[
	Proper Cleanup
--]]

if ChatEnabled then
	spawn(ChatHUDFunc)
end

if ViewportEnabled then
	spawn(ViewHUDFunc)
end


end

Permadeath = function()
end;

Respawn = function()
end;

ChatHUDFunc = function()
	--[[
		Variables
	--]]
	
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	
	local VRService = game:GetService("VRService")
	 local VRReady = VRService.VREnabled
	
	local Players = game:GetService("Players")
	 local Client = Players.LocalPlayer
	
	local ChatHUD = game:GetObjects("rbxassetid://4649972829")[1]
	ChatHUD.ResetOnSpawn = false
	 local GlobalFrame = ChatHUD.GlobalFrame
	  local Template = GlobalFrame.Template
	 local LocalFrame = ChatHUD.LocalFrame
	 local Global = ChatHUD.Global
	 local Local = ChatHUD.Local
	
	local Camera = workspace.CurrentCamera
	
	Template.Parent = nil
	ChatHUD.Parent = game:GetService("CoreGui")
	
	--[[
		Code
	--]]
	
	local Highlight = Global.Frame.BackgroundColor3
	local Deselected = Local.Frame.BackgroundColor3
	
	local OpenGlobalTab = function()
		Global.Frame.BackgroundColor3 = Highlight
		Local.Frame.BackgroundColor3 = Deselected
		
		Global.Font = Enum.Font.SourceSansBold
		Local.Font = Enum.Font.SourceSans
		
		GlobalFrame.Visible = true
		LocalFrame.Visible = false
	end
	
	local OpenLocalTab = function()
		Global.Frame.BackgroundColor3 = Deselected
		Local.Frame.BackgroundColor3 = Highlight
		
		Global.Font = Enum.Font.SourceSans
		Local.Font = Enum.Font.SourceSansBold
		
		GlobalFrame.Visible = false
		LocalFrame.Visible = true
	end
	
	Global.MouseButton1Down:Connect(OpenGlobalTab)
	Local.MouseButton1Down:Connect(OpenLocalTab)
	Global.MouseButton1Click:Connect(OpenGlobalTab)
	Local.MouseButton1Click:Connect(OpenLocalTab)
	
	OpenLocalTab()
	
	--
	
	local function GetPlayerDistance(Sender)
		if Sender.Character and Sender.Character:FindFirstChild("Head") then
			return math.floor((Sender.Character.Head.Position - Camera:GetRenderCFrame().p).Magnitude + 0.5)
		end
	end
	
	local function NewGlobal(Message, Sender, Color)
		local Frame = Template:Clone()
		
		Frame.Text = ("[%s]: %s"):format(Sender.Name, Message)
		Frame.User.Text = ("[%s]:"):format(Sender.Name)
		Frame.User.TextColor3 = Color
		Frame.BackgroundColor3 = Color
		Frame.Parent = GlobalFrame
		
		delay(60, function()
			Frame:Destroy()
		end)
	end
	
	local function NewLocal(Message, Sender, Color, Dist)
		local Frame = Template:Clone()
		
		Frame.Text = ("(%s) [%s]: %s"):format(tostring(Dist), Sender.Name, Message)
		Frame.User.Text = ("(%s) [%s]:"):format(tostring(Dist), Sender.Name)
		Frame.User.TextColor3 = Color
		Frame.BackgroundColor3 = Color
		Frame.Parent = LocalFrame
		
		delay(60, function()
			Frame:Destroy()
		end)
	end
	
	local function OnNewChat(Message, Sender, Color)
		if not ChatHUD or not ChatHUD.Parent then return end
		
		NewGlobal(Message, Sender, Color)
		
		local Distance = GetPlayerDistance(Sender)
		
		if Distance and Distance <= ChatLocalRange then
			NewLocal(Message, Sender, Color, Distance)
		end
	end
	
	local function OnPlayerAdded(Player)
		if not ChatHUD or not ChatHUD.Parent then return end
		
		local Color = BrickColor.Random().Color
		
		Player.Chatted:Connect(function(Message)
			OnNewChat(Message, Player, Color)
		end)
	end
	
	Players.PlayerAdded:Connect(OnPlayerAdded)
	
	for _, Player in pairs(Players:GetPlayers()) do
		OnPlayerAdded(Player)
	end
	
	--
	
	local ChatPart = ChatHUD.Part
	
	ChatHUD.Adornee = ChatPart
	
	if VRReady then
		ChatHUD.Parent = game:GetService("CoreGui")
		ChatHUD.Enabled = true
		ChatHUD.AlwaysOnTop = true
		
		local OnInput = UserInputService.InputBegan:Connect(function(Input, Processed)
			if not Processed then
				if Input.KeyCode == Enum.KeyCode.ButtonX then
					ChatHUD.Enabled = not ChatHUD.Enabled
				end
			end
		end)
		
		local RenderStepped = RunService.RenderStepped:Connect(function()
			local LeftHand = VRService:GetUserCFrame(Enum.UserCFrame.LeftHand)
			
			ChatPart.CFrame = Camera.CFrame * LeftHand
		end)
	end
	
	wait(9e9)
end;

ViewHUDFunc = function()
	--[[
		Variables
	--]]
	
	local ViewportRange = ViewportRange or 32
	
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	
	local VRService = game:GetService("VRService")
	 local VRReady = VRService.VREnabled
	
	local Players = game:GetService("Players")
	 local Client = Players.LocalPlayer
	  local Mouse = Client:GetMouse()
	
	local Camera = workspace.CurrentCamera
	 local CameraPort = Camera.CFrame
	
	local ViewHUD = game:GetObjects("rbxassetid://4649974000")[1]
	 local Viewport = ViewHUD.Viewport
	  local Viewcam = Instance.new("Camera")
	 local ViewPart = ViewHUD.Part
	
	ViewHUD.Parent = game:GetService("CoreGui")
	
	Viewcam.Parent = Viewport
	Viewcam.CameraType = Enum.CameraType.Scriptable
	Viewport.CurrentCamera = Viewcam
	Viewport.BackgroundTransparency = 1
	
	--[[
		Code
	--]]
	
	local function Clone(Character)
		local Arc = Character.Archivable
		local Clone;
		
		Character.Archivable = true
		Clone = Character:Clone()
		Character.Archivable = Arc
		
		return Clone
	end
	
	local function GetPart(Name, Parent, Descendants)
		for i = 1, #Descendants do
			local Part = Descendants[i]
			
			if Part.Name == Name and Part.Parent.Name == Parent then
				return Part
			end
		end
	end
	
	local function OnPlayerAdded(Player)
		if not ViewHUD or not ViewHUD.Parent then return end
		
		local function CharacterAdded(Character)
			if not ViewHUD or not ViewHUD.Parent then return end
			
			Character:WaitForChild("Head")
			Character:WaitForChild("Humanoid")
			task.wait(0.9)
			
			local FakeChar = Clone(Character)
			local Root = FakeChar:FindFirstChild("HumanoidRootPart") or FakeChar:FindFirstChild("Head")
			local RenderConnection;
			
			local Descendants = FakeChar:GetDescendants()
			local RealDescendants = Character:GetDescendants()
			local Correspondents = {};
			
			FakeChar.Humanoid.DisplayDistanceType = "None"
			
			for i = 1, #Descendants do
				local Part = Descendants[i]
				local Real = Part:IsA("BasePart") and GetPart(Part.Name, Part.Parent.Name, RealDescendants)
				
				if Part:IsA("BasePart") and Real then
					Part.Anchored = true
					Part:BreakJoints()
					
					if Part.Parent:IsA("Accessory") then
						Part.Transparency = 0
					end
					
					table.insert(Correspondents, {Part, Real})
				end
			end
			
			RenderConnection = RunService.RenderStepped:Connect(function()
				if not Character or not Character.Parent then
					RenderConnection:Disconnect()
					FakeChar:Destroy()
					
					return
				end
				
				if (Root and (Root.Position - Camera.CFrame.p).Magnitude <= ViewportRange) or Player == Client or not Root then
					for i = 1, #Correspondents do
						local Part, Real = unpack(Correspondents[i])
						
						if Part and Real and Part.Parent and Real.Parent then
							Part.CFrame = Real.CFrame
						elseif Part.Parent and not Real.Parent then
							Part:Destroy()
						end
					end
				end
			end)
			
			FakeChar.Parent = Viewcam
		end
		
		Player.CharacterAdded:Connect(CharacterAdded)
		
		if Player.Character then
			spawn(function()
				CharacterAdded(Player.Character)
			end)
		end
	end
	
	local PlayerAdded = Players.PlayerAdded:Connect(OnPlayerAdded)
	
	for _, Player in pairs(Players:GetPlayers()) do
		OnPlayerAdded(Player)
	end
	
	ViewPart.Size = Vector3.new()
	
	if VRReady then
		Viewport.Position = UDim2.new(.62, 0, .89, 0)
		Viewport.Size = UDim2.new(.3, 0, .3, 0)
		Viewport.AnchorPoint = Vector2.new(.5, 1)
	else
		Viewport.Size = UDim2.new(0.3, 0, 0.3, 0)
	end
	
	local RenderStepped = RunService.RenderStepped:Connect(function()
		local Render = Camera.CFrame
		local Scale = Camera.ViewportSize
		
		if VRReady then
			Render = Render * VRService:GetUserCFrame(Enum.UserCFrame.Head)
		end
		
		CameraPort = CFrame.new(Render.p + Vector3.new(5, 2, 0), Render.p)
		
		Viewport.Camera.CFrame = CameraPort
		
		ViewPart.CFrame = Render * CFrame.new(0, 0, -16)
		
		ViewHUD.Size = UDim2.new(0, Scale.X - 6, 0, Scale.Y - 6)
	end)
	
	wait(9e9)
end;

local plr = game.Players.LocalPlayer

_isnetworkowner = function(v)
    return v.ReceiveAge == 0 and not v.NetworkIsSleeping
end

function Align(Part1,name,cf,velocity)
	if not velocity then velocity = Vector3.new(20,20,20) end
	local doit = true
	local con;con=game:GetService("RunService").PostSimulation:Connect(function()
		if not doit then return end
		if not Part1:IsDescendantOf(workspace) then con:Disconnect() return end
		if not _isnetworkowner(Part1) then return end
		Part1.Velocity = velocity
		Part1.CFrame=(((typeof(name) == "string") and limbCFs[name]) or name.CFrame)*cf
		Part1.CanQuery = false
		Part1.CanTouch = false
		Part1.CanCollide = falsea
	end)
	return {Set=function(self,a) doit=a end,Disconnect=con.Disconnect}
end

function findMeshID(id,hatname,alreadyfound)
	if getgenv().options.leftToy == "meshid"..id or getgenv().options.leftToy == hatname then
		return "lefttoy",getgenv().options.leftToy:find("meshid:")
	end
	if getgenv().options.rightToy == "meshid"..id or getgenv().options.rightToy == hatname then
		return "righttoy",getgenv().options.rightToy:find("meshid:")
	end
	for i,v in pairs(AccessorySettings) do
		if typeof(v)~='table' then continue end
		if alreadyfound[i]==true then continue end
		for i2,v2 in next, v do
			if (v2:find("meshid:") and v2 == "meshid:"..id) or v2 == hatname then
				return i,v2:find("meshid:"),i2
			end
		end
	end
    return "Head"
end

function filterMeshID(id)
	return (string.find(id,'assetdelivery')~=nil and string.match(string.sub(id,37,#id),"%d+")) or string.match(id,"%d+")
end

local ExtraParts = {
	["Back"] = "Torso",
	["Body"] = "Torso",
	["Hair"] = "Head",
	["FaceCenter"] = "Head",
	["FaceFront"] = "Head",
	["Waist"] = "Torso",
	["Hat"] = "Head",
	["Neck"] = "Torso",
}
Script()
for i,v in next, plr.Character.HumanoidRootPart:GetChildren() do if v:IsA("Sound") then v.Volume = 0 end end
local toolcons = {}
for i,v in plr.Backpack:GetChildren() do 
	local w = Instance.new("Weld") 	
	w.Name = "RightGrip" 	
	w.Parent = plr.Character["Right Arm"] 	
	w.Part0 = w.Parent 	
	w.Part1 = v.Handle 	
	v.Parent = plr.Character 	
	task.wait(0.03) 	
	w:Destroy() 
	v.Handle.CanQuery=false;v.Handle.CanCollide=false;v.Handle.CanTouch=false 
	toolcons[v.Name] = Align(v.Handle,"RightArm",CFrame.Angles(math.pi/2,0,0)*CFrame.new(-1.5,1,0)*CFrame.Angles(0,-math.pi/2,-math.pi/2))
	v.Parent=plr.Backpack
end
plr.Character.ChildAdded:Connect(function(tool: Tool)
	if tool:IsA("Tool") then
		if toolcons[tool.Name] then toolcons[tool.Name]:Set(true) return end
	end
end)
plr.Character.ChildRemoved:Connect(function(tool: Tool)
	if tool:IsA("Tool") then
		toolcons[tool.Name]:Set(false)
	end
end)
plr.Character.Humanoid.Health = 0
local alreadyfound = {}
for i,v in next, plr.Character.Humanoid:GetAccessories() do
	local handle = v:FindFirstChild("Handle") if not handle then continue end
	local id = filterMeshID((handle:IsA("MeshPart") and handle.MeshId) or handle:FindFirstChildOfClass("SpecialMesh").MeshId)
	local limbName, foundthroughmeshid, index = findMeshID(id,v.Name,alreadyfound)
	alreadyfound[limbName]=true
	if ("meshid:"..id)==getgenv().options.rightToy then
		Align(handle,(righttoypart),CFrame.new())
		continue
	end
	handle.Transparency=getgenv().options.limbTransparency
	if limbName=="Head" then handle.Transparency=1 end
	if limbName=="Torso" then handle.Transparency=1 end
	handle.CanQuery = false
	handle.CanTouch = false
	local hatattcf = handle:FindFirstChildOfClass("Attachment")
	local headcf = VirtualRig:FindFirstChild(hatattcf.Name, true)
	local washead=false
	if limbName == "Head" then
		for i,v in pairs(ExtraParts) do
			if hatattcf.Name:find(i) then if limbName~=v then limbName = v washead=true break end end
		end
	end
	Align(handle, limbName, (((limbName == "Head") or washead) and (washead and CFrame.Angles(-math.pi/2,0,0)*headcf.CFrame*hatattcf.CFrame:Inverse() or headcf.CFrame*hatattcf.CFrame:Inverse())) or getgenv().accoffsets[limbName][index])
end
plr.CharacterAdded:Connect(function(char)
	local hrp = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")
	task.wait(0.25)
	hrp.CFrame=VirtualBody.HumanoidRootPart.CFrame*CFrame.new(15,-15,15)
	task.wait(0.15)
	for i,v in next, hrp:GetChildren() do if v:IsA("Sound") then v.Volume = 0 end end
	local toolcons = {}
	for i,v in plr.Backpack:GetChildren() do 
		local w = Instance.new("Weld") 	
		w.Name = "RightGrip" 	
		w.Parent = char["Right Arm"] 	
		w.Part0 = w.Parent 	
		w.Part1 = v.Handle 	
		v.Parent = char 	
		task.wait(0.03) 	
		w:Destroy() 
		v.Handle.CanQuery=false;v.Handle.CanCollide=false;v.Handle.CanTouch=false 
		toolcons[v.Name] = Align(v.Handle,"RightArm",CFrame.Angles(math.pi/2,0,0)*CFrame.new(-1.5,1,0)*CFrame.Angles(0,-math.pi/2,-math.pi/2))
		v.Parent=plr.Backpack
	end
	char.ChildAdded:Connect(function(tool: Tool)
		if tool:IsA("Tool") then
			if toolcons[tool.Name] then toolcons[tool.Name]:Set(true) return end
		end
	end)
	char.ChildRemoved:Connect(function(tool: Tool)
		if tool:IsA("Tool") then
			toolcons[tool.Name]:Set(false)
		end
	end)
	hum.Health = 0



	local alreadyfound = {}
	for i,v in next, hum:GetAccessories() do
		local handle = v:FindFirstChild("Handle") if not handle then continue end
		local id = filterMeshID((handle:IsA("MeshPart") and handle.MeshId) or handle:FindFirstChildOfClass("SpecialMesh").MeshId)
		local limbName, foundthroughmeshid, index = findMeshID(id,v.Name,alreadyfound)
		alreadyfound[limbName]=true
		if ("meshid:"..id)==getgenv().options.rightToy then
			Align(handle,(righttoypart),CFrame.new())
			continue
		end
		handle.Transparency=getgenv().options.limbTransparency
		if limbName=="Head" then handle.Transparency=1 end
		if limbName=="Torso" then handle.Transparency=1 end
		handle.CanQuery = false
		handle.CanTouch = false
		local hatattcf = handle:FindFirstChildOfClass("Attachment")
		local headcf = VirtualRig:FindFirstChild(hatattcf.Name, true)
		local washead=false
		if limbName == "Head" then
			for i,v in pairs(ExtraParts) do
				if hatattcf.Name:find(i) then if limbName~=v then limbName = v washead=true break end end
			end
		end
		Align(handle, limbName, (((limbName == "Head") or washead) and (washead and CFrame.Angles(-math.pi/2,0,0)*headcf.CFrame*hatattcf.CFrame:Inverse() or headcf.CFrame*hatattcf.CFrame:Inverse())) or getgenv().accoffsets[limbName][index])
	end
end)
