PrefabFiles = {
	"wanda",
	"mapel",
}

Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/wanda.tex" ),
    Asset( "ATLAS", "images/saveslot_portraits/wanda.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/wanda.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wanda.xml" ),
	
    Asset( "IMAGE", "images/selectscreen_portraits/wanda_silho.tex" ),
    Asset( "ATLAS", "images/selectscreen_portraits/wanda_silho.xml" ),

    Asset( "IMAGE", "bigportraits/wanda.tex" ),
    Asset( "ATLAS", "bigportraits/wanda.xml" ),
	
	Asset( "IMAGE", "images/map_icons/wanda.tex" ),
	Asset( "ATLAS", "images/map_icons/wanda.xml" ),

}

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- The character select screen lines
STRINGS.CHARACTER_TITLES.wanda = "The Stargazer"
STRINGS.CHARACTER_NAMES.wanda = "Wanda"
STRINGS.CHARACTER_DESCRIPTIONS.wanda = "*Has an imaginary friend\n*Loves the night\n*Weak but fast"
STRINGS.CHARACTER_QUOTES.wanda = "\"The stars are pretty. Right... ?\""

-- Custom speech strings
STRINGS.CHARACTERS.WANDA = require "speech_wanda"

-- Let the game know character is male, female, or robot
table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "wanda")

AddMinimapAtlas("images/map_icons/wanda.xml")
AddModCharacter("wanda")

-- Custom item name
STRINGS.NAMES.MAPEL = "Mapel"
-- Generic description of an item
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MAPEL = "Mapel is always with me."
