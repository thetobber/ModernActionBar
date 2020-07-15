local RetailStyle = ModernActionBar:GetModule('RetailStyle')

local databaseDefaults = {
    showTextures = true,
    showGryphons = true,
    colorTextures = { 1, 1, 1, 1 },
    colorGryphons = { 1, 1, 1, 1 }
}

function RetailStyle:OnInitialize()
    self:SetEnabledState(self.db.enabled)

    self.db = ModernActionBar.db.char.retailStyle
    self.shouldUpdateActionBars = false
    self.shouldUpdateExperienceBars = false
    self.shouldUpdatePetActionBar = false

    self:SetEnabledState(self.db.enabled) -- from options
end

function RetailStyle:OnEnable()
    self:RegisterEvent('ACTIONBAR_SHOWGRID')
    self:RegisterEvent('ACTIONBAR_HIDEGRID')

    self:SecureHook('SetActionBarToggles', 'UpdateActionBars')
    self:SecureHook('MainMenuBar_UpdateExperienceBars', 'UpdateExperienceBars')
    self:SecureHook('PetActionBar_UpdatePositionValues', 'UpdatePetActionBar')
end

function RetailStyle:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()
end

function RetailStyle:SetButtonGridAlpha(name, alpha)
    _G[name.."NormalTexture"]:SetAlpha(alpha)
    _G[name.."HotKey"]:SetAlpha(alpha)
    _G[name.."Count"]:SetAlpha(alpha)
    _G[name.."Name"]:SetAlpha(alpha)
    _G[name.."Cooldown"]:SetAlpha(alpha)
end

function RetailStyle:ShowBottomRightGrid()
    -- Have to use alpha of button due to combat lockdown restriction
    for index = 1, 6 do
        local buttonName = "MultiBarBottomRightButton"..index
        self:SetButtonGridAlpha(buttonName, show and 1 or (_G[buttonName].eventsRegistered and 1 or 0))
    end
end

function RetailStyle:UpdateActionBars()
    if InCombatLockdown() then
        self.shouldUpdateActionBars = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
end

function RetailStyle:UpdateExperienceBars()
    if InCombatLockdown() then
        self.shouldUpdateExperienceBars = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
end

function RetailStyle:UpdatePetActionBar()
    if InCombatLockdown() then
        self.shouldUpdatePetActionBar = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
end

function RetailStyle:PLAYER_REGEN_ENABLED()
    if self.shouldUpdateActionBars then
        self:UpdateActionBars()
        self.shouldUpdateActionBars = false
    end

    if self.shouldUpdateExperienceBars then
        self:UpdateExperienceBars()
        self.shouldUpdateExperienceBars = false
    end

    if self.shouldUpdatePetActionBar then
        self:UpdatePetActionBar()
        self.shouldUpdatePetActionBar = false
    end

    self:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function RetailStyle:ACTIONBAR_SHOWGRID()
end

function RetailStyle:ACTIONBAR_HIDEGRID()
end

ModernActionBar.optionsTree.args.retailStyle = {
    order = 1,
    type = 'group',
    name = 'Retail style',
    handler = RetailStyle,
    guiInline = true,
    args = {
        showTextures = {
            order = 1,
            type = 'toggle',
            name = 'Show textures',
            desc = 'Show/hide all action bar textures',
            get = function(handler)
                return handler.db.showTextures
            end,
            set = function(handler, value)
                handler.db.showTextures = value
            end
        },
        showGryphons = {
            order = 2,
            type = 'toggle',
            name = 'Show gryphons',
            desc = 'Show/hide gryphons',
            get = function(handler)
                return handler.db.showGryphons
            end,
            set = function(handler, value)
                handler.db.showGryphons = value
            end,
            disabled = function(handler)
                return not handler.db.showTextures
            end
        },
        colorTextures = {
            order = 3,
            type = 'color',
            name = 'Textures color',
            desc = 'Sets the color of all action bar textures except gryphons',
            hasAlpha = true,
            get = function(handler)
                return unpack(handler.db.colorTextures)
            end,
            set = function(handler, ...)
                handler.db.colorTextures = { ... }
            end
        },
        colorGryphons = {
            order = 4,
            type = 'color',
            name = 'Gryphons color',
            desc = 'Sets the color of both gryphons',
            hasAlpha = true,
            get = function(handler)
                return unpack(handler.db.colorGryphons)
            end,
            set = function(handler, ...)
                handler.db.colorTextures = { ... }
            end
        }
    }
}
