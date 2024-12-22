-- DO NOT RUN THIS IN VR MODE
skyvrversion = '2.2.0'

VR_Model_Customization_GUI = game:GetObjects("rbxassetid://93922799482853")[1]
VR_Model_Customization_GUI.Parent = game.CoreGui

loadstring(game:HttpGet("https://raw.githubusercontent.com/presidentanvil/skyvr/main/VRCustomizationMain.lua"))()
