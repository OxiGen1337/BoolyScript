local fs = require("BoolyScript/util/file_system")

local paths = {}
paths.files = {}
paths.folders = {}
paths.logs = {}

paths.folders.main = fs.getInitScriptPath() .. '\\BoolyScript'
paths.folders.user = paths.folders.main .. '\\user'
paths.folders.dumps = paths.folders.main .. '\\dumps'
paths.folders.loadouts = paths.folders.user .. '\\loadouts'
paths.folders.translations = paths.folders.user .. '\\translations'
paths.folders.outfits = paths.folders.user .. '\\outfits'
paths.folders.chat_spammer = paths.folders.user.. '\\chat_spammer'
paths.folders.logs = paths.folders.user .. '\\logs'

paths.logs.chat = paths.folders.logs .. '\\' .. 'Chat.log'
paths.logs.weapons = paths.folders.logs .. '\\' .. 'Weapons.log'
paths.logs.warnScreens = paths.folders.logs .. '\\' .. 'Warning Screens.log'
paths.logs.netEvents = paths.folders.logs .. '\\' .. 'Network Events.log'
paths.logs.scriptEvents = paths.folders.logs .. '\\' .. 'Script Events.log'

paths.files.weapons = paths.folders.dumps .. '\\' .. 'weapons.json'
paths.files.weaponHashes = paths.folders.dumps .. '\\' .. 'WeaponList.json'

paths.files.config = paths.folders.user .. '\\config.json'

return paths