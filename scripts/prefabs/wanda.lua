
local MakePlayerCharacter = require "prefabs/player_common"


local assets = {

        Asset( "ANIM", "anim/player_basic.zip" ),
        Asset( "ANIM", "anim/player_idles_shiver.zip" ),
        Asset( "ANIM", "anim/player_actions.zip" ),
        Asset( "ANIM", "anim/player_actions_axe.zip" ),
        Asset( "ANIM", "anim/player_actions_pickaxe.zip" ),
        Asset( "ANIM", "anim/player_actions_shovel.zip" ),
        Asset( "ANIM", "anim/player_actions_blowdart.zip" ),
        Asset( "ANIM", "anim/player_actions_eat.zip" ),
        Asset( "ANIM", "anim/player_actions_item.zip" ),
        Asset( "ANIM", "anim/player_actions_uniqueitem.zip" ),
        Asset( "ANIM", "anim/player_actions_bugnet.zip" ),
        Asset( "ANIM", "anim/player_actions_fishing.zip" ),
        Asset( "ANIM", "anim/player_actions_boomerang.zip" ),
        Asset( "ANIM", "anim/player_bush_hat.zip" ),
        Asset( "ANIM", "anim/player_attacks.zip" ),
        Asset( "ANIM", "anim/player_idles.zip" ),
        Asset( "ANIM", "anim/player_rebirth.zip" ),
        Asset( "ANIM", "anim/player_jump.zip" ),
        Asset( "ANIM", "anim/player_amulet_resurrect.zip" ),
        Asset( "ANIM", "anim/player_teleport.zip" ),
        Asset( "ANIM", "anim/wilson_fx.zip" ),
        Asset( "ANIM", "anim/player_one_man_band.zip" ),
        Asset( "ANIM", "anim/shadow_hands.zip" ),
        Asset( "SOUND", "sound/sfx.fsb" ),
        Asset( "SOUND", "sound/wilson.fsb" ),
        Asset( "ANIM", "anim/beard.zip" ),

        Asset( "ANIM", "anim/wanda.zip" ),
}
local prefabs = {
	"mapel",
}

-- Custom starting items
local start_inv = {
	"mapel",
}

local fn = function(inst)
	
	-- choose which sounds this character will play
	inst.soundsname = "willow"

	-- Minimap icon
	inst.MiniMapEntity:SetIcon( "wanda.tex" )
	
	-- Stats	
	inst.components.health:SetMaxHealth(100)
	inst.components.hunger:SetMax(150)
	inst.components.sanity:SetMax(100)
	
	-- Damage multiplier (optional)
    inst.components.combat.damagemultiplier = 0.8
	
	-- Hunger rate (optional)
	inst.components.hunger.hungerrate = 1 * TUNING.WILSON_HUNGER_RATE
	
	-- Movement speed (optional)
	inst.components.locomotor.walkspeed = 5.1
	inst.components.locomotor.runspeed = 6
	
	--Sanity gained at night.
	inst.components.sanity.night_drain_mult = -7 
	--Sanity lost during the day.
	inst.components.sanity.dapperness = (TUNING.DAPPERNESS_SMALL * (-5)) 
	end

return MakePlayerCharacter("wanda", prefabs, assets, fn, start_inv)
