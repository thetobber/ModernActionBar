local BagAndMicroBar = ModernActionBar:GetModule('BagAndMicroBar')

function BagAndMicroBar:OnInitialize()
    self.db = ModernActionBar.db
    self.Frame = CreateFrame('Frame', 'ModernActionBarBags', UIParent)
    self:RegisterEvent('PLAYER_LOGIN')
end

function BagAndMicroBar:Option_Show()
    if self.db.char.visibility.showBars then
        self.Frame:Show()
    else
        self.Frame:Hide()
    end
end

function BagAndMicroBar:Option_Color()
    local r, g, b, a = unpack(ModernActionBar.db.char.coloring.colorBars)
    self.Frame.Texture:SetVertexColor(r, g, b, a)
end

function BagAndMicroBar:PLAYER_LOGIN()
    local microButtons = {
        CharacterMicroButton,
        SpellbookMicroButton,
        TalentMicroButton,
        QuestLogMicroButton,
        SocialsMicroButton,
        WorldMapMicroButton,
        MainMenuMicroButton,
        HelpMicroButton
    }

    self.Frame = CreateFrame('Frame', 'ModernActionBarBags', UIParent)
    self.Frame:SetSize(224, 89)
    self.Frame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT')
    self.Frame.Texture = self.Frame:CreateTexture(nil, 'BACKGROUND')
    self.Frame.Texture:SetTexture('Interface\\AddOns\\ModernActionBar\\Media\\Textures\\Console.tga')
    self.Frame.Texture:SetAllPoints()
    self.Frame.Texture:SetTexCoord(0.78125, 1, 0.65234375, 1)

    MainMenuBarBackpackButton:ClearAllPoints()
    MainMenuBarBackpackButton:SetPoint('BOTTOMRIGHT', self.Frame, 'BOTTOMRIGHT', -7, 47)

    KeyRingButton:ClearAllPoints()
    KeyRingButton:SetSize(14, 28)
    KeyRingButton:SetPoint('BOTTOMRIGHT', MainMenuBarBackpackButton, 'BOTTOMLEFT', -6, 0)

    CharacterBag0Slot:ClearAllPoints()
    CharacterBag0Slot:SetPoint('RIGHT', KeyRingButton, 'LEFT', -4, 0)

    CharacterBag1Slot:ClearAllPoints()
    CharacterBag1Slot:SetPoint('RIGHT', CharacterBag0Slot, 'LEFT', -4, 0)

    CharacterBag2Slot:ClearAllPoints()
    CharacterBag2Slot:SetPoint('RIGHT', CharacterBag1Slot, 'LEFT', -4, 0)

    CharacterBag3Slot:ClearAllPoints()
    CharacterBag3Slot:SetPoint('RIGHT', CharacterBag2Slot, 'LEFT', -4, 0)

    for index, button in ipairs({
        CharacterBag0Slot,
        CharacterBag1Slot,
        CharacterBag2Slot,
        CharacterBag3Slot
    }) do
        button:SetSize(28, 28)
        _G[button:GetName()..'NormalTexture']:ClearAllPoints()
        _G[button:GetName()..'NormalTexture']:SetPoint('TOPLEFT', button, 'TOPLEFT', -10, 10)
        _G[button:GetName()..'NormalTexture']:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', 10, -10)
    end

    for index, button in ipairs(microButtons) do
        button:ClearAllPoints()

        if index == 1 then
            button:SetPoint('BOTTOMLEFT', self.Frame, 'BOTTOMLEFT', 8, 3)
        else
            button:SetPoint('LEFT', microButtons[index - 1], 'RIGHT', -3, 0)
        end
    end
end
