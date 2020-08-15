local _G = getfenv(0)
local InCombatLockdown = _G.InCombatLockdown

local StanceBar = _G.ModernActionBar:GetModule('StanceBar')

function StanceBar:OnInitialize()
    _G.UIPARENT_MANAGED_FRAME_POSITIONS['StanceBarFrame'] = nil

    self.frame = _G.StanceBarFrame

    self.frame:SetScript('OnShow', nil)
    self.frame:SetScript('OnHide', nil)
end

function StanceBar:OnEnable()
    self:RegisterEvent('PLAYER_ENTERING_WORLD')
    self:SecureHook('SetActionBarToggles', 'UpdatePosition')
end

function StanceBar:PLAYER_ENTERING_WORLD(isLogin, isReload)
    if isLogin or isReload then
        self:UpdateStyle()
        self:UpdatePosition()
    end
end

function StanceBar:UpdateStyle()
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

        self:StyleButton(button)
    end
end

function StanceBar:UpdatePosition()
    if InCombatLockdown() then
        return
    end

    self.frame:ClearAllPoints()

    if _G.SHOW_MULTI_ACTIONBAR_1 then
        self.frame:SetPoint('BOTTOMLEFT', _G.MultiBarBottomLeftButton1, 'TOPLEFT', 42, 6)
    else
        self.frame:SetPoint('BOTTOMLEFT', _G.ActionButton1, 'TOPLEFT', 42, 12)
    end
end
