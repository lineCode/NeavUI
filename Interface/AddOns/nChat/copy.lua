
local _, nChat = ...
local cfg = nChat.Config

local select = select
local tostring = tostring
local concat = table.concat

local container = CreateFrame('Frame', nil, UIParent)
container:SetHeight(220)
container:SetBackdropColor(0, 0, 0, 1)
container:SetFrameStrata('DIALOG')
container:CreateBeautyBorder(12)
container:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = '',
    tile = true, tileSize = 16, edgeSize = 16,
    insets = {left = 3, right = 3, top = 3, bottom = 3
}})
container:Hide()

local title = container:CreateFontString(nil, 'OVERLAY')
title:SetFont('Fonts\\ARIALN.ttf', 18)
title:SetPoint('TOPLEFT', container, 8, -8)
title:SetTextColor(1, 1, 0)
title:SetShadowOffset(1, -1)
title:SetJustifyH('LEFT')

local copyBox = CreateFrame('EditBox', nil, container)
copyBox:SetMultiLine(true)
copyBox:SetMaxLetters(20000)
copyBox:SetSize(450, 270)
copyBox:SetScript('OnEscapePressed', function()
    container:Hide()
end)

local scroll = CreateFrame('ScrollFrame', '$parentScrollBar', container, 'UIPanelScrollFrameTemplate')
scroll:SetPoint('TOPLEFT', container, 'TOPLEFT', 8, -30)
scroll:SetPoint('BOTTOMRIGHT', container, 'BOTTOMRIGHT', -30, 8)
scroll:SetScrollChild(copyBox)

local closeButton = CreateFrame('Button', nil, container, 'UIPanelCloseButton')
closeButton:SetPoint('TOPRIGHT', container, 'TOPRIGHT', 0, -1)

local function GetChatLines(chat)
    local lines = {}
    for message = 1, chat:GetNumMessages() do
        lines[message] = chat:GetMessageInfo(message)
    end

    return lines
end

local function CopyChat(chat)
    ToggleFrame(container)

    if (container:IsShown()) then
        local lines = GetChatLines(chat)
        if (cfg.showInputBoxAbove) then
            local editBox = _G[chat:GetName()..'EditBox']
            container:SetPoint('BOTTOMLEFT', editBox, 'TOPLEFT', 3, 10)
            container:SetPoint('BOTTOMRIGHT', editBox, 'TOPRIGHT', -3, 10)
        else
            local tabHeight = _G[chat:GetName()..'Tab']:GetHeight()
            container:SetPoint('BOTTOMLEFT', chat, 'TOPLEFT', 0, tabHeight + 10)
            container:SetPoint('BOTTOMRIGHT', chat, 'TOPRIGHT', 0, tabHeight + 10)
        end

        title:SetText(chat:GetName())

        local f1, f2, f3 = chat:GetFont()
        copyBox:SetFont(f1, f2, f3)

        local text = concat(lines, '\n')
        copyBox:SetText(text)
    end
end

local function CreateCopyButton(self)
    self.Copy = CreateFrame('Button', nil, self)
    self.Copy:SetSize(20, 20)
    self.Copy:SetPoint('TOPRIGHT', self, -5, -5)

    self.Copy:SetNormalTexture('Interface\\AddOns\\nChat\\media\\textureCopyNormal')
    self.Copy:GetNormalTexture():SetSize(20, 20)

    self.Copy:SetHighlightTexture('Interface\\AddOns\\nChat\\media\\textureCopyHighlight')
    self.Copy:GetHighlightTexture():SetAllPoints(self.Copy:GetNormalTexture())

    local tab = _G[self:GetName()..'Tab']
    hooksecurefunc(tab, 'SetAlpha', function()
        self.Copy:SetAlpha(tab:GetAlpha()*0.55)
    end)

    self.Copy:SetScript('OnMouseDown', function(self)
        self:GetNormalTexture():ClearAllPoints()
        self:GetNormalTexture():SetPoint('CENTER', 1, -1)
    end)

    self.Copy:SetScript('OnMouseUp', function()
        self.Copy:GetNormalTexture():ClearAllPoints()
        self.Copy:GetNormalTexture():SetPoint('CENTER')

        if (self.Copy:IsMouseOver()) then
            CopyChat(self)
        end
    end)
end

local function EnableCopyButton()
    for _, v in pairs(CHAT_FRAMES) do
        local chat = _G[v]
        if (chat and not chat.Copy) then
            CreateCopyButton(chat)
        end
    end
end
hooksecurefunc('FCF_OpenTemporaryWindow', EnableCopyButton)
EnableCopyButton()
