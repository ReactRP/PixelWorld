Config = {
-- Change the language of the menu here!.
-- Note fr and de are google translated, if you would like to help out with translation / just fix it for your server check below and change translations yourself
-- try en, fr, de or sv.
	MenuLanguage = 'en',	
-- Set this to true to enable some extra prints
	DebugDisplay = false,
-- Set this to false if you have something else on X, and then just use /e c to cancel emotes.
	EnableXtoCancel = true,
-- Set this to true if you want to disarm the player when they play an emote.
	DisarmPlayer= false,
-- You can disable the (F3) menu here / change the keybind.
	MenuKeybindEnabled = true,
	MenuKeybind = 170, -- Get the button number here https://docs.fivem.net/game-references/controls/
    CancelKeyBind = 178,
-- You can change the menu position here
	MenuPosition = "right", -- (left, right)
-- You can disable the Ragdoll keybinding here.
	RagdollEnabled = true,
	RagdollKeybind = 303, -- Get the button number here https://docs.fivem.net/game-references/controls/
-- You can disable the Facial Expressions menu here.
	ExpressionsEnabled = false,
-- You can disable the Walking Styles menu here.
	WalkingStylesEnabled = false,	
-- You can disable the Shared Emotes here.
    SharedEmotesEnabled = true,
}

Config.KeybindKeys = {
    [1] = { ['id'] = 108, ['keyName'] = 'NUMPAD 4' },
    [2] = { ['id'] = 110, ['keyName'] = 'NUMPAD 5' },
    [3] = { ['id'] = 109, ['keyName'] = 'NUMPAD 6' },
    [4] = { ['id'] = 117, ['keyName'] = 'NUMPAD 7' },
    [5] = { ['id'] = 111, ['keyName'] = 'NUMPAD 8' },
    [6] = { ['id'] = 118, ['keyName'] = 'NUMPAD 9' }
}
