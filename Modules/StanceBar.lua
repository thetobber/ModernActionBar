local StanceBar = _G.ModernActionBar:GetModule('StanceBar')

function StanceBar:OnInitialize()
    _G.UIPARENT_MANAGED_FRAME_POSITIONS['StanceBarFrame'] = nil
    self.frame = _G.StanceBarFrame

    self.frame:SetScript('OnShow', nil)
    self.frame:SetScript('OnHide', nil)

    _G.StanceBarFrame._ClearAllPoints = _G.StanceBarFrame.ClearAllPoints
    _G.StanceBarFrame.ClearAllPoints = function() end

    _G.StanceBarFrame._SetPoint = _G.StanceBarFrame.SetPoint
    _G.StanceBarFrame.SetPoint = function() end
end

function StanceBar:OnEnable()
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
    self:SecureHook('SetActionBarToggles', 'Update')
end

function StanceBar:PLAYER_ENTERING_WORLD(isLogin, isReload)
    if isLogin or isReload then
        self:Update()
    end
end

function StanceBar:Update()
    if InCombatLockdown() then
        return
    end

    if not self.frame.fixed then
        local buttonCount = GetNumShapeshiftForms()
        self.frame:SetSize(buttonCount * (30 + 6) - 6, 30)

        for index = 1, buttonCount do
            local button = _G['StanceButton'..index]
            button:SetParent(self.frame)
            button:SetSize(30, 30)
            button:ClearAllPoints()

            if index == 1 then
                button:SetPoint('LEFT')
            else
                button:SetPoint('LEFT', (index - 1) * (30 + 6), 0)
            end

            -- self:RemoveTexture(_G['StanceButton'..index..'NormalTexture2'])
            self:UpdateButtonStyle(button)
        end

        self.frame.fixed = true
    end

    self.frame:_ClearAllPoints()

    if SHOW_MULTI_ACTIONBAR_1 then
        self.frame:_SetPoint('BOTTOMLEFT', _G.MultiBarBottomLeftButton1, 'TOPLEFT', 42, 6)
    else
        self.frame:_SetPoint('BOTTOMLEFT', _G.ActionButton1, 'TOPLEFT', 42, 12)
    end
end
