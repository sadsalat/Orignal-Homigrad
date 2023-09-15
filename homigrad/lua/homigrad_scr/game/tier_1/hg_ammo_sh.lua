
local ammotypes = {
    ["556x45mm"] = {
        name = "5.56x45 mm",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 200,
        maxcarry = 120,
        minsplash = 10,
        maxsplash = 5
    },

    ["762x39mm"] = {
        name = "7.62x39 mm",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 400,
        maxcarry = 120,
        minsplash = 10,
        maxsplash = 5
    },

    ["545×39mm"] = {
        name = "5.45x39 mm",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 160,
        maxcarry = 120,
        minsplash = 10,
        maxsplash = 5
    },

    ["12/70gauge"] = {
        name = "12/70 gauge",
        dmgtype = DMG_BUCKSHOT, 
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 350,
        maxcarry = 46,
        minsplash = 10,
        maxsplash = 5
    },

    ["12/70beanbag"] = {
        name = "12/70 beanbag",
        dmgtype = DMG_BUCKSHOT, 
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 350,
        maxcarry = 46,
        minsplash = 10,
        maxsplash = 5
    },

    ["9х19mm"] = {
        name = "9х19 mm Parabellum",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 100,
        maxcarry = 80,
        minsplash = 10,
        maxsplash = 5
    },

    [".45rubber"] = {
        name = ".45 Rubber",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 100,
        maxcarry = 80,
        minsplash = 10,
        maxsplash = 5
    },

    ["46×30mm"] = {
        name = "4.6×30 mm",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 100,
        maxcarry = 120,
        minsplash = 10,
        maxsplash = 5
    },
    
    ["57×28mm"] = {
        name = "5.7×28 mm",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 100,
        maxcarry = 150,
        minsplash = 10,
        maxsplash = 5
    },

    [".44magnum"] = {
        name = ".44 Remington Magnum",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 100,
        maxcarry = 150,
        minsplash = 10,
        maxsplash = 5
    },

    ["9x39mm"] = {
        name = "9x39 mm",
        dmgtype = DMG_BULLET, 
        tracer = TRACER_LINE,
        plydmg = 0,
        npcdmg = 0,
        force = 100,
        maxcarry = 150,
        minsplash = 10,
        maxsplash = 5
    },
}

local ammoents = {
    ["556x45mm"] = {
        Material = "models/hmcd_ammobox_556",
        Scale = 1.2
    },

    ["762x39mm"] = {
        Material = "mmodels/hmcd_ammobox_792",
        Scale = 1,
        Color = Color(95,95,95)
    },

    ["545×39mm"] = {
        Material = "mmodels/hmcd_ammobox_792",
        Scale = 0.8,
        Color = Color(125,155,95)
    },

    ["12/70gauge"] = {
        Material = "models/hmcd_ammobox_12",
        Scale = 1.1,
    },

    ["12/70beanbag"] = {
        Material = "models/hmcd_ammobox_12",
        Scale = 0.9,
        Color = Color(255,155,55)
    },

    ["9х19mm"] = {
        Material = "models/hmcd_ammobox_9",
        Scale = 0.8,
    },

    [".45rubber"] = {
        Material = "models/hmcd_ammobox_38",
        Scale = 0.8,
    },

    ["46×30mm"] = {
        Material = "models/hmcd_ammobox_22",
        Scale = 1,
    },

    [".44magnum"] = {
        Material = "models/hmcd_ammobox_22",
        Scale = 0.8,
    },

    ["9x39mm"] = {
        Material = "models/hmcd_ammobox_9",
        Scale = 0.9,
        Color = Color(125,155,95)
    },
    
    ["57×28mm"] = {
        Material = "models/hmcd_ammobox_22",
        Scale = 1.2,
        Color = Color(125,155,95)
    },
}

print("yea!")
for k,v in pairs(ammotypes) do
    --PrintTable(v)
    game.AddAmmoType( v )
    if CLIENT then
        language.Add(v.name.."_ammo", v.name)
    end
    timer.Simple(1,function()
    local ammoent = {} 
    ammoent.Base = "ammo_base"
    ammoent.PrintName = v.name
    ammoent.Category = "Патроны"
    ammoent.Spawnable = true
    ammoent.AmmoCount = 10
    ammoent.AmmoType = v.name
    ammoent.ModelMaterial = ammoents[k].Material
    ammoent.ModelScale = ammoents[k].Scale
    ammoent.Color = ammoents[k].Color or nil

    scripted_ents.Register( ammoent, "ent_ammo_"..k )
    end)
end

timer.Simple(1,function()
    game.BuildAmmoTypes()
    PrintTable(game.GetAmmoTypes())
end)

if CLIENT then
    function AmmoMenu(ply)
        local ammodrop = 0
        if !ply:Alive() then return end
        local Frame = vgui.Create( "DFrame" )
        Frame:SetTitle( "Амуниция" )
        Frame:SetSize( 200,300 )
        Frame:Center()			
        Frame:MakePopup()
        Frame.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
            draw.RoundedBox( 5, 0, 0, w, h, Color( 115, 115, 115 ) )
            draw.RoundedBox( 2, 0, 0, w, 25, Color( 95, 95, 95 ) )
            draw.RoundedBox( 2, 0, 268, w, h, Color( 95, 95, 95 ) ) -- Draw a red box instead of the frame
        end
        local DPanel = vgui.Create( "DScrollPanel", Frame )
        DPanel:SetPos( 5, 30 ) -- Set the position of the panel
        DPanel:SetSize( 190, 215 ) -- Set the size of the panel
        DPanel.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
            draw.RoundedBox( 0, 0, 0, w, h, Color( 175, 175, 175 ) )
        end

        local sbar = DPanel:GetVBar()
        function sbar:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(115, 115, 115))
        end
        function sbar.btnUp:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(145, 145, 145))
        end
        function sbar.btnDown:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(145, 145, 145))
        end
        function sbar.btnGrip:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(195, 195, 195))
        end


        local DermaNumSlider = vgui.Create( "DNumSlider", Frame )
        DermaNumSlider:SetPos( 10, 245 )				
        DermaNumSlider:SetSize( 210, 25 )			
        DermaNumSlider:SetText( "Кол-во" )	
        DermaNumSlider:SetMin( 0 )				 	
        DermaNumSlider:SetMax( 60 )				
        DermaNumSlider:SetDecimals( 0 )				

        -- If not using convars, you can use this hook + Panel.SetValue()
        DermaNumSlider.OnValueChanged = function( self, value )
            ammodrop = math.Round(value)
        end 

        local ammos = LocalPlayer():GetAmmo()
        for k,v in pairs(ammos) do
            local DermaButton = vgui.Create( "DButton", DPanel ) 
            DermaButton:SetText( game.GetAmmoName( k )..": "..v )					
            DermaButton:SetPos( 0, 0 )	
            DermaButton:Dock( TOP )
            DermaButton:DockMargin( 5, 5, 5, 0 )				
            DermaButton:SetSize( 120, 20 )	
            DermaButton.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
                draw.RoundedBox( 0, 0, 0, w, h, Color( 225, 225, 225 ) )
            end				
            DermaButton.DoClick = function()
                --print( math.min(ammodrop,v),game.GetAmmoName( k ))				
                net.Start( "drop_ammo" )
                    net.WriteFloat( k )
                    net.WriteFloat( math.min(ammodrop,v) )
                net.SendToServer()
                Frame:Close()
            end

            DermaButton.DoRightClick = function()
                net.Start( "drop_ammo" )
                    net.WriteFloat( k )
                    net.WriteFloat( math.min(v,v) )
                net.SendToServer()
                Frame:Close()	
            end
        end
        local DLabel = vgui.Create( "DLabel", Frame )
        DLabel:SetPos( 10, 270 )
        DLabel:SetText( "ЛКМ - Скинуть Кол-во\nПКМ - Скинуть все" )
        DLabel:SizeToContents()

    end

    concommand.Add( "hg_ammomenu", function( ply, cmd, args )
        AmmoMenu(ply)
    end )
end

local ammolistent = {
    [38] = ".44magnum",
    [39] = ".45rubber",
    [40] = "12/70beanbag",
    [41] = "12/70gauge",
    [42] = "46×30mm",
    [44] = "545×39mm",
    [45] = "556x45mm",
    [46] = "57×28mm",
    [47] = "762x39mm",
    [48] = "9x39mm",
    [49] = "9х19mm"
}

if SERVER then
    util.AddNetworkString( "drop_ammo" )

    net.Receive( "drop_ammo", function( len, ply )
        if !ply:Alive() or ply.Otrub then return end
        local ammotype = net.ReadFloat()
        local count = net.ReadFloat()
        local pos = ply:EyePos()+ply:EyeAngles():Forward()*15
        if ply:GetAmmoCount(ammotype)-count < 0 then ply:ChatPrint("У тебя столько нет пулек") return end
        if count < 1 then ply:ChatPrint("Ноль пулек не скинуть") return end
        if not ammolistent[ammotype] then ply:ChatPrint("Нету ентити этих патрон...") return end
        local AmmoEnt = ents.Create( "ent_ammo_"..ammolistent[ammotype] )
        AmmoEnt:SetPos( pos )
        AmmoEnt:Spawn()
        AmmoEnt.AmmoCount = count
        ply:SetAmmo(ply:GetAmmoCount(ammotype)-count,ammotype)
        ply:EmitSound("snd_jack_hmcd_ammobox.wav", 75, math.random(80,90), 1, CHAN_ITEM )
    end)
end
