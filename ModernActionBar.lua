local NAME, _ = ...
local _G = getfenv(0)
local CreateFrame = _G.CreateFrame
local InCombatLockdown = _G.InCombatLockdown
local ipairs = _G.ipairs
local hooksecurefunc = _G.hooksecurefunc
local floor = _G.floor

local AceAddon = _G.LibStub('AceAddon-3.0')
local AceDB = _G.LibStub('AceDB-3.0')
local AceConfig = _G.LibStub('AceConfig-3.0')
local AceConfigDialog = _G.LibStub('AceConfigDialog-3.0')

local function EmptyFunc() end

local function RemoveFrame(self, frame)
    frame:UnregisterAllEvents()
    frame:SetScript('OnEvent', nil)
    frame:SetScript('OnUpdate', nil)
    frame:SetScript('OnShow', nil)
    frame:SetScript('OnHide', nil)
    frame:Hide()
    frame.SetScript = EmptyFunc
    frame.RegisterEvent = EmptyFunc
    frame.RegisterAllEvents = EmptyFunc
    frame.Show = EmptyFunc
end

local function RemoveTexture(self, texture)
    texture:SetTexture(nil)
    texture:Hide()
    texture.Show = EmptyFunc
end

hooksecurefunc('ActionButton_UpdateRangeIndicator', function(self, checksRange, inRange)
    if self.HotKey:GetText() == _G.RANGE_INDICATOR then
        if checksRange and inRange then
            self.HotKey:SetVertexColor(1, 1, 1, 1)
        end
    else
        if checksRange and not inRange then
            self.HotKey:SetVertexColor(_G.RED_FONT_COLOR:GetRGB())
        else
            self.HotKey:SetVertexColor(1, 1, 1, 1)
        end
    end
end)

local function StyleButton(self, button)
    if not button.styled then
        local path = 'Interface\\AddOns\\'..NAME..'\\Textures\\'
        local name = button:GetName()
        local size = floor(button:GetSize())

        button:GetNormalTexture():SetAlpha(0)

        button.NormalTex = button:CreateTexture(nil, 'ARTWORK')
        button.NormalTex:SetTexture(path..'Button\\Normal.tga')
        button.NormalTex:SetAllPoints()

        button:SetPushedTexture(path..'Button\\Pushed.tga')
        button:GetPushedTexture():ClearAllPoints()
        button:GetPushedTexture():SetAllPoints()

        button:SetHighlightTexture(path..'Button\\Highlight.tga')
        button:GetHighlightTexture():ClearAllPoints()
        button:GetHighlightTexture():SetAllPoints()

        button:SetCheckedTexture(path..'Button\\Checked.tga')
        button:GetCheckedTexture():ClearAllPoints()
        button:GetCheckedTexture():SetAllPoints()

        local flash = button.Flash
        if flash then
            flash:SetTexture(path..'Button\\Flash.tga')
            flash:ClearAllPoints()
            flash:SetAllPoints()
        end

        local border = button.Border
        if border then
            border:SetTexture(path..'Button\\Border.tga')
            border:ClearAllPoints()
            border:SetAllPoints()
        end

        local autoCastable = _G[name..'AutoCastable'] or button.AutoCastable
        if autoCastable then
            autoCastable:SetTexture(path..'Button\\AutoCastable.tga')
            autoCastable:ClearAllPoints()
            autoCastable:SetAllPoints()
        end

        local cooldown = button.cooldown or button.Cooldown
        if cooldown then
            cooldown:SetSwipeTexture(path..'Button\\Swipe.tga')
            cooldown:SetSwipeColor(0, 0, 0, 1)

            cooldown:ClearAllPoints()
            cooldown:SetAllPoints()
        end

        local icon = button.icon or button.Icon
        if icon then
            icon:ClearAllPoints()
            icon:SetPoint('CENTER')
            icon:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375)
            icon:SetSize(size - 4, size - 4)
        end

        local floatingBg = _G[name..'FloatingBG']
        if floatingBg then
            floatingBg:SetTexture(path..'Button\\Floating.tga')
            floatingBg:ClearAllPoints()
            floatingBg:SetAllPoints()
        end

        local hotKey = button.HotKey
        if hotKey then
            hotKey:ClearAllPoints()
            hotKey:SetDrawLayer('OVERLAY')
            hotKey:SetFontObject('MAB_ButtonNormalFont')
            hotKey:SetJustifyH('RIGHT')
            hotKey:SetPoint('TOP')
            hotKey:SetSize(size - 4, 16)
        end

        local count = button.Count
        if count then
            count:ClearAllPoints()
            count:SetDrawLayer('OVERLAY')
            count:SetFontObject('MAB_ButtonNormalFont')
            count:SetJustifyH('RIGHT')
            count:SetPoint('BOTTOM')
            count:SetSize(size - 4, 16)
        end

        local macro = button.Name
        if macro then
            macro:ClearAllPoints()
            macro:SetDrawLayer('OVERLAY')
            macro:SetFontObject('MAB_ButtonNormalFont')
            macro:SetJustifyH('LEFT')
            macro:SetPoint('BOTTOM')
            macro:SetSize(size - 4, 16)
        end

        button.styled = true
    end
end

_G.ModernActionBar = AceAddon:NewAddon(NAME, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0')

_G.ModernActionBar:NewModule(
    'ActionBar',
    { EmptyFunc = EmptyFunc, StyleButton = StyleButton },
    'AceHook-3.0',
    'AceEvent-3.0'
)

_G.ModernActionBar:NewModule(
    'MicroBar',
    'AceHook-3.0',
    'AceEvent-3.0'
)

_G.ModernActionBar:NewModule(
    'BagBar',
    { EmptyFunc = EmptyFunc, StyleButton = StyleButton },
    'AceHook-3.0',
    'AceEvent-3.0'
)

_G.ModernActionBar:NewModule(
    'StanceBar',
    { EmptyFunc = EmptyFunc, RemoveTexture = RemoveTexture, StyleButton = StyleButton },
    'AceHook-3.0',
    'AceEvent-3.0'
)

_G.ModernActionBar:NewModule(
    'PetBar',
    { EmptyFunc = EmptyFunc, StyleButton = StyleButton },
    'AceHook-3.0',
    'AceEvent-3.0'
)

_G.ModernActionBar.optionsTree = {
    name = name,
    type = 'group',
    args = {},
}

_G.ModernActionBar.dbDefaults = {
    global = {
        actionBar = {
            background = true,
            gryphons = true,
            vehicleLeaveButton = {
                anchor = 'BOTTOMLEFT',
                xOffset = 362,
                yOffset = 115,
            }
        },
        bagBar = {
            enabled = true,
            mouseOver = false,
            anchor = 'BOTTOMRIGHT',
            xOffset = -2,
            yOffset = 50,
        },
        microBar = {
            enabled = true,
            mouseOver = false,
            anchor = 'BOTTOMRIGHT',
            xOffset = -2,
            yOffset = 2,
        },
    },
}

_G.ModernActionBar.optionButtons = {
    _G.ReputationDetailMainScreenCheckBox,
    _G.ReputationDetailInactiveCheckBox,
    _G.InterfaceOptionsActionBarsPanelBottomLeft,
    _G.InterfaceOptionsActionBarsPanelBottomRight,
    _G.InterfaceOptionsActionBarsPanelRight,
    _G.InterfaceOptionsActionBarsPanelRightTwo,
    _G.InterfaceOptionsActionBarsPanelAlwaysShowActionBars,
}

function _G.ModernActionBar:OnInitialize()
    self.db = AceDB:New(NAME..'DB', self.dbDefaults, true)
    AceConfig:RegisterOptionsTable(NAME, self.optionsTree, nil)

    self:RegisterChatCommand('mab', 'OpenInterfaceOptions')
    self:RegisterChatCommand('modernactionbar', 'OpenInterfaceOptions')
end

function _G.ModernActionBar:OnEnable()
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
    self:RegisterEvent('PLAYER_REGEN_ENABLED')
    self:RegisterEvent('PLAYER_REGEN_DISABLED')

    self:SecureHook('InterfaceOptionsOptionsFrame_RefreshCategories', function()
        if InCombatLockdown() then
            _G.InterfaceOptionsActionBarsPanelRightTwo:Disable()
        end
    end)
end

function _G.ModernActionBar:PLAYER_ENTERING_WORLD(isLogin, isReload)
    if isLogin or isReload then
        for index, frame in ipairs({
            _G.MainMenuBarPerformanceBarFrame,
            _G.MainMenuBarMaxLevelBar
        }) do
            RemoveFrame(self, frame)
        end

        for index, texture in ipairs({
            _G.MainMenuBarTexture1,
            _G.MainMenuBarTexture2,
            _G.MainMenuBarTexture3,
            _G.MainMenuXPBarTexture0,
            _G.MainMenuXPBarTexture1,
            _G.MainMenuXPBarTexture2,
            _G.MainMenuXPBarTexture3,
            _G.ReputationWatchBar.StatusBar.WatchBarTexture0,
            _G.ReputationWatchBar.StatusBar.WatchBarTexture1,
            _G.ReputationWatchBar.StatusBar.WatchBarTexture2,
            _G.ReputationWatchBar.StatusBar.WatchBarTexture3,
            _G.ReputationWatchBar.StatusBar.XPBarTexture0,
            _G.ReputationWatchBar.StatusBar.XPBarTexture1,
            _G.ReputationWatchBar.StatusBar.XPBarTexture2,
            _G.ReputationWatchBar.StatusBar.XPBarTexture3,
            _G.MainMenuMaxLevelBar0,
            _G.MainMenuMaxLevelBar1,
            _G.MainMenuMaxLevelBar2,
            _G.MainMenuMaxLevelBar3,
            _G.MultiBarBottomRightButton1FloatingBG,
            _G.MultiBarBottomRightButton2FloatingBG,
            _G.MultiBarBottomRightButton3FloatingBG,
            _G.MultiBarBottomRightButton4FloatingBG,
            _G.MultiBarBottomRightButton5FloatingBG,
            _G.MultiBarBottomRightButton6FloatingBG,
            _G.StanceBarLeft,
            _G.StanceBarMiddle,
            _G.StanceBarRight,
            _G.SlidingActionBarTexture0,
            _G.SlidingActionBarTexture1,
        }) do
            RemoveTexture(self, texture)
        end

        if not self.db.global.bagBar.enabled then
            self:DisableModule('BagBar')
        end

        if not self.db.global.microBar.enabled then
            self:DisableModule('MicroBar')
        end
    end
end

function _G.ModernActionBar:PLAYER_REGEN_ENABLED()
    if self.shouldOpenOptions then
        AceConfigDialog:Open(NAME)
    end

    for index, button in ipairs(self.optionButtons) do
        button:Enable()
    end
end

function _G.ModernActionBar:PLAYER_REGEN_DISABLED()
    if AceConfigDialog.OpenFrames[NAME] then
        AceConfigDialog:Close(NAME)
        self.shouldOpenOptions = true
    end

    for index, button in ipairs(self.optionButtons) do
        button:Disable()
    end
end

function _G.ModernActionBar:OpenInterfaceOptions()
    if InCombatLockdown() then
        self.shouldOpenOptions = true
    else
        AceConfigDialog:Open(NAME)
    end
end
