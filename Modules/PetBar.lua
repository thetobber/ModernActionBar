local NAME, _ = ...
local PetBar = _G.ModernActionBar:GetModule('PetBar')

function PetBar:OnInitialize()
    _G.UIPARENT_MANAGED_FRAME_POSITIONS['PetActionBarFrame'] = nil

    self.frame = CreateFrame('Frame', nil, _G.UIParent, 'SecureHandlerStateTemplate')
    self.frame:SetFrameStrata('LOW')

    self.frame:SetAttribute('_onstate-show', [[
        if newstate == 'hide' then
            self:Hide()
        else
            self:Show()
        end
    ]])

    RegisterStateDriver(self.frame, 'show', '[pet,nooverridebar,nopossessbar] show;hide')
    _G.PetActionBarFrame:SetScale(0.0001)
end

function PetBar:OnEnable()
    local path = 'Interface\\AddOns\\'..NAME..'\\Textures\\Button\\'

    self:RegisterEvent('PLAYER_ENTERING_WORLD')
    self:SecureHook('SetActionBarToggles', 'Update')

    self:SecureHook('PetActionBar_Update', function()
        for index = 1, 10 do
            local _, texture = GetPetActionInfo(index)
            local button = _G['PetActionButton'..index]

            if texture then
                button:SetNormalTexture(path..'UI-Quickslot2.tga')
            else
                button:SetNormalTexture(path..'UI-Quickslot.tga')
            end
        end
    end)
end

function PetBar:PLAYER_ENTERING_WORLD(isLogin, isReload)
    if isLogin or isReload then
        self:Update()
    end
end

function PetBar:Update()
    if InCombatLockdown() then
        return
    end

    if not self.frame.fixed then
        self.frame:SetSize(10 * (30 + 6) - 6, 30)

        for index = 1, 10 do
            local button = _G['PetActionButton'..index]
            button:SetParent(self.frame)
            button:SetSize(30, 30)
            button:ClearAllPoints()

            if index == 1 then
                button:SetPoint('LEFT')
            else
                button:SetPoint('LEFT', (index - 1) * (30 + 6), 0)
            end

            self:UpdateButtonStyle(button)
        end

        self.frame.fixed = true
    end

    self.frame:ClearAllPoints()

    if SHOW_MULTI_ACTIONBAR_1 then
        self.frame:SetPoint('BOTTOMLEFT', _G.MultiBarBottomLeftButton1, 'TOPLEFT', 42, 6)
    else
        self.frame:SetPoint('BOTTOMLEFT', _G.ActionButton1, 'TOPLEFT', 42, 14)
    end
end
