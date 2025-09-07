fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Bandi'
  
  
client_scripts {
    'client/*.*'
}
  
shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'shared.lua'
}

server_scripts {
    'server/*.*',
    '@oxmysql/lib/MySQL.lua'
}

ui_page 'ui/index.html'

files {
    'ui/*.*'
}

dependencies {
    'oxmysql',
    'es_extended',
    'ox_lib'
}
