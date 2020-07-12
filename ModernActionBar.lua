local AddonName = ...

-- local AceAddon = LibStub('AceAddon-3.0')
-- local AceDB = LibStub('AceDB-3.0')
-- local AceConfig = LibStub('AceConfig-3.0')
-- local AceConfigDialog = LibStub('AceConfigDialog-3.0')

local defaults = {
    char = {
        visibility = {
            showBars = true,
            showGryphons = true
        },
        coloring = {
            colorBars = { 1, 1, 1, 1 },
            colorGryphons = { 1, 1, 1, 1 }
        }
    }
}

local options = {
    name = 'ModernActionBar',
    handler = ModernActionBar,
    type = 'group',
    args = {
        visibility = {
            order = 1,
            type = 'group',
            name = 'Visibility',
            guiInline = true,
            args = {
                showBars = {
                    order = 1,
                    type = 'toggle',
                    name = 'Show action bar textures',
                    desc = 'Show or hide all action bar textures',
                    get = function(info)
                        return ModernActionBar.db.char.visibility.showBars
                    end,
                    set = function(info, value)
                        ModernActionBar.db.char.visibility.showBars = value
                        ModernActionBar.ActionBars:Option_ShowBarsAndGryphons()
                        ModernActionBar.BagAndMicroBar:Option_Show()
                    end
                },
                showGryphons = {
                    order = 2,
                    type = 'toggle',
                    name = 'Show gryphons',
                    desc = 'Show or hide right and left gryphons',
                    get = function(info)
                        return ModernActionBar.db.char.visibility.showGryphons
                    end,
                    set = function(info, value)
                        ModernActionBar.db.char.visibility.showGryphons = value
                        ModernActionBar.ActionBars:Option_ShowBarsAndGryphons()
                    end,
                    disabled = function()
                        return not ModernActionBar.db.char.visibility.showBars
                    end
                }
            }
        },
        coloring = {
            order = 2,
            type = 'group',
            name = 'Coloring',
            guiInline = true,
            args = {
                colorBars = {
                    order = 1,
                    type = 'color',
                    name = 'Action bars coloring',
                    hasAlpha = true,
                    get = function(info)
                        local c = ModernActionBar.db.char.coloring.colorBars
                        return c[1], c[2], c[3], c[4]
                    end,
                    set = function(info, r, g, b, a)
                        ModernActionBar.db.char.coloring.colorBars = { r, g, b, a }
                        ModernActionBar.ActionBars:Option_ColorBars()
                        ModernActionBar.BagAndMicroBar:Option_Color()
                    end
                },
                colorGryphons = {
                    order = 2,
                    type = 'color',
                    name = 'Gryphons coloring',
                    hasAlpha = true,
                    get = function(info)
                        local c = ModernActionBar.db.char.coloring.colorGryphons
                        return c[1], c[2], c[3], c[4]
                    end,
                    set = function(info, r, g, b, a)
                        ModernActionBar.db.char.coloring.colorGryphons = { r, g, b, a }
                        ModernActionBar.ActionBars:Option_ColorGryphons()
                    end
                }
            }
        }
    }
}

ModernActionBar = LibStub('AceAddon-3.0'):NewAddon(AddonName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceHook-3.0')
ModernActionBar.ActionBars = ModernActionBar:NewModule('ActionBars', 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0')
ModernActionBar.BagAndMicroBar = ModernActionBar:NewModule('BagAndMicroBar', 'AceHook-3.0', 'AceEvent-3.0')

function ModernActionBar:OnInitialize()
    self.db = LibStub('AceDB-3.0'):New(AddonName..'DB', defaults, true)

    LibStub('AceConfig-3.0'):RegisterOptionsTable(AddonName, options, nil)
    self.options = LibStub('AceConfigDialog-3.0'):AddToBlizOptions(AddonName, AddonName..' '..GetAddOnMetadata(AddonName, 'Version'))

    -- self:NewModule('ActionBars', 'AceHook-3.0', 'AceEvent-3.0')

    self:RegisterChatCommand('mab', 'OpenOptions')
    self:RegisterChatCommand('modernactionbar', 'OpenOptions')
end

function ModernActionBar:OpenOptions()
    InterfaceOptionsFrame_OpenToCategory(self.options)
end
