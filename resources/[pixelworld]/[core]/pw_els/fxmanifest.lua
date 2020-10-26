fx_version 'bodacious'
games {'gta5'}

description 'SynCity Emergency Lighting System'
name 'SynCity: [pw_els]'
author 'SynCityRP [Dr Nick] - https://SynCityrp.com'
version 'v1.0.0'

server_scripts {
    'server/main.lua',
}

client_scripts {
    'client/main.lua',
}

--[[
Will automatically apply to all emergency vehicles (vehicle class 18)

CONTROLS:

Right indicator:	=	(Next Custom Radio Track)
Left indicator:		-	(Previous Custom Radio Track)
Hazard lights:	Backspace	(Phone Cancel)
Toggle emergency lights:	Y	(Text Chat Team)
Airhorn:	E	(Horn)
Toggle siren:	,	(Previous Radio Station)
Manual siren / Change siren tone:	N	(Next Radio Station)
Auxiliary siren:	Down Arrow	(Phone Up)
]]