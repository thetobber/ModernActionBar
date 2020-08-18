-- LUA API
local _G = getfenv(0)
local unpack = _G.unpack
local select = _G.select

-- WOW API
local GetScreenWidth = _G.GetScreenWidth
local GetScreenHeight = _G.GetScreenHeight
local UnitClass = _G.UnitClass
local CreateFrame = _G.CreateFrame
local RegisterStateDriver = _G.RegisterStateDriver
local InCombatLockdown = _G.InCombatLockdown
local ClearOverrideBindings = _G.ClearOverrideBindings
local GetBindingKey = _G.GetBindingKey
local SetOverrideBindingClick = _G.SetOverrideBindingClick

-- LIBRARIES
local LibStub = _G.LibStub
local AceAddon = LibStub('AceAddon-3.0')
local AceDB = LibStub('AceDB-3.0')
local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')
local LibActionButton = LibStub('LibActionButton-1.0')

-- CONSTANTS
local NAME = ...
local PREFIX = 'MAB_'
local EMPTY_FUNC = function(...) end
local SCREEN_WIDTH = GetScreenWidth()
local SCREEN_HEIGHT = GetScreenHeight()
local PLAYER_CLASS = select(2, UnitClass('player'))
local DB_DEFAULTS = { global = {} }

local BAR_PAGING = {
    DRUID = '[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;',
    PRIEST = '[bonusbar:1] 7;',
    ROGUE = '[stance:1] 7;  [stance:2] 7; [stance:3] 7;',
    MONK = '[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;',
    WARRIOR = '[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3]9;',
}

local BAR_DEFAULTS = {
    -- MainMenuBar
    [PREFIX..'MainMenuBar'] = {
        page = 1,
        buttonType = 'ACTIONBUTTON',
        conditions = '[shapeshift] 13; [form,noform] 0; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;',
        position = 'BOTTOM,UIParent,BOTTOM,-144,6',
        size = '498,36',
    },
    -- MultiBarBottomLeft -> SHOW_MULTI_ACTIONBAR_1
    [PREFIX..'MultiBarBottomLeft'] = {
        page = 6,
        buttonType = 'MULTIACTIONBAR1BUTTON',
        conditions = '',
        position = 'BOTTOM,'..PREFIX..'MainMenuBar'..',TOP,0,6',
        size = '498,36',
    },
    -- MultiBarBottomRight -> SHOW_MULTI_ACTIONBAR_2
    [PREFIX..'MultiBarBottomRight'] = {
        page = 5,
        buttonType = 'MULTIACTIONBAR2BUTTON',
        conditions = '',
        position = 'BOTTOMLEFT,'..PREFIX..'MainMenuBar'..',BOTTOMRIGHT,42,0',
        size = '246,78',
    },
    -- MultiBarLeft -> SHOW_MULTI_ACTIONBAR_4
    [PREFIX..'MultiBarLeft'] = {
        page = 4,
        buttonType = 'MULTIACTIONBAR4BUTTON',
        conditions = '',
        position = 'RIGHT,UIParent,RIGHT,-48,-47',
        size = '36,498',
    },
    -- MultiBarRight -> SHOW_MULTI_ACTIONBAR_3
    [PREFIX..'MultiBarRight'] = { -- SHOW_MULTI_ACTIONBAR_3
        page = 3,
        buttonType = 'MULTIACTIONBAR3BUTTON',
        conditions = '',
        position = 'RIGHT,UIParent,RIGHT,-6,-47',
        size = '36,498',
    },
}

-- VARIABLES
local managedBars = {}
local buttonSize = 36
local buttonGap = 6

-- ADDON
local A = AceAddon:NewAddon(NAME, 'AceConsole-3.0', 'AceEvent-3.0', 'AceHook-3.0')

function A:OnInitialize()
    self.db = AceDB:New(NAME..'DB', DB_DEFAULTS, true)
end

function A:OnEnable()
    for k, _ in pairs(BAR_DEFAULTS) do
        self:ActionBars_CreateBar(k)
    end
    self:ActionBars_DisableBlizzard()
    self:ActionBars_UpdatePositionAndSize()
    self:ActionBars_AssignKeyBinds()

    self:RegisterEvent('UPDATE_BINDINGS', 'ActionBars_AssignKeyBinds')
end

function A:ActionBars_DisableBlizzard()
    for i, name in ipairs({
        'StanceBarFrame',
        'PetActionBarFrame',
        'MainMenuBar',
        'MultiBarBottomLeft',
        'MultiBarBottomRight',
        'MultiBarLeft',
        'MultiBarRight',
    }) do
        local frame = _G[name]

        if i < 6 then
            frame:UnregisterAllEvents()
        end

        RegisterStateDriver(frame, 'visibility', 'hide')
        _G.UIPARENT_MANAGED_FRAME_POSITIONS[name] = nil
    end

    for _, name in ipairs({
        'ActionButton',
        'MultiBarBottomLeftButton',
        'MultiBarBottomRightButton',
        'MultiBarRightButton',
        'MultiBarLeftButton',
        'OverrideActionBarButton',
        'MultiCastActionButton',
    }) do
        for i = 1, 12 do
            local frame = _G[name..i]

            if frame then
                frame:UnregisterAllEvents()
            end
        end
    end

    -- shut down some events for things we dont use
    _G.MainMenuBarArtFrame:UnregisterAllEvents()
    _G.ActionBarController:UnregisterAllEvents()

    -- * these seem to work but keep an eye on them for possible new taints spawned
    -- MultiBarRight:SetShown taint during combat from: SpellBookFrame, ZoneAbility, and ActionBarController
    _G.ActionBarController_UpdateAll = EMPTY_FUNC -- this seems to work
    -- MainMenuBar:ClearAllPoints taint during combat from: MainMenuBar
    _G.MainMenuBar.SetPositionForStatusBars = EMPTY_FUNC -- this seems to work

    -- hide some interface options we dont use
    -- _G.InterfaceOptionsActionBarsPanelStackRightBars:SetScale(0.5)
    -- _G.InterfaceOptionsActionBarsPanelStackRightBars:SetAlpha(0)
    -- _G.InterfaceOptionsActionBarsPanelStackRightBarsText:Hide() -- hides the !
    -- _G.InterfaceOptionsActionBarsPanelRightTwoText:SetTextColor(1,1,1) -- no yellow
    -- _G.InterfaceOptionsActionBarsPanelRightTwoText.SetTextColor = EMPTY_FUNC -- i said no yellow
    -- _G.InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetScale(0.0001)
    -- _G.InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
    -- _G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetScale(0.0001)
    -- _G.InterfaceOptionsActionBarsPanelLockActionBars:SetScale(0.0001)
    -- _G.InterfaceOptionsActionBarsPanelAlwaysShowActionBars:SetAlpha(0)
    -- _G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDownButton:SetAlpha(0)
    -- _G.InterfaceOptionsActionBarsPanelLockActionBars:SetAlpha(0)
    -- _G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetAlpha(0)
    -- _G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetScale(0.0001)
end

function A:ActionBars_GetPage(barName, defaultPage, conditions)
    local page

    if barName == PREFIX..'MainMenuBar' then
        page = BAR_PAGING[PLAYER_CLASS]
    else
        page = ''
    end

    if page then
        conditions = conditions..' '..page
    end

    return conditions..' '..defaultPage
end

function A:ActionBars_UpdateButtonConfig(bar, buttonType)
    if InCombatLockdown() then
        return
    end

    if not bar.buttonConfig then
        bar.buttonConfig = {
            outOfRangeColoring = 'button',
            tooltip = 'enabled',
            showGrid = false,
            colors = {
                range = { 0.8, 0.1, 0.1 },
                mana = { 0.5, 0.5, 1.0 }
            },
            hideElements = {
                macro = false,
                hotkey = false,
                equipped = false,
            },
            clickOnDown = false,
            flyoutDirection = 'UP',
        }
    end

    for i, button in pairs(bar.buttons) do
        bar.buttonConfig.keyBoundTarget = buttonType..i
        button.keyBoundTarget = bar.buttonConfig.keyBoundTarget

        button:SetAttribute('checkselfcast', true)
        button:UpdateConfig(bar.buttonConfig)
        self:ActionBars_UpdateKeyBindText(button)
    end
end

function A:ActionBars_CreateBar(barName)
    local bar = CreateFrame('Frame', barName, _G.UIParent, 'SecureHandlerStateTemplate')
    bar:SetFrameRef('MainMenuBarArtFrame', _G.MainMenuBarArtFrame)
    bar:SetFrameStrata('LOW')

    local barDefault = BAR_DEFAULTS[barName]
    bar.buttons = {}
    bar.buttonType = barDefault.buttonType

    -- self:HookScript(bar, 'OnEnter', 'func')
    -- self:HookScript(bar, 'OnLeave', 'func')

    for i = 1, _G.NUM_ACTIONBAR_BUTTONS, 1 do
        local button = LibActionButton:CreateButton(i, barName..'Button'..i, bar, nil)
        button:SetParent(bar)
        button:SetState(0, 'action', i)

        for k = 1, 14 do
            button:SetState(k, 'action', (k - 1) * 12 + i)
        end

        bar.buttons[i] = button

        -- self:HookScript(bar.buttons[i], 'OnEnter', 'func')
        -- self:HookScript(bar.buttons[i], 'OnLeave', 'func')
    end
    self:ActionBars_UpdateButtonConfig(bar, barDefault.buttonType)

    bar:SetAttribute('_onstate-page', [[
        if HasTempShapeshiftActionBar() and self:GetAttribute('hasTempBar') then
            newstate = GetTempShapeshiftBarIndex() or newstate
        end

        if newstate ~= 0 then
            self:SetAttribute('state', newstate)
            control:ChildUpdate('state', newstate)
            self:GetFrameRef('MainMenuBarArtFrame'):SetAttribute('actionpage', newstate)
        else
            local newCondition = self:GetAttribute('newCondition')

            if newCondition then
                newstate = SecureCmdOptionParse(newCondition)
                self:SetAttribute('state', newstate)
                control:ChildUpdate('state', newstate)
                self:GetFrameRef('MainMenuBarArtFrame'):SetAttribute('actionpage', newstate)
            end
        end
    ]])

    local page = self:ActionBars_GetPage(barName, barDefault.page, barDefault.conditions)

    if barDefault.conditions:find('[form,noform]') then
        bar:SetAttribute('hasTempBar', true)

        local newCondition = gsub(barDefault.conditions, ' %[form,noform%] 0; ', '')
        bar:SetAttribute('newCondition', newCondition)
    else
        bar:SetAttribute('hasTempBar', false)
    end

    RegisterStateDriver(bar, 'page', page)
    bar:SetAttribute('page', page)

    managedBars[barName] = bar
end

function A:ActionBars_UpdatePositionAndSize()
    for k, bar in pairs(managedBars) do




        for i, button in ipairs(bar.buttons) do
            button:SetSize(buttonSize, buttonSize)
            button:ClearAllPoints()
            button:Show()

            if k == PREFIX..'MultiBarBottomRight' then
                if i < 7 then
                    button:SetPoint('BOTTOMLEFT', (i - 1) * (buttonSize + buttonGap), 0)
                else
                    button:SetPoint('TOPLEFT', (i - 7) * (buttonSize + buttonGap), 0)
                end
            elseif k == PREFIX..'MultiBarLeft' or k == PREFIX..'MultiBarRight' then
                button:SetPoint('TOP', 0, -((i - 1) * (buttonSize + buttonGap)))
            else
                button:SetPoint('LEFT', (i - 1) * (buttonSize + buttonGap), 0)
            end
        end

        bar:ClearAllPoints()
        bar:SetPoint(strsplit(',', BAR_DEFAULTS[k].position))
        bar:SetSize(strsplit(',', BAR_DEFAULTS[k].size))
        bar:Show()
    end
end

function A:ActionBars_UpdateKeyBindText(button)
    local keyBind = _G[button:GetName()..'HotKey']
    local keyBindText = keyBind:GetText()

    if text then
        text = gsub(text, 'SHIFT%-', 'S')
        text = gsub(text, 'ALT%-', 'A')
        text = gsub(text, 'CTRL%-', 'C')
        text = gsub(text, 'BUTTON', 'M')
        text = gsub(text, 'MOUSEWHEELUP', 'MwU')
        text = gsub(text, 'MOUSEWHEELDOWN', 'MwD')
        text = gsub(text, 'NUMPAD', 'N')
        text = gsub(text, 'PAGEUP', 'PU')
        text = gsub(text, 'PAGEDOWN', 'PD')
        text = gsub(text, 'SPACE', 'SpB')
        text = gsub(text, 'INSERT', 'Ins')
        text = gsub(text, 'HOME', 'Hm')
        text = gsub(text, 'DELETE', 'Del')
        text = gsub(text, 'NMULTIPLY', '*')
        text = gsub(text, 'NMINUS', 'N-')
        text = gsub(text, 'NPLUS', 'N+')
        text = gsub(text, 'NEQUALS', 'N=')

        keyBind:SetText(text)
        keyBind:SetJustifyH('RIGHT')
    end

    keyBind:ClearAllPoints()
    keyBind:SetPoint('TOPRIGHT', -2, 2)
end

function A:ActionBars_AssignKeyBinds(event)
    if event == 'UPDATE_BINDINGS' then
        -- update pet and stance bindings
    end

    if InCombatLockdown() then
        return
    end

    for _, bar in pairs(managedBars) do
        if bar then
            ClearOverrideBindings(bar)

            for i = 1, #bar.buttons do
                local buttonType = bar.buttonType..i
                local buttonName = bar.buttons[i]:GetName()

                for k = 1, select('#', GetBindingKey(buttonType)) do
                    local key = select(k, GetBindingKey(buttonType))

                    if key and key ~= '' then
                        SetOverrideBindingClick(bar, false, key, buttonName)
                    end
                end
            end
        end
    end
end
