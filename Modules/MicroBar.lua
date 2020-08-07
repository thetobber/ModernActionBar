local N, S = ...
local M = S.A:GetModule('MicroBar')

function M:OnInitialize()
    self.db = S.A.db

    self.frame = CreateFrame('Frame', nil, UIParent)
    self.frame:SetSize(228, 52)

    self.frame.texture = self.frame:CreateTexture(nil, 'BACKGROUND')
    self.frame.texture:SetScale(0.5)
    self.frame.texture:SetTexture('Interface\\AddOns\\'..N..'\\Textures\\MicroBar.tga')
    self.frame.texture:SetPoint('CENTER')

    self.buttons = {
        CharacterMicroButton,
        SpellbookMicroButton,
        TalentMicroButton,
        QuestLogMicroButton,
        SocialsMicroButton,
        WorldMapMicroButton,
        MainMenuMicroButton,
        HelpMicroButton,
    }
end

function M:OnEnable()
    self.frame:Show()

    for index, button in ipairs(self.buttons) do
        button:SetParent(self.frame)
        button:ClearAllPoints()

        if index == 1 then
            button:SetPoint('LEFT', self.frame, 'LEFT', 8, 11)
        else
            button:SetPoint('LEFT', self.buttons[index - 1], 'RIGHT', -3, 0)
        end

        button:Show()
    end

    if GetCVar('displayFreeBagSlots') == '1' then
        self:RegisterEvent('BAG_UPDATE')
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

function M:BAG_UPDATE()
    MainMenuBarBackpackButtonCount:SetText(string.format('(%s)', MainMenuBarBackpackButton.freeSlots))
end

function M:OnEnter()
    if self.db.global.microBarEnabled and self.db.global.microBarMouseOver then
        self.frame:SetAlpha(1)
    end
end

function M:OnLeave()
    if self.db.global.microBarEnabled and self.db.global.microBarMouseOver then
        self.frame:SetAlpha(0)
    end
end

function M:Update()
    self:UpdatePosition()
    self:UpdateMouserOver()
end

function M:UpdatePosition()
    self.frame:ClearAllPoints()
    self.frame:SetPoint(unpack(self.db.global.microBarPosition))
end

function M:UpdateMouserOver()
    if self.db.global.microBarMouseOver then
        self.frame:SetAlpha(0)
    else
        self.frame:SetAlpha(1)
    end
end
