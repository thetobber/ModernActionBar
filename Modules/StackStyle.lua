local StackStyle = ModernActionBar:GetModule('StackStyle')

function StackStyle:OnInitialize()
    self.db = ModernActionBar.db
    self.shouldUpdateActionBars = false
    self.shouldUpdateExperienceBars = false
    self.shouldUpdatePetActionBar = false

    self:SetEnabledState(false) -- from options
end

function StackStyle:OnEnable()
    self:SecureHook('SetActionBarToggles', 'UpdateActionBars')
    self:SecureHook('MainMenuBar_UpdateExperienceBars', 'UpdateExperienceBars')
    self:SecureHook('PetActionBar_UpdatePositionValues', 'UpdatePetActionBar')
end

function StackStyle:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()
end

function StackStyle:UpdateActionBars()
    if InCombatLockdown() then
        self.shouldUpdateActionBars = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
end

function StackStyle:UpdateExperienceBars()
    if InCombatLockdown() then
        self.shouldUpdateExperienceBars = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
end

function StackStyle:UpdatePetActionBar()
    if InCombatLockdown() then
        self.shouldUpdatePetActionBar = true
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
end

function StackStyle:PLAYER_REGEN_ENABLED()
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
