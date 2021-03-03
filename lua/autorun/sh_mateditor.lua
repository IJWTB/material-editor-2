if (SERVER) then
	util.AddNetworkString("Materialize")
	util.AddNetworkString("advmat2_sendmatqueue")
	util.AddNetworkString("advmat2_readytoreceive")
end

advMats = advMats or {}
advMats.stored = advMats.stored or {}

function advMats:GetStored()
	return self.stored
end

function advMats:Set(ent, texture, data, submatid)
	if (SERVER) then
		local compresseddata = util.Compress(util.TableToJSON(data))
		local compressedlen = compresseddata:len()
		
		net.Start("Materialize")
		net.WriteEntity(ent)
		net.WriteString(texture)
		net.WriteUInt(compressedlen, 16)
		net.WriteData(compresseddata, compressedlen)
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
			PhongFresnel = data.PhongFresnel or "0, 0.5, 1",
			UseTreeSway = data.UseTreeSway or 0,
			TreeSwaySpeed = data.TreeSwaySpeed or 1,
			TreeSwayStrength = data.TreeSwayStrength or 0.1,
			TreeSwayStartHeight = data.TreeSwayStartHeight or 0.1,
			TreeSwayHeight = data.TreeSwayHeight or 300,
			TreeSwayStartRadius = data.TreeSwayStartRadius or 0.1,
			TreeSwayRadius = data.TreeSwayRadius or 100,
			TreeLeafSpeed = data.TreeLeafSpeed or 0.1,
			TreeLeafStrength = data.TreeLeafStrength or 0.1,
			AlphaType = data.AlphaType or 0,
			NoCull = data.NoCull or 0
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
		local uid = texture .. "+" .. (data.ScaleX or 1) .. "+" .. (data.ScaleY or 1) .. "+" .. (data.OffsetX or 0) .. "+" .. (data.OffsetY or 0) .. "+" .. (data.Rotate or 0) .. "+" .. (data.AlphaType or 0) .. "+" .. (data.NoCull or 0)

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
			uid = uid .. (data.PhongBoost or 1) .. "+" .. (fresnels or "[0 0.5 1]")
		end
		
		if	(data.UseTreeSway) then
			uid = uid .. (data.UseTreeSway) .. "+" .. (data.TreeSwaySpeed or 1) .. "+" .. (data.TreeSwayStrength or 0.1) .. "+" .. (data.TreeLeafSpeed or 0.1) .. "+" .. (data.TreeLeafStrength or 0.1) .. "+" .. (data.TreeSwayStartHeight or 0.1) .. "+" .. (data.TreeSwayHeight or 300) .. "+" .. (data.TreeSwayStartRadius or 0.1) .. "+" .. (data.TreeSwayRadius or 100)
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
		data.PhongFresnel = data.PhongFresnel or "0, 0.5, 1"
		data.UseTreeSway = data.UseTreeSway or 0
		data.TreeSwaySpeed = data.TreeSwaySpeed or 1
		data.TreeSwayStrength = data.TreeSwayStrength or 0.1
		data.TreeSwayStartHeight = data.TreeSwayStartHeight or 0.1
		data.TreeSwayHeight = data.TreeSwayHeight or 300
		data.TreeSwayStartRadius = data.TreeSwayStartRadius or 0.1
		data.TreeSwayRadius = data.TreeSwayRadius or 100
		data.TreeLeafSpeed = data.TreeLeafSpeed or 0.1
		data.TreeLeafStrength = data.TreeLeafStrength or 0.1
		data.AlphaType = data.AlphaType or 0
		data.NoCull = data.NoCull or 0

		texture = texture:lower()
		texture = string.Trim(texture)

		local tempMat = Material(texture)

		if (string.find(texture, "../", 1, true) or string.find(texture, "pp/", 1, true)) then
			return
		end

		local uid = texture .. "+" .. data.ScaleX .. "+" .. data.ScaleY .. "+" .. data.OffsetX .. "+" .. data.OffsetY .. "+" .. data.Rotate  .. "+" .. data.AlphaType .. "+" .. data.NoCull

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
		
		if	(data.UseTreeSway) then
			uid = uid .. (data.UseTreeSway) .. "+" .. data.TreeSwaySpeed .. "+" .. data.TreeSwayStrength .. data.TreeLeafSpeed .. "+" .. data.TreeLeafStrength .. "+" .. data.TreeSwayStartHeight .. "+" .. data.TreeSwayHeight .. "+" .. data.TreeSwayStartRadius .. "+" .. data.TreeSwayRadius
		end

		uid = uid:gsub("%.", "-")

		if (!self.stored[uid]) then

			local matTable = {
				["$basetexture"] = tempMat:GetName(),
				["$basetexturetransform"] = "center .5 .5 scale " .. (1 / data.ScaleX) .. " " .. (1 / data.ScaleY) .. " rotate " .. data.Rotate .. " translate " .. data.OffsetX .. " " .. data.OffsetY,
				["$model"] = 1
			}

			for k, v in pairs(data) do
				if (k:sub(1, 1) == "$") then
					matTable[k] = v
				end
			end
			
			local AlphaTypes = {
				[1] = "$alphatest",
				[2] = "$vertexalpha",
				[3] = "$translucent"
			}
			
			if (data.AlphaType > 0) then
				matTable[AlphaTypes[data.AlphaType]] = 1
			end
			
			if	(data.NoCull == 1) then
				matTable["$nocull"] = 1
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
			
			
			if (data.UsePhong) then
				if !string.find(tostring(data.PhongFresnel), ",") then 
					print("TRIED TO SET PHONG FRESNEL WITH INCORRECT VALUES, PLEASE CHECK YOUR VALUES") 
				return end
				
				local tintnumbers = tostring(data.PhongFresnel)
				tintnumbers = string.Replace(tintnumbers, " ", "")
				local tintexplo = string.Explode(",", tintnumbers)
				for _, v in pairs(tintexplo) do
					v = tonumber(v)
					v = math.Round(v, 2)
				end
				local phongactual = "[".. tintexplo[1] .. " " .. tintexplo[2] .. " " .. tintexplo[3] .. "]"
			
				matTable["$phong"] = 1
				matTable["$halflambert"] = 1 -- APPARENTLY THIS NEEDED TO BE INCLUDED FOR IT TO FUCKING WORK BUT NOO, WHY SHOULD THE VDC TELL ME THAT????
				matTable["$phongexponent"] = "0"
				matTable["$phongboost"] = data.PhongBoost
				matTable["$phongfresnelranges"] = phongactual
			end
			
			if(data.UseTreeSway > 0) then
				matTable["$treesway"] = data.UseTreeSway
				matTable["$treeSwaySpeed"] = data.TreeSwaySpeed
				matTable["$treeSwayStrength"] = data.TreeSwayStrength
				matTable["$treeSwayScrumbleSpeed"] = data.TreeLeafSpeed
				matTable["$treeSwayScrumbleStrength"] = data.TreeLeafStrength
				if data.UseTreeSway == 1 then
					matTable["$treeSwayHeight"] = data.TreeSwayHeight
					matTable["$treeSwayStartHeight"] = data.TreeSwayStartHeight
				elseif data.UseTreeSway == 2 then
					matTable["$treeSwayRadius"] = data.TreeSwayRadius
					matTable["$treeSwayStartRadius"] = data.TreeSwayStartRadius
				end
				
				matTable["$treeSwayStatic"] = 1 -- Only static treesway, cus I don't wanna deal with hundreds of parameters, that env_wind may or may not fuck up anyway.
				-- If $treeswaystaticvalues is added to gmod, put that in here
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
			texture 	= texture,
			SubMatID 	= submatid,
			ScaleX 		= data.ScaleX or 1,
			ScaleY 		= data.ScaleY or 1,
			OffsetX 	= data.OffsetX or 0,
			OffsetY 	= data.OffsetY or 0,
			Rotate 		= data.Rotate or 0,
			UseNoise 	= data.UseNoise or false,
			NoiseTexture = data.NoiseTexture or "",
			NoiseScaleX = data.NoiseScaleX or 1,
			NoiseScaleY = data.NoiseScaleY or 1,
			NoiseOffsetX = data.NoiseOffsetX or 0,
			NoiseOffsetY = data.NoiseOffsetY or 0,
			NoiseRotate = data.NoiseRotate or 0,
			UseBump 	= data.UseBump or false,
			BumpTexture = data.BumpTexture or "",
			UseLightwarp = data.UseLightwarp or false,
			LightwarpTexture = data.LightwarpTexture or "",
			UseEnvMap 	= data.UseEnvMap or false,
			EnvMapTexture = data.EnvMapTexture or "",
			EnvMapContrast = data.EnvMapContrast or 0.5,
			EnvMapTint 	= data.EnvMapTint or "1, 1, 1",
			UsePhong 	= data.UsePhong or false,
			PhongBoost 	= data.PhongBoost or 1,
			PhongFresnel = data.PhongFresnel or "0, 0.5, 1",
			UseTreeSway 	= data.UseTreeSway or 0,
			TreeSwaySpeed = data.TreeSwaySpeed or 1,
			TreeSwayStrength = data.TreeSwayStrength or 0.1,
			TreeSwayStartHeight = data.TreeSwayStartHeight or 0.1,
			TreeSwayHeight = data.TreeSwayHeight or 300,
			TreeSwayStartRadius = data.TreeSwayStartRadius or 0.1,
			TreeSwayRadius = data.TreeSwayRadius or 100,
			TreeLeafSpeed = data.TreeLeafSpeed or 0.1,
			TreeLeafStrength = data.TreeLeafStrength or 0.1,
			AlphaType = data.AlphaType or 0
		}
		if submatid == -1 and IsValid(ent) then
			ent:SetMaterial("!" .. uid)
		elseif submatid > -1  and IsValid(ent) then
			ent:SetSubMaterial(submatid, "!" .. uid)
		end
	end
end

if (CLIENT) then

	net.Receive("Materialize", function()
		local ent = net.ReadEntity()
		local texture = net.ReadString()
		local datalen = net.ReadUInt(16)
		local data = net.ReadData(datalen)
		local submatid = net.ReadInt(5)	
		
		if (!IsValid(ent)) then
			return -- ent isn't even valid, don't bother decompressing the data
		end
		
		local jsonuncompresseddata = util.JSONToTable(util.Decompress(data))
		advMats:Set(ent, texture, jsonuncompresseddata, submatid)
	end)
	
	hook.Add( "InitPostEntity", "advmat2_readytoreceivemats", function()
		net.Start( "advmat2_readytoreceive" )
		net.SendToServer()
	end )
	
	
	local jsonmatqueue = ""
	
	net.Receive("advmat2_sendmatqueue", function( len )
		local done = net.ReadBool()
		local data = net.ReadData(len - 8) -- the bool takes a byte, so the remainder of the bits must be the compressed data
		
		-- concatenate the data so far and check if we're done receiving it all
		jsonmatqueue = jsonmatqueue .. data
		
		if (!done) then
			return -- still receiving more incoming data
		end
		
		local matqueue = util.JSONToTable(util.Decompress(jsonmatqueue))
		local initcount = table.Count(matqueue)
		local percdone = 0
		
		jsonmatqueue = "" -- clear the jsonmatqueue now that we're done, just in case the client requests it again
		
		if table.Count(matqueue) > 0 then
			timer.Create("loadQueueMats", 0.1, table.Count(matqueue), function()
				notification.AddProgress("advmat2queue", "Requesting Materials: "..percdone.." of "..initcount, percdone / initcount)
				advMats:Set(Entity(table.maxn(matqueue)), matqueue[table.maxn(matqueue)].texture, matqueue[table.maxn(matqueue)], -1)
				matqueue[table.maxn(matqueue)] = nil
				percdone = percdone + 1
				
				if percdone >= initcount then
					notification.AddProgress("advmat2queue", "Material Requesting Complete!", 1)
					timer.Simple(3, function()
						notification.Kill("advmat2queue")
					end)
				end
				
			end)
		end
	end)
	
else

	net.Receive( "advmat2_readytoreceive", function(len, player)
		local matqueue = {}
		
		for k, v in ipairs(ents.GetAll()) do
			if (IsValid(v) and v["MaterialData-1"]) then
				matqueue[v:EntIndex()] = v["MaterialData-1"]
			end
		end
		
		if table.Count(matqueue) > 0 then
			local MAX_NET_BYTES = 65533 - 1 -- max data the net library can send per message, need 1 byte to send boolean indicating done or not
			
			local compressedjson = util.Compress(util.TableToJSON(matqueue))
			local compressedlen = compressedjson:len()
			local nummsgs = math.ceil(compressedlen / MAX_NET_BYTES)
			
			-- split the data in roughly 64kb chunks to ensure we don't surpass the net library limitations
			for k = 1, nummsgs do
				local lowerbound = ((k-1) * MAX_NET_BYTES) + 1
				local upperbound = k * MAX_NET_BYTES
				local subdata = string.sub(compressedjson, lowerbound, upperbound)
				
				net.Start("advmat2_sendmatqueue")
				net.WriteBool(k == nummsgs) -- 1 byte indicating if we're done yet
				net.WriteData(subdata, subdata:len())
				net.Send(player)
			end
		else
			print("Material Queue requested with empty queue?")
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
