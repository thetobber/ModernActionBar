local N, S = ...
local M = S.A:GetModule('BagBar')

function M:OnInitialize()
    self.db = S.A.db

    self.frame = CreateFrame('Frame', nil, UIParent)
    self.frame:SetSize(204, 54)

    self.frame.texture = self.frame:CreateTexture(nil, 'BACKGROUND')
    self.frame.texture:SetScale(0.5)
    self.frame.texture:SetTexture('Interface\\AddOns\\'..N..'\\Textures\\BagBar.tga')
    self.frame.texture:SetPoint('CENTER')

    self.buttons = {
        MainMenuBarBackpackButton,
        KeyRingButton,
        CharacterBag0Slot,
        CharacterBag1Slot,
        CharacterBag2Slot,
        CharacterBag3Slot,
    }
end

function M:OnEnable()
    self.frame:Show()

    for index, button in ipairs(self.buttons) do
        button:SetParent(self.frame)
        button:ClearAllPoints()

        if index == 1 then
            button:SetPoint('RIGHT', self.frame, 'RIGHT', -9, 0)
        elseif index == 2 then
            button:SetSize(14, 28)
            button:SetPoint('BOTTOMRIGHT', self.buttons[1], 'BOTTOMLEFT', -7, 0)
        else
            button:SetSize(28, 28)
            button:SetPoint('BOTTOMRIGHT', self.buttons[index - 1], 'BOTTOMLEFT', -4, 0)

            local texture = button:GetNormalTexture()
            texture:ClearAllPoints()
            texture:SetPoint('TOPLEFT', -10, 10)
            texture:SetPoint('BOTTOMRIGHT', 10, -10)
        end

        button:Show()
    end

    self:HookScript(self.frame, 'OnEnter')
    self:HookScript(self.frame, 'OnLeave')

    for index, button in ipairs(self.buttons) do
        self:SecureHookScript(button, 'OnEnter')
        self:SecureHookScript(button, 'OnLeave')
    end

    self:Update()
end

function M:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()

    self.frame:SetAlpha(1)
    self.frame:Hide()

    -- for index, button in ipairs(self.buttons) do
    --     button:Hide()
    -- end
end

function M:OnEnter()
    if self.db.global.bagBarEnabled and self.db.global.bagBarMouseOver then
        self.frame:SetAlpha(1)
    end
end

function M:OnLeave()
    if self.db.global.bagBarEnabled and self.db.global.bagBarMouseOver then
        self.frame:SetAlpha(0)
    end
end

function M:Update()
    self:UpdatePosition()
    self:UpdateMouserOver()
end

function M:UpdatePosition()
    self.frame:ClearAllPoints()
    self.frame:SetPoint(unpack(self.db.global.bagBarPosition))
end

function M:UpdateMouserOver()
    if self.db.global.bagBarMouseOver then
        self.frame:SetAlpha(0)
    else
        self.frame:SetAlpha(1)
    end
end
