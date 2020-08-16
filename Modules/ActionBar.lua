local _G = getfenv(0)
local CreateFrame = _G.CreateFrame
local InCombatLockdown = _G.InCombatLockdown
local pairs = _G.pairs
local match = _G.string.match

local ActionBar = _G.ModernActionBar:GetModule('ActionBar')

function ActionBar:OnInitialize()
    self.db = _G.ModernActionBar.db.global.actionBar

    _G.UIPARENT_MANAGED_FRAME_POSITIONS['MultiBarBottomLeft'] = nil

    self.consoleTexture = 'Interface\\AddOns\\ModernActionBar\\Textures\\Console.tga'

    _G.ReputationWatchBar._SetPoint = _G.ReputationWatchBar.SetPoint
    _G.ReputationWatchBar.SetPoint = self.EmptyFunc

    _G.ReputationWatchBar._ClearAllPoints = _G.ReputationWatchBar.ClearAllPoints
    _G.ReputationWatchBar.ClearAllPoints = self.EmptyFunc
end

function ActionBar:OnEnable()
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
    self:RegisterEvent('ACTIONBAR_SHOWGRID')
    self:RegisterEvent('ACTIONBAR_HIDEGRID')
    self:SecureHook('SetActionBarToggles', 'UpdateActionBar')
    self:SecureHook('MainMenuBar_UpdateExperienceBars', 'UpdateWatchBar')

    for i = 1, 6 do
        local button = _G['MultiBarBottomRightButton'..i]

        button:HookScript('OnReceiveDrag', function()
            if button.eventsRegistered then
                button:SetAlpha(1)
            else
                button:SetAlpha(0)
            end
        end)
    end
end

function ActionBar:PLAYER_ENTERING_WORLD(isLogin, isReload)
    if isLogin or isReload then
        _G.MultiBarBottomRight:SetSize(246, 86)
        _G.MultiBarBottomRight:ClearAllPoints()
        _G.MultiBarBottomRight:SetPoint('BOTTOMRIGHT', _G.MainMenuBar, 'BOTTOMRIGHT', -8, 20)

        _G.MultiBarBottomLeft:SetSize(498, 36)
        _G.MultiBarBottomLeft:ClearAllPoints()
        _G.MultiBarBottomLeft:SetPoint('BOTTOMLEFT', _G.ActionButton1, 'TOPLEFT', 0, 15)

        for index = 1, 12 do
            local actionButton = _G['ActionButton'..index]
            actionButton:ClearAllPoints()
            actionButton:SetPoint('TOPLEFT', (index - 1) * 42 + 9, -14)
            self:StyleButton(actionButton)

            local bottomRightButton = _G['MultiBarBottomRightButton'..index]
            bottomRightButton:ClearAllPoints()
            self:StyleButton(bottomRightButton)

            if index < 7 then
                bottomRightButton:SetPoint('BOTTOMLEFT', (index - 1) * 42, 0)

                if not bottomRightButton.eventsRegistered then
                    bottomRightButton:SetAlpha(0)
                end
            else
                bottomRightButton:SetPoint('TOPLEFT', (index - 7) * 42, 0)
            end

            self:StyleButton(_G['MultiBarBottomLeftButton'..index])
            self:StyleButton(_G['MultiBarLeftButton'..index])
            self:StyleButton(_G['MultiBarRightButton'..index])
        end

        _G.MainMenuBarLeftEndCap:ClearAllPoints()
        _G.MainMenuBarLeftEndCap:SetPoint('BOTTOM', _G.UIParent, 'BOTTOM')
        _G.MainMenuBarLeftEndCap:SetPoint('RIGHT', _G.MainMenuBar, 'LEFT', 32, 0)
        _G.MainMenuBarLeftEndCap:SetSize(128, 77.5)
        _G.MainMenuBarLeftEndCap:SetTexture(self.consoleTexture)
        _G.MainMenuBarLeftEndCap:SetTexCoord(0.56884765625, 0.6982421875, 0.697265625, 1)

        _G.MainMenuBarRightEndCap:ClearAllPoints()
        _G.MainMenuBarRightEndCap:SetPoint('BOTTOM', _G.UIParent, 'BOTTOM')
        _G.MainMenuBarRightEndCap:SetPoint('LEFT', _G.MainMenuBar, 'RIGHT', -32, 0)
        _G.MainMenuBarRightEndCap:SetSize(128, 77.5)
        _G.MainMenuBarRightEndCap:SetTexture(self.consoleTexture)
        _G.MainMenuBarRightEndCap:SetTexCoord(0.56884765625, 0.6982421875, 0.39453125, 0.697265625)

        _G.MainMenuBarTexture0:SetAllPoints()
        _G.MainMenuBarTexture0:SetTexture(self.consoleTexture)

        _G.MainMenuExpBar:SetHeight(16)
        _G.MainMenuExpBar:ClearAllPoints()
        _G.MainMenuExpBar:SetPoint('BOTTOMLEFT', _G.MainMenuBar, 'BOTTOMLEFT')
        _G.MainMenuExpBar:SetPoint('BOTTOMRIGHT', _G.MainMenuBar, 'BOTTOMRIGHT')

        _G.ReputationWatchBar:SetHeight(16)
        _G.ReputationWatchBar:_ClearAllPoints()
        _G.ReputationWatchBar:_SetPoint('BOTTOMLEFT')
        _G.ReputationWatchBar:_SetPoint('BOTTOMRIGHT')
        _G.ReputationWatchBar.StatusBar:ClearAllPoints()
        _G.ReputationWatchBar.StatusBar:SetAllPoints()

        _G.ActionBarUpButton:ClearAllPoints()
        _G.ActionBarUpButton:SetPoint('LEFT', _G.MainMenuBar, 'LEFT', 506, 12)

        _G.ActionBarDownButton:ClearAllPoints()
        _G.ActionBarDownButton:SetPoint('LEFT', _G.MainMenuBar, 'LEFT', 506, -7)

        _G.MainMenuBarPageNumber:SetSize(14, 14)
        _G.MainMenuBarPageNumber:ClearAllPoints()
        _G.MainMenuBarPageNumber:SetPoint('LEFT', _G.MainMenuBar, 'LEFT', 534, 3)

        self:UpdateActionBar()
        self:UpdateWatchBar()
        self:UpdateBackground()
        self:UpdateGryphons()
        self:FixVehicleLeaveButton()
    end
end

function ActionBar:ACTIONBAR_SHOWGRID()
    for i = 1, 6 do
        _G['MultiBarBottomRightButton'..i]:SetAlpha(1)
    end
end

function ActionBar:ACTIONBAR_HIDEGRID()
    for i = 1, 6 do
        local button = _G['MultiBarBottomRightButton'..i]

        if not button.eventsRegistered then
            button:SetAlpha(0)
        end
    end
end

function ActionBar:ShowButtonGrid(name, show)
    local alpha = show and 1 or 0

    _G[name]:SetAlpha(alpha)

    -- _G[name..'HotKey']:SetAlpha(alpha)
    -- _G[name..'Count']:SetAlpha(alpha)
    -- _G[name..'Name']:SetAlpha(alpha)
    -- _G[name..'Cooldown']:SetAlpha(alpha)
end

function ActionBar:ShowButtonGridRange(baseName, from, to, show)
    for index = from, to do
        local name = baseName..index

        if _G[name].eventsRegistered or show then
            self:ShowButtonGrid(name, true)
        else
            self:ShowButtonGrid(name, false)
        end
    end
end

function ActionBar:UpdateBackground()
    if InCombatLockdown() then
        return
    end

    -- TODO: Somehow factor in stance/pet bar position

    _G.MultiBarBottomLeft:ClearAllPoints()

    if self.db.background then
        _G.MainMenuBarTexture0:SetAlpha(1)
        _G.MultiBarBottomLeft:SetPoint('BOTTOMLEFT', _G.ActionButton1, 'TOPLEFT', 0, 15)
    else
        _G.MainMenuBarTexture0:SetAlpha(0)
        _G.MultiBarBottomLeft:SetPoint('BOTTOMLEFT', _G.ActionButton1, 'TOPLEFT', 0, 5)
    end

    for index = 7, 12 do
        local button = _G['MultiBarBottomRightButton'..index]
        button:ClearAllPoints()

        local xOffset = (index - 7) * 42

        if self.db.background then
            button:SetPoint('TOPLEFT', xOffset, 0)
        else
            button:SetPoint('TOPLEFT', xOffset, -9)
        end
    end
end

function ActionBar:UpdateGryphons()
    _G.MainMenuBarLeftEndCap:SetAlpha(self.db.gryphons and 1 or 0)
    _G.MainMenuBarRightEndCap:SetAlpha(self.db.gryphons and 1 or 0)
end

function ActionBar:UpdateActionBar()
    if InCombatLockdown() then
        return
    end

    if SHOW_MULTI_ACTIONBAR_2 then
        -- large layout
        _G.MainMenuBar:SetSize(806, 70)
        _G.MainMenuBarTexture0:SetTexCoord(0, 0.787109375, 0, 0.2734375)
    else
        -- small layout
        _G.MainMenuBar:SetSize(552, 70)
        _G.MainMenuBarTexture0:SetTexCoord(0, 0.5390625, 0.7265625, 1)
    end
end

function ActionBar:UpdateWatchBar()
    if InCombatLockdown() then
        return
    end

    local showExp = _G.MainMenuExpBar:IsShown()
    local showRep = _G.ReputationWatchBar:IsShown()

    if showExp or showRep then
        _G.MainMenuBar:SetPoint('BOTTOM')

        if showRep then
            _G.MainMenuExpBar:Hide()
            _G.MainMenuExpBar.pauseUpdates = true
        elseif UnitLevel('player') < MAX_PLAYER_LEVEL then
            _G.MainMenuExpBar:Show()
            _G.MainMenuExpBar.pauseUpdates = nil
        end
    else
        _G.MainMenuBar:SetPoint('BOTTOM', 0, -16)
    end
end

function ActionBar:FixVehicleLeaveButton()
    local frame = CreateFrame('Frame', nil, _G.UIParent)
    frame:SetPoint('CENTER', _G.UIParent, 'CENTER')
    frame:SetSize(_G.MainMenuBarVehicleLeaveButton:GetSize())

    local button = _G.MainMenuBarVehicleLeaveButton
    button:ClearAllPoints()
    button:SetParent(_G.UIParent)
    button:SetPoint('CENTER', frame, 'CENTER')

    self:SecureHook(button, 'SetPoint', function(_, _, parent)
        if parent ~= frame then
            button:ClearAllPoints()
            button:SetParent(_G.UIParent)
            button:SetPoint('CENTER', frame, 'CENTER')
        end
    end)

    self.vehicleLeaveButton = frame
end

function ActionBar:UpdateVehicleLeaveButtonPosition()
    if InCombatLockdown() then
        return
    end

    self.vehicleLeaveButton:ClearAllPoints()
    self.vehicleLeaveButton:SetPoint(
        self.db.vehicleLeaveButton.anchor,
        self.db.vehicleLeaveButton.xOffset,
        self.db.vehicleLeaveButton.yOffset
    )
end

_G.ModernActionBar.optionsTree.args.actionBar = {
    order = 1,
    type = 'group',
    handler = ActionBar,
    name = 'Action Bar',
    guiInline = true,
    args = {
        background = {
            order = 1,
            type = 'toggle',
            name = 'Show Background',
            desc = '',
            get = function(info)
                return info.handler.db.background
            end,
            set = function(info, value)
                info.handler.db.background = value
                info.handler:UpdateBackground()
            end,
        },
        spacer1 = {
            order = 2,
            type = 'description',
            name = '',
        },
        gryphons = {
            order = 3,
            type = 'toggle',
            name = 'Show Gryphons',
            desc = '',
            get = function(info)
                return info.handler.db.gryphons
            end,
            set = function(info, value)
                info.handler.db.gryphons = value
                info.handler:UpdateGryphons()
            end,
        },
        spacer2 = {
            order = 4,
            type = 'description',
            name = '',
        },
        reset = {
            order = 5,
            type = 'execute',
            name = 'Reset',
            desc = '',
            func = function(info)
                local defaults = _G[info.appName].dbDefaults.global.actionBar

                for key, value in pairs(defaults) do
                    info.handler.db[key] = value
                end

                info.handler:UpdateBackground()
                info.handler:UpdateGryphons()
            end
        },
    },
}

_G.ModernActionBar.optionsTree.args.vehicleLeaveButton = {
    order = 2,
    type = 'group',
    handler = ActionBar,
    name = 'Vehicle Leave Button',
    guiInline = true,
    args = {
        anchor = {
            order = 1,
            type = 'select',
            style = 'dropdown',
            name = 'Anchor',
            desc = 'Anchored position relative to the screen.',
            values = {
                CENTER = 'Center',
                TOP = 'Top',
                TOPLEFT = 'Top left',
                TOPRIGHT = 'Top right',
                RIGHT = 'Right',
                BOTTOM = 'Bottom',
                BOTTOMLEFT = 'Bottom left',
                BOTTOMRIGHT = 'Bottom right',
                LEFT = 'Left',
            },
            get = function(info)
                return info.handler.db.vehicleLeaveButton.anchor
            end,
            set = function(info, value)
                info.handler.db.vehicleLeaveButton.anchor = value
                info.handler:UpdateVehicleLeaveButtonPosition()
            end,
        },
        xOffset = {
            order = 2,
            type = 'range',
            name = 'Offset X',
            desc = 'Horizontal offset relative to the anchored position.',
            min = -(floor(GetScreenWidth())),
            max = floor(GetScreenWidth()),
            step = 1,
            get = function(info)
                return info.handler.db.vehicleLeaveButton.xOffset
            end,
            set = function(info, value)
                info.handler.db.vehicleLeaveButton.xOffset = value
                info.handler:UpdateVehicleLeaveButtonPosition()
            end,
        },
        yOffset = {
            order = 3,
            type = 'range',
            name = 'Offset Y',
            desc = 'Vertical offset relative to the anchored position.',
            min = -(floor(GetScreenHeight())),
            max = floor(GetScreenHeight()),
            step = 1,
            get = function(info)
                return info.handler.db.vehicleLeaveButton.yOffset
            end,
            set = function(info, value)
                info.handler.db.vehicleLeaveButton.yOffset = value
                info.handler:UpdateVehicleLeaveButtonPosition()
            end,
        },
        spacer1 = {
            order = 4,
            type = 'description',
            name = '',
        },
        reset = {
            order = 5,
            type = 'execute',
            name = 'Reset',
            desc = '',
            func = function(info)
                local defaults = _G[info.appName].dbDefaults.global.actionBar.vehicleLeaveButton

                for key, value in pairs(defaults) do
                    info.handler.db.vehicleLeaveButton[key] = value
                end

                info.handler:UpdateVehicleLeaveButtonPosition()
            end
        },
    },
}
