local LineStyle = ModernActionBar:GetModule('LineStyle')

function LineStyle:OnInitialize()
    self.db = ModernActionBar.db
    self.shouldUpdateActionBars = false
    self.shouldUpdateExperienceBars = false
    self.shouldUpdatePetActionBar = false

    self:SetEnabledState(false) -- from options
end

function LineStyle:OnEnable()
    self:SecureHook('SetActionBarToggles', 'UpdateActionBars')
    self:SecureHook('MainMenuBar_UpdateExperienceBars', 'UpdateExperienceBars')
    self:SecureHook('PetActionBar_UpdatePositionValues', 'UpdatePetActionBar')
end

function LineStyle:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()
end

function LineStyle:UpdateActionBars()
    if InCombatLockdown() then
        self.shouldUpdateActionBars = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
end

function LineStyle:UpdateExperienceBars()
    if InCombatLockdown() then
        self.shouldUpdateExperienceBars = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
end

function LineStyle:UpdatePetActionBar()
    if InCombatLockdown() then
        self.shouldUpdatePetActionBar = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
end

function LineStyle:PLAYER_REGEN_ENABLED()
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
