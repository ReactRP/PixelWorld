local imgPre = "imgsrc:https://donotdelete.chrisrogersuk.co.uk/fonts/svg/"

menuConfigs = {
    ['mainMenu'] = {
        data = {                                    -- Data that is passed to Javascript
            style = {                               -- Wheel style settings
                sizePx = 600,                       -- Wheel size in pixels
                slices = {                          -- Slice style settings
                    default = { ['fill'] = '#ffffff', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.40 },
                    hover = { ['fill'] = '#7700DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 },
                    selected = { ['fill'] = '#7700DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 }
                },
                titles = {                          -- Text style settings
                    default = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    hover = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    selected = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' }
                },
                icons = {
                    width = 54,
                    height = 54
                }
            },
            wheels = {                              -- Array of wheels to display
                {
                    navAngle = 270,                 -- Oritentation of wheel
                    minRadiusPercent = 0.3,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.6,         -- Maximum radius of wheel in percentage
                    labels = {"JOBSHIT", imgPre .. "solid/universal-access.svg", imgPre .. "solid/times-circle.svg", imgPre .. "solid/smile.svg", imgPre .. "solid/stop-circle.svg"},
                    eventTrigger = {{'pw_radialmenu:openJobWheel'}, {'pw_pedfeatures:client:walkMenu'}, {--[[CLOSE MENU]]}, {'pw_pedfeatures:client:moodMenu'}, {'pw_emotes:client:cancelCurrentEmote'}}
                },
                {
                    navAngle = 285,                 -- Oritentation of wheel
                    minRadiusPercent = 0.6,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.9,         -- Maximum radius of wheel in percentage
                    labels = {"HANDSUP", 'GIVE KEY', "ESCORT", "SEAT", "UNSEAT", imgPre .. "solid/mask.svg", imgPre .. "solid/hard-hat.svg", imgPre .. "solid/glasses.svg", "GIVE NUMBER"},
                    eventTrigger = {{'pw_emotes:client:doAnEmote', 'handsup'}, {--[[GIVE CAR KEY]]}, {--[[ESCORT SOMEONE IN CUFFS]]}, {--[[SEAT SOMEONE IN CAR]]}, {--[[UNSEAT SOMEONE FROM CAR]]}, {'pw_character:client:toggleCharacterAccess', 'masks'}, {'pw_character:client:toggleCharacterAccess', 'hats'}, {'pw_character:client:toggleCharacterAccess', 'glasses'}, {--[[GIVE PHONE NUMBER]]}}
                }
            }
        }
    },
    ['police'] = {
        data = {                                    -- Data that is passed to Javascript
            style = {                               -- Wheel style settings
                sizePx = 600,                       -- Wheel size in pixels
                slices = {                          -- Slice style settings
                    default = { ['fill'] = '#ffffff', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.60 },
                    hover = { ['fill'] = '#0068DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 },
                    selected = { ['fill'] = '#0068DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 }
                },
                titles = {                          -- Text style settings
                    default = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    hover = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    selected = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' }
                },
                icons = {
                    width = 64,
                    height = 64
                }
            },
            wheels = {                              -- Array of wheels to display
                {
                    navAngle = 270,                 -- Oritentation of wheel
                    minRadiusPercent = 0.3,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.6,         -- Maximum radius of wheel in percentage
                    labels = {imgPre .. "solid/tablet-alt.svg", imgPre .. "solid/times-circle.svg", "SEARCH"},
                    eventTrigger = {{--[[MDT]]}, {--[[CLOSE MENU]]}, {--[[SEARCH NEAREST]]}}
                },
                {
                    navAngle = 285,                 -- Oritentation of wheel
                    minRadiusPercent = 0.6,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.9,         -- Maximum radius of wheel in percentage
                    labels = {"IMPOUND", imgPre .. "solid/heartbeat.svg", "HELLO", "HELLO", "HELLO", "HELLO", "HELLO", "HELLO"},
                    eventTrigger = {{--[[Impound]]}, {--[[CHECK STATUS]]}, {}, {}, {}, {}, {}, {}}
                }
            }
        }
    },
    ['prisonguard'] = {
        data = {                                    -- Data that is passed to Javascript
            style = {                               -- Wheel style settings
                sizePx = 600,                       -- Wheel size in pixels
                slices = {                          -- Slice style settings
                    default = { ['fill'] = '#ffffff', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.60 },
                    hover = { ['fill'] = '#0068DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 },
                    selected = { ['fill'] = '#0068DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 }
                },
                titles = {                          -- Text style settings
                    default = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    hover = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    selected = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' }
                },
                icons = {
                    width = 64,
                    height = 64
                }
            },
            wheels = {                              -- Array of wheels to display
                {
                    navAngle = 270,                 -- Oritentation of wheel
                    minRadiusPercent = 0.3,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.6,         -- Maximum radius of wheel in percentage
                    labels = {"HELLO", imgPre .. "solid/times-circle.svg"},
                    eventTrigger = {{}, {--[[CLOSE MENU]]}}
                },
                {
                    navAngle = 285,                 -- Oritentation of wheel
                    minRadiusPercent = 0.6,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.9,         -- Maximum radius of wheel in percentage
                    labels = {"HELLO", "HELLO", "HELLO", "HELLO"},
                    eventTrigger = {{}, {}, {}, {}}
                }
            }
        }
    },
    ['ems'] = {
        data = {                                    -- Data that is passed to Javascript
            style = {                               -- Wheel style settings
                sizePx = 600,                       -- Wheel size in pixels
                slices = {                          -- Slice style settings
                    default = { ['fill'] = '#ffffff', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.60 },
                    hover = { ['fill'] = '#DF0700', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 },
                    selected = { ['fill'] = '#DF0700', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 }
                },
                titles = {                          -- Text style settings
                    default = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    hover = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    selected = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' }
                },
                icons = {
                    width = 64,
                    height = 64
                }
            },
            wheels = {                              -- Array of wheels to display
                {
                    navAngle = 270,                 -- Oritentation of wheel
                    minRadiusPercent = 0.3,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.6,         -- Maximum radius of wheel in percentage
                    labels = {imgPre .. "solid/heartbeat.svg", "REVIVE", imgPre .. "solid/times-circle.svg", "HEAL"},
                    eventTrigger = {{'pw_ems:client:getClosestPersonStatus'}, {'pw_ems:getClosestRevive', 'close'}, {--[[CLOSE MENU]]}, {'pw_ems:getClosestHeal', 'close'}}
                },
                {
                    navAngle = 285,                 -- Oritentation of wheel
                    minRadiusPercent = 0.6,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.9,         -- Maximum radius of wheel in percentage
                    labels = {imgPre .. "solid/tablet-alt.svg", "SOMETHING", "SOMETHING", "SOMETHING", "SOMETHING", "SOMETHING", "SOMETHING"},
                    eventTrigger = {--[[OPEN MDT]]{}, {}, {}, {}, {}, {}, {}}
                }
            }
        }
    },
    ['doctor'] = {
        data = {                                    -- Data that is passed to Javascript
            style = {                               -- Wheel style settings
                sizePx = 600,                       -- Wheel size in pixels
                slices = {                          -- Slice style settings
                    default = { ['fill'] = '#ffffff', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.60 },
                    hover = { ['fill'] = '#DF0700', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 },
                    selected = { ['fill'] = '#DF0700', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 }
                },
                titles = {                          -- Text style settings
                    default = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    hover = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    selected = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' }
                },
                icons = {
                    width = 64,
                    height = 64
                }
            },
            wheels = {                              -- Array of wheels to display
                {
                    navAngle = 270,                 -- Oritentation of wheel
                    minRadiusPercent = 0.3,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.6,         -- Maximum radius of wheel in percentage
                    labels = {imgPre .. "solid/heartbeat.svg", "REVIVE", imgPre .. "solid/times-circle.svg", "HEAL"},
                    eventTrigger = {{'pw_ems:client:getClosestPersonStatus'}, {'pw_ems:getClosestRevive', 'close'}, {--[[CLOSE MENU]]}, {'pw_ems:getClosestHeal', 'close'}}
                },
                {
                    navAngle = 285,                 -- Oritentation of wheel
                    minRadiusPercent = 0.6,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.9,         -- Maximum radius of wheel in percentage
                    labels = {imgPre .. "solid/tablet-alt.svg"},
                    eventTrigger = {{--[[OPEN MDT]]},}
                }
            }
        }
    },
    ['newsreporter'] = {
        data = {                                    -- Data that is passed to Javascript
            style = {                               -- Wheel style settings
                sizePx = 600,                       -- Wheel size in pixels
                slices = {                          -- Slice style settings
                    default = { ['fill'] = '#ffffff', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.60 },
                    hover = { ['fill'] = '#00A822', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 },
                    selected = { ['fill'] = '#00A822', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 }
                },
                titles = {                          -- Text style settings
                    default = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    hover = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    selected = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' }
                },
                icons = {
                    width = 64,
                    height = 64
                }
            },
            wheels = {                              -- Array of wheels to display
                {
                    navAngle = 270,                 -- Oritentation of wheel
                    minRadiusPercent = 0.3,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.8,         -- Maximum radius of wheel in percentage
                    labels = {"CAMERA", "MIC", imgPre .. "solid/times-circle.svg", "BOOM MIC"},
                    eventTrigger = {{'pw_newsreporter:client:ToggleCam'}, {'pw_newsreporter:client:ToggleMic'}, {--[[CLOSE MENU]]}, {'pw_newsreporter:client:ToggleBMic'}}
                }
            }
        }
    },
    ['policeDead'] = {
        data = {                                    -- Data that is passed to Javascript
            style = {                               -- Wheel style settings
                sizePx = 600,                       -- Wheel size in pixels
                slices = {                          -- Slice style settings
                    default = { ['fill'] = '#ffffff', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.60 },
                    hover = { ['fill'] = '#0068DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 },
                    selected = { ['fill'] = '#0068DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 }
                },
                titles = {                          -- Text style settings
                    default = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    hover = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    selected = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' }
                },
                icons = {
                    width = 64,
                    height = 64
                }
            },
            wheels = {                              -- Array of wheels to display
                {
                    navAngle = 270,                 -- Oritentation of wheel
                    minRadiusPercent = 0.3,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.6,         -- Maximum radius of wheel in percentage
                    labels = {'10-13A', "10-13B", imgPre .. "solid/times-circle.svg"},
                    eventTrigger = {{}, {}, {--[[CLOSE MENU]]}}
                }
            }
        }
    },
    ['prisonguardDead'] = {
        data = {                                    -- Data that is passed to Javascript
            style = {                               -- Wheel style settings
                sizePx = 600,                       -- Wheel size in pixels
                slices = {                          -- Slice style settings
                    default = { ['fill'] = '#ffffff', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.60 },
                    hover = { ['fill'] = '#0068DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 },
                    selected = { ['fill'] = '#0068DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 }
                },
                titles = {                          -- Text style settings
                    default = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    hover = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    selected = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' }
                },
                icons = {
                    width = 64,
                    height = 64
                }
            },
            wheels = {                              -- Array of wheels to display
                {
                    navAngle = 270,                 -- Oritentation of wheel
                    minRadiusPercent = 0.3,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.6,         -- Maximum radius of wheel in percentage
                    labels = {'10-13A', "10-13B", imgPre .. "solid/times-circle.svg"},
                    eventTrigger = {{}, {}, {--[[CLOSE MENU]]}}
                }
            }
        }
    },
    ['emsDead'] = {
        data = {                                    -- Data that is passed to Javascript
            style = {                               -- Wheel style settings
                sizePx = 600,                       -- Wheel size in pixels
                slices = {                          -- Slice style settings
                    default = { ['fill'] = '#ffffff', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.60 },
                    hover = { ['fill'] = '#0068DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 },
                    selected = { ['fill'] = '#0068DF', ['stroke'] = '#000000', ['stroke-width'] = 2, ['opacity'] = 0.80 }
                },
                titles = {                          -- Text style settings
                    default = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    hover = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' },
                    selected = { ['fill'] = '#000000', ['stroke'] = 'none', ['font'] = 'Helvetica', ['font-size'] = 16, ['font-weight'] = 'bold' }
                },
                icons = {
                    width = 64,
                    height = 64
                }
            },
            wheels = {                              -- Array of wheels to display
                {
                    navAngle = 270,                 -- Oritentation of wheel
                    minRadiusPercent = 0.3,         -- Minimum radius of wheel in percentage
                    maxRadiusPercent = 0.6,         -- Maximum radius of wheel in percentage
                    labels = {'10-14', imgPre .. "solid/times-circle.svg"},
                    eventTrigger = {{}, {--[[CLOSE MENU]]}}
                }
            }
        }
    },
}