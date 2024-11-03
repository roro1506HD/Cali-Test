--[[ FX Information ]]--
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

--[[ Resource Information ]]--
name 'cali-test-bateau'
version '1.0.0'
description 'Test project for developer application'
author 'roro1506HD'

--[[ Manifest ]]--
dependencies {
    "es_extended",
	"oxmysql"
}

shared_scripts {
	'@es_extended/imports.lua',
    'table.lua',
    "config.lua"
}

client_scripts {
    "client/main.lua",
    "client/menu.lua"
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    "server/main.lua"
}