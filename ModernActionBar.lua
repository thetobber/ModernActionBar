local NAME, _ = ...

local AceConfigDialog = LibStub('AceConfigDialog-3.0')

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

local function UpdateButtonStyle(self, button)
    if not button.styled then
        local path = 'Interface\\AddOns\\'..NAME..'\\Textures\\'
        local name = button:GetName()

        button:SetNormalTexture(path..'Button\\UI-Quickslot2.tga')
        button:SetPushedTexture(path..'Button\\UI-Quickslot-Depress.tga')
        button:SetHighlightTexture(path..'Button\\ButtonHilight-Square.tga')
        button:SetCheckedTexture(path..'Button\\CheckButtonHilight.tga')

        local flash = button.Flash
        if flash then
            flash:SetTexture(path..'Button\\UI-QuickslotRed.tga')
        end

        local border = button.Border
        if border then
            border:SetTexture(path..'Button\\UI-ActionButton-Border.tga')
        end

        local autoCastable = button.AutoCastable
        if autoCastable then
            autoCastable:SetTexture(path..'Button\\UI-AutoCastableOverlay.tga')
        end

        local cooldown = button.Cooldown or _G[name..'Cooldown']
        if cooldown then
            cooldown:SetSwipeTexture(path..'ButtonSwipe.tga')
        end

        local icon = button.Icon or _G[name..'Icon']
        if icon then
            local mask = button:CreateMaskTexture()

            mask:SetTexture(path..'ButtonMask.tga')
            mask:SetPoint('TOPLEFT', -2, 2)
            mask:SetPoint('BOTTOMRIGHT', 2, -2)

            icon:AddMaskTexture(mask)
            icon:ClearAllPoints()
            icon:SetPoint('TOPLEFT', -4, 4)
            icon:SetPoint('BOTTOMRIGHT', 4, -4)
        end

        local floatingBg = _G[name..'FloatingBG']
        if floatingBg then
            floatingBg:SetTexture(path..'Button\\UI-Quickslot.tga')
        end

        button.styled = true
    end
end

ModernActionBar = LibStub('AceAddon-3.0')
    :NewAddon(NAME, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0')

ModernActionBar:NewModule(
    'ActionBar',
    { EmptyFunc = EmptyFunc, UpdateButtonStyle = UpdateButtonStyle },
    'AceHook-3.0',
    'AceEvent-3.0'
)

ModernActionBar:NewModule(
    'MicroBar',
    'AceHook-3.0',
    'AceEvent-3.0'
)

ModernActionBar:NewModule(
    'BagBar',
    { EmptyFunc = EmptyFunc, UpdateButtonStyle = UpdateButtonStyle },
    'AceHook-3.0',
    'AceEvent-3.0'
)

ModernActionBar:NewModule(
    'StanceBar',
    { EmptyFunc = EmptyFunc, RemoveTexture = RemoveTexture, UpdateButtonStyle = UpdateButtonStyle },
    'AceHook-3.0',
    'AceEvent-3.0'
)

ModernActionBar:NewModule(
    'PetBar',
    { EmptyFunc = EmptyFunc, UpdateButtonStyle = UpdateButtonStyle },
    'AceHook-3.0',
    'AceEvent-3.0'
)

ModernActionBar.optionsTree = {
    name = name,
    type = 'group',
    disabled = InCombatLockdown,
    args = {},
}

ModernActionBar.dbDefaults = {
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

ModernActionBar.optionButtons = {
    ReputationDetailMainScreenCheckBox,
    ReputationDetailInactiveCheckBox,
    InterfaceOptionsActionBarsPanelBottomLeft,
    InterfaceOptionsActionBarsPanelBottomRight,
    InterfaceOptionsActionBarsPanelRight,
    InterfaceOptionsActionBarsPanelRightTwo,
    InterfaceOptionsActionBarsPanelAlwaysShowActionBars,
}

function ModernActionBar:OnInitialize()
    self.db = LibStub('AceDB-3.0')
        :New(NAME..'DB', self.dbDefaults, true)

    LibStub('AceConfig-3.0')
        :RegisterOptionsTable(NAME, self.optionsTree, nil)

    self.optionsFrame = CreateFrame('Frame', NAME..'Options', _G.UIParent)

    -- self.optionsFrame = LibStub('AceConfigDialog-3.0')
    --     :AddToBlizOptions(name, name)

    self:RegisterChatCommand('mab', 'OpenInterfaceOptions')
    self:RegisterChatCommand('modernactionbar', 'OpenInterfaceOptions')
end

function ModernActionBar:OnEnable()
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
    self:RegisterEvent('PLAYER_REGEN_ENABLED')
    self:RegisterEvent('PLAYER_REGEN_DISABLED')

    self:SecureHook('InterfaceOptionsOptionsFrame_RefreshCategories', function()
        if InCombatLockdown() then
            InterfaceOptionsActionBarsPanelRightTwo:Disable()
        end
    end)
end

function ModernActionBar:PLAYER_ENTERING_WORLD(isLogin, isReload)
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

function ModernActionBar:PLAYER_REGEN_ENABLED()
    if self.shouldOpenOptions then
        AceConfigDialog:Open(NAME)
    end

    for index, button in ipairs(self.optionButtons) do
        button:Enable()
    end
end

function ModernActionBar:PLAYER_REGEN_DISABLED()
    if AceConfigDialog.OpenFrames[NAME] then
        AceConfigDialog:Close(NAME)
        self.shouldOpenOptions = true
    end

    for index, button in ipairs(self.optionButtons) do
        button:Disable()
    end
end

function ModernActionBar:OpenInterfaceOptions()
    if InCombatLockdown() then
        self.shouldOpenOptions = true
    else
        AceConfigDialog:Open(NAME)
    end
    -- InterfaceOptionsFrame_OpenToCategory(self.interfaceOptions)
    -- InterfaceOptionsFrame_OpenToCategory(InterfaceOptionsActionBarsPanel)
end
