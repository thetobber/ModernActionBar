local N, T = select(1, ...), 'Interface\\AddOns\\ModernActionBar\\Console.tga'

UIPARENT_MANAGED_FRAME_POSITIONS['MultiBarBottomLeft'] = nil
UIPARENT_MANAGED_FRAME_POSITIONS['StanceBarFrame'] = nil
UIPARENT_MANAGED_FRAME_POSITIONS['PETACTIONBAR_YPOS'] = nil

local function emptyFunc() end

local function removeFrame(frame)
    if type(frame) == 'table' and frame.SetScript then
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
end

local function removeTexture(texture)
    if type(texture) == 'table' and texture.SetTexture then
        texture:SetTexture(nil)
        texture:Hide()
        texture.Show = emptyFunc
    end
end

local unusedFrames = {
    MainMenuBarPerformanceBarFrame,
    MainMenuBarMaxLevelBar,
}

local unusedTextures = {
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
}

local optionButtons = {
    ReputationDetailMainScreenCheckBox,
    ReputationDetailInactiveCheckBox,
    InterfaceOptionsActionBarsPanelBottomLeft,
    InterfaceOptionsActionBarsPanelBottomRight,
    InterfaceOptionsActionBarsPanelRight,
    InterfaceOptionsActionBarsPanelRightTwo,
    InterfaceOptionsActionBarsPanelAlwaysShowActionBars,
}

local f1 = CreateFrame('Frame')
f1:RegisterEvent('ADDON_LOADED')
f1:RegisterEvent('PLAYER_ENTERING_WORLD')
f1:RegisterEvent('ACTIONBAR_SHOWGRID')
f1:RegisterEvent('ACTIONBAR_HIDEGRID')
f1:RegisterEvent('PLAYER_REGEN_ENABLED')
f1:RegisterEvent('PLAYER_REGEN_DISABLED')

local function f1_setBtnVisible(name, visible)
    local alpha = 0

    if visible then
        alpha = 1
        _G[name..'NormalTexture']:SetAlpha(0.5)
    else
        _G[name..'NormalTexture']:SetAlpha(alpha)
    end

    _G[name..'HotKey']:SetAlpha(alpha)
    _G[name..'Count']:SetAlpha(alpha)
    _G[name..'Name']:SetAlpha(alpha)
    _G[name..'Cooldown']:SetAlpha(alpha)
end

local function f1_setBtnGridVisible(visible)
    for i = 1, 6 do
        local name = 'MultiBarBottomRightButton'..i

        if _G[name].eventsRegistered or visible then
            f1_setBtnVisible(name, true)
        else
            f1_setBtnVisible(name, false)
        end
    end
end

local function f1_enableOptionButtons()
    for i, btn in ipairs(optionButtons) do
        btn:Enable()
    end
end

local function f1_disableOptionButtons()
    for i, btn in ipairs(optionButtons) do
        btn:Disable()
    end
end

local function f1_useSmallMainMenuBar()
    if InCombatLockdown() then
        return
    end

    MainMenuBar:SetSize(552, 70)
    MainMenuBarTexture0:SetTexCoord(0, 0.5390625, 0.7265625, 1)
end

local function f1_useLargeMainMenuBar()
    if InCombatLockdown() then
        return
    end

    MainMenuBar:SetSize(806, 70)
    MainMenuBarTexture0:SetTexCoord(0, 0.787109375, 0, 0.2734375)
end

local function f1_updateActionBars()
    if InCombatLockdown() then
        return
    end

    if StanceBarFrame:IsShown() then
        StanceBarFrame:ClearAllPoints()

        if SHOW_MULTI_ACTIONBAR_1 then
            StanceBarFrame:_SetPoint('BOTTOMLEFT', MultiBarBottomLeftButton1, 'TOPLEFT', 30, 6)
        else
            StanceBarFrame:_SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 30, 9)
        end
    end

    if SHOW_MULTI_ACTIONBAR_2 then
        f1_useLargeMainMenuBar()
    else
        f1_useSmallMainMenuBar()
    end
end

local function f1_updateWatchBars()
    if InCombatLockdown() then
        return
    end

    local showExp = MainMenuExpBar:IsShown()
    local showRep = ReputationWatchBar:IsShown()

    if showExp or showRep then
        MainMenuBar:SetPoint('BOTTOM')

        if showRep then
            MainMenuExpBar:Hide()
            MainMenuExpBar.pauseUpdates = true
        elseif UnitLevel('player') < MAX_PLAYER_LEVEL then
            MainMenuExpBar:Show()
            MainMenuExpBar.pauseUpdates = nil
        end
    else
        MainMenuBar:SetPoint('BOTTOM', 0, -16)
    end
end

local function f1_updatePetBar()
    if InCombatLockdown() then
        return
    end

    if PetActionBarFrame:IsShown() then
        PetActionBarFrame:ClearAllPoints()

        if SHOW_MULTI_ACTIONBAR_1 then
            PetActionBarFrame:_SetPoint('BOTTOMLEFT', MultiBarBottomLeftButton1, 'TOPLEFT', 30, 6)
        else
            PetActionBarFrame:_SetPoint('BOTTOMLEFT', ActionButton1, 'TOPLEFT', 30, 9)
        end
    end
end

local function f1_onAddonLoaded(self, addonName)
    if addonName == N then
        ReputationWatchBar._SetPoint = ReputationWatchBar.SetPoint
        ReputationWatchBar.SetPoint = function(self, ...)
            self:SetSize(MainMenuBar:GetWidth(), 16)
            self:ClearAllPoints()
            self:_SetPoint('BOTTOMLEFT', MainMenuBar, 'BOTTOMLEFT')
            self:_SetPoint('BOTTOMRIGHT', MainMenuBar, 'BOTTOMRIGHT')

            self.StatusBar:ClearAllPoints()
            self.StatusBar:SetAllPoints()
        end

        StanceBarFrame._SetPoint = StanceBarFrame.SetPoint
        StanceBarFrame.SetPoint = emptyFunc

        PetActionBarFrame._SetPoint = PetActionBarFrame.SetPoint
        PetActionBarFrame.SetPoint = emptyFunc

        hooksecurefunc('SetActionBarToggles', f1_updateActionBars)
        hooksecurefunc('MainMenuBar_UpdateExperienceBars', f1_updateWatchBars)
        hooksecurefunc('PetActionBar_UpdatePositionValues', f1_updatePetBar)
        hooksecurefunc('InterfaceOptionsOptionsFrame_RefreshCategories', function()
            if InCombatLockdown() then
                f1_disableOptionButtons()
            end
        end)

        self:UnregisterEvent('ADDON_LOADED')
    end
end

local function f1_onPlayerEnteringWorld(isLogin, isReload)
    if isLogin or isReload then
        -- remove unused frames and textures
        for _, frame in ipairs(unusedFrames) do
            removeFrame(frame)
        end

        for _, texture in ipairs(unusedTextures) do
            removeTexture(texture)
        end

        for i = 1, 12 do
            local btn = _G['ActionButton'..i]

            btn:ClearAllPoints()
            btn:SetSize(36, 36)
            btn:SetPoint('TOPLEFT', (i - 1) * 42 + 9, -14)
        end

        MultiBarBottomLeft:SetSize(498, 36)
        for i = 1, 12 do
            local btn = _G['MultiBarBottomLeftButton'..i]

            btn:ClearAllPoints()
            btn:SetSize(36, 36)
            btn:SetPoint('LEFT', (i - 1) * 42, 0)
        end

        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint('BOTTOMRIGHT', MainMenuBar, 'BOTTOMRIGHT', -8, 20)
        MultiBarBottomRight:SetSize(246, 89)
        for i = 1, 12 do
            local btn = _G['MultiBarBottomRightButton'..i]

            btn:ClearAllPoints()
            btn:SetSize(36, 36)

            if i < 7 then
                removeTexture(_G['MultiBarBottomRightButton'..i..'FloatingBG'])
                btn:SetPoint('BOTTOMLEFT', (i - 1) * 42, 0)
                btn:GetNormalTexture():SetAlpha(1)

                btn:HookScript('OnReceiveDrag', function()
                    f1_setBtnVisible(btn:GetName(), true)
                end)
            else
                btn:SetPoint('TOPLEFT', (i - 7) * 42, 0)
            end
        end
        f1_setBtnGridVisible(false)

        MultiBarLeft:SetSize(36, 498)
        for i = 1, 12 do
            local btn = _G['MultiBarLeftButton'..i]

            btn:ClearAllPoints()
            btn:SetSize(36, 36)
            btn:SetPoint('TOP', 0, -((i - 1) * 42))
        end

        MultiBarRight:SetSize(36, 498)
        for i = 1, 12 do
            local btn = _G['MultiBarRightButton'..i]

            btn:ClearAllPoints()
            btn:SetSize(36, 36)
            btn:SetPoint('TOP', 0, -((i - 1) * 42))
        end

        MainMenuBarLeftEndCap:ClearAllPoints()
        MainMenuBarLeftEndCap:SetPoint('BOTTOM', UIParent, 'BOTTOM')
        MainMenuBarLeftEndCap:SetPoint('RIGHT', MainMenuBar, 'LEFT', 32, 0)
        MainMenuBarLeftEndCap:SetSize(128, 77.5)
        MainMenuBarLeftEndCap:SetTexture(T)
        MainMenuBarLeftEndCap:SetTexCoord(0.56884765625, 0.6982421875, 0.697265625, 1)

        MainMenuBarRightEndCap:ClearAllPoints()
        MainMenuBarRightEndCap:SetPoint('BOTTOM', UIParent, 'BOTTOM')
        MainMenuBarRightEndCap:SetPoint('LEFT', MainMenuBar, 'RIGHT', -32, 0)
        MainMenuBarRightEndCap:SetSize(128, 77.5)
        MainMenuBarRightEndCap:SetTexture(T)
        MainMenuBarRightEndCap:SetTexCoord(0.56884765625, 0.6982421875, 0.39453125, 0.697265625)

        MainMenuBarTexture0:SetAllPoints()
        MainMenuBarTexture0:SetTexture(T)

        MainMenuExpBar:SetHeight(16)
        MainMenuExpBar:ClearAllPoints()
        MainMenuExpBar:SetPoint('BOTTOMLEFT', MainMenuBar, 'BOTTOMLEFT')
        MainMenuExpBar:SetPoint('BOTTOMRIGHT', MainMenuBar, 'BOTTOMRIGHT')

        ActionBarUpButton:ClearAllPoints()
        ActionBarUpButton:SetPoint('LEFT', MainMenuBar, 'LEFT', 506, 12)

        ActionBarDownButton:ClearAllPoints()
        ActionBarDownButton:SetPoint('LEFT', MainMenuBar, 'LEFT', 506, -7)

        MainMenuBarPageNumber:SetSize(14, 14)
        MainMenuBarPageNumber:ClearAllPoints()
        MainMenuBarPageNumber:SetPoint('LEFT', MainMenuBar, 'LEFT', 534, 3)

        f1_updateActionBars()
        f1_updateWatchBars()
    end
end

f1:SetScript('OnEvent', function(self, event, ...)
    if event == 'ADDON_LOADED' then
        f1_onAddonLoaded(self, ...)
    elseif event == 'PLAYER_ENTERING_WORLD' then
        f1_onPlayerEnteringWorld(...)
    elseif event == 'ACTIONBAR_SHOWGRID' then
        f1_setBtnGridVisible(true)
    elseif event == 'ACTIONBAR_HIDEGRID' then
        f1_setBtnGridVisible(false)
    elseif event == 'PLAYER_REGEN_DISABLED' then
        f1_disableOptionButtons()
    elseif event == 'PLAYER_REGEN_ENABLED' then
        f1_enableOptionButtons()
    end
end)

local microButtons = {
    CharacterMicroButton,
    SpellbookMicroButton,
    TalentMicroButton,
    QuestLogMicroButton,
    SocialsMicroButton,
    WorldMapMicroButton,
    MainMenuMicroButton,
    HelpMicroButton,
}

local bagButtons = {
    MainMenuBarBackpackButton,
    KeyRingButton,
    CharacterBag0Slot,
    CharacterBag1Slot,
    CharacterBag2Slot,
    CharacterBag3Slot,
}

local f2 = CreateFrame('Frame', 'MicroAndBagsBar', UIParent)
f2:RegisterEvent('ADDON_LOADED')
f2:RegisterEvent('PLAYER_ENTERING_WORLD')

local function f2_onAddonLoaded(self, addonName)
    if addonName == N then
        if GetCVar('displayFreeBagSlots') == '1' then
            self:RegisterEvent('BAG_UPDATE')
        end

        self:UnregisterEvent('ADDON_LOADED')
    end
end

local function f2_onPlayerEnteringWorld(self, isLogin, isReload)
    if isLogin or isReload then
        self:SetSize(224, 92)
        self:SetPoint('BOTTOMRIGHT')
        self.Texture = self:CreateTexture(nil, 'BACKGROUND')
        self.Texture:SetTexture(T)
        self.Texture:SetAllPoints()
        self.Texture:SetTexCoord(0.78125, 1, 0.640625, 1)

        for index, button in ipairs(microButtons) do
            button:ClearAllPoints()

            if index == 1 then
                button:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 8, 3)
            else
                button:SetPoint('LEFT', microButtons[index - 1], 'RIGHT', -3, 0)
            end
        end

        for index, button in ipairs(bagButtons) do
            button:ClearAllPoints()

            if index == 1 then
                button:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -7, 47)
            elseif index == 2 then
                button:SetSize(14, 28)
                button:SetPoint('BOTTOMRIGHT', bagButtons[index - 1], 'BOTTOMLEFT', -6, 0)
            else
                button:SetSize(28, 28)
                button:SetPoint('BOTTOMRIGHT', bagButtons[index - 1], 'BOTTOMLEFT', -4, 0)

                local normalTexture = button:GetNormalTexture()
                normalTexture:ClearAllPoints()
                normalTexture:SetPoint('TOPLEFT', button, 'TOPLEFT', -10, 10)
                normalTexture:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 10, -10)
            end
        end
    end
end

local function f2_onBagUpdate()
    MainMenuBarBackpackButtonCount:SetText(string.format('(%s)', MainMenuBarBackpackButton.freeSlots))
end

f2:SetScript('OnEvent', function(self, event, ...)
    if event == 'ADDON_LOADED' then
        f2_onAddonLoaded(self, ...)
    elseif event == 'PLAYER_ENTERING_WORLD' then
        f2_onPlayerEnteringWorld(self, ...)
    elseif event == 'BAG_UPDATE' then
        f2_onBagUpdate()
    end
end)
