local ActionBars = ModernActionBar:GetModule('ActionBars')


local retail = {
    {
        enabled = true,
        reference = _G["MainMenuBar"],
        points = {
            { anchor = "" }
        },
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRight"],
        width = 261
        points = {
            { anchor = "" }
        },
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton1FloatingBG"],
        texture = nil
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton2FloatingBG"],
        texture = nil
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton3FloatingBG"],
        texture = nil
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton4FloatingBG"],
        texture = nil
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton5FloatingBG"],
        texture = nil
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton6FloatingBG"],
        texture = nil
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton7"],
        points = {
            { anchor = "BOTTOMLEFT", relativeTo = _G["MultiBarBottomRightButton1"], "TOPLEFT", 0, 16 }
        }
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton8"],
        points = {
            { anchor = "LEFT", relativeTo = _G["MultiBarBottomRightButton7"], "RIGHT", 6, 0 }
        }
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton9"],
        points = {
            { anchor = "LEFT", relativeTo = _G["MultiBarBottomRightButton8"], "RIGHT", 6, 0 }
        }
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton10"],
        points = {
            { anchor = "LEFT", relativeTo = _G["MultiBarBottomRightButton9"], "RIGHT", 6, 0 }
        }
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton11"],
        points = {
            { anchor = "LEFT", relativeTo = _G["MultiBarBottomRightButton10"], "RIGHT", 6, 0 }
        }
    },
    {
        enabled = true,
        reference = _G["MultiBarBottomRightButton12"],
        points = {
            { anchor = "LEFT", relativeTo = _G["MultiBarBottomRightButton11"], "RIGHT", 6, 0 }
        }
    },
    {
        enabled = true,
        reference = _G["MainMenuBarTexture0"],
        points = {
            { anchor = "TOPLEFT", relativeTo = _G["MainMenuBarArtFrame"], "TOPLEFT" },
            { anchor = "BOTTOMRIGHT", relativeTo = _G["MainMenuBarArtFrame"], "BOTTOMRIGHT" }
        },
        texture = "Interface\\AddOns\\ModernActionBar\\Media\\Textures\\Console.tga"
    },
    {
        enabled = true,
        reference = _G["MainMenuXPBarTexture0"],
        points = {
            { anchor = "TOPLEFT", relativeTo = _G["MainMenuExpBar"], "TOPLEFT" },
            { anchor = "BOTTOMRIGHT", relativeTo = _G["MainMenuExpBar"], "BOTTOMRIGHT" }
        },
        texture = "Interface\\AddOns\\ModernActionBar\\Media\\Textures\\Console.tga"
    },
    {
        enabled = true,
        reference = _G["ActionBarUpButton"],
        points = {
            { anchor = "TOPLEFT", relativeTo = _G["MainMenuBarArtFrame"], "TOPLEFT", 506, -2 }
        }
    },
    {
        enabled = true,
        reference = _G["ActionBarDownButton"],
        points = {
            { anchor = "BOTTOMLEFT", relativeTo = _G["MainMenuBarArtFrame"], "BOTTOMLEFT", 506, -4 }
        }
    },
    {
        enabled = true,
        reference = _G["MainMenuBarPageNumber"],
        points = {
            { anchor = "LEFT", relativeTo = _G["MainMenuBarArtFrame"], "LEFT", 538, -3 }
        }
    },
    {
        enabled = true,
        reference = _G["ReputationWatchBar"].StatusBar.WatchBarTexture0,
        points = {
            { anchor = "TOPLEFT", relativeTo = _G["ReputationWatchBar"].StatusBar, "TOPLEFT" },
            { anchor = "BOTTOMRIGHT", relativeTo = _G["ReputationWatchBar"].StatusBar, "BOTTOMRIGHT" },
        },
        texture = "Interface\\AddOns\\ModernActionBar\\Media\\Textures\\Console.tga"
    },
    {
        enabled = true,
        reference = _G["ReputationWatchBar"].StatusBar.XPBarTexture0,
        points = {
            { anchor = "TOPLEFT", relativeTo = _G["ReputationWatchBar"].StatusBar, "TOPLEFT" },
            { anchor = "BOTTOMRIGHT", relativeTo = _G["ReputationWatchBar"].StatusBar, "BOTTOMRIGHT" },
        },
        texture = "Interface\\AddOns\\ModernActionBar\\Media\\Textures\\Console.tga"
    },
    {
        enabled = false,
        reference = _G[MainMenuXPBarTexture1]
    },
    {
        enabled = false,
        reference = _G[MainMenuXPBarTexture2]
    },
    {
        enabled = false,
        reference = _G[MainMenuXPBarTexture3]
    },
    {
        enabled = false,
        reference = _G[MainMenuBarTexture1]
    },
    {
        enabled = false,
        reference = _G[MainMenuBarTexture2]
    },
    {
        enabled = false,
        reference = _G[MainMenuBarTexture3]
    },
    {
        enabled = false,
        reference = _G[ReputationWatchBar].StatusBar.WatchBarTexture1
    },
    {
        enabled = false,
        reference = _G[ReputationWatchBar].StatusBar.WatchBarTexture2
    },
    {
        enabled = false,
        reference = _G[ReputationWatchBar].StatusBar.WatchBarTexture3
    },
    {
        enabled = false,
        reference = _G[ReputationWatchBar].StatusBar.XPBarTexture1
    },
    {
        enabled = false,
        reference = _G[ReputationWatchBar].StatusBar.XPBarTexture2
    },
    {
        enabled = false,
        reference = _G[ReputationWatchBar].StatusBar.XPBarTexture3
    },
    {
        enabled = false,
        reference = _G[MainMenuBarPerformanceBarFrame]
    },
    {
        enabled = false,
        reference = _G[MainMenuBarMaxLevelBar]
    }
}


function ActionBars:OnInitialize()
    self.db = ModernActionBar.db

    self.shouldUpdateActionBars = false
    self.shouldUpdateWatchBars = false
    self.shoulUpdatePetBar = false

    self:RegisterEvent('PLAYER_LOGIN')
    self:RegisterEvent('ACTIONBAR_SHOWGRID')
    self:RegisterEvent('ACTIONBAR_HIDEGRID')

    self:SecureHook('SetActionBarToggles', 'UpdateActionBars')
    self:SecureHook('MainMenuBar_UpdateExperienceBars', 'UpdateWatchBars')
    self:SecureHook('PetActionBar_UpdatePositionValues', 'UpdatePetBar')
    self:SecureHook('MultiActionBar_UpdateGridVisibility', function() self:ShowBottomRightButtonsGrid(false) end)
end

function ActionBars:SetButtonGridAlpha(buttonName, alpha)
    _G[buttonName.."NormalTexture"]:SetAlpha(alpha)
    _G[buttonName.."HotKey"]:SetAlpha(alpha)
    _G[buttonName.."Count"]:SetAlpha(alpha)
    _G[buttonName.."Name"]:SetAlpha(alpha)
    _G[buttonName.."Cooldown"]:SetAlpha(alpha)
end

function ActionBars:ShowBottomRightButtonsGrid(show)
    -- Have to use alpha of button due to combat lockdown restriction
    for index = 1, 6 do
        local buttonName = "MultiBarBottomRightButton"..index
        self:SetButtonGridAlpha(buttonName, show and 1 or (_G[buttonName].eventsRegistered and 1 or 0))
    end
end

function ActionBars:UseSmallActionBars()
    MainMenuBar:SetSize(552, 49)
    MainMenuBarTexture0:SetTexCoord(0, 0.5390625, 0.70703125, 0.8984375)

    MainMenuExpBar:SetSize(552, 16)
    MainMenuXPBarTexture0:SetTexCoord(0, 0.5390625, 0.9375, 1)

    ReputationWatchBar:SetSize(552, 16)
    ReputationWatchBar.StatusBar:SetSize(552, 16)

    ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexCoord(0, 0.5390625, 0.9375, 1)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetTexCoord(0, 0.5390625, 0.9375, 1)
end

function ActionBars:UseLargeActionBars()
    MainMenuBar:SetSize(806, 49)
    MainMenuBarTexture0:SetTexCoord(0, 0.787109375, 0, 0.19140625)

    MainMenuExpBar:SetSize(806, 16)
    MainMenuXPBarTexture0:SetTexCoord(0, 0.787109375, 0.23046875, 0.29296875)

    ReputationWatchBar:SetSize(806, 16)
    ReputationWatchBar.StatusBar:SetSize(806, 16)

    ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexCoord(0, 0.787109375, 0.23046875, 0.29296875)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetTexCoord(0, 0.787109375, 0.23046875, 0.29296875)
end

function ActionBars:Option_ShowBarsAndGryphons()
    if self.db.char.visibility.showBars then
        MainMenuBarTexture0:Show()
        MainMenuXPBarTexture0:Show()
        ReputationWatchBar.StatusBar.WatchBarTexture0:Show()
        ReputationWatchBar.StatusBar.XPBarTexture0:Show()

        if self.db.char.visibility.showGryphons then
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
end

function ActionBars:Option_ColorBars()
    local r, g, b, a = unpack(self.db.char.coloring.colorBars)
    MainMenuBarTexture0:SetVertexColor(r, g, b, a)
    MainMenuXPBarTexture0:SetVertexColor(r, g, b, a)
    ReputationWatchBar.StatusBar.WatchBarTexture0:SetVertexColor(r, g, b, a)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetVertexColor(r, g, b, a)
end

function ActionBars:Option_ColorGryphons()
    local r, g, b, a = unpack(self.db.char.coloring.colorGryphons)
    MainMenuBarLeftEndCap:SetVertexColor(r, g, b, a)
    MainMenuBarRightEndCap:SetVertexColor(r, g, b, a)
end

function ActionBars:UpdateActionBars()
    if InCombatLockdown() then
        self.shouldUpdateActionBars = true
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
        self:UseLargeActionBars()
    else
        self:UseSmallActionBars()
    end
end

function ActionBars:UpdateWatchBars()
    if InCombatLockdown() then
        self.shouldUpdateWatchBars = true
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

    self:UpdateActionBars()
end

function ActionBars:UpdatePetBar()
    if InCombatLockdown() then
        self.shoulUpdatePetBar = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end

    if SHOW_MULTI_ACTIONBAR_1 then
        PETACTIONBAR_YPOS = 141
    else
        PETACTIONBAR_YPOS = 93
    end
end

function ActionBars:PLAYER_LOGIN()
    UIPARENT_MANAGED_FRAME_POSITIONS['MultiBarBottomLeft'] = nil
    UIPARENT_MANAGED_FRAME_POSITIONS['StanceBarFrame'] = nil
    UIPARENT_MANAGED_FRAME_POSITIONS['PETACTIONBAR_YPOS'] = nil

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
    MainMenuBarTexture0:SetTexture('Interface\\AddOns\\ModernActionBar\\Media\\Textures\\Console.tga')

    MainMenuXPBarTexture0:ClearAllPoints()
    MainMenuXPBarTexture0:SetPoint('TOPLEFT', MainMenuExpBar, 'TOPLEFT', 0, 0)
    MainMenuXPBarTexture0:SetPoint('BOTTOMRIGHT', MainMenuExpBar, 'BOTTOMRIGHT', 0, 0)
    MainMenuXPBarTexture0:SetTexture('Interface\\AddOns\\ModernActionBar\\Media\\Textures\\Console.tga')

    ActionBarUpButton:ClearAllPoints()
    ActionBarUpButton:SetPoint('TOPLEFT', MainMenuBarArtFrame, 'TOPLEFT', 506, -2)

    ActionBarDownButton:ClearAllPoints()
    ActionBarDownButton:SetPoint('BOTTOMLEFT', MainMenuBarArtFrame, 'BOTTOMLEFT', 506, -4)

    MainMenuBarPageNumber:ClearAllPoints()
    MainMenuBarPageNumber:SetPoint('LEFT', MainMenuBarArtFrame, 'LEFT', 538, -3)

    ReputationWatchBar.StatusBar.WatchBarTexture0:ClearAllPoints()
    ReputationWatchBar.StatusBar.WatchBarTexture0:SetPoint('TOPLEFT', ReputationWatchBar.StatusBar, 'TOPLEFT', 0, 0)
    ReputationWatchBar.StatusBar.WatchBarTexture0:SetPoint('BOTTOMRIGHT', ReputationWatchBar.StatusBar, 'BOTTOMRIGHT', 0, 0)
    ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexture('Interface\\AddOns\\ModernActionBar\\Media\\Textures\\Console.tga')

    ReputationWatchBar.StatusBar.XPBarTexture0:ClearAllPoints()
    ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint('TOPLEFT', ReputationWatchBar.StatusBar, 'TOPLEFT', 0, 0)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint('BOTTOMRIGHT', ReputationWatchBar.StatusBar, 'BOTTOMRIGHT', 0, 0)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetTexture('Interface\\AddOns\\ModernActionBar\\Media\\Textures\\Console.tga')

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
        button:HookScript('OnReceiveDrag', function(self)
            ActionBars:SetButtonGridAlpha(self:GetName(), 1)
        end)
    end

    self:UpdateActionBars()
    self:Option_ShowBarsAndGryphons()
    self:Option_ColorBars()
    self:Option_ColorGryphons()
end

function ActionBars:PLAYER_REGEN_ENABLED()
    if self.shouldUpdateActionBars then
        self:UpdateActionBars()
    end

    if self.shouldUpdateWatchBars then
        self:UpdateWatchBars()
    end

    if self.shoulUpdatePetBar then
        self:UpdateActionBars()
    end

    self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function ActionBars:ACTIONBAR_SHOWGRID()
    self:ShowBottomRightButtonsGrid(true)
end

function ActionBars:ACTIONBAR_HIDEGRID()
    self:ShowBottomRightButtonsGrid(false)
end
