-- Lua API
local _G = getfenv(0)

-- WoW API
local GetScreenWidth = _G.GetScreenWidth
local GetScreenHeight = _G.GetScreenHeight
local CreateFrame = _G.CreateFrame
local RegisterStateDriver = _G.RegisterStateDriver

-- Libraries
local LibStub = _G.LibStub
local AceAddon = LibStub('AceAddon-3.0')
local AceDB = LibStub('AceDB-3.0')
local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')
local LibActionButton = LibStub('LibActionButton-1.0')

-- Init
local ADDON_NAME, ADDON_TABLE = ...

local A = AceAddon:NewAddon(ADDON_NAME, 'AceConsole-3.0', 'AceEvent-3.0', 'AceHook-3.0')
A.db = { profile = {}, global = {}, }
A.dbDefaults = { profile = {}, global = {}, }
A.options = { type = 'group', args = {}, childGroups = 'tabs', }

-- Setting up references for addon table
ADDON_TABLE[1] = A
ADDON_TABLE[2] = { EMPTY_FUNC = function (...) end, SCREEN_WIDTH = GetScreenWidth(), SCREEN_HEIGHT = GetScreenHeight(), }
ADDON_TABLE[3] = A.db.profile
ADDON_TABLE[4] = A.db.global

-- Addon modules
A.ActionBars = A:NewModule('ActionBars', 'AceHook-3.0', 'AceEvent-3.0')
A.MicroBar = A:NewModule('MicroBar', 'AceHook-3.0', 'AceEvent-3.0')
A.BagBar = A:NewModule('BagBar', 'AceHook-3.0', 'AceEvent-3.0')

function A:OnInitialize()
    -- Create saved variables database
    A.db = AceDB:New(ADDON_NAME..'DB', A.dbDefaults, true)
end





A.ActionBars.barDefaults = {
    -- MainMenuBar
    bar1 = {
        page = 1,
        buttonType = 'ACTIONBUTTON',
        conditions = '',
        position = 'CENTER',
    },
    -- MultiBarBottomLeft
    bar2 = {
        page = 6,
        buttonType = 'MULTIACTIONBAR1BUTTON',
        conditions = '',
        position = 'BOTTOM,MAB_Bar1,TOP,0,6',
    },
    -- -- MultiBarBottomRight
    -- bar3 = {
    --     page = 5,
    --     buttonType = 'MULTIACTIONBAR2BUTTON',
    --     conditions = '',
    --     position = 'BOTTOM,MAB_Bar2,TOP,0,6',
    -- },
    -- -- MultiBarLeft
    -- bar4 = {
    --     page = 4,
    --     buttonType = 'MULTIACTIONBAR4BUTTON',
    --     conditions = '',
    --     position = 'RIGHT,UIParent,RIGHT,-48,0',
    -- },
    -- -- MultiBarRight
    -- bar5 = {
    --     page = 3,
    --     buttonType = 'MULTIACTIONBAR3BUTTON',
    --     conditions = '',
    --     position = 'RIGHT,UIParent,RIGHT,-6,0',
    -- },
}

A.ActionBars.managedBars = {}

function A.ActionBars:GetPage(barName, defaultPage, condition)
    local page = ''

    if not condition then
        condition = ''
    end

    if barName == 'bar1' then
        local _, playerClass = UnitClass('player')

        if playerClass == 'DRUID' then
            page = '[bonusbar:1,nostealth]7;[bonusbar:1,stealth]8;[bonusbar:2]8;[bonusbar:3] 9;[bonusbar:4]10;'
        elseif playerClass == 'PRIEST' then
            page = '[bonusbar:1]7;'
        elseif playerClass == 'ROGUE' then
            page = '[stance:1]7;[stance:2]7;[stance:3]7;'
        elseif playerClass == 'WARRIOR' then
            page = '[bonusbar:1]7;[bonusbar:2]8;[bonusbar:3]9;'
        end
    end

    return condition..page..defaultPage
end

function A.ActionBars:UpdateBindingText(button)
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

function A.ActionBars:UpdateButtonConfig(bar, buttonType)
    if InCombatLockdown() then
        -- update after combat
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
        self:UpdateBindingText(button)
    end
end

function A.ActionBars:CreateBar(id)
    local bar = CreateFrame('Frame', 'MAB_Bar'..id, _G.UIParent, 'SecureHandlerStateTemplate')

    local barDefault = self.barDefaults['bar'..id]
    local defaultPage = barDefault.page
    local buttonType = barDefault.buttonType
    local conditions = barDefault.conditions

    bar.id = id
    bar:SetFrameRef('MainMenuBarArtFrame', _G.MainMenuBarArtFrame)
    bar:SetFrameStrata('LOW')

    bar.buttons = {}
    bar.buttonType = buttonType

    -- self:HookScript(bar, 'OnEnter', 'func')
    -- self:HookScript(bar, 'OnLeave', 'func')

    for i = 1, 12 do
        local button = LibActionButton:CreateButton(i, bar:GetName()..'Button'..i, bar, nil)
        button:SetState(0, 'action', i)
        button:SetParent(bar)

        for k = 1, 14 do
            button:SetState(k, 'action', (k - 1) * 12 + i)
        end

        bar.buttons[i] = button

        -- self:HookScript(bar.buttons[i], 'OnEnter', 'func')
        -- self:HookScript(bar.buttons[i], 'OnLeave', 'func')
    end
    self:UpdateButtonConfig(bar, bar.buttonType)

    if conditions:find('[form]') then
        bar:SetAttribute('hasTempBar', true)
    else
        bar:SetAttribute('hasTempBar', false)
    end

    bar:SetAttribute('_onstate-page', [[
        if HasTempShapeshiftActionBar() and self:GetAttribute('hasTempBar') then
            newstate = GetTempShapeshiftBarIndex() or newstate
        end

        print(newstate)

        if newstate ~= 0 then
            self:SetAttribute('state', newstate)
            control:ChildUpdate('state', newstate)
            self:GetFrameRef('MainMenuBarArtFrame'):SetAttribute('actionpage', newstate)
        end
    ]])

    RegisterStateDriver(bar, 'page', conditions)
    bar:SetAttribute('page', self:GetPage(bar:GetName(), defaultPage, conditions))

    self.managedBars['bar'..id] = bar
end

function A.ActionBars:UpdatePositionAndSize()
    local buttonSize = 36
    local buttonGap = 6

    for k, bar in pairs(self.managedBars) do
        if k == 'MultiBarLeft' or k == 'MultiBarRight' then
            for i, button in ipairs(bar.buttons) do
                button:SetSize(buttonSize, buttonSize)
                button:SetPoint('TOP', 0, -((i - 1) * (buttonSize + buttonGap)))
                button:Show()
            end
            bar:SetSize(buttonSize, 12 * (buttonSize + buttonGap) - buttonGap)
        else
            for i, button in ipairs(bar.buttons) do
                button:SetSize(buttonSize, buttonSize)
                button:SetPoint('LEFT', (i - 1) * (buttonSize + buttonGap), 0)
                button:Show()
            end
            bar:SetSize(12 * (buttonSize + buttonGap) - buttonGap, buttonSize)
        end

        bar:ClearAllPoints()
        bar:SetPoint(strsplit(',', self.barDefaults[k].position))
        bar:Show()
    end
end

function A.ActionBars:AssignBindings(event)
    if event == 'UPDATE_BINDINGS' then
        -- update pet and stance bindings
    end

    if InCombatLockdown() then
        return
    end

    for _, bar in pairs(self.managedBars) do
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

function A.ActionBars:OnInitialize()
    for i = 1, 2 do
        self:CreateBar(i)
    end

    self:UpdatePositionAndSize()
    self:AssignBindings()

    self:RegisterEvent('UPDATE_BINDINGS', 'AssignBindings')
end

-- function A.ActionBars:OnEnable()
--     self:RegisterEvent('PLAYER_ENTERING_WORLD')
-- end

-- function A.ActionBars:PLAYER_ENTERING_WORLD(isLogin, isReload)
--     if not (isLogin or isReload) then
--         return
--     end

--     self:UpdatePositionAndSize()
--     self:AssignBindings()
-- end
