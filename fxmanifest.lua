author 'Xakra <Discord:Xakra#8145:https://discord.gg/kmsqB6xQjH>'
version '1.0'
description ''

fx_version "adamant"
lua54 "on"
game "rdr3"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

shared_scripts {
    'config.lua',
}

client_scripts {
	'client/client.lua'
}

server_scripts {
	'server/server.lua'
}