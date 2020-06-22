UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"] = nil
UIPARENT_MANAGED_FRAME_POSITIONS["StanceBarFrame"] = nil
UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = nil

local consoleTexturePath = "Interface\\AddOns\\ModernActionBar\\Texture.tga"

local unusedFrames = {
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
}

local optionButtons = {
    ReputationDetailMainScreenCheckBox,
    ReputationDetailInactiveCheckBox,
    InterfaceOptionsActionBarsPanelBottomLeft,
    InterfaceOptionsActionBarsPanelBottomRight,
    InterfaceOptionsActionBarsPanelRight,
    InterfaceOptionsActionBarsPanelRightTwo,
    InterfaceOptionsActionBarsPanelAlwaysShowActionBars
}

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

local hiddenFrame
do
    hiddenFrame = CreateFrame("Frame", nil, nil)
    hiddenFrame:RegisterEvent("ACTIONBAR_SHOWGRID")
    hiddenFrame:RegisterEvent("ACTIONBAR_HIDEGRID")
    hiddenFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    hiddenFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    hiddenFrame:Hide()
end

local bagAndMicroFrame
do
    bagAndMicroFrame = CreateFrame("Frame", nil, UIParent)
    bagAndMicroFrame:SetSize(224, 89)
    bagAndMicroFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT")
    bagAndMicroFrame.Texture = bagAndMicroFrame:CreateTexture(nil, "BACKGROUND")
    bagAndMicroFrame.Texture:SetTexture(consoleTexturePath)
    bagAndMicroFrame.Texture:SetAllPoints()
    bagAndMicroFrame.Texture:SetTexCoord(0.78125, 1, 0.65234375, 1)

    MainMenuBarBackpackButton:ClearAllPoints()
    MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", bagAndMicroFrame, "BOTTOMRIGHT", -7, 47)

    KeyRingButton:ClearAllPoints()
    KeyRingButton:SetSize(14, 28)
    KeyRingButton:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMLEFT", -6, 0)

    CharacterBag0Slot:ClearAllPoints()
    CharacterBag0Slot:SetPoint("RIGHT", KeyRingButton, "LEFT", -4, 0)

    CharacterBag1Slot:ClearAllPoints()
    CharacterBag1Slot:SetPoint("RIGHT", CharacterBag0Slot, "LEFT", -4, 0)

    CharacterBag2Slot:ClearAllPoints()
    CharacterBag2Slot:SetPoint("RIGHT", CharacterBag1Slot, "LEFT", -4, 0)

    CharacterBag3Slot:ClearAllPoints()
    CharacterBag3Slot:SetPoint("RIGHT", CharacterBag2Slot, "LEFT", -4, 0)

    for index, button in ipairs({
        CharacterBag0Slot,
        CharacterBag1Slot,
        CharacterBag2Slot,
        CharacterBag3Slot
    }) do
        button:SetSize(28, 28)
        _G[button:GetName().."NormalTexture"]:ClearAllPoints()
        _G[button:GetName().."NormalTexture"]:SetPoint("TOPLEFT", button, "TOPLEFT", -10, 10)
        _G[button:GetName().."NormalTexture"]:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 10, -10)
    end

    for index, button in ipairs(microButtons) do
        button:ClearAllPoints()

        if index == 1 then
            button:SetPoint("BOTTOMLEFT", bagAndMicroFrame, "BOTTOMLEFT", 8, 3)
        else
            button:SetPoint("LEFT", microButtons[index - 1], "RIGHT", -3, 0)
        end
    end
end

local function removeUnusedFrames()
    for index, frame in ipairs(unusedFrames) do
        frame:SetParent(hiddenFrame)
        frame:Hide()
        frame:SetSize(0, 0)

        if frame.SetTexture then
            frame:SetTexture(nil)
        end
    end
end

local function toggleOptionButtons()
    if InCombatLockdown() then
        for _, button in ipairs(optionButtons) do
            button:Disable()
        end
    else
        for _, button in ipairs(optionButtons) do
            button:Enable()
        end
    end
end

local function setActionButtonAlpha(buttonName, alpha)
    _G[buttonName.."NormalTexture"]:SetAlpha(alpha)
    _G[buttonName.."HotKey"]:SetAlpha(alpha)
    _G[buttonName.."Count"]:SetAlpha(alpha)
    _G[buttonName.."Name"]:SetAlpha(alpha)
    _G[buttonName.."Cooldown"]:SetAlpha(alpha)
end

local function setBottomRightGridVisibility(show)
    -- Have to use alpha of button due to combat lockdown restriction
    for index = 1, 6 do
        local buttonName = "MultiBarBottomRightButton"..index
        setActionButtonAlpha(buttonName, show and 1 or (_G[buttonName].eventsRegistered and 1 or 0))
    end
end

local function applyLayoutBase()
    if InCombatLockdown() then
        return
    end

    MainMenuBarTexture0:ClearAllPoints()
    MainMenuBarTexture0:SetPoint("TOPLEFT", MainMenuBarArtFrame, "TOPLEFT", 0, 0)
    MainMenuBarTexture0:SetPoint("BOTTOMRIGHT", MainMenuBarArtFrame, "BOTTOMRIGHT", 0, 0)
    MainMenuBarTexture0:SetTexture(consoleTexturePath)

    MainMenuXPBarTexture0:ClearAllPoints()
    MainMenuXPBarTexture0:SetPoint("TOPLEFT", MainMenuExpBar, "TOPLEFT", 0, 0)
    MainMenuXPBarTexture0:SetPoint("BOTTOMRIGHT", MainMenuExpBar, "BOTTOMRIGHT", 0, 0)
    MainMenuXPBarTexture0:SetTexture(consoleTexturePath)

    ActionBarUpButton:ClearAllPoints()
    ActionBarUpButton:SetPoint("TOPLEFT", MainMenuBarArtFrame, "TOPLEFT", 506, -2)

    ActionBarDownButton:ClearAllPoints()
    ActionBarDownButton:SetPoint("BOTTOMLEFT", MainMenuBarArtFrame, "BOTTOMLEFT", 506, -4)

    MainMenuBarPageNumber:ClearAllPoints()
    MainMenuBarPageNumber:SetPoint("LEFT", MainMenuBarArtFrame, "LEFT", 538, -3)

    ReputationWatchBar.StatusBar.WatchBarTexture0:ClearAllPoints()
    ReputationWatchBar.StatusBar.WatchBarTexture0:SetPoint("TOPLEFT", ReputationWatchBar.StatusBar, "TOPLEFT", 0, 0)
    ReputationWatchBar.StatusBar.WatchBarTexture0:SetPoint("BOTTOMRIGHT", ReputationWatchBar.StatusBar, "BOTTOMRIGHT", 0, 0)
    ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexture(consoleTexturePath)

    ReputationWatchBar.StatusBar.XPBarTexture0:ClearAllPoints()
    ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint("TOPLEFT", ReputationWatchBar.StatusBar, "TOPLEFT", 0, 0)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint("BOTTOMRIGHT", ReputationWatchBar.StatusBar, "BOTTOMRIGHT", 0, 0)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetTexture(consoleTexturePath)

    MultiBarBottomRight:SetWidth(261)

    for index = 1, NUM_ACTIONBAR_BUTTONS / 2 do
        _G["MultiBarBottomRightButton"..index.."FloatingBG"]:SetTexture(nil)
    end

    for index = 7, NUM_ACTIONBAR_BUTTONS do
        local button = _G["MultiBarBottomRightButton"..index]
        button:ClearAllPoints()

        if index == 7 then
            button:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton1, "TOPLEFT", 0, 16)
        else
            button:SetPoint("LEFT", _G["MultiBarBottomRightButton"..(index - 1)], "RIGHT", 6, 0)
        end
    end

    for index = 1, GetNumShapeshiftForms() do
        local button = _G["StanceButton"..index]
        local texture = _G["StanceButton"..index.."NormalTexture2"]

        if texture then
            texture:ClearAllPoints()
            texture:SetPoint("TOPLEFT", button, "TOPLEFT", -10, 10)
            texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 10, -10)
        end
    end
end

local function applyLayoutSmall()
    if InCombatLockdown() then
        return
    end

    MainMenuBar:SetSize(552, 49)
    MainMenuBarTexture0:SetTexCoord(0, 0.5390625, 0.70703125, 0.8984375)

    MainMenuExpBar:SetSize(552, 16)
    MainMenuXPBarTexture0:SetTexCoord(0, 0.5390625, 0.9375, 1)

    ReputationWatchBar:SetSize(552, 16)
    ReputationWatchBar.StatusBar:SetSize(552, 16)

    ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexCoord(0, 0.5390625, 0.9375, 1)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetTexCoord(0, 0.5390625, 0.9375, 1)
end

local function applyLayoutLarge()
    if InCombatLockdown() then
        return
    end

    MainMenuBar:SetSize(806, 49)
    MainMenuBarTexture0:SetTexCoord(0, 0.787109375, 0, 0.19140625)

    MainMenuExpBar:SetSize(806, 16)
    MainMenuXPBarTexture0:SetTexCoord(0, 0.787109375, 0.23046875, 0.29296875)

    ReputationWatchBar:SetSize(806, 16)
    ReputationWatchBar.StatusBar:SetSize(806, 16)

    ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexCoord(0, 0.787109375, 0.23046875, 0.29296875)
    ReputationWatchBar.StatusBar.XPBarTexture0:SetTexCoord(0, 0.787109375, 0.23046875, 0.29296875)
end

local function updateActionBars()
    if InCombatLockdown() then
        return
    end

    StanceBarFrame:ClearAllPoints()

    if SHOW_MULTI_ACTIONBAR_1 then
        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, 16)
        StanceBarFrame:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton1, "TOPLEFT", 30, 6)
    else
        StanceBarFrame:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 30, 9)
    end

    if SHOW_MULTI_ACTIONBAR_2 then
        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint("BOTTOMLEFT", ActionButton12, "BOTTOMRIGHT", 46, 0)
        applyLayoutLarge()
    else
        applyLayoutSmall()
    end
end

local function updateWatchBars()
    if InCombatLockdown() then
        return
    end

    local showExperience = UnitLevel("player") < MAX_PLAYER_LEVEL
    local showReputation = (select(1, GetWatchedFactionInfo())) ~= nil

    MainMenuBar:ClearAllPoints()
    MainMenuBarLeftEndCap:ClearAllPoints()
    MainMenuBarRightEndCap:ClearAllPoints()

    if showExperience or showReputation then
        MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 16)
        MainMenuBarLeftEndCap:SetPoint("BOTTOMRIGHT", MainMenuBarArtFrame, "BOTTOMLEFT", 30, -16)
        MainMenuBarRightEndCap:SetPoint("BOTTOMLEFT", MainMenuBarArtFrame, "BOTTOMRIGHT", -30, -16)
    else
        MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM")
        MainMenuBarLeftEndCap:SetPoint("BOTTOMRIGHT", MainMenuBarArtFrame, "BOTTOMLEFT", 30, 0)
        MainMenuBarRightEndCap:SetPoint("BOTTOMLEFT", MainMenuBarArtFrame, "BOTTOMRIGHT", -30, 0)
    end

    if showReputation then
        MainMenuExpBar:Hide()
        ReputationWatchBar:ClearAllPoints()
        ReputationWatchBar:SetPoint("BOTTOM", UIParent, "BOTTOM")
    elseif showExperience then
        MainMenuExpBar:ClearAllPoints()
        MainMenuExpBar:SetPoint("BOTTOM", UIParent, "BOTTOM")
    end

    updateActionBars()
end

local function updatePetBar()
    if InCombatLockdown() then
        return
    end

    if SHOW_MULTI_ACTIONBAR_1 then
        PETACTIONBAR_YPOS = 141
    else
        PETACTIONBAR_YPOS = 93
    end
end

hiddenFrame:SetScript("OnEvent", function(self, event, ...)
    -- ACTIONBAR_SHOWGRID/ACTIONBAR_HIDEGRID are dispatched when an ability is being dragged/dropped
    if event == "ACTIONBAR_SHOWGRID" then
        setBottomRightGridVisibility(true)
    elseif event == "ACTIONBAR_HIDEGRID" then
        setBottomRightGridVisibility(false)
    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        toggleOptionButtons()
    end
end)

-- Show the button again when receiving an ability dragged on to it
for index, button in ipairs({
    MultiBarBottomRightButton1,
    MultiBarBottomRightButton2,
    MultiBarBottomRightButton3,
    MultiBarBottomRightButton4,
    MultiBarBottomRightButton5,
    MultiBarBottomRightButton6
}) do
    button:HookScript("OnReceiveDrag", function(self)
        setActionButtonAlpha(self:GetName(), 1)
    end)
end

-- Happens when toggling "Always Show ActionBars" in interface options
hooksecurefunc("MultiActionBar_UpdateGridVisibility", function()
    setBottomRightGridVisibility(false)
end)

hooksecurefunc("SetActionBarToggles", updateActionBars)
hooksecurefunc("PetActionBar_UpdatePositionValues", updatePetBar)
hooksecurefunc("MainMenuBar_UpdateExperienceBars", updateWatchBars)
hooksecurefunc("InterfaceOptionsOptionsFrame_RefreshCategories", toggleOptionButtons)

removeUnusedFrames()
applyLayoutBase()
