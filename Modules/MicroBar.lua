local _G = getfenv(0)
local CreateFrame = _G.CreateFrame
local pairs = _G.pairs
local ipairs = _G.ipairs

local MicroBar = _G.ModernActionBar:GetModule('MicroBar')

function MicroBar:OnInitialize()
    self.db = _G.ModernActionBar.db.global.microBar

    self.frame = CreateFrame('Frame', nil, _G.UIParent)
    self.frame:SetSize(228, 52)

    self.frame.texture = self.frame:CreateTexture(nil, 'BACKGROUND')
    self.frame.texture:SetScale(0.5)
    self.frame.texture:SetTexture('Interface\\AddOns\\ModernActionBar\\Textures\\MicroBar.tga')
    self.frame.texture:SetPoint('CENTER')

    self.buttons = {
        _G.CharacterMicroButton,
        _G.SpellbookMicroButton,
        _G.TalentMicroButton,
        _G.QuestLogMicroButton,
        _G.SocialsMicroButton,
        _G.WorldMapMicroButton,
        _G.MainMenuMicroButton,
        _G.HelpMicroButton,
    }
end

function MicroBar:OnEnable()
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

    self:HookScript(self.frame, 'OnEnter')
    self:HookScript(self.frame, 'OnLeave')

    for index, button in ipairs(self.buttons) do
        self:SecureHookScript(button, 'OnEnter')
        self:SecureHookScript(button, 'OnLeave')
    end

    self:UpdateEnabled()
    self:UpdateMouseOver()
    self:UpdatePosition()
end

function MicroBar:OnDisable()
    self:UnhookAll()
    self:UnregisterAllEvents()
    self.frame:Hide()
end

function MicroBar:OnEnter()
    if self.db.enabled and self.db.mouseOver then
        self.frame:SetAlpha(1)
    end
end

function MicroBar:OnLeave()
    if self.db.enabled and self.db.mouseOver then
        self.frame:SetAlpha(0)
    end
end

function MicroBar:UpdateEnabled()
    if self.db.enabled then
        self:Enable()
    else
        self:Disable()
    end
end

function MicroBar:UpdateMouseOver()
    if self.db.mouseOver then
        self.frame:SetAlpha(0)
    else
        self.frame:SetAlpha(1)
    end
end

function MicroBar:UpdatePosition()
    self.frame:ClearAllPoints()
    self.frame:SetPoint(self.db.anchor, self.db.xOffset, self.db.yOffset)
end

_G.ModernActionBar.optionsTree.args.microBar = {
    order = 5,
    type = 'group',
    handler = MicroBar,
    name = 'Micro Bar',
    guiInline = true,
    args = {
        enabled = {
            order = 1,
            type = 'toggle',
            name = 'Enable',
            get = function(info)
                return info.handler.db.enabled
            end,
            set = function(info, value)
                info.handler.db.enabled = value
                info.handler:UpdateEnabled()
            end,
        },
        spacer1 = {
            order = 2,
            type = 'description',
            name = '',
        },
        mouseOver = {
            order = 3,
            type = 'toggle',
            name = 'Mouse Over',
            desc = 'Show/hide on mouse over.',
            get = function(info)
                return info.handler.db.mouseOver
            end,
            set = function(info, value)
                info.handler.db.mouseOver = value
                info.handler:UpdateMouseOver()
            end,
        },
        spacer2 = {
            order = 4,
            type = 'description',
            name = '',
        },
        anchor = {
            order = 5,
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
                return info.handler.db.anchor
            end,
            set = function(info, value)
                info.handler.db.anchor = value
                info.handler:UpdatePosition()
            end,
        },
        xOffset = {
            order = 6,
            type = 'range',
            name = 'Offset X',
            desc = 'Horizontal offset relative to the anchored position.',
            min = -(floor(GetScreenWidth())),
            max = floor(GetScreenWidth()),
            step = 1,
            get = function(info)
                return info.handler.db.xOffset
            end,
            set = function(info, value)
                info.handler.db.xOffset = value
                info.handler:UpdatePosition()
            end,
        },
        yOffset = {
            order = 7,
            type = 'range',
            name = 'Offset Y',
            desc = 'Vertical offset relative to the anchored position.',
            min = -(floor(GetScreenHeight())),
            max = floor(GetScreenHeight()),
            step = 1,
            get = function(info)
                return info.handler.db.yOffset
            end,
            set = function(info, value)
                info.handler.db.yOffset = value
                info.handler:UpdatePosition()
            end,
        },
        spacer3 = {
            order = 8,
            type = 'description',
            name = '',
        },
        reset = {
            order = 9,
            type = 'execute',
            name = 'Reset',
            desc = '',
            func = function(info)
                local defaults = _G[info.appName].dbDefaults.global.microBar

                for key, value in pairs(defaults) do
                    info.handler.db[key] = value
                end

                info.handler:UpdatePosition()
            end,
        },
    },
}
