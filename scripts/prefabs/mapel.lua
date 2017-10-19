local assets=
{
	Asset("ANIM", "anim/mapel.zip"),

	Asset("ATLAS", "images/inventoryimages/mapel.xml"),
	Asset("ATLAS", "images/inventoryimages/mapel_broken.xml"),
	Asset("ATLAS", "images/inventoryimages/mapel_charged.xml"),

	Asset("IMAGE","images/inventoryimages/mapel.tex"),
	Asset("IMAGE","images/inventoryimages/mapel_broken.tex"),
	Asset("IMAGE","images/inventoryimages/mapel_charged.tex"),
}

local prefabs = {
}

local function getStatus(inst)
    if inst.MapelState == "CHARGED"
        then
        if inst.components.inventoryitem.owner
            then
            return "CHARGED_POCKET"
        else
            return "CHARGED_GROUND"
        end
    elseif inst.MapelState == "BROKEN"
        then
        if inst.components.inventoryitem.owner
            then
            return "BROKEN_POCKET"
        else
            return "BROKEN_GROUND"
        end
    elseif inst.MapelState == "NORMAL"
        then
        if inst.components.inventoryitem.owner
            then
            return "NORMAL_POCKET"
        else
            return "NORMAL_GROUND"
        end
    end
end

local function updateState(inst)
		local anim = inst.entity:AddAnimState()
    local clock = GetWorld().components.clock
    if clock:GetMoonPhase() == "full" and inst.MapelState == "BROKEN" and clock:IsNight()
        then
        inst.MapelState = "CHARGED"
		    inst.components.inventoryitem.atlasname = "images/inventoryimages/mapel_charged.xml"
		    inst.components.inventoryitem.imagename = "mapel_charged"

		    anim:SetBank("mapel_charged") -- Bank name, within the scml
		    anim:SetBuild("mapel") -- Build name, as seen in anim folder
		    anim:PlayAnimation("idle")  -- Animation name
--[[]]
				if getStatus(inst) == "CHARGED_POCKET"
				then
					local player = GetPlayer()
					player.components.inventory:FindItem(function(item) return item.prefab=="mapel" end):Remove()
					player.components.inventory:GiveItem(SpawnPrefab("mapel"))
				end
    elseif inst.MapelState == "NORMAL"
        then
		    inst.components.inventoryitem.atlasname = "images/inventoryimages/mapel.xml"
		    inst.components.inventoryitem.imagename = "mapel"

		    anim:SetBank("mapel") -- Bank name, within the scml
		    anim:SetBuild("mapel") -- Build name, as seen in anim folder
		    anim:PlayAnimation("idle")  -- Animation name
    elseif inst.MapelState == "CHARGED"
        then
		    inst.components.inventoryitem.atlasname = "images/inventoryimages/mapel_charged.xml"
		    inst.components.inventoryitem.imagename = "mapel_charged"

		    anim:SetBank("mapel_charged") -- Bank name, within the scml
		    anim:SetBuild("mapel") -- Build name, as seen in anim folder
		    anim:PlayAnimation("idle")  -- Animation name
			else
        inst.MapelState = "BROKEN"
		    inst.components.inventoryitem.atlasname = "images/inventoryimages/mapel_broken.xml"
		    inst.components.inventoryitem.imagename = "mapel_broken"

		    anim:SetBank("mapel_broken") -- Bank name, within the scml
		    anim:SetBuild("mapel") -- Build name, as seen in anim folder
		    anim:PlayAnimation("idle")  -- Animation name
    end
end


local function updateActive(inst)
    inst.components.resurrector.used = false
    inst.components.resurrector.active = true
    if inst.components.resurrector.active then
        SaveGameIndex:RegisterResurrector(inst)
    else
        SaveGameIndex:DeregisterResurrector(inst)
    end
    inst.MapelState = "NORMAL"
    updateState(inst)
end

local function onDeath(inst, owner)
    if owner.components.health
    then
    --heal and set invincible for a short
				inst.MapelState = "BROKEN"
				updateState(inst)
        owner.components.health:Respawn(50)
        owner.components.health:SetInvincible(true)
        owner:DoTaskInTime(5,function()
            owner.components.health:SetInvincible(false)
        end)
				GetClock():MakeNextDay()

    --teleport
        local function getrandomposition(inst)
            local ground = GetWorld()
            local centers = {}
            for i,node in ipairs(ground.topology.nodes) do
                local tile = GetWorld().Map:GetTileAtPoint(node.x, 0, node.y)
                if tile and tile ~= GROUND.IMPASSABLE then
                    table.insert(centers, {x = node.x, z = node.y})
                end
            end
            if #centers > 0 then
                local pos = centers[math.random(#centers)]
                return Point(pos.x, 0, pos.z)
            else
                return GetPlayer():GetPosition()
            end
        end

        local function canteleport(inst, caster, target)
            if target then
                return target.components.locomotor ~= nil
            end

            return true
        end

        local function teleport_thread(inst, caster, teletarget)
            local ground = GetWorld()

            local t_loc = nil
            t_loc = getrandomposition()

            local teleportee = teletarget
            local pt = teleportee:GetPosition()
            if teleportee.components.locomotor then
                teleportee.components.locomotor:StopMoving()
            end

            if ground.topology.level_type == "cave" then
                TheCamera:Shake("FULL", 0.3, 0.02, .5, 40)
                ground.components.quaker:MiniQuake(3, 5, 1.5, teleportee)
                return
            end

            if teleportee.components.health then
                teleportee.components.health:SetInvincible(true)
            end
            teleportee:Hide()

            if teleportee == GetPlayer() then
                TheFrontEnd:Fade(false, 2)
                Sleep(3)
            end
            if ground.components.seasonmanager then
                ground.components.seasonmanager:ForcePrecip()
            end

            teleportee.Transform:SetPosition(t_loc.x, 0, t_loc.z)

            if teleportee == GetPlayer() then
                TheCamera:Snap()
                TheFrontEnd:DoFadeIn(1)
                Sleep(1)
            end

-- No lightning after tp --          GetSeasonManager():DoLightningStrike(t_loc)
            teleportee:Show()
            if teleportee.components.health then
                teleportee.components.health:SetInvincible(false)
            end

            if teleportee == GetPlayer() then
                teleportee.sg:GoToState("wakeup")
                teleportee.SoundEmitter:PlaySound("dontstarve/common/staffteleport")
            end
        end

        local function teleport_func(inst, target)
            local mindistance = 1
            local caster = inst.components.inventoryitem.owner
            local tar = target or caster
            local pt = tar:GetPosition()
            local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 9000, {"telebase"})

            if #ents <= 0 then
                --There's no bases, active or inactive. Teleport randomly.
                inst.task = inst:StartThread(function() teleport_thread(inst, caster, tar) end)
                return
            end

            local targets = {}
            for k,v in pairs(ents) do
                local v_pt = v:GetPosition()
                if distsq(pt, v_pt) >= mindistance * mindistance then
                    table.insert(targets, {base = v, distance = distsq(pt, v_pt)})
                end
            end

            table.sort(targets, function(a,b) return (a.distance) < (b.distance) end)
            for i = 1, #targets do
                local teletarget = targets[i]
                if teletarget.base and teletarget.base.canteleto(teletarget.base) then
                    inst.task = inst:StartThread(function()  teleport_thread(inst, caster, tar, teletarget.base) end)
                    return
                end
            end

            inst.task = inst:StartThread(function() teleport_thread(inst, caster, tar) end)
        end
				--TP disabled
        --teleport_func(inst, owner)

    end

    owner.sg:GoToState("hit") --anim stuff
    owner.SoundEmitter:PlaySound("dontstarve/characters/wx78/spark") --sound stuff

    --interface stuff
    TheCamera:SetDefault()
    if owner.HUD then
        owner.HUD:Show()
    end
    if owner.components.playercontroller then
        owner.components.playercontroller:Enable(true)
    end
end

local function toPocket(inst, owner)
    if GetPlayer().prefab ~= "wanda"
        then
        owner.components.inventory:DropEverything()
    end
		updateState(inst)
end

local function toGround(inst)
		if inst.MapelState == "CHARGED"
				then
				updateActive(inst)
		end
		updateState(inst)
end

local function Onsave(inst, data)
    data.MapelState = inst.MapelState
end

local function Onload(inst, data)

    if data and data.MapelState then
        if data.MapelState == "BROKEN" then
            inst.MapelState = "BROKEN"
        elseif data.MapelState == "CHARGED" then
            inst.MapelState = "CHARGED"
        elseif data.MapelState == "NORMAL" then
            inst.MapelState = "NORMAL"
        end
    end
end


local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    -- Check if Shipwrecked is enabled
    if IsDLCEnabled(CAPY_DLC) then
        -- Make floatable
        MakeInventoryFloatable(inst, "idle_water", "idle")
    end

    -- Prevents this item from being lost
    inst:AddTag("irreplaceable")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getStatus

    inst:AddComponent("inventoryitem")
		updateState(inst)
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.onpickupfn = toPocket
		inst.components.inventoryitem.ondroppedfn = toGround

    inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("wanda")

		local clock = GetWorld().components.clock
		if clock:GetMoonPhase() == "full" and clock:IsNight()
			then
				inst.MapelState = "CHARGED"
			else
		    inst.MapelState = "NORMAL"
		end

    inst.OnLoad = Onload
    inst.OnSave = Onsave

    inst:AddComponent("resurrector")
    inst.components.resurrector.used = false
    inst.components.resurrector.active = true
    inst.components.resurrector.doresurrect = onDeath

    if inst.components.resurrector.active then
        SaveGameIndex:RegisterResurrector(inst)
    else
        SaveGameIndex:DeregisterResurrector(inst)
    end

    inst:ListenForEvent("onputininventory", toPocket)
    inst:ListenForEvent("ondropped", toGround)
    inst:ListenForEvent("daytime", function() updateState(inst) end, GetWorld())
    inst:ListenForEvent("dusktime", function() updateState(inst) end, GetWorld())
    inst:ListenForEvent("nighttime", function() updateState(inst) end, GetWorld())
    return inst
end

return Prefab( "common/inventory/mapel", fn, assets)
