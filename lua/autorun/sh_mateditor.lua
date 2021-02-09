if (SERVER) then
	util.AddNetworkString("Materialize")
	util.AddNetworkString("RequestMaterials")
	util.AddNetworkString("SendMaterials")
end

file.CreateDir("advmat2cache")

advMats = advMats or {}
advMats.stored = advMats.stored or {}

function advMats:GetStored()
	return self.stored
end

function advMats:Set(ent, texture, data, submatid)
		local texture = texture
		local submatid = submatid
		local ScaleX = data.ScaleX or 1
		local ScaleY = data.ScaleY or 1
		local OffsetX = data.OffsetX or 0
		local OffsetY = data.OffsetY or 0
		local Rotate = data.Rotate or 0
		local UseNoise = data.UseNoise or false
		local NoiseTexture = data.NoiseTexture or "detail/noise_detail_01"
		local NoiseScaleX = data.NoiseScaleX or 1
		local NoiseScaleY = data.NoiseScaleY or 1
		local NoiseOffsetX = data.NoiseOffsetX or 0
		local NoiseOffsetY = data.NoiseOffsetY or 0
		local NoiseRotate = data.NoiseRotate or 0
		local UseBump = data.UseBump or false
		local BumpTexture = data.BumpTexture or ""
		local BumpScaleX = data.BumpScaleX or 1
		local BumpScaleY = data.BumpScaleY or 1
		local BumpOffsetX = data.BumpOffsetX or 0
		local BumpOffsetY = data.BumpOffsetY or 0
		local UseLightwarp = data.UseLightwarp or false
		local LightwarpTexture = data.LightwarpTexture or ""
		local UseEnvMap = data.UseEnvMap or false
		local EnvMapTexture = data.EnvMapTexture or ""
		local EnvMapContrast = data.EnvMapContrast or 0.5
		local EnvMapTint = data.EnvMapTint or "1, 1, 1"
		local UsePhong = data.UsePhong or false
		local PhongBoost = data.PhongBoost or 1
		local PhongFresnel = data.PhongFresnel or "0 0.5 1"
			
			
			texture = texture:lower()
			texture = string.Trim(texture)
			local uid = texture .. "+" .. (data.ScaleX or 1) .. "+" .. (data.ScaleY or 1) .. "+" .. (data.OffsetX or 0) .. "+" .. (data.OffsetY or 0) .. "+" .. (data.Rotate or 0)

			if (data.UseNoise) then
				uid = uid .. (data.NoiseTexture or "detail/noise_detail_01") .. "+" .. (data.NoiseScaleX or 1) .. "+" .. (data.NoiseScaleY or 1) .. "+" .. (data.NoiseOffsetX or 0) .. "+" .. (data.NoiseOffsetY or 0) .. "+" .. (data.NoiseRotate or 0)
			end
			
			if (data.UseBump) then
				uid = uid .. (data.BumpTexture)
			end
			
			if (data.UseLightwarp) then
				uid = uid .. (data.LightwarpTexture)
			end
			
			if (data.UseEnvMap) then
				local tint = tostring(data.EnvMapTint)
				string.Replace(tint, " ", "")
				uid = uid .. (data.EnvMapTexture) .. "+" .. (data.EnvMapContrast) .. "+" .. (tint)
			end
			
			if (data.UsePhong) then
				local fresnels = tostring(data.PhongFresnel)
				string.Replace(fresnels, " ", "")
				uid = uid .. (data.PhongBoost) .. "+" .. (fresnels)
			end

			uid = uid:gsub("%.", "-")
			uid = uid:gsub("/", "-")
			
			if !file.Exists("advmat2cache/"..uid..".vmt", "DATA") then
				
				--Time for some crappy formatting
				--Always new line when adding new parameter, as vmts require an empty new line at the end for some reason.

				
				local fileToWrite = [[
"VertexLitGeneric"
{
	"$baseTexture " ]] .. texture .. "\n" .. [[
	"$basetexturetransform " ]] .. "center .5 .5 scale " .. ScaleX .. " " .. ScaleY .. " rotate " .. Rotate .. " translate " .. OffsetX .. " " .. OffsetY .. "\n" .. [[
	"$bumpmap " ]] .. BumpTexture .. "\n" .. [[
	"$detail " ]] .. NoiseTexture .. "\n" .. [[
	"$detailtexturetransform " ]] .. "center .5 .5 scale " .. NoiseScaleX .. " " .. NoiseScaleY .. " rotate " .. NoiseRotate .. " translate " .. NoiseOffsetX .. " " .. NoiseOffsetY .. "\n" .. [[
	"$lightwarptexture " ]] .. LightwarpTexture .. "\n" .. [[
	"$envmap " ]] .. EnvMapTexture .. "\n" .. [[
	"$envmapcontrast " ]] .. EnvMapContrast .. "\n" .. [[
	"$envmaptint " ]] .. "[1 1 1]" .. "\n" .. [[

}
]]

				file.Write("advmat2cache/"..uid..".vmt", fileToWrite)

					if submatid == -1 then
						ent:SetMaterial("../data/advmat2cache/"..uid..".vmt")
					else
						ent:SetSubMaterial(submatid, "../data/advmat2cache/"..uid..".vmt")
					end
			
			else
			
			
					if submatid == -1 then
						ent:SetMaterial("../data/advmat2cache/"..uid..".vmt")
					else
						ent:SetSubMaterial(submatid, "../data/advmat2cache/"..uid..".vmt")
					end
				
			end


			ent["MaterialFilename"] = uid

end

if (CLIENT) then

	local matqueue = {}

	net.Receive("Materialize", function()
		local ent = net.ReadEntity()
		local texture = net.ReadString()
		local data = net.ReadTable()
		local submatid = net.ReadInt(32)

		if (IsValid(ent)) then
			advMats:Set(ent, texture, data, submatid)
		end
	end)
	
	hook.Add("PlayerInitialSpawn", "AdvMatSet", function(player)
		for k, v in pairs(ents.GetAll()) do
			if (IsValid(v) and v.MaterialFilename) then
				if !file.Exists("advmat2cache/"..v.MaterialFilename..".vmt") then
					table.insert(matqueue, v)
				end
			end
			
			net.Start("RequestMaterials")
			net.WriteEntity(player)
			net.WriteTable(matqueue)
			net.SendToServer()
			
			table.Empty(matqueue)
			
		end
	end)
	
	net.Receive("SendMaterials", function(data)
		data = net.ReadTable()
		
		for k, v in pairs(data) do
			file.Write("advmat2cache/"..k..".vmt", v)
		end
		
		for k, v in pairs(ents.GetAll()) do
			if (IsValid(v) and v.MaterialFilename) then
				v:SetMaterial(v.MaterialFilename)
			end
		end
		
	end)
	
else
	
	net.Receive("RequestMaterials", function(player, data)
	
		player = net.ReadEntity()
		data = net.ReadTable()
		
		local matstosend = {}
		
		for k, v in pairs(data) do
			matstosend[v] = file.Read("advmat2cache/"..v..".vmt", "DATA")
		end
		
		net.Start("SendMaterials")
		net.WriteTable(matstosend)
		net.Send(player)
	
	end)
	
end

duplicator.RegisterEntityModifier("MaterialData", function(player, entity, data)
	advMats:Set(entity, data.texture, data, -1)
end)

duplicator.RegisterEntityModifier("SubMaterialData", function(player, entity, data)
	for subid, matdata in pairs (data) do
		advMats:Set(entity, matdata.texture, matdata, subid)
	end
end)
