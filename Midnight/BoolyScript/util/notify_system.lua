local consoleColors = 
{
	['Black'] = 0,
	['Blue'] = 1,
	['Green'] = 2,
	['Cyan'] = 3,
	['Red'] = 4,
	['Purple'] = 5,
	['Orange'] = 6,
	['LightGrey'] = 7,
	['Grey'] = 8,
	['LightBlue'] = 9,
	['LightGreen'] = 10,
	['LightCyan'] = 11,
	['LightRed'] = 12,
	['LightPurple'] = 13,
	['Yellow'] = 14,
	['White'] = 15,
}

local notifyIcons =
{
   ['aimbot'] = 0,
   ['bind'] = 1,
   ['warning'] = 2,
   ['color'] = 3,
   ['visuals'] = 4,
   ['grenade'] = 5,
   ['boost'] = 6,
   ['image'] = 7,
   ['inventory'] = 8,
   ['join'] = 9,
   ['kick'] = 10,
   ['leave'] = 11,
   ['misc'] = 12,
   ['players'] = 13,
   ['self'] = 14,
   ['radar'] = 15,
   ['configs'] = 16,
   ['scripts'] = 17,
   ['security'] = 18,
   ['settings'] = 19,
   ['share'] = 20,
   ['incognito'] = 21,
   ['teleport'] = 22,
   ['tools'] = 23,
   ['triggerbot'] = 24,
   ['vehicle'] = 25,
   ['weapons'] = 26,
   ['armor'] = 27,
   ['world'] = 28,
   ['spoofing'] = 29,
}

local notifyType =
{
    ['default'] = 0,
    ['success'] = 1,
    ['warning'] = 2,
    ['important'] = 3,
    ['fatal'] = 4,
}

GET_CONSOLE_COLORS = function ()
    return consoleColors
end

GET_NOTIFY_ICONS = function ()
    return notifyIcons
end

GET_NOTIFY_TYPES = function ()
    return notifyType
end

log = {
    dbg = function (text_s)
        console.log(consoleColors.Purple, string.format("[DEBUG] %s\n", text_s))
    end,
    error = function (page_s, text_s)
        console.log(consoleColors.Red, string.format("[ERROR] [%s] %s\n", page_s, text_s))
    end,
    default = function (page_s, text_s)
        console.log(consoleColors.Grey, string.format("[LOGS] [%s] %s\n", page_s, text_s))
    end,
    success = function (page_s, text_s)
        console.log(consoleColors.LightGreen, string.format("[SUCCESS] [%s] %s\n", page_s, text_s))
    end,
    init = function (text_s)
        console.log(consoleColors.LightBlue, string.format("[INIT] %s\n", text_s))
    end,
}

notify = {
    default = function (page_s, text_s, icon_i)
        utils.notify(page_s, text_s, icon_i, notifyType.default)
    end,
    success = function (page_s, text_s, icon_i)
        utils.notify(page_s, text_s, icon_i, notifyType.success)
    end,
    warning = function (page_s, text_s, icon_i)
        utils.notify(page_s, text_s, icon_i, notifyType.warning)
    end,
    important = function (page_s, text_s, icon_i)
        utils.notify(page_s, text_s, icon_i, notifyType.important)
    end,
    fatal = function (page_s, text_s, icon_i)
        utils.notify(page_s, text_s, icon_i, notifyType.fatal)
    end,
}