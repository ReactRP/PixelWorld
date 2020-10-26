fx_version 'bodacious'
games {'gta5'}

description 'SynCity Bomb Defusal'
name 'SynCity: pw_bombdefuse'
author 'SynCityRP [creaKtive & Chris Rogers] - https://SynCityrp.com'
version 'v1.0.0'

client_script('client/client.lua')

ui_page('client/html/index.html')

files({
    'client/html/index.html',
    'client/html/script.js',
    'client/html/style.css',
    'client/html/cursor.png'
})

dependencies {
    'pw_mysql',
    'pw_notify',
    'pw_progbar',
    'pw_core'
}