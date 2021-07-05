AddCSLuaFile()


local disguiseList = {
	{"Drug Dealer","models/player/Kleiner.mdl"},
	{"Gun Dealer","models/player/monk.mdl"},
	{"Citizen","models/player/Group01/Female_01.mdl"},
	{"Civil Protection","models/player/Police.mdl"},
	{"Gangster","models/player/Group03/Female_01.mdl"},
	{"Hobo","models/player/corpse1.mdl"},
}

CreateConVar( "disguise_swep_time", 60, {FCVAR_ARCHIVE,FCVAR_REPLICATED}, "")
CreateConVar( "disguise_freeze_time", 5, {FCVAR_ARCHIVE,FCVAR_REPLICATED}, "")


if SERVER then

util.AddNetworkString( "use_agentweapon" )
util.AddNetworkString( "timer_agentweapon" )

net.Receive("use_agentweapon",function(len,ply)
	if not IsValid(ply) then return end
	if ply:GetActiveWeapon():GetClass() != "weapon_agent" then return end
	local num = net.ReadFloat()
	local model = disguiseList[num][2]
	local old = ply:GetModel()
	
	if model == nil then return end

	ply:GetActiveWeapon():SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	if ply:LookupBone("ValveBiped.Bip01_R_Foot") != nil then
		ParticleEffectAttach( "generic_smoke", 4, ply, ply:LookupBone("ValveBiped.Bip01_R_Foot") )
		ParticleEffectAttach( "generic_smoke", 4, ply, ply:LookupBone("ValveBiped.Bip01_L_Foot") )
		ParticleEffectAttach( "generic_smoke", 4, ply, ply:LookupBone("ValveBiped.Bip01_R_Foot") )	
	end
	ply:Freeze(true)
	timer.Simple(GetConVar("disguise_freeze_time"):GetFloat(),function()
		if IsValid(ply) then
			ply:SetModel(model)
			ply:StopParticles()
			ply:SetNWBool("istransformed",true)
			ply:Freeze(false)
			
			net.Start("timer_agentweapon") net.WriteString(model) net.Send(ply)
			
			
			
			ply:StripWeapon("weapon_agent")
				
				timer.Simple(GetConVar("disguise_swep_time"):GetFloat(),function()
				if ply:GetNWBool("istransformed") == false then return end
					if ply:LookupBone("ValveBiped.Bip01_R_Foot") != nil then
						ParticleEffectAttach( "generic_smoke", 4, ply, ply:LookupBone("ValveBiped.Bip01_R_Foot") )
						ParticleEffectAttach( "generic_smoke", 4, ply, ply:LookupBone("ValveBiped.Bip01_L_Foot") )
						ParticleEffectAttach( "generic_smoke", 4, ply, ply:LookupBone("ValveBiped.Bip01_R_Foot") )	
					end
					ply:Freeze(true)
					timer.Simple(GetConVar("disguise_freeze_time"):GetFloat(),function()
					ply:SetModel(old)
					ply:SetNWBool("istransformed",false)
					ply:Give("weapon_agent")
					
					ply:Freeze(false)
				
					
					end)
					
				
				end)
			
			
		end
	end)
	
	
	


end)


end





SWEP.PrintName			= "Advanced Diguise Swep" 
SWEP.Author			= "g_o_r_k_e_m" 
SWEP.Instructions		= "Use this tool to disguise as any job you want "
SWEP.Spawnable = true
SWEP.Category = "Gorkem"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo		= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"



SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = false
SWEP.ViewModel = "models/weapons/v_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {}




SWEP.VElements = {
	["screen"] = { type = "Quad", bone = "v_weapon.c4", rel = "", pos = Vector(2.786, 0.390, 8.5), angle = Angle(174.967, 3.197, -46.361), size = 1, draw_func = nil}
}


if CLIENT then



	 surface.CreateFont( "disguisekitface1", {
		font = DermaDefault,
		size = ScreenScale(10),
		weight = 100
	})
	 
	function SWEP:DrawHUD() 
		draw.DrawText("You are currently seen as a "..LocalPlayer():getDarkRPVar("job")..".","disguisekitface1",ScrW()/2,(250/4),Color(248,42,74),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	end



	-- Legit just derma

	 surface.CreateFont( "disguisekitfont1", {
		font = DermaDefault,
		size = ScreenScale(6),
		weight = 100
	})
	 


	local drawBorder = function(x,y,w,h,size,color)
		draw.RoundedBox(0,x,y,w,size,color)
		draw.RoundedBox(0,x,y,size,h,color)
		draw.RoundedBox(0,w-size,y,size,h,color)
		draw.RoundedBox(0,x,h-size,w,size,color)
	end
end












function SWEP:Initialize()
self:SetHoldType( "slam" )
	// other initialize code goes here

	if CLIENT then
	

		// Create a new table for every weapon instance
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements) // create viewmodels
		self:CreateModels(self.WElements) // create worldmodels
		
		// init view model bone build function
		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				
				// Init viewmodel visibility
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					// we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
					vm:SetColor(Color(255,255,255,1))
					// ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
					// however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
					vm:SetMaterial("Debug/hsv")			
				end
			end
		end
		
	end

end

function SWEP:Holster()
	
	if CLIENT and IsValid(self.Owner) then
		local vm = self.Owner:GetViewModel()
		if IsValid(vm) then
			self:ResetBonePositions(vm)
		end
	end
	
	return true
end

function SWEP:OnRemove()
	self:Holster()
end

if CLIENT then

	function DisguiseMenu()
	
	 local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW()*0.45, ScrH()*0.3)
    frame:SetTitle("")
    frame:SetVisible(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame:Center()
    frame.Paint = function(self, w, h)
    	draw.RoundedBox(3,0,0,w,h,Color(32,33,40))
    	draw.RoundedBoxEx(3,0,0,w,30,Color(248,42,74),true,true,false,false)
    end
    scrollDis = vgui.Create("DScrollPanel",frame)
    scrollDis:SetSize(frame:GetWide()-15,frame:GetTall()-60)
    scrollDis:SetPos(15,45)
    scrollDis.Paint = function() return false end
    scrollDis:GetVBar().Paint = function() return false end
    scrollDis:GetVBar().btnUp.Paint = function() return false end
    scrollDis:GetVBar().btnDown.Paint = function() return false end 
    scrollDis:GetVBar().btnGrip.Paint = function() return false end


    scrollLay = vgui.Create("DIconLayout",scrollDis)
    scrollLay:SetPos(0,0)
    scrollLay:SetSize(scrollDis:GetWide(),scrollDis:GetTall())
    scrollLay:SetSpaceY(16) 
	scrollLay:SetSpaceX(16)
	for k,v in pairs(disguiseList) do
		local disItem = scrollLay:Add( "DPanel",scrollLay) 
		disItem:SetSize(scrollLay:GetWide()/3-16, scrollLay:GetTall()/2-8) 
		disItem.Paint = function(self,w,h)
			draw.DrawText("Disguise as a","disguisekitfont1",w/1.5,h/4,Color(248,42,74),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
			draw.DrawText(v[1],"disguisekitfont1",w/1.5,h/4+draw.GetFontHeight("disguisekitfont1"),Color(248,42,74),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
		local disModel = vgui.Create("DModelPanel",disItem)
		disModel:SetPos(3,3)
		disModel:SetSize(disItem:GetWide()/2,disItem:GetTall()-6)
		disModel:SetModel(v[2])
		disModel:SetLookAt(disModel.Entity:GetBonePosition( disModel.Entity:LookupBone( "ValveBiped.Bip01_Head1")))
		disModel:SetCamPos(disModel.Entity:GetBonePosition( disModel.Entity:LookupBone( "ValveBiped.Bip01_Head1"))-Vector(-15, 0, 0 ))	-- Move cam in front of eyes
		disModel.Entity:SetEyeTarget(disModel.Entity:GetBonePosition( disModel.Entity:LookupBone( "ValveBiped.Bip01_Head1" ) )-Vector(-12, 0, 0 ))
		function disModel:LayoutEntity(ent) end
		local circleLerp = 0
		local circleLerpTo = 0
		local disButton = vgui.Create("DButton",disItem)
		disButton:SetPos(0,0)
		disButton:SetSize(disItem:GetSize())
		disButton:SetText("")
		disButton.Paint = function(self,w,h)
		end 
		disButton.DoClick = function()
			net.Start("use_agentweapon")
			net.WriteFloat(k)
			net.SendToServer()
			frame:Close()
		end
	end
	local closeButton = vgui.Create("DButton",frame)
	closeButton:SetPos(frame:GetWide()-40,7.5)
	closeButton:SetSize(30,15)
	closeButton:SetText("")
	closeButton.Paint = function(self,w,h) draw.RoundedBox(0,0,0,w,h,Color(32,33,40)) draw.SimpleText("X","disguisekitfont1",15,7.5,Color(248,42,74),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
	closeButton.DoClick= function() frame:Remove() end
end

	function SWEP:SecondaryAttack()
		if IsFirstTimePredicted() then
		DisguiseMenu()
		end
	end
		
	function SWEP:PrimaryAttack()
		if IsFirstTimePredicted() then
		DisguiseMenu()
		end
	end
		

		
	
	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		
		if (!self.WElements) then return end
		
		if (!self.wRenderOrder) then

			self.wRenderOrder = {}

			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end

		end
		
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			// when the weapon is dropped
			bone_ent = self
		end
		
		for k, name in pairs( self.wRenderOrder ) do
		
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end
			
			local pos, ang
			
			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end
			
			if (!pos) then continue end
			
			local model = v.modelEnt
			local sprite = v.spriteMaterial
			
			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )
				
				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end
				
				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end
				
				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end
				
				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)
				
				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
				
			elseif (v.type == "Sprite" and sprite) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				render.SetMaterial(sprite)
				render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
				
			elseif (v.type == "Quad" ) then
				
				local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
				cam.Start3D2D(drawpos, ang, 0.1)

				cam.End3D2D()

			end
			
		end
		
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )
		
		local bone, pos, ang
		if (tab.rel and tab.rel != "") then
			
			local v = basetab[tab.rel]
			
			if (!v) then return end
			
			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )
			
			if (!pos) then return end
			
			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				
		else
		
			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end
			
			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end
			
			if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end
		
		end
		
		return pos, ang
	end

	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and 
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then
				
				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
				
			elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite) 
				and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then
				
				local name = v.sprite.."-"
				local params = { ["$basetexture"] = v.sprite }
				// make sure we create a unique name based on the selected options
				local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
				for i, j in pairs( tocheck ) do
					if (v[j]) then
						params["$"..j] = 1
						name = name.."1"
					else
						name = name.."0"
					end
				end

				v.createdSprite = v.sprite
				v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
				
			end
		end
		
	end
	
	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)
		
		if self.ViewModelBoneMods then
			
			if (!vm:GetBoneCount()) then return end
			
			// !! WORKAROUND !! //
			// We need to check all model names :/
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then 
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = { 
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end
				
				loopthrough = allbones
			end
			// !! ----------- !! //
			
			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end
				
				// !! WORKAROUND !! //
				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end
				
				s = s * ms
				// !! ----------- !! //
				
				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end
		   
	end
	 
	function SWEP:ResetBonePositions(vm)
		
		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end
		
	end

	/**************************
		Global utility code
	**************************/

	// Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
	// Does not copy entities of course, only copies their reference.
	// WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
	function table.FullCopy( tab )

		if (!tab) then return nil end
		
		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end
		
		return res
		
	end
	
end
