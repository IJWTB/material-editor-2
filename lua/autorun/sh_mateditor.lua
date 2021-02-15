if (SERVER) then
	util.AddNetworkString("Materialize")
end

advMats = advMats or {}
advMats.stored = advMats.stored or {}

function advMats:GetStored()
	return self.stored
end

function advMats:Set(ent, texture, data, submatid)
	if (SERVER) then
		local jsondata = util.TableToJSON(data, true)
		local compresseddata = serialize.Encode(jsondata) 	-- Convert to JSON and serialize the table into a string so we don't have to use the expensive net.WriteTable()
															-- Initially tried to use util.Compress and util.Decompress but that doesn't wanna play nice with net.WriteString() for some reason

		net.Start("Materialize")
		net.WriteEntity(ent)
		net.WriteString(texture)
		net.WriteString(compresseddata)
		net.WriteInt(submatid, 5)
		net.Broadcast()

		ent["MaterialData"..submatid] = {
			texture = texture,
			submatid = submatid,
			ScaleX = data.ScaleX or 1,
			ScaleY = data.ScaleY or 1,
			OffsetX = data.OffsetX or 0,
			OffsetY = data.OffsetY or 0,
			Rotate = data.Rotate or 0,
			UseNoise = data.UseNoise or false,
			NoiseTexture = data.NoiseTexture or "detail/noise_detail_01",
			NoiseScaleX = data.NoiseScaleX or 1,
			NoiseScaleY = data.NoiseScaleY or 1,
			NoiseOffsetX = data.NoiseOffsetX or 0,
			NoiseOffsetY = data.NoiseOffsetY or 0,
			NoiseRotate = data.NoiseRotate or 0,
			UseBump = data.UseBump or false,
			BumpTexture = data.BumpTexture or "",
			UseLightwarp = data.UseLightwarp or false,
			LightwarpTexture = data.LightwarpTexture or "",
			UseEnvMap = data.UseEnvMap or false,
			EnvMapTexture = data.EnvMapTexture or "",
			EnvMapContrast = data.EnvMapContrast or 0.5,
			EnvMapTint = data.EnvMapTint or "1, 1, 1",
			UsePhong = data.UsePhong or false,
			PhongBoost = data.PhongBoost or 1,
			PhongFresnel = data.PhongFresnel or "0 0.5 1"
		}

		if !ent.SubMaterialData then ent.SubMaterialData = {} end

		if (texture == nil or texture == "") then
			if (IsValid(ent)) then
				if submatid == -1 then
					ent:SetMaterial("")
					ent["MaterialData"..submatid] = nil -- clear the table so it doesn't get reapplied
					duplicator.ClearEntityModifier(ent, "MaterialData") -- clear modifier
				elseif submatid > -1 then
					ent:SetSubMaterial(submatid, "")
					ent["MaterialData"..submatid] = nil
					ent.SubMaterialData[submatid] = nil
					if table.Count(ent.SubMaterialData) > 0 then -- clear the modifier if there is no submat data
						duplicator.StoreEntityModifier(ent, "SubMaterialData", ent.SubMaterialData)
					else
						duplicator.ClearEntityModifier(ent, "SubMaterialData")
					end
				end


			end

			return
		end

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
		
		
		if submatid == -1 then
			ent:SetMaterial("!" .. uid)
			duplicator.StoreEntityModifier(ent, "MaterialData", ent["MaterialData"..submatid])
		elseif submatid > -1 then
			ent:SetSubMaterial(submatid, "!" .. uid)
			ent.SubMaterialData[submatid] = ent["MaterialData"..submatid]
			duplicator.StoreEntityModifier(ent, "SubMaterialData", ent.SubMaterialData)
		end
		
	else
		if (texture == nil or texture == "") then
			if (IsValid(ent)) then
				if submatid == -1 then
					ent:SetMaterial("")
				elseif submatid > -1 then
					ent:SetSubMaterial(data.SubMatID, "")
				end
			end

			return
		end

		data = data or {}
		data.SubMatID = data.SubMatID or -1
		data.UseNoise = data.UseNoise or false
		data.ScaleX = data.ScaleX or 1
		data.ScaleY = data.ScaleY or 1
		data.OffsetX = data.OffsetX or 0
		data.OffsetY = data.OffsetY or 0
		data.Rotate = data.Rotate or 0
		data.NoiseTexture = data.NoiseTexture or ""
		data.NoiseScaleX = data.NoiseScaleX or 1
		data.NoiseScaleY = data.NoiseScaleY or 1
		data.NoiseOffsetX = data.NoiseOffsetX or 0
		data.NoiseOffsetY = data.NoiseOffsetY or 0
		data.NoiseRotate = data.NoiseRotate or 0
		data.UseBump = data.UseBump or false
		data.BumpTexture = data.BumpTexture or ""
		data.UseLightwarp = data.UseLightwarp or false
		data.LightwarpTexture = data.LightwarpTexture or ""
		data.UseEnvMap = data.UseEnvMap or false
		data.EnvMapTexture = data.EnvMapTexture or ""
		data.EnvMapContrast = data.EnvMapContrast or 0.5
		data.EnvMapTint = data.EnvMapTint or "1, 1, 1"
		data.UsePhong = data.UsePhong or false
		data.PhongBoost = data.PhongBoost or 1
		data.PhongFresnel = data.PhongFresnel or "0 0.5 1"

		texture = texture:lower()
		texture = string.Trim(texture)

		local tempMat = Material(texture)

		if (string.find(texture, "../", 1, true) or string.find(texture, "pp/", 1, true)) then
			return
		end

		local uid = texture .. "+" .. data.ScaleX .. "+" .. data.ScaleY .. "+" .. data.OffsetX .. "+" .. data.OffsetY .. "+" .. data.Rotate

		if (data.UseNoise) then
			uid = uid .. (data.NoiseTexture or "detail/noise_detail_01") .. "+" .. (data.NoiseScaleX or 1) .. "+" .. (data.NoiseScaleY or 1) .. "+" .. (data.NoiseOffsetX or 0) .. "+" .. (data.NoiseOffsetY or 0) .. "+" .. (data.NoiseRotate or 0)
		end
		
		if(data.UseBump) then
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

		if (!self.stored[uid]) then

			local matTable = {
				["$basetexture"] = tempMat:GetName(),
				["$basetexturetransform"] = "center .5 .5 scale " .. (1 / data.ScaleX) .. " " .. (1 / data.ScaleY) .. " rotate " .. data.Rotate .. " translate " .. data.OffsetX .. " " .. data.OffsetY,
				["$vertexalpha"] = 0,
				["$vertexcolor"] = 1
			}

			for k, v in pairs(data) do
				if (k:sub(1, 1) == "$") then
					matTable[k] = v
				end
			end

			if (data.UseNoise) then
				matTable["$detail"] = data.NoiseTexture
			end
			

			if (file.Exists("materials/" .. texture .. "_normal.vtf", "GAME") and !data.UseBump) then
				matTable["$bumpmap"] = texture .. "_normal"
				matTable["$bumptransform"] = "center .5 .5 scale " .. (1 / data.ScaleX) .. " " .. (1 / data.ScaleY) .. " rotate 0 translate " .. data.OffsetX .. " " .. data.OffsetY
			elseif (data.UseBump) then
				matTable["$bumpmap"] = data.BumpTexture
			end
			
			if (data.UseEnvMap) then
				if !string.find(tostring(data.EnvMapTint), ",") then 
					print("TRIED TO SET ENV MAP WITH INCORRECT TINT VALUES, PLEASE CHECK YOUR TINT VALUES") 
				return end
				
				matTable["$envmap"] = data.EnvMapTexture
				matTable["$envmapcontrast"] = data.EnvMapContrast
				local tintnumbers = tostring(data.EnvMapTint)
				tintnumbers = string.Replace(tintnumbers, " ", "")
				local tintexplo = string.Explode(",", tintnumbers)
				for _, v in pairs(tintexplo) do
					v = tonumber(v)
					v = math.Round(v, 2)
				end
				local tintactual = "[".. tintexplo[1] .. " " .. tintexplo[2] .. " " .. tintexplo[3] .. "]"
				matTable["$envmaptint"] = tintactual
			end
			
			
			--Phong doesn't wanna work for some reason, makes props invisible. If anyone can help me fix this, it would be much appreciated.
			if (data.UsePhong) then
				matTable["$phong"] = "1"
				matTable["$phongexponent"] = "1"
				matTable["$phongboost"] = data.PhongBoost
				matTable["$phongfresnelranges"] = data.PhongFresnel
			end
			
			if (data.UseLightwarp) then
				matTable["$lightwarptexture"] = data.LightwarpTexture
			end

			local matrix = Matrix()
			matrix:Scale(Vector(1 / data.ScaleX, 1 / data.ScaleY, 1))
			matrix:Translate(Vector(data.OffsetX, data.OffsetY, 0))
			matrix:Rotate(Angle(0, data.Rotate, 0))

			local noiseMatrix = Matrix()
			noiseMatrix:Scale(Vector(1 / data.NoiseScaleX, 1 / data.NoiseScaleY, 1))
			noiseMatrix:Translate(Vector(data.NoiseOffsetX, data.NoiseOffsetY, 0))
			noiseMatrix:Rotate(Angle(0, data.NoiseRotate, 0))

			self.stored[uid] = CreateMaterial(uid, "VertexLitGeneric", matTable)
			self.stored[uid]:SetTexture("$basetexture", tempMat:GetTexture("$basetexture"))
			self.stored[uid]:SetMatrix("$basetexturetransform", matrix)
			self.stored[uid]:SetMatrix("$detailtexturetransform", noiseMatrix)
		end

		ent["MaterialData"..submatid] = {
			texture = texture,
			SubMatID = submatid,
			ScaleX = data.ScaleX or 1,
			ScaleY = data.ScaleY or 1,
			OffsetX = data.OffsetX or 0,
			OffsetY = data.OffsetY or 0,
			Rotate = data.Rotate or 0,
			UseNoise = data.UseNoise or false,
			NoiseTexture = data.NoiseTexture or "",
			NoiseScaleX = data.NoiseScaleX or 1,
			NoiseScaleY = data.NoiseScaleY or 1,
			NoiseOffsetX = data.NoiseOffsetX or 0,
			NoiseOffsetY = data.NoiseOffsetY or 0,
			NoiseRotate = data.NoiseRotate or 0,
			UseBump = data.UseBump or false,
			BumpTexture = data.BumpTexture or "",
			UseLightwarp = data.UseLightwarp or false,
			LightwarpTexture = data.LightwarpTexture or "",
			UseEnvMap = data.UseEnvMap or false,
			EnvMapTexture = data.EnvMapTexture or "",
			EnvMapContrast = data.EnvMapContrast or 0.5,
			EnvMapTint = data.EnvMapTint or "1, 1, 1",
			UsePhong = data.UsePhong or false,
			PhongBoost = data.PhongBoost or 1,
			PhongFresnel = data.PhongFresnel or "0 0.5 1",
		}
		if submatid == -1 then
			ent:SetMaterial("!" .. uid)
		elseif submatid > -1 then
			ent:SetSubMaterial(submatid, "!" .. uid)
		end
	end
end

if (CLIENT) then
	net.Receive("Materialize", function()
		local ent = net.ReadEntity()
		local texture = net.ReadString()
		local data = net.ReadString()
		local submatid = net.ReadInt(5)	
		local jsonuncompresseddata = util.JSONToTable(serialize.Decode(data))

		if (IsValid(ent)) then
			advMats:Set(ent, texture, jsonuncompresseddata, submatid)
		end
	end)
else
	hook.Add("PlayerInitialSpawn", "AdvMatSet", function(player)
		for k, v in pairs(ents.GetAll()) do
			if (IsValid(v) and v.MaterialData) then
				net.Start("Materialize")
				net.WriteEntity(v)
				net.WriteString(v.MaterialData.texture)
				net.WriteString(util.Compress(util.JSONToTable(v.MaterialData)))
				net.Send(player)
			end
		end
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
