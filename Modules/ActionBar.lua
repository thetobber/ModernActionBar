local N, S = ...
local M = S.A:GetModule('ActionBar')

UIPARENT_MANAGED_FRAME_POSITIONS['MultiBarBottomLeft'] = nil

UIPARENT_MANAGED_FRAME_POSITIONS['PETACTIONBAR_YPOS'] = {
    baseY = 98,
    bottomLeft = 46,
    justBottomRightAndStance = 46,
    watchBar = 0,
    maxLevel = 0,
    isVar = 'yAxis',
}

UIPARENT_MANAGED_FRAME_POSITIONS['StanceBarFrame'] = {
    baseY = -2,
    bottomLeft = 46,
    watchBar = 0,
    maxLevel = 0,
    anchorTo = 'MainMenuBar',
    point = 'BOTTOMLEFT',
    rpoint = 'TOPLEFT',
    xOffset = 30,
}

function M:OnInitialize()
    self.db = S.A.db
    self.consoleTexture = S.A.consoleTexture

    -- fix pet and stance positioning
    -- local UIMFP = UIPARENT_MANAGED_FRAME_POSITIONS

    -- UIMFP['MultiBarBottomLeft'] = nil

    -- UIMFP['PETACTIONBAR_YPOS'] = {
    --     baseY = 98,
    --     bottomLeft = 46,
    --     justBottomRightAndStance = 46,
    --     watchBar = 0,
    --     maxLevel = 0,
    --     isVar = 'yAxis',
    -- }

    -- UIMFP['StanceBarFrame'] = {
    --     baseY = -2,
    --     bottomLeft = 46,
    --     watchBar = 0,
    --     maxLevel = 0,
    --     anchorTo = 'MainMenuBar',
    --     point = 'BOTTOMLEFT',
    --     rpoint = 'TOPLEFT',
    --     xOffset = 30,
    -- }

    -- circumvent rep. bar positioning on rep. change
    ReputationWatchBar._SetPoint = ReputationWatchBar.SetPoint

    ReputationWatchBar.SetPoint = function(self, ...)
        self:SetSize(MainMenuBar:GetWidth(), 16)
        self:ClearAllPoints()
        self:_SetPoint('BOTTOMLEFT', MainMenuBar, 'BOTTOMLEFT')
        self:_SetPoint('BOTTOMRIGHT', MainMenuBar, 'BOTTOMRIGHT')

        self.StatusBar:ClearAllPoints()
        self.StatusBar:SetAllPoints()
    end
end

function M:OnEnable()
    -- register events
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
    self:RegisterEvent('ACTIONBAR_SHOWGRID')
    self:RegisterEvent('ACTIONBAR_HIDEGRID')

    -- register hooks
    self:SecureHook('SetActionBarToggles', 'UpdateActionBar')
    self:SecureHook('MainMenuBar_UpdateExperienceBars', 'UpdateWatchBar')
end

function M:StyleButton(button, point, xOffset, yOffset)
    button:SetSize(36, 36)

    if point and xOffset and yOffset then
        button:ClearAllPoints()
        button:SetPoint(point, xOffset, yOffset)
    end
end

function M:StyleStanceButton(button, xOffset, yOffset)
    local texture = button:GetNormalTexture()

    button:SetSize(30, 30)
    button:ClearAllPoints()
    button:SetPoint('LEFT', xOffset, yOffset)

    texture:ClearAllPoints()
    texture:SetPoint('TOPLEFT', button, 'TOPLEFT', -10, 10)
    texture:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 10, -10)
end

function M:ShowButtonGrid(name, show)
    local alpha = show and 1 or 0

    _G[name..'HotKey']:SetAlpha(alpha)
    _G[name..'Count']:SetAlpha(alpha)
    _G[name..'Name']:SetAlpha(alpha)
    _G[name..'Cooldown']:SetAlpha(alpha)
end

function M:ShowButtonGridRange(baseName, from, to, show)
    for index = from, to do
        local name = baseName..index

        if _G[name].eventsRegistered or show then
            self:ShowButtonGrid(name, true)
        else
            self:ShowButtonGrid(name, false)
        end
    end
end

function M:UpdateActionBar()
    if InCombatLockdown() then
        return
    end

    -- use small or large layout depending on action bars shown
    if SHOW_MULTI_ACTIONBAR_2 then
        -- large layout
        MainMenuBar:SetSize(806, 70)
        MainMenuBarTexture0:SetTexCoord(0, 0.787109375, 0, 0.2734375)
    else
        -- small layout
        MainMenuBar:SetSize(552, 70)
        MainMenuBarTexture0:SetTexCoord(0, 0.5390625, 0.7265625, 1)
    end
end

function M:UpdateWatchBar()
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

function M:PLAYER_ENTERING_WORLD(isLogin, isReload)
    if isLogin or isReload then
        -- action bars position and sizing
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint('BOTTOMRIGHT', MainMenuBar, 'BOTTOMRIGHT', -8, 20)
        MultiBarBottomRight:SetSize(246, 89)
        MultiBarBottomLeft:SetSize(498, 36)

        -- fix action buttons
        for index = 1, 12 do
            self:StyleButton(_G['ActionButton'..index], 'TOPLEFT', (index - 1) * 42 + 9, -14)
            self:StyleButton(_G['MultiBarBottomLeftButton'..index], 'LEFT', (index - 1) * 42, 0)

            local bottomRightButton = _G['MultiBarBottomRightButton'..index]

            if index < 7 then
                bottomRightButton:GetNormalTexture():SetAlpha(1)
                self:StyleButton(bottomRightButton, 'BOTTOMLEFT', (index - 1) * 42, 0)

                bottomRightButton:HookScript('OnReceiveDrag', function()
                    self:ShowButtonGrid(bottomRightButton:GetName(), true)
                end)
            else
                self:StyleButton(bottomRightButton, 'TOPLEFT', (index - 7) * 42, 0)
            end

            _G['MultiBarLeftButton'..index]:SetSize(36, 36)
            _G['MultiBarRightButton'..index]:SetSize(36, 36)
        end

        -- stance and pet bar sizing
        StanceBarFrame:SetSize(30, 30)
        PetActionBarFrame:SetSize(30, 30)

        -- fix stance and pet buttons
        for index = 1, 10 do
            local xOffset = (index - 1) * 34

            self:StyleStanceButton(_G['StanceButton'..index], xOffset, 0)
            self:StyleStanceButton(_G['PetActionButton'..index], xOffset, 0)
        end

        -- left gryphon position, size and texture
        MainMenuBarLeftEndCap:ClearAllPoints()
        MainMenuBarLeftEndCap:SetPoint('BOTTOM', UIParent, 'BOTTOM')
        MainMenuBarLeftEndCap:SetPoint('RIGHT', MainMenuBar, 'LEFT', 32, 0)
        MainMenuBarLeftEndCap:SetSize(128, 77.5)
        MainMenuBarLeftEndCap:SetTexture(self.consoleTexture)
        MainMenuBarLeftEndCap:SetTexCoord(0.56884765625, 0.6982421875, 0.697265625, 1)

        -- right gryphon position, size and texture
        MainMenuBarRightEndCap:ClearAllPoints()
        MainMenuBarRightEndCap:SetPoint('BOTTOM', UIParent, 'BOTTOM')
        MainMenuBarRightEndCap:SetPoint('LEFT', MainMenuBar, 'RIGHT', -32, 0)
        MainMenuBarRightEndCap:SetSize(128, 77.5)
        MainMenuBarRightEndCap:SetTexture(self.consoleTexture)
        MainMenuBarRightEndCap:SetTexCoord(0.56884765625, 0.6982421875, 0.39453125, 0.697265625)

        -- action bar texture
        MainMenuBarTexture0:SetAllPoints()
        MainMenuBarTexture0:SetTexture(self.consoleTexture)

        -- exp. bar size and texture
        MainMenuExpBar:SetHeight(16)
        MainMenuExpBar:ClearAllPoints()
        MainMenuExpBar:SetPoint('BOTTOMLEFT', MainMenuBar, 'BOTTOMLEFT')
        MainMenuExpBar:SetPoint('BOTTOMRIGHT', MainMenuBar, 'BOTTOMRIGHT')

        -- action page up button position
        ActionBarUpButton:ClearAllPoints()
        ActionBarUpButton:SetPoint('LEFT', MainMenuBar, 'LEFT', 506, 12)

        -- action page down button position
        ActionBarDownButton:ClearAllPoints()
        ActionBarDownButton:SetPoint('LEFT', MainMenuBar, 'LEFT', 506, -7)

        -- action page number size and position
        MainMenuBarPageNumber:SetSize(14, 14)
        MainMenuBarPageNumber:ClearAllPoints()
        MainMenuBarPageNumber:SetPoint('LEFT', MainMenuBar, 'LEFT', 534, 3)

        -- invoke update functions initially
        UIParent_ManageFramePositions()
        self:UpdateActionBar()
        self:UpdateWatchBar()
    end
end

function M:ACTIONBAR_SHOWGRID()
    self:ShowButtonGridRange('MultiBarBottomRightButton', 1, 6, true)
end

function M:ACTIONBAR_HIDEGRID()
    self:ShowButtonGridRange('MultiBarBottomRightButton', 1, 6, true)
end
