fx_version 'cerulean'

games { 
	'gta5' 
}

lua54 "yes"

name 'ngKeybox'
author 'Niklas Gschaider <niklas.gschaider@gschaider-systems.at>'
description 'Adds storage opportunities for vehicle keys'
version 'v1.0.0'

escrow_ignore {
	"config.lua",
	"locales/*.lua",
}

dependencies {
	"es_extended",
}

client_scripts {
	'@NativeUI/NativeUI.lua',
	'@es_extended/locale.lua',
	"locales/*.lua",
	"config.lua",
	"client.lua",
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	"locales/*.lua",
	"config.lua",
	"server.lua",
}