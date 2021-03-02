AddCSLuaFile()

TOOL.Category = "Render"
TOOL.Name = "Advanced Material 2"
TOOL.ClientConVar["submatid"] = "-1"
TOOL.ClientConVar["texture"] = ""
TOOL.ClientConVar["noisetexture"] = "detail/noise_detail_01"
TOOL.ClientConVar["scalex"] = "1"
TOOL.ClientConVar["scaley"] = "1"
TOOL.ClientConVar["offsetx"] = "0"
TOOL.ClientConVar["offsety"] = "0"
TOOL.ClientConVar["rotate"] = "0"
TOOL.ClientConVar["usenoise"] = "0"
TOOL.ClientConVar["noisescalex"] = "1"
TOOL.ClientConVar["noisescaley"] = "1"
TOOL.ClientConVar["noiseoffsetx"] = "0"
TOOL.ClientConVar["noiseoffsety"] = "0"
TOOL.ClientConVar["noiserotate"] = "0"
TOOL.ClientConVar["usebump"] = "0"
TOOL.ClientConVar["bumptexture"] = ""
TOOL.ClientConVar["uselightwarp"] = "0"
TOOL.ClientConVar["lightwarptexture"] = ""
TOOL.ClientConVar["useenvmap"] = "0"
TOOL.ClientConVar["envmaptexture"] = ""
TOOL.ClientConVar["envmapcontrast"] = "0.5"
TOOL.ClientConVar["envmaptint"] = "1, 1, 1"
TOOL.ClientConVar["usephong"] = "0"
TOOL.ClientConVar["phongboost"] = "1"
TOOL.ClientConVar["phongfresnel"] = "0, 0.5, 1"
TOOL.ClientConVar["usetreesway"] = "0"
TOOL.ClientConVar["alphatype"] = "0"
TOOL.ClientConVar["nocull"] = "0"

TOOL.DetailWhitelist = {
	"concrete",
	"metal",
	"plaster",
	"rock"
}
TOOL.DetailTranslation = {
	concrete = "detail/noise_detail_01",
	rock = "detail/rock_detail_01",
	metal = "detail/metal_detail_01",
	plaster = "detail/plaster_detail_01"
}
TOOL.Information = {
	{name = "left"},
	{name = "right"},
	{name = "reload"}
}

/*
	MATERIALIZE
*/

function TOOL:LeftClick(trace)
	if (!IsValid(trace.Entity)) then return false end
	if (trace.Entity:IsPlayer()) then return false end
	if (CLIENT) then return true end

	local submatid = tonumber(self:GetClientInfo("submatid"))
	local texture = self:GetClientInfo("texture")
	local scalex = tonumber(self:GetClientInfo("scalex"))
	local scaley = tonumber(self:GetClientInfo("scaley"))
	local offsetx = tonumber(self:GetClientInfo("offsetx"))
	local offsety = tonumber(self:GetClientInfo("offsety"))
	local rotate = tonumber(self:GetClientInfo("rotate"))
	local usenoise = tobool(self:GetClientInfo("usenoise"))
	local noisetexture = self:GetClientInfo("noisetexture")
	local noisescalex = tonumber(self:GetClientInfo("noisescalex"))
	local noisescaley = tonumber(self:GetClientInfo("noisescaley"))
	local noiseoffsetx = tonumber(self:GetClientInfo("noiseoffsetx"))
	local noiseoffsety = tonumber(self:GetClientInfo("noiseoffsety"))
	local noiserotate = tonumber(self:GetClientInfo("noiserotate"))
	local usebump = tobool(self:GetClientInfo("usebump"))
	local bumptexture = self:GetClientInfo("bumptexture")
	local uselightwarp = tobool(self:GetClientInfo("uselightwarp"))
	local lightwarptexture = self:GetClientInfo("lightwarptexture")
	local useenvmap = tobool(self:GetClientInfo("useenvmap"))
	local envmaptexture = self:GetClientInfo("envmaptexture")
	local envmapcontrast = tonumber(self:GetClientInfo("envmapcontrast"))
	local envmaptint = self:GetClientInfo("envmaptint")
	local usephong = tobool(self:GetClientInfo("usephong"))
	local phongboost = tonumber(self:GetClientInfo("phongboost"))
	local phongfresnel = self:GetClientInfo("phongfresnel")
	local usetreesway = tonumber(self:GetClientInfo("usetreesway"))
	local alphatype = tonumber(self:GetClientInfo("alphatype"))
	local nocull = tonumber(self:GetClientInfo("nocull"))
	
	local toSet = trace.Entity
	if toSet:GetClass() == "prop_effect" then toSet = trace.Entity:GetChildren()[1] end
	
	advMats:Set(toSet, string.Trim(texture):lower(), {
		ScaleX = scalex,
		ScaleY = scaley,
		OffsetX = offsetx,
		OffsetY = offsety,
		Rotate = rotate,
		UseNoise = usenoise,
		NoiseTexture = noisetexture,
		NoiseScaleX = noisescalex,
		NoiseScaleY = noisescaley,
		NoiseOffsetX = noiseoffsetx,
		NoiseOffsetY = noiseoffsety,
		NoiseRotate = noiserotate,
		UseBump = usebump,
		BumpTexture = bumptexture,
		UseLightwarp = uselightwarp,
		LightwarpTexture = lightwarptexture,
		UseEnvMap = useenvmap,
		EnvMapTexture = envmaptexture,
		EnvMapContrast = envmapcontrast,
		EnvMapTint = envmaptint,
		UsePhong = usephong,
		PhongBoost = phongboost,
		PhongFresnel = phongfresnel,
		UseTSway = usetreesway,
		AlphaType = alphatype,
		NoCull = nocull
	}, submatid)

	return true
end

function TOOL:RightClick(trace)
	if (trace.Entity:IsPlayer()) then return false end
	if (CLIENT) then return true end

	toSet = trace.Entity
	if trace.Entity:GetClass() == "prop_effect" then toSet = trace.Entity:GetChildren()[1] end

	local submatid = tonumber(self:GetClientInfo("submatid"))
	local bIsMat = false

	if (IsValid(toSet)) then
		if (toSet:GetMaterial() != "") then
			if (toSet:GetMaterial():sub(1, 1) != "!") then
				bIsMat = true
			end
		end
	end



	local tempMat = Material(trace.HitTexture)
	local hitNoise = tempMat:GetString("$detail")
	local noiseTexture = false

	for k, v in pairs(self.DetailTranslation) do
		if (v == hitNoise) then
			noiseTexture = k
			break
		end
	end

	local data = {}

	if bIsMat then
		if submatid == -1 or trace.HitWorld then
			data = toSet["MaterialData"..submatid] or {
			texture = bIsMat and trace.Entity:GetMaterial() or trace.HitTexture,
			scalex = 1,
			scaley = 1,
			offsetx = 0,
			offsety = 0,
			usenoise = noiseTexture and 1 or 0,
			noisetexture = noiseTexture
		}
		elseif submatid > -1 and trace.HitNonWorld then
			data = toSet.SubMaterialData[submatid] or {
			texture = bIsMat and trace.Entity:GetMaterial() or trace.HitTexture,
			scalex = 1,
			scaley = 1,
			offsetx = 0,
			offsety = 0,
			usenoise = noiseTexture and 1 or 0,
			noisetexture = noiseTexture
		}
		end
	else
		self:GetOwner():ConCommand("advmat_texture " .. toSet:GetMaterials()[1]) 
	end

	

	for k, v in pairs(data) do
		if (isbool(v)) then continue end

		self:GetOwner():ConCommand("advmat_" .. k:lower() .. " " .. tostring(v))
	end

	return true
end

function TOOL:Reload(trace)
	local submatid = tonumber(self:GetClientInfo("submatid"))
	if (!IsValid(trace.Entity)) then return false end
	if (CLIENT) then return true end
	
	toSet = trace.Entity
	
	if trace.Entity:GetClass() == "prop_effect" then toSet = trace.Entity:GetChildren()[1] end

	advMats:Set(toSet, "", {}, submatid)

	return true
end

// function TOOL:UpdateGhostMat(player, ent)
// 	if (!IsValid(ent)) then return end
// 	local trace = player:GetEyeTrace()

// 	if (!IsValid(trace.Entity)) then ent:SetNoDraw(true) return end

// 	ent:SetModel(trace.Entity:GetModel())
// 	ent:SetAngles(trace.Entity:GetAngles())

// 	ent:SetPos(trace.Entity:GetPos())
// 	ent:SetNoDraw(false)
// 	ent:SetColor(Color(255, 255, 255, 255))

// 	ent:SetMaterial("!AdvMatPreview")
// end

local noBump = Material("debug/debugdrawflat"):GetTexture("$bumpmap")
function TOOL:Think()
	if (CLIENT) then
		local texture = self:GetClientInfo("texture")
		local scalex = self:GetClientNumber("scalex", 1)
		local scaley = self:GetClientNumber("scaley", 1)
		local offsetx = self:GetClientNumber("offsetx")
		local offsety = self:GetClientNumber("offsety")

		local bUseNoise = tobool(self:GetClientInfo("usenoise"))
		local noisescalex = self:GetClientNumber("noisescalex", 1)
		local noisescaley = self:GetClientNumber("noisescaley", 1)
		local noiseoffsetx = self:GetClientNumber("noiseoffsetx", 0)
		local noiseoffsety = self:GetClientNumber("noiseoffsety", 0)
		
		local bUseLightwarp = tobool(self:GetClientInfo("uselightwarp"))
		local lightwarptexture = self:GetClientInfo("lightwarptexture")

		if (texture == "") then
			return
		end

	end
end

if (CLIENT) then
	function TOOL:DrawHUD()

	end

	hook.Add("PostDrawOpaqueRenderables", "AdvMatPreview", function()
		local player = LocalPlayer()

		if (!IsValid(player)) then return end

		if (IsValid(player:GetActiveWeapon()) and player:GetActiveWeapon():GetClass() == "gmod_tool") then
			local toolObj = player:GetTool()

			if (!toolObj) then return end

			if (toolObj.Name != "Advanced Material") then return end

			local ent = player:GetEyeTrace().Entity

			if (IsValid(ent)) then
				local mat = tobool(toolObj:GetClientInfo("usenoise")) and toolObj.Preview or toolObj.PreviewMat

				render.MaterialOverride(mat)
				ent:DrawModel()
				render.MaterialOverride()
			end
		end
	end)
end

/*
	Holster
	Clear stored objects and reset state
*/

function TOOL:Holster()
	self:ClearObjects()
	self:SetStage(0)
	self:ReleaseGhostEntity()
end

/*
	Control Panel
*/
do
	local transformData = {
		scalex = 1,
		scaley = 1,
		offsetx = 0,
		offsety = 0,
		rotate = 0
	}

	function TOOL.BuildCPanel(CPanel)
		CPanel:AddControl("Header", {
			Description = "#tool.advmat.desc"
		})
		
		local warningH = CPanel:Help("FEATURES MARKED WITH RED TEXT DO NOT WORK OR ARE VERY BUGGY!")
		warningH:SetTextColor(Color(255, 0, 0))
		
		CPanel:NumSlider("#tool.advmat.submatid", "advmat_submatid", -1, 128, 0)
		CPanel:ControlHelp("Setting this to -1 will override all of the model's materials.")

		CPanel:TextEntry("#tool.advmat.texture", "advmat_texture")

		CPanel:NumSlider("#tool.advmat.scalex", "advmat_scalex", 0.01, 5, 2)
		CPanel:NumSlider("#tool.advmat.scaley", "advmat_scaley", 0.01, 5, 2)
		CPanel:NumSlider("#tool.advmat.offsetx", "advmat_offsetx", 0, 5, 2)
		CPanel:NumSlider("#tool.advmat.offsety", "advmat_offsety", 0, 5, 2)
		CPanel:NumSlider("#tool.advmat.rotate", "advmat_rotate", -180, 180, 2)

		local baseTextureReset = CPanel:Button("#tool.advmat.reset.base")

		function baseTextureReset:DoClick()
			for k, v in pairs(transformData) do
				LocalPlayer():ConCommand("advmat_" .. k:lower() .. " " .. v)
			end
		end

		CPanel:CheckBox("#tool.advmat.usenoise", "advmat_usenoise")
		CPanel:ControlHelp("If this box is checked, your material will be sharpened using an HD detail texture, specified below.")

		CPanel:TextEntry("#tool.advmat.noisetexture", "advmat_noisetexture")

		CPanel:NumSlider("#tool.advmat.scalex", "advmat_noisescalex", 0.01, 5, 2)
		CPanel:NumSlider("#tool.advmat.scaley", "advmat_noisescaley", 0.01, 5, 2)
		CPanel:NumSlider("#tool.advmat.offsetx", "advmat_noiseoffsetx", 0, 5, 2)
		CPanel:NumSlider("#tool.advmat.offsety", "advmat_noiseoffsety", 0, 5, 2)
		CPanel:NumSlider("#tool.advmat.rotate", "advmat_noiserotate", -180, 180, 2)

		local noiseTextureReset = CPanel:Button("#tool.advmat.reset.noise")

		function noiseTextureReset:DoClick()
			for k, v in pairs(transformData) do
				LocalPlayer():ConCommand("advmat_noise" .. k:lower() .. " " .. v)
			end
		end
		
		CPanel:CheckBox("#tool.advmat.usebump", "advmat_usebump")
		CPanel:ControlHelp("If this box is checked, your material will use the bumpmap texture specified by you below.")
		CPanel:TextEntry("#tool.advmat.bumptexture", "advmat_bumptexture")
			
		CPanel:CheckBox("#tool.advmat.uselightwarp", "advmat_uselightwarp")
		CPanel:ControlHelp("If this box ix checked, your material will use the lightwarp texture specified by you below.")
		CPanel:TextEntry("#tool.advmat.lightwarptexture", "advmat_lightwarptexture")
		
		CPanel:CheckBox("#tool.advmat.useenvmap", "advmat_useenvmap")
		CPanel:ControlHelp("If this box is checked, your material will use the envmap texture specified by you below.")
		CPanel:TextEntry("#tool.advmat.envmaptexture", "advmat_envmaptexture")
		CPanel:NumSlider("#tool.advmat.envmapcontrast", "advmat_envmapcontrast", 0, 1)
		CPanel:TextEntry("#tool.advmat.envmaptint", "advmat_envmaptint")
		CPanel:ControlHelp("Enter 3 numbers. They must be in the range of 0 to 1 and must be separated by commas.")
		
		local tscombox, tslab = CPanel:ComboBox("Tree Sway", "advmat_usetreesway")
		tscombox:AddChoice("None", 0)
		tscombox:AddChoice("Classic", 1)
		tscombox:AddChoice("Radial", 2)
		CPanel:ControlHelp("If enabled, your prop will sway according to the sway type.")
		
		local alphabox, alphalab = CPanel:ComboBox("Alpha Type", "advmat_alphatype")
		alphabox:AddChoice("None", 0)
		alphabox:AddChoice("AlphaTest", 1)
		alphabox:AddChoice("Vertex Alpha", 2)
		alphabox:AddChoice("Translucent", 3)
		CPanel:ControlHelp("Sets what type of alpha your prop should use if it has transparency in its base texture. If unsure, set to AlphaTest.")
		
		CPanel:CheckBox("#tool.advmat.nocull", "advmat_nocull")
		CPanel:ControlHelp("Prevents the backfaces of a prop from being culled. Useful for infinitely thin dual-sided objects, like foliage.")
		
		local phongCheckBox = CPanel:CheckBox("#tool.advmat.usephong", "advmat_usephong")
		phongCheckBox:SetTextColor(Color(255, 0, 0))
		CPanel:ControlHelp("If this box is checked, your material will use the phong shader, controlled by the settings below. REQUIRES BUMPMAP.")
		CPanel:NumSlider("#tool.advmat.phongboost", "advmat_phongboost", 0, 100)
		CPanel:TextEntry("#tool.advmat.phongfresnel", "advmat_phongfresnel")
		CPanel:ControlHelp("Enter 3 numbers with spaces in between. They must be enclosed in [] brackets.")
		
	end
end
/*
	Language strings
*/

if (CLIENT) then
	language.Add("tool.advmat.name", "Advanced Material 2")
	language.Add("tool.advmat.left", "Set material/Sub-material")
	language.Add("tool.advmat.right", "Copy material/Sub-material")
	language.Add("tool.advmat.reload", "Remove material/Sub-material")
	language.Add("tool.advmat.desc", "Use any material on any prop, with the ability to copy materials from the map.")
	language.Add("tool.advmat.texture", "Material to use")
	language.Add("tool.advmat.scalex", "Width Magnification")
	language.Add("tool.advmat.scaley", "Height Magnification")
	language.Add("tool.advmat.offsetx", "Horizontal Translation")
	language.Add("tool.advmat.offsety", "Vertical Translation")
	language.Add("tool.advmat.rotate", "Rotation")
	language.Add("tool.advmat.usenoise", "Use noise texture")
	language.Add("tool.advmat.submatid", "SubMaterial ID")
	
	language.Add("tool.advmat.nocull", "No Cull")

	language.Add("tool.advmat.noisetexture", "Detail Texture")

	language.Add("tool.advmat.reset.base", "Reset Texture Transformations")
	language.Add("tool.advmat.reset.noise", "Reset Noise Transformations")
	language.Add("tool.advmat.reset.bump", "Reset Bump Transformations")
	
	language.Add("tool.advmat.usebump", "Use custom bump texture")
	language.Add("tool.advmat.bumptexture", "Bump texture to use")
	
	language.Add("tool.advmat.uselightwarp", "Use custom lightwarp texture")
	language.Add("tool.advmat.lightwarptexture", "Lightwarp texture to use")
	
	language.Add("tool.advmat.useenvmap", "Use custom envmap texture")
	language.Add("tool.advmat.envmaptexture", "Envmap texture to use")
	language.Add("tool.advmat.envmapcontrast", "Envmap Contrast (DOESN'T WORK WITH PHONG)")
	language.Add("tool.advmat.envmaptint", "Envmap Tint (DOESN'T WORK WITH PHONG)")
	
	language.Add("tool.advmat.usephong", "Use phong")
	language.Add("tool.advmat.phongboost", "Phong Boost")
	language.Add("tool.advmat.phongfresnel", "Phong Fresnel Ranges")
end