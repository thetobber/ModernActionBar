local ADDON_NAME = ...

local function setShowTextures(value)
    if value then
        ModernActionBarBags.Texture:Show()
        MainMenuBarTexture0:Show()
        MainMenuXPBarTexture0:Show()
        ReputationWatchBar.StatusBar.WatchBarTexture0:Show()
        ReputationWatchBar.StatusBar.XPBarTexture0:Show()

        if ModernActionBarDB.showLeftGryphon then
            MainMenuBarLeftEndCap:Show()
        end

        if ModernActionBarDB.showRightGryphon then
            MainMenuBarRightEndCap:Show()
        end
    else
        ModernActionBarBags.Texture:Hide()
        MainMenuBarTexture0:Hide()
        MainMenuXPBarTexture0:Hide()
        ReputationWatchBar.StatusBar.WatchBarTexture0:Hide()
        ReputationWatchBar.StatusBar.XPBarTexture0:Hide()
        MainMenuBarLeftEndCap:Hide()
        MainMenuBarRightEndCap:Hide()
    end
end

local function setTextureLightness(value)
    if ModernActionBarDB.showTextures then
        local color

        if value then
            color = value / 100
        else
            color = 1
        end

        ModernActionBarBags.Texture:SetVertexColor(color, color, color)
        MainMenuBarTexture0:SetVertexColor(color, color, color)
        MainMenuXPBarTexture0:SetVertexColor(color, color, color)
        ReputationWatchBar.StatusBar.WatchBarTexture0:SetVertexColor(color, color, color)
        ReputationWatchBar.StatusBar.XPBarTexture0:SetVertexColor(color, color, color)
        MainMenuBarLeftEndCap:SetVertexColor(color, color, color)
        MainMenuBarRightEndCap:SetVertexColor(color, color, color)
    end
end

local function setShowLeftGryphon(value)
    if ModernActionBarDB.showTextures then
        if value then
            MainMenuBarLeftEndCap:Show()
        else
            MainMenuBarLeftEndCap:Hide()
        end
    end
end

local function setShowRightGryphon(value)
    if ModernActionBarDB.showTextures then
        if value then
            MainMenuBarRightEndCap:Show()
        else
            MainMenuBarRightEndCap:Hide()
        end
    end
end

function ModernActionBarOptions_OnLoad(self)
    local title = ADDON_NAME.." "..GetAddOnMetadata(ADDON_NAME, "Version")

    self:RegisterEvent("ADDON_LOADED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")

    self.name = title
    self.okay = function() end
    self.cancel = function() end

    self.Title:SetText(title)
    self.SubText:SetText(title.." addon options")

    InterfaceOptions_AddCategory(self)
end

function ModernActionBarOptions_OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        if type(ModernActionBarDB) ~= "table" then
            ModernActionBarDB = {
                ["showTextures"] = true,
                ["showLeftGryphon"] = true,
                ["showRightGryphon"] = true,
                ["textureLightness"] = 1
            }
        end

        setShowTextures(ModernActionBarDB.showTextures)
        self.ShowTextures:SetChecked(ModernActionBarDB.showTextures)
        self.ShowTextures.setFunc = function()
            local newValue = not ModernActionBarDB.showTextures

            if newValue then
                self.ShowLeftGryphon:Enable()
                self.ShowRightGryphon:Enable()
            else
                self.ShowLeftGryphon:Disable()
                self.ShowRightGryphon:Disable()
            end

            ModernActionBarDB.showTextures = newValue
            setShowTextures(newValue)
        end

        setShowLeftGryphon(ModernActionBarDB.showLeftGryphon)
        self.ShowLeftGryphon:SetChecked(ModernActionBarDB.showLeftGryphon)
        self.ShowLeftGryphon.setFunc = function()
            ModernActionBarDB.showLeftGryphon = not ModernActionBarDB.showLeftGryphon
            setShowLeftGryphon(ModernActionBarDB.showLeftGryphon)
        end

        setShowRightGryphon(ModernActionBarDB.showRightGryphon)
        self.ShowRightGryphon:SetChecked(ModernActionBarDB.showRightGryphon)
        self.ShowRightGryphon.setFunc = function()
            ModernActionBarDB.showRightGryphon = not ModernActionBarDB.showRightGryphon
            setShowRightGryphon(ModernActionBarDB.showRightGryphon)
        end

        setTextureLightness(ModernActionBarDB.textureLightness)
        self.TextureLightness.Text:SetText("Texture Lightness")
        self.TextureLightness.Value:SetText(ModernActionBarDB.textureLightness.."%")
        self.TextureLightness:SetValue(ModernActionBarDB.textureLightness)
        self.TextureLightness:SetValueStep(1)
        self.TextureLightness:SetMinMaxValues(0, 100)
        self.TextureLightness:SetObeyStepOnDrag(true)
        self.TextureLightness:SetScript("OnValueChanged", function(self, value)
            self:SetValue(value)
            self.Value:SetText(value.."%")
            ModernActionBarDB.textureLightness = value
            setTextureLightness(value)
        end)
    elseif event == "PLAYER_REGEN_ENABLED" then
        self.ShowLeftGryphon:Enable()
        self.ShowRightGryphon:Enable()
        self.TextureLightness:Enable()
    elseif event == "PLAYER_REGEN_DISABLED" then
        self.ShowLeftGryphon:Disable()
        self.ShowRightGryphon:Disable()
        self.TextureLightness:Disable()
    end
end
