local N, S = ...
local DISPLAY_NAME = '|cfffc7703'..N..'|r |cffcccccc'..GetAddOnMetadata(N, 'Version')..'|r'

local SCREEN_WIDTH, SCREEN_HEIGHT =
    floor(GetScreenWidth()),
    floor(GetScreenHeight())

local AceAddon, AceDB, AceConfig, AceConfigDialog =
    LibStub('AceAddon-3.0'),
    LibStub('AceDB-3.0'),
    LibStub('AceConfig-3.0'),
    LibStub('AceConfigDialog-3.0')

local A = AceAddon:NewAddon(N, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0')
S.A = A

A:NewModule('ActionBar', 'AceHook-3.0', 'AceEvent-3.0')
A:NewModule('MicroBar', 'AceHook-3.0', 'AceEvent-3.0')
A:NewModule('BagBar', 'AceHook-3.0', 'AceEvent-3.0')

local defaults = {
    global = {
        generalColor = { 1, 1, 1, 1 },

        actionBarBackground = true,
        actionBarGryphons = true,

        bagBarEnabled = true,
        bagBarMouseOver = false,
        bagBarPosition = { 'BOTTOMRIGHT', 2, 44 },

        microBarEnabled = true,
        microBarMouseOver = false,
        microBarPosition = { 'BOTTOMRIGHT', 2, -2 },
    },
}

function A:OnInitialize()
    -- create database
    self.db = AceDB:New(N..'DB', defaults, true)

    -- register options ui
    AceConfig:RegisterOptionsTable(N, self.optionsTree, nil)
    self.interfaceOptions = AceConfigDialog:AddToBlizOptions(N, DISPLAY_NAME)

    -- register chat commands
    self:RegisterChatCommand('mab', 'OpenInterfaceOptions')
    self:RegisterChatCommand('modernactionbar', 'OpenInterfaceOptions')

    self.consoleTexture = 'Interface\\AddOns\\'..N..'\\Textures\\Console.tga'

    -- blizzard interface option buttons that affect this addon
    self.interfaceOptionButtons = {
        ReputationDetailMainScreenCheckBox,
        ReputationDetailInactiveCheckBox,
        InterfaceOptionsActionBarsPanelBottomLeft,
        InterfaceOptionsActionBarsPanelBottomRight,
        InterfaceOptionsActionBarsPanelRight,
        InterfaceOptionsActionBarsPanelRightTwo,
        InterfaceOptionsActionBarsPanelAlwaysShowActionBars,
    }
end

function A:OnEnable()
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
    self:RegisterEvent('PLAYER_REGEN_ENABLED')
    self:RegisterEvent('PLAYER_REGEN_DISABLED')

    self:SecureHook('InterfaceOptionsOptionsFrame_RefreshCategories', function()
        if InCombatLockdown() then
            InterfaceOptionsActionBarsPanelRightTwo:Disable()
        end
    end)
end

function A:PLAYER_ENTERING_WORLD(isLogin, isReload)
    if isLogin or isReload then
        -- empty function for unwanted script handlers
        local emptyFunc = function() end

        -- remove frames
        for index, frame in ipairs({
            MainMenuBarPerformanceBarFrame,
            MainMenuBarMaxLevelBar,
        }) do
            frame:UnregisterAllEvents()
            frame:SetScript('OnEvent', nil)
            frame:SetScript('OnUpdate', nil)
            frame:SetScript('OnShow', nil)
            frame:SetScript('OnHide', nil)
            frame:Hide()
            frame.SetScript = emptyFunc
            frame.RegisterEvent = emptyFunc
            frame.RegisterAllEvents = emptyFunc
            frame.Show = emptyFunc
        end

        -- remove textures
        for index, texture in ipairs({
            MainMenuBarTexture1,
            MainMenuBarTexture2,
            MainMenuBarTexture3,
            MainMenuXPBarTexture0,
            MainMenuXPBarTexture1,
            MainMenuXPBarTexture2,
            MainMenuXPBarTexture3,
            ReputationWatchBar.StatusBar.WatchBarTexture0,
            ReputationWatchBar.StatusBar.WatchBarTexture1,
            ReputationWatchBar.StatusBar.WatchBarTexture2,
            ReputationWatchBar.StatusBar.WatchBarTexture3,
            ReputationWatchBar.StatusBar.XPBarTexture0,
            ReputationWatchBar.StatusBar.XPBarTexture1,
            ReputationWatchBar.StatusBar.XPBarTexture2,
            ReputationWatchBar.StatusBar.XPBarTexture3,
            MainMenuMaxLevelBar0,
            MainMenuMaxLevelBar1,
            MainMenuMaxLevelBar2,
            MainMenuMaxLevelBar3,
            MultiBarBottomRightButton1FloatingBG,
            MultiBarBottomRightButton2FloatingBG,
            MultiBarBottomRightButton3FloatingBG,
            MultiBarBottomRightButton4FloatingBG,
            MultiBarBottomRightButton5FloatingBG,
            MultiBarBottomRightButton6FloatingBG,
            StanceBarLeft,
            StanceBarMiddle,
            StanceBarRight,
            SlidingActionBarTexture0,
            SlidingActionBarTexture1,
        }) do
            texture:SetTexture(nil)
            texture:Hide()
            texture.Show = emptyFunc
        end

        if not self.db.global.bagBarEnabled then
            self:DisableModule('BagBar')
        end

        if not self.db.global.microBarEnabled then
            self:DisableModule('MicroBar')
        end
    end
end

function A:PLAYER_REGEN_ENABLED()
    for index, button in ipairs(self.interfaceOptionButtons) do
        button:Enable()
    end
end

function A:PLAYER_REGEN_DISABLED()
    for index, button in ipairs(self.interfaceOptionButtons) do
        button:Disable()
    end
end

function A:OpenInterfaceOptions()
    -- AceConfigDialog:Open(N)
    InterfaceOptionsFrame_OpenToCategory(self.interfaceOptions)
    -- InterfaceOptionsFrame_OpenToCategory(InterfaceOptionsActionBarsPanel)
end

--------------------------------------
-- [[ ACTION BAR OPTION HANDLERS ]] --
--------------------------------------

-----------------------------------
-- [[ BAG BAR OPTION HANDLERS ]] --
-----------------------------------
function A:GetBagBarEnabled(info)
    return self.db.global.bagBarEnabled
end

function A:SetBagBarEnabled(info, value)
    if value ~= self.db.global.bagBarEnabled then
        self.db.global.bagBarEnabled = value

        if value then
            self:EnableModule('BagBar')
        else
            self:DisableModule('BagBar')
        end
    end
end

function A:BagBarDisabled()
    return not self:GetBagBarEnabled()
end

function A:GetBagBarMouseOver(info)
    return self.db.global.bagBarMouseOver
end

function A:SetBagBarMouseOver(info, value)
    if value ~= self.db.global.bagBarMouseOver then
        self.db.global.bagBarMouseOver = value
        self:GetModule('BagBar'):UpdateMouserOver()
    end
end

function A:GetBagBarAnchor(info)
    return self.db.global.bagBarPosition[1]
end

function A:SetBagBarAnchor(info, value)
    if self.db.global.bagBarPosition[1] ~= value then
        self.db.global.bagBarPosition[1] = value
        self:GetModule('BagBar'):UpdatePosition()
    end
end

function A:GetBagBarXOffset(info)
    return self.db.global.bagBarPosition[2]
end

function A:SetBagBarXOffset(info, value)
    if self.db.global.bagBarPosition[2] ~= value then
        self.db.global.bagBarPosition[2] = value
        self:GetModule('BagBar'):UpdatePosition()
    end
end

function A:GetBagBarYOffset(info)
    return self.db.global.bagBarPosition[3]
end

function A:SetBagBarYOffset(info, value)
    if self.db.global.bagBarPosition[3] ~= value then
        self.db.global.bagBarPosition[3] = value
        self:GetModule('BagBar'):UpdatePosition()
    end
end

-------------------------------------
-- [[ MICRO BAR OPTION HANDLERS ]] --
-------------------------------------
function A:GetMicroBarEnabled(info)
    return self.db.global.microBarEnabled
end

function A:SetMicroBarEnabled(info, value)
    if value ~= self.db.global.microBarEnabled then
        self.db.global.microBarEnabled = value

        if value then
            self:EnableModule('MicroBar')
        else
            self:DisableModule('MicroBar')
        end
    end
end

function A:MicroBarDisabled()
    return not self:GetMicroBarEnabled()
end

function A:GetMicroBarMouseOver(info)
    return self.db.global.microBarMouseOver
end

function A:SetMicroBarMouseOver(info, value)
    if value ~= self.db.global.microBarMouseOver then
        self.db.global.microBarMouseOver = value
        self:GetModule('MicroBar'):UpdateMouserOver()
    end
end

function A:GetMicroBarAnchor(info)
    return self.db.global.microBarPosition[1]
end

function A:SetMicroBarAnchor(info, value)
    if self.db.global.microBarPosition[1] ~= value then
        self.db.global.microBarPosition[1] = value
        self:GetModule('MicroBar'):UpdatePosition()
    end
end

function A:GetMicroBarXOffset(info)
    return self.db.global.microBarPosition[2]
end

function A:SetMicroBarXOffset(info, value)
    if self.db.global.microBarPosition[2] ~= value then
        self.db.global.microBarPosition[2] = value
        self:GetModule('MicroBar'):UpdatePosition()
    end
end

function A:GetMicroBarYOffset(info)
    return self.db.global.microBarPosition[3]
end

function A:SetMicroBarYOffset(info, value)
    if self.db.global.microBarPosition[3] ~= value then
        self.db.global.microBarPosition[3] = value
        self:GetModule('MicroBar'):UpdatePosition()
    end
end

A.optionsTree = {
    name = DISPLAY_NAME,
    handler = A,
    type = 'group',
    disabled = function()
        return InCombatLockdown()
    end,
    args = {
        general = {
            order = 1,
            type = 'group',
            name = 'General',
            guiInline = true,
            args = {

            },
        },

        actionBar = {
            order = 2,
            type = 'group',
            name = 'Action bar',
            guiInline = true,
            args = {},
        },

        bagBarEnabled = {
            order = 3,
            type = 'toggle',
            name = 'Enable Bag Bar',
            get = 'GetBagBarEnabled',
            set = 'SetBagBarEnabled',
        },
        bagBar = {
            order = 4,
            type = 'group',
            name = 'Bag Bar',
            guiInline = true,
            disabled = 'BagBarDisabled',
            args = {
                bagBarMouseOver = {
                    order = 1,
                    type = 'toggle',
                    name = 'Enable Mouse Over',
                    desc = 'Show/hide on mouse over.',
                    get = 'GetBagBarMouseOver',
                    set = 'SetBagBarMouseOver',
                },
                spacer1 = {
                    order = 2,
                    type = 'description',
                    name = ''
                },
                bagBarAnchor = {
                    order = 3,
                    type = 'select',
                    style = 'dropdown',
                    name = 'Anchor',
                    desc = 'Anchored position relative to the screen.',
                    values = {
                        CENTER = 'Center',
                        TOP = 'Top',
                        TOPLEFT = 'Top left',
                        TOPRIGHT = 'Top right',
                        RIGHT = 'Right',
                        BOTTOM = 'Bottom',
                        BOTTOMLEFT = 'Bottom left',
                        BOTTOMRIGHT = 'Bottom right',
                        LEFT = 'Left',
                    },
                    get = 'GetBagBarAnchor',
                    set = 'SetBagBarAnchor',
                },
                bagBarXOffset = {
                    order = 4,
                    type = 'range',
                    name = 'Offset X',
                    desc = 'Horizontal offset relative to the anchored position.',
                    min = -SCREEN_WIDTH,
                    max = SCREEN_WIDTH,
                    step = 1,
                    get = 'GetBagBarXOffset',
                    set = 'SetBagBarXOffset',
                },
                bagBarYOffset = {
                    order = 5,
                    type = 'range',
                    name = 'Offset Y',
                    desc = 'Vertical offset relative to the anchored position.',
                    min = -SCREEN_HEIGHT,
                    max = SCREEN_HEIGHT,
                    step = 1,
                    get = 'GetBagBarYOffset',
                    set = 'SetBagBarYOffset',
                },
            },
        },
        microBarEnabled = {
            order = 5,
            type = 'toggle',
            name = 'Enable Micro Bar',
            get = 'GetMicroBarEnabled',
            set = 'SetMicroBarEnabled',
        },
        microBar = {
            order = 6,
            name = 'Micro bar',
            type = 'group',
            guiInline = true,
            disabled = 'MicroBarDisabled',
            args = {
                microBarMouseOver = {
                    order = 1,
                    type = 'toggle',
                    name = 'Enable Mouse Over',
                    desc = 'Show/hide on mouse over.',
                    get = 'GetMicroBarMouseOver',
                    set = 'SetMicroBarMouseOver',
                },
                spacer1 = {
                    order = 2,
                    type = 'description',
                    name = '',
                },
                microBarAnchor = {
                    order = 3,
                    type = 'select',
                    style = 'dropdown',
                    name = 'Anchor',
                    desc = 'Anchored position relative to the screen.',
                    values = {
                        CENTER = 'Center',
                        TOP = 'Top',
                        TOPLEFT = 'Top left',
                        TOPRIGHT = 'Top right',
                        RIGHT = 'Right',
                        BOTTOM = 'Bottom',
                        BOTTOMLEFT = 'Bottom left',
                        BOTTOMRIGHT = 'Bottom right',
                        LEFT = 'Left',
                    },
                    get = 'GetMicroBarAnchor',
                    set = 'SetMicroBarAnchor',
                },
                microBarXOffset = {
                    order = 4,
                    type = 'range',
                    name = 'Offset X',
                    desc = 'Horizontal offset relative to the anchored position.',
                    min = -SCREEN_WIDTH,
                    max = SCREEN_WIDTH,
                    step = 1,
                    get = 'GetMicroBarXOffset',
                    set = 'SetMicroBarXOffset',
                },
                microBarYOffset = {
                    order = 5,
                    type = 'range',
                    name = 'Offset Y',
                    desc = 'Vertical offset relative to the anchored position.',
                    min = -SCREEN_HEIGHT,
                    max = SCREEN_HEIGHT,
                    step = 1,
                    get = 'GetMicroBarYOffset',
                    set = 'SetMicroBarYOffset',
                },
            },
        },
    },
}
