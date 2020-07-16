local AddonName = ...
local AceDB = LibStub('AceDB-3.0')
local AceConfig = LibStub('AceConfig-3.0')
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

UIPARENT_MANAGED_FRAME_POSITIONS['MultiBarBottomLeft'] = nil
UIPARENT_MANAGED_FRAME_POSITIONS['StanceBarFrame'] = nil
UIPARENT_MANAGED_FRAME_POSITIONS['PETACTIONBAR_YPOS'] = nil

ModernActionBar = LibStub('AceAddon-3.0'):NewAddon(AddonName, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0')

ModernActionBar.defaultOptions = {
    global = {
        showTextures = true,
        showGryphons = true,
        colorTextures = { 1, 1, 1, 1 },
        colorGryphons = { 1, 1, 1, 1 }
    }
}

ModernActionBar.optionsTree = {
    name = AddonName,
    handler = ModernActionBar,
    type = 'group',
    disabled = function () return InCombatLockdown() end,
    args = {
        showTextures = {
            order = 3,
            type = 'toggle',
            name = 'Show textures',
            desc = 'Show/hide all action bar textures',
            get = 'Option_GetShowTextures',
            set = 'Option_SetShowTextures'
        },
        showGryphons = {
            order = 4,
            type = 'toggle',
            name = 'Show gryphons',
            desc = 'Show/hide gryphons',
            get = 'Option_GetShowGryphons',
            set = 'Option_SetShowGryphons',
            disabled = 'Option_DisabledShowGryphons'
        },
        spacer2 = {
            order = 5,
            type = 'description',
            name = ''
        },
        colorTextures = {
            order = 6,
            type = 'color',
            name = 'Textures color',
            desc = 'Sets the color of all action bar textures except gryphons',
            hasAlpha = true,
            get = 'Option_GetColorTextures',
            set = 'Option_SetColorTextures'
        },
        colorGryphons = {
            order = 7,
            type = 'color',
            name = 'Gryphons color',
            desc = 'Sets the color of both gryphons',
            hasAlpha = true,
            get = 'Option_GetColorGryphons',
            set = 'Option_SetColorGryphons'
        }
    }
}

function ModernActionBar:OnInitialize()
    self.db = AceDB:New(AddonName..'DB', self.defaultOptions, true)
    AceConfig:RegisterOptionsTable(AddonName, self.optionsTree, nil)

    self.consoleTexture = 'Interface\\AddOns\\ModernActionBar\\Media\\Textures\\Console.tga'
    self.shouldUpdateActionBar = false
    self.shouldUpdateWatchBar = false
    self.shouldUpdatePetActionBar = false

    self.optionsFrame = AceConfigDialog:AddToBlizOptions(AddonName, AddonName..' '..GetAddOnMetadata(AddonName, 'Version'))
    self:RegisterChatCommand('mab', 'Chat_GoToOptions')
    self:RegisterChatCommand('modernactionbar', 'Chat_GoToOptions')

    self:RegisterEvent('ACTIONBAR_SHOWGRID')
    self:RegisterEvent('ACTIONBAR_HIDEGRID')
    self:SecureHook('SetActionBarToggles', 'Update_ActionBar')
    self:SecureHook('MainMenuBar_UpdateExperienceBars', 'Update_WatchBar')
    self:SecureHook('PetActionBar_UpdatePositionValues', 'Update_PetBar')

    self:Setup_ActionBar()
    self:Setup_MicroAndBagFrame()
    self:Option_Apply()
    -- self:Update_WatchBar()
    -- self:Update_PetBar()
end

function ModernActionBar:Chat_GoToOptions()
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function ModernActionBar:Setup_ActionBar()
    for index, frame in ipairs({
        MainMenuXPBarTexture1,
        MainMenuXPBarTexture2,
        MainMenuXPBarTexture3,
        MainMenuBarTexture1,
        MainMenuBarTexture2,
        MainMenuBarTexture3,
        ReputationWatchBar.StatusBar.WatchBarTexture1,
        ReputationWatchBar.StatusBar.WatchBarTexture2,
        ReputationWatchBar.StatusBar.WatchBarTexture3,
        ReputationWatchBar.StatusBar.XPBarTexture1,
        ReputationWatchBar.StatusBar.XPBarTexture2,
        ReputationWatchBar.StatusBar.XPBarTexture3,
        MainMenuBarPerformanceBarFrame,
        MainMenuBarMaxLevelBar
    }) do
        frame:Hide()
        frame:SetSize(0, 0)

        if frame.SetTexture then
            frame:SetTexture(nil)
        end
    end

    MainMenuBarTexture0:ClearAllPoints()
    MainMenuBarTexture0:SetPoint('TOPLEFT', MainMenuBarArtFrame, 'TOPLEFT', 0, 0)
    MainMenuBarTexture0:SetPoint('BOTTOMRIGHT', MainMenuBarArtFrame, 'BOTTOMRIGHT', 0, 0)
    MainMenuBarTexture0:SetTexture(self.consoleTexture)

    MainMenuXPBarTexture0:ClearAllPoints()
    MainMenuXPBarTexture0:SetPoint('TOPLEFT', MainMenuExpBar, 'TOPLEFT', 0, 0)
    MainMenuXPBarTexture0:SetPoint('BOTTOMRIGHT', MainMenuExpBar, 'BOTTOMRIGHT', 0, 0)
    MainMenuXPBarTexture0:SetTexture(self.consoleTexture)

    ActionBarUpButton:ClearAllPoints()
    ActionBarUpButton:SetPoint('TOPLEFT', MainMenuBarArtFrame, 'TOPLEFT', 506, -2)

    ActionBarDownButton:ClearAllPoints()
    ActionBarDownButton:SetPoint('BOTTOMLEFT', MainMenuBarArtFrame, 'BOTTOMLEFT', 506, -4)

    MainMenuBarPageNumber:ClearAllPoints()
    MainMenuBarPageNumber:SetPoint('LEFT', MainMenuBarArtFrame, 'LEFT', 538, -3)

    ReputationWatchBar.StatusBar.WatchBarTexture0:ClearAllPoints()
    ReputationWatchBar.StatusBar.WatchBarTexture0:SetPoint('TOPLEFT', ReputationWatchBar.StatusBar, 'TOPLEFT', 0, 0)
    ReputationWatchBar.StatusBar.WatchBarTexture0:SetPoint('BOTTOMRIGHT', ReputationWatchBar.StatusBar, 'BOTTOMRIGHT', 0, 0)
    ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexture(self.consoleTexture)

    ReputationWatchBar.StatusBar.XPBarTexture0:ClearAllPoints()
    ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint('TOPLEFT', ReputationWatchBar.StatusBar, 'TOPLEFT', 0, 0)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint('BOTTOMRIGHT', ReputationWatchBar.StatusBar, 'BOTTOMRIGHT', 0, 0)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetTexture(self.consoleTexture)

    MultiBarBottomRight:SetWidth(261)

    for index = 1, NUM_ACTIONBAR_BUTTONS / 2 do
        _G['MultiBarBottomRightButton'..index..'FloatingBG']:SetTexture(nil)
    end

    for index = 7, NUM_ACTIONBAR_BUTTONS do
        local button = _G['MultiBarBottomRightButton'..index]
        button:ClearAllPoints()

        if index == 7 then
            button:SetPoint('BOTTOMLEFT', MultiBarBottomRightButton1, 'TOPLEFT', 0, 16)
        else
            button:SetPoint('LEFT', _G['MultiBarBottomRightButton'..(index - 1)], 'RIGHT', 6, 0)
        end
    end

    for index = 1, GetNumShapeshiftForms() do
        local button = _G['StanceButton'..index]
        local texture = _G['StanceButton'..index..'NormalTexture2']

        if texture then
            texture:ClearAllPoints()
            texture:SetPoint('TOPLEFT', button, 'TOPLEFT', -10, 10)
            texture:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 10, -10)
        end
    end

    for index, button in ipairs({
        MultiBarBottomRightButton1,
        MultiBarBottomRightButton2,
        MultiBarBottomRightButton3,
        MultiBarBottomRightButton4,
        MultiBarBottomRightButton5,
        MultiBarBottomRightButton6
    }) do
        self:SecureHookScript(button, 'OnReceiveDrag', function()
            self:Update_ButtonGridAlpha(button:GetName(), 1)
        end)
    end
end

function ModernActionBar:Setup_MicroAndBagFrame()
    self.MicroAndBagFrame = CreateFrame('Frame', nil, UIParent)

    local microButtons = {
        CharacterMicroButton,
        SpellbookMicroButton,
        TalentMicroButton,
        QuestLogMicroButton,
        SocialsMicroButton,
        WorldMapMicroButton,
        MainMenuMicroButton,
        HelpMicroButton
    }

    self.MicroAndBagFrame = CreateFrame('Frame', 'ModernActionBarBags', UIParent)
    self.MicroAndBagFrame:SetSize(224, 89)
    self.MicroAndBagFrame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT')
    self.MicroAndBagFrame.Texture = self.MicroAndBagFrame:CreateTexture(nil, 'BACKGROUND')
    self.MicroAndBagFrame.Texture:SetTexture('Interface\\AddOns\\ModernActionBar\\Media\\Textures\\Console.tga')
    self.MicroAndBagFrame.Texture:SetAllPoints()
    self.MicroAndBagFrame.Texture:SetTexCoord(0.78125, 1, 0.65234375, 1)

    MainMenuBarBackpackButton:ClearAllPoints()
    MainMenuBarBackpackButton:SetPoint('BOTTOMRIGHT', self.MicroAndBagFrame, 'BOTTOMRIGHT', -7, 47)

    KeyRingButton:ClearAllPoints()
    KeyRingButton:SetSize(14, 28)
    KeyRingButton:SetPoint('BOTTOMRIGHT', MainMenuBarBackpackButton, 'BOTTOMLEFT', -6, 0)

    CharacterBag0Slot:ClearAllPoints()
    CharacterBag0Slot:SetPoint('RIGHT', KeyRingButton, 'LEFT', -4, 0)

    CharacterBag1Slot:ClearAllPoints()
    CharacterBag1Slot:SetPoint('RIGHT', CharacterBag0Slot, 'LEFT', -4, 0)

    CharacterBag2Slot:ClearAllPoints()
    CharacterBag2Slot:SetPoint('RIGHT', CharacterBag1Slot, 'LEFT', -4, 0)

    CharacterBag3Slot:ClearAllPoints()
    CharacterBag3Slot:SetPoint('RIGHT', CharacterBag2Slot, 'LEFT', -4, 0)

    for index, button in ipairs({
        CharacterBag0Slot,
        CharacterBag1Slot,
        CharacterBag2Slot,
        CharacterBag3Slot
    }) do
        button:SetSize(28, 28)
        _G[button:GetName()..'NormalTexture']:ClearAllPoints()
        _G[button:GetName()..'NormalTexture']:SetPoint('TOPLEFT', button, 'TOPLEFT', -10, 10)
        _G[button:GetName()..'NormalTexture']:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 10, -10)
    end

    for index, button in ipairs(microButtons) do
        button:ClearAllPoints()

        if index == 1 then
            button:SetPoint('BOTTOMLEFT', self.MicroAndBagFrame, 'BOTTOMLEFT', 8, 3)
        else
            button:SetPoint('LEFT', microButtons[index - 1], 'RIGHT', -3, 0)
        end
    end
end

function ModernActionBar:Update_ButtonGridAlpha(name, alpha)
    _G[name..'NormalTexture']:SetAlpha(alpha)
    _G[name..'HotKey']:SetAlpha(alpha)
    _G[name..'Count']:SetAlpha(alpha)
    _G[name..'Name']:SetAlpha(alpha)
    _G[name..'Cooldown']:SetAlpha(alpha)
end

function ModernActionBar:Update_BottomRightGrid(show)
    -- Have to use alpha of button due to combat lockdown restriction
    for index = 1, 6 do
        local buttonName = 'MultiBarBottomRightButton'..index
        self:Update_ButtonGridAlpha(buttonName, show and 1 or (_G[buttonName].eventsRegistered and 1 or 0))
    end
end

function ModernActionBar:Update_ActionBar()
    if InCombatLockdown() then
        self.shouldUpdateActionBar = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end

    StanceBarFrame:ClearAllPoints()

    if SHOW_MULTI_ACTIONBAR_1 then
        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 0, 16)
        StanceBarFrame:SetPoint('BOTTOMLEFT', MultiBarBottomLeftButton1, 'TOPLEFT', 30, 6)
    else
        StanceBarFrame:SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 30, 9)
    end

    if SHOW_MULTI_ACTIONBAR_2 then
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint('BOTTOMLEFT', ActionButton12, 'BOTTOMRIGHT', 46, 0)

        MainMenuBar:SetSize(806, 49)
        MainMenuBarTexture0:SetTexCoord(0, 0.787109375, 0, 0.19140625)

        MainMenuExpBar:SetSize(806, 16)
        MainMenuXPBarTexture0:SetTexCoord(0, 0.787109375, 0.23046875, 0.29296875)

        ReputationWatchBar:SetSize(806, 16)
        ReputationWatchBar.StatusBar:SetSize(806, 16)

        ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexCoord(0, 0.787109375, 0.23046875, 0.29296875)
        ReputationWatchBar.StatusBar.XPBarTexture0:SetTexCoord(0, 0.787109375, 0.23046875, 0.29296875)
    else
        MainMenuBar:SetSize(552, 49)
        MainMenuBarTexture0:SetTexCoord(0, 0.5390625, 0.70703125, 0.8984375)

        MainMenuExpBar:SetSize(552, 16)
        MainMenuXPBarTexture0:SetTexCoord(0, 0.5390625, 0.9375, 1)

        ReputationWatchBar:SetSize(552, 16)
        ReputationWatchBar.StatusBar:SetSize(552, 16)

        ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexCoord(0, 0.5390625, 0.9375, 1)
        ReputationWatchBar.StatusBar.XPBarTexture0:SetTexCoord(0, 0.5390625, 0.9375, 1)
    end
end

function ModernActionBar:Update_WatchBar()
    if InCombatLockdown() then
        self.shouldUpdateWatchBar = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end

    local showExperience = UnitLevel('player') < MAX_PLAYER_LEVEL
    local showReputation = (select(1, GetWatchedFactionInfo())) ~= nil

    MainMenuBar:ClearAllPoints()
    MainMenuBarLeftEndCap:ClearAllPoints()
    MainMenuBarRightEndCap:ClearAllPoints()

    if showExperience or showReputation then
        MainMenuBar:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 16)
        MainMenuBarLeftEndCap:SetPoint('BOTTOMRIGHT', MainMenuBarArtFrame, 'BOTTOMLEFT', 30, -16)
        MainMenuBarRightEndCap:SetPoint('BOTTOMLEFT', MainMenuBarArtFrame, 'BOTTOMRIGHT', -30, -16)
    else
        MainMenuBar:SetPoint('BOTTOM', UIParent, 'BOTTOM')
        MainMenuBarLeftEndCap:SetPoint('BOTTOMRIGHT', MainMenuBarArtFrame, 'BOTTOMLEFT', 30, 0)
        MainMenuBarRightEndCap:SetPoint('BOTTOMLEFT', MainMenuBarArtFrame, 'BOTTOMRIGHT', -30, 0)
    end

    if showReputation then
        MainMenuExpBar:Hide()
        ReputationWatchBar:ClearAllPoints()
        ReputationWatchBar:SetPoint('BOTTOM', UIParent, 'BOTTOM')
    elseif showExperience then
        MainMenuExpBar:ClearAllPoints()
        MainMenuExpBar:SetPoint('BOTTOM', UIParent, 'BOTTOM')
    end

    self:Update_ActionBar()
end

function ModernActionBar:Update_PetBar()
    if InCombatLockdown() then
        self.shouldUpdatePetActionBar = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end

    if SHOW_MULTI_ACTIONBAR_1 then
        PETACTIONBAR_YPOS = 141
    else
        PETACTIONBAR_YPOS = 93
    end
end

function ModernActionBar:PLAYER_REGEN_ENABLED()
    if self.shouldUpdateActionBar then
        self:Update_ActionBar()
        self.shouldUpdateActionBar = false
    end

    if self.shouldUpdateWatchBar then
        self:Update_WatchBar()
        self.shouldUpdateWatchBar = false
    end

    if self.shouldUpdatePetActionBar then
        self:Update_PetBar()
        self.shouldUpdatePetActionBar = false
    end

    self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function ModernActionBar:ACTIONBAR_SHOWGRID()
    self:Update_BottomRightGrid(true)
end

function ModernActionBar:ACTIONBAR_HIDEGRID()
    self:Update_BottomRightGrid(false)
end

function ModernActionBar:Option_Apply()
    if self.db.global.showTextures then
        MainMenuBarTexture0:Show()
        MainMenuXPBarTexture0:Show()
        ReputationWatchBar.StatusBar.WatchBarTexture0:Show()
        ReputationWatchBar.StatusBar.XPBarTexture0:Show()

        if self.db.global.showGryphons then
            MainMenuBarLeftEndCap:Show()
            MainMenuBarRightEndCap:Show()
        else
            MainMenuBarLeftEndCap:Hide()
            MainMenuBarRightEndCap:Hide()
        end
    else
        MainMenuBarTexture0:Hide()
        MainMenuXPBarTexture0:Hide()
        ReputationWatchBar.StatusBar.WatchBarTexture0:Hide()
        ReputationWatchBar.StatusBar.XPBarTexture0:Hide()
        MainMenuBarLeftEndCap:Hide()
        MainMenuBarRightEndCap:Hide()
    end

    local r1, g1, b1, a1 = unpack(self.db.global.colorTextures)
    MainMenuBarTexture0:SetVertexColor(r1, g1, b1, a1)
    MainMenuXPBarTexture0:SetVertexColor(r1, g1, b1, a1)
    ReputationWatchBar.StatusBar.WatchBarTexture0:SetVertexColor(r1, g1, b1, a1)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetVertexColor(r1, g1, b1, a1)

    local r2, g2, b2, a2 = unpack(self.db.global.colorGryphons)
    MainMenuBarLeftEndCap:SetVertexColor(r2, g2, b2, a2)
    MainMenuBarRightEndCap:SetVertexColor(r2, g2, b2, a2)
end

--[[ Show/hide textures ]]
function ModernActionBar:Option_GetShowTextures(info)
    return self.db.global.showTextures
end

function ModernActionBar:Option_SetShowTextures(info, showTextures)
    self.db.global.showTextures = showTextures
    self:Option_Apply()
end

--[[ Show/hide gryphons ]]
function ModernActionBar:Option_GetShowGryphons(info)
    return self.db.global.showGryphons
end

function ModernActionBar:Option_SetShowGryphons(info, showGryphons)
    self.db.global.showGryphons = showGryphons
    self:Option_Apply()
end

function ModernActionBar:Option_DisabledShowGryphons(info)
    return InCombatLockdown() or not self.db.global.showTextures
end

--[[ Set color for textures ]]
function ModernActionBar:Option_GetColorTextures(info)
    return unpack(self.db.global.colorTextures)
end
function ModernActionBar:Option_SetColorTextures(info, ...)
    self.db.global.colorTextures = { ... }
    self:Option_Apply()
end

--[[ Set color for gryphons ]]
function ModernActionBar:Option_GetColorGryphons(info)
    return unpack(self.db.global.colorGryphons)
end

function ModernActionBar:Option_SetColorGryphons(info, ...)
    self.db.global.colorGryphons = { ... }
    self:Option_Apply()
end