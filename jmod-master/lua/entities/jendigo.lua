AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "The Ancient Wendigo"
ENT.Author = "Jackarunda"
ENT.Spawnable = false

-- we need to code this EXTRA defensively, because we don't want to generate any errors
-- that would ruin the secret

if (SERVER) then

	function ENT:Initialize()
		self:SetModel("models/ancient jendigo/ancient jendigo.mdl")
		self:PhysicsInit(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:DrawShadow(false)
	end

	function ENT:Think()
		local Time = CurTime()
		for k, ply in pairs(player.GetAll()) do
			if ((IsValid(ply)) and (ply:Alive()) and (math.random(1, 2) == 1)) then
				local wep = ply:GetActiveWeapon()
				if (IsValid(wep)) then
					if (wep:GetClass() == "gmod_camera") then
						self:SetPos(ply:GetShootPos() + ply:GetAimVector() * 500 + Vector(0, 0, 200))
					end
				end
			end
		end
		self:NextThink(Time + 1)
		return true
	end

elseif (CLIENT) then

	function ENT:Draw()
		if (ANCIENT_WENDIGO_DRAW_FRAMES > 0) then
			local ViewPos, ViewVec, ViewAng = EyePos(), EyeVector(), EyeAngles()
			ViewVec.z = 0
			ViewVec:Normalize()
			local Right = ViewAng:Right()

			local CheckPos = ViewPos + ViewVec * math.random(1000, 3000) + Vector(0, 0, 1000) + Right * math.random(-500, 500)
			
			local Tr = util.QuickTrace(CheckPos, Vector(0, 0, -2000))

			if ((Tr.Hit) and (Tr.HitWorld)) then
				self:SetRenderOrigin(Tr.HitPos)
				self:SetRenderAngles((-ViewVec):Angle())
				for i = 0, 58 do
					self:ManipulateBoneAngles(i, Angle(math.random(-3, 3), math.random(-3, 3), math.random(-3, 3)))
				end
				self:SetBodygroup(1, math.random(0, 2))
				self:SetBodygroup(2, math.random(0, 5))
				self:SetBodygroup(3, math.random(0, 1))
				-- 15 left arm, 33 right arm
				self:ManipulateBoneAngles(15, Angle(0, 0, 30))
				self:ManipulateBoneAngles(16, Angle(0, 40, 10))
				self:ManipulateBoneAngles(33, Angle(0, 0, 30))
				self:ManipulateBoneAngles(34, Angle(0, 40, 10))
				self:DrawModel()
				--[[
					for i = 0, 100 do
						print(i, self:GetBoneName(i))
					end
				--]]
			end

			ANCIENT_WENDIGO_DRAW_FRAMES = math.Clamp(ANCIENT_WENDIGO_DRAW_FRAMES - 1, 0, 10)
		end
	end

end
