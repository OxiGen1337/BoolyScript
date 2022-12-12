require("BoolyScript/util/menu")
local gui = require("BoolyScript/globals/gui")

local name = "BoolyScript"
name = name .. " " .. os.clock() -- TODO: remove that shit

menu.add_page(name, "BS_Main", gui.icons.scripts)

require("BoolyScript/pages/BoolyScript/self")
require("BoolyScript/pages/BoolyScript/presets_mgr")
require("BoolyScript/pages/BoolyScript/vehicle")
require("BoolyScript/pages/BoolyScript/players")
require("BoolyScript/pages/BoolyScript/network")
require("BoolyScript/pages/BoolyScript/settings")


