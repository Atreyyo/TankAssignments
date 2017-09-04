--[[
########################################
####		TankAssignments			####
####	by Atreyyo @ vanillagaming	####
########################################
]]

TankAssignments = CreateFrame("Button", "TankAssignments",UIParent)
TankAssignments.ToolTip = CreateFrame("Button", "ToolTip",UIParent)
TankAssignments.Minimap = CreateFrame("Frame",nil,Minimap) -- Minimap Frame

-- vars

TankAssignments_Settings = TankAssignments_Settings or {}

TankAssignments.Settings = {
	["MainFrame"] = false,
	["Animation"] = false,
	["MainFrameX"] = 450,
	["MainFrameY"] = 500,
	["SizeX"] = 0,
	["SizeY"] = 0,
	["active"] = "",

}

TankAssignments.Marks = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
}

TankAssignments.RealMarks = {
	[1] = "Star",
	[2] = "Circle",
	[3] = "Diamond",
	[4] = "Triangle",
	[5] = "Moon",
	[6] = "Square",
	[7] = "Cross",
	[8] = "Skull",
}

TankAssignments.Frames = {
	["ToolTip"] = {},
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
}

TankAssignments.Classes = {
	[1] = "Warrior",
	[2] = "Warlock",
	[3] = "Rogue",
	[4] = "Priest",
	[5] = "Mage",
	[6] = "Hunter",
	[7] = "Druid",
	[8] = "Paladin",
	[9] = "Shaman",
}

TankAssignments.ChanTable = {
	["s"] = "SAY",
	["y"] = "YELL",
	["e"] = "EMOTE",
	["g"] = "GUILD",
	["p"] = "PARTY",
	["r"] = "RAID",
	["1"] = {"CHANNEL", "1"},
	["2"] = {"CHANNEL", "2"},
	["3"] = {"CHANNEL", "3"},
	["4"] = {"CHANNEL", "4"},
	["5"] = {"CHANNEL", "5"},
	["6"] = {"CHANNEL", "6"},
	["7"] = {"CHANNEL", "7"},
	["8"] = {"CHANNEL", "8"},
	["9"] = {"CHANNEL", "9"},
}

-- events
TankAssignments:RegisterEvent("ADDON_LOADED")
TankAssignments:RegisterEvent("RAID_ROSTER_UPDATE")
TankAssignments:RegisterEvent("CHAT_MSG_WHISPER")
TankAssignments:RegisterEvent("UNIT_PORTRAIT_UPDATE")
TankAssignments:RegisterEvent("CHAT_MSG_ADDON") 

function TankAssignments:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "TankAssignments" then
		DEFAULT_CHAT_FRAME:AddMessage("TankAssignments 2.0 Loaded!")
		TankAssignments:ConfigMainFrame()
		TankAssignments:UnregisterEvent("ADDON_LOADED")
	elseif event == "RAID_ROSTER_UPDATE" then 
		TankAssignments:UpdateTanks()
	elseif event ==	"UNIT_PORTRAIT_UPDATE" then
		TankAssignments:UpdateTanks()
	elseif (event == "CHAT_MSG_ADDON") then
		if string.sub(arg1,1,15) == "TankAssignments" and UnitName("player") ~= arg4 then
			if string.sub(arg1,16,string.len(arg1)) == "Marks" then

				TankAssignments.Marks = {
					[1] = {},
					[2] = {},
					[3] = {},
					[4] = {},
					[5] = {},
					[6] = {},
					[7] = {},
					[8] = {},
				}

				for text in string.gfind(arg2,"%d%a+") do	
					local mark = tonumber(string.sub(text,1,1))
					--DEFAULT_CHAT_FRAME:AddMessage(mark..string.sub(text,2,string.len(text)))
					table.insert(TankAssignments.Marks[mark],string.sub(text,2,string.len(text)))
				end
			TankAssignments:UpdateTanks()
			elseif string.sub(arg1,7,string.len(arg1)) == "Ignore" then

			end
		end
	end	
end

-- /script TankAssignments:ConfigMainFrame()

function TankAssignments:ConfigMainFrame()

	TankAssignments.Drag = {}
	function TankAssignments.Drag:StartMoving()
		TankAssignments:StartMoving()
		this.drag = true
	end
	
	function TankAssignments.Drag:StopMovingOrSizing()
		TankAssignments:StopMovingOrSizing()
		this.drag = false
	end
	
	local backdrop = {
			--edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			tile="false",
			tileSize="16",
			edgeSize="4",
			insets={
				left="0",
				right="0",
				top="0",
				bottom="0"
			}
	}
	
	self:SetFrameStrata("BACKGROUND")
	self:SetWidth(TankAssignments.Settings["MainFrameX"]) 
	self:SetHeight(TankAssignments.Settings["MainFrameY"]) 
	self:SetPoint("CENTER",0,100)
	self:SetMovable(1)
	self:EnableMouse(1)
	self:RegisterForDrag("LeftButton")
	self:SetBackdrop(backdrop) --border around the frame
	self:SetBackdropColor(0,0,0,1)

	self:SetScript("OnUpdate", function()
		local updfreq=(math.floor(GetFramerate())*0.3)
		if TankAssignments:IsVisible() then
			if not TankAssignments.Settings["MainFrame"] then
				if TankAssignments.Settings["SizeX"] >= TankAssignments.Settings["MainFrameX"] and TankAssignments.Settings["SizeY"] >= TankAssignments.Settings["MainFrameY"] then
					TankAssignments.Settings["MainFrame"] = true
					TankAssignments:SetWidth(TankAssignments.Settings["MainFrameX"])
					TankAssignments:SetHeight(TankAssignments.Settings["MainFrameY"])
					TankAssignments.bg:Show()
				else
					if TankAssignments.Settings["SizeX"] < TankAssignments.Settings["MainFrameX"] then
						TankAssignments.Settings["SizeX"] = TankAssignments.Settings["SizeX"]+(TankAssignments.Settings["MainFrameX"]/updfreq)
						TankAssignments:SetWidth(TankAssignments.Settings["SizeX"])
					end
					if TankAssignments.Settings["SizeY"] < TankAssignments.Settings["MainFrameY"] then
						TankAssignments.Settings["SizeY"] = TankAssignments.Settings["SizeY"]+(TankAssignments.Settings["MainFrameY"]/updfreq)
						TankAssignments:SetHeight(TankAssignments.Settings["SizeY"])
					end
				end
			else
				if TankAssignments.Settings["Animation"] then
					TankAssignments.bg:Hide()
					if TankAssignments.Settings["SizeX"] <= 0 and TankAssignments.Settings["SizeY"] <= 0 then
						TankAssignments.Settings["MainFrame"] = false
						TankAssignments.Settings["Animation"] = false
						TankAssignments.bg:Hide()
						TankAssignments:Hide()
					else
						if TankAssignments.Settings["SizeY"] >= 0 then
							TankAssignments.Settings["SizeY"] = TankAssignments.Settings["SizeY"]-(TankAssignments.Settings["MainFrameY"]/updfreq)
							TankAssignments:SetHeight(TankAssignments.Settings["SizeY"])
						end
						if TankAssignments.Settings["SizeY"] < TankAssignments.Settings["MainFrameY"]/4 then
							TankAssignments.Settings["SizeX"] = TankAssignments.Settings["SizeX"]-(TankAssignments.Settings["MainFrameX"]/updfreq)
							TankAssignments:SetWidth(TankAssignments.Settings["SizeX"])
						end	
					end
				end
			end
		else

		end
	--[[
		this:EnableMouse(IsAltKeyDown())
		if not IsAltKeyDown() and this.drag then
			self.Drag:StopMovingOrSizing()
		end
		]]
	end)	

	self.bg = CreateFrame("Button", "bg",TankAssignments)
	self.bg:SetWidth(self:GetWidth()) 
	self.bg:SetHeight(self:GetHeight()) 
	self.bg:SetPoint("TOPLEFT",0,0)	
	self.bg:SetBackdropColor(0,0,0,1)
	self.bg:EnableMouse(1)
	self.bg:SetMovable(1)
	self.bg:RegisterForDrag("LeftButton")
	self.bg:SetScript("OnDragStart",TankAssignments.Drag.StartMoving)
	self.bg:SetScript("OnDragStop", TankAssignments.Drag.StopMovingOrSizing)
	self.bg:SetScript("OnEnter", function()
			TankAssignments.ToolTip:Hide()
		end)
	
	self.text = self.bg:CreateFontString(nil, "OVERLAY")
    self.text:SetPoint("CENTER", self.bg, "CENTER", 0, 225)
    self.text:SetFont("Fonts\\FRIZQT__.TTF", 25)
	local r,g,b= TankAssignments:GetClassColors("Warrior","class")
	self.text:SetTextColor(r,g,b, 1)
	self.text:SetShadowOffset(2,-2)
    self.text:SetText("TankAssignments 2.0")
	
	Icon = self.bg:CreateTexture(nil, 'ARTWORK')
	Icon:SetTexture("Interface\\AddOns\\TankAssignments\\Icon")
	Icon:SetPoint('TOPLEFT', 5, -5)
	Icon:SetWidth(50)
	Icon:SetHeight(50)
	
	-- classes
	local i = 1
	for n, class in pairs(TankAssignments.Classes) do	
		local r, l, t, b = TankAssignments:ClassPos(class)
		local classframe = CreateFrame('Button', class, self.bg)
		classframe:SetWidth(20)
		classframe:SetHeight(20)
		classframe:SetBackdropColor(0,0,0,1)
		classframe:SetPoint('TOPLEFT', 100+(i*25), -40)
		classframe:SetFrameStrata('MEDIUM')
		classframe.Icon = classframe:CreateTexture(nil, 'ARTWORK')
		classframe.Icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		classframe.Icon:SetTexCoord(r, l, t, b)
		classframe.Icon:SetPoint('TOPRIGHT', -1, -1)
		classframe.Icon:SetWidth(20)
		classframe.Icon:SetHeight(20)
		classframe:SetScript("OnEnter", function() 
			--DEFAULT_CHAT_FRAME:AddMessage(this:GetName())
			local r,g,b=TankAssignments:GetClassColors(this:GetName(),"class")
			GameTooltip:SetOwner(classframe, "ANCHOR_TOPRIGHT");
			GameTooltip:SetText("|cffFFFFFFShow|r "..this:GetName(), r,g,b);
			GameTooltip:Show()
		end)
		classframe:SetScript("OnLeave", function() GameTooltip:Hide() end)
		classframe:SetScript("OnMouseDown", function()
			if (arg1 == "LeftButton") then
				if TankAssignments_Settings[this:GetName()] == 1 then
					TankAssignments_Settings[this:GetName()] = 0
					classframe.Icon:SetVertexColor(0.5, 0.5, 0.5)
				else
					TankAssignments_Settings[this:GetName()] = 1
					classframe.Icon:SetVertexColor(1.0, 1.0, 1.0)
				end
			end
		end)
		if class == "Paladin" and UnitFactionGroup("player") == "Horde" then	
			classframe:Hide()
		elseif class == "Shaman" and UnitFactionGroup("player") == "Alliance" then
			classframe:Hide()
		else
		i=i+1
		end
		if TankAssignments_Settings[class] == nil then
			TankAssignments_Settings[class] = 1
			classframe.Icon:SetVertexColor(1.0, 1.0, 1.0)			
		else
			if TankAssignments_Settings[class] == 1 then
				classframe.Icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				classframe.Icon:SetVertexColor(0.5, 0.5, 0.5)
			end			
		end
	end
	-- icons
	for i in pairs(TankAssignments.Marks) do
		local r, l, t, b = TankAssignments:GetMarkPos(i)
		local icon = CreateFrame("Frame",i,self.bg) 
		icon:SetWidth(50)
		icon:SetHeight(50) 
		icon:SetPoint('BOTTOMLEFT', 50, (50*i)-25)
		icon:SetBackdropColor(0,0,0,1)
		icon:SetFrameStrata('MEDIUM')
		icon:EnableMouse(1)
		icon:SetScript("OnEnter", function()
			TankAssignments:OpenToolTip(this:GetName())
		end)
		icon:SetScript("OnLeave", function()
			--TankAssignments.ToolTip:Hide()
		end)	
		
		icon.Icon = icon:CreateTexture(nil, 'ARTWORK')
		icon.Icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		icon.Icon:SetTexCoord(r, l, t, b)
		icon.Icon:SetPoint('CENTER', 0,0)
		icon.Icon:SetWidth(50)
		icon.Icon:SetHeight(50)

	--[[
		local text = self.bg:CreateFontString(nil, "OVERLAY")
		text:SetPoint("CENTER", icon, "CENTER", 70, 0)
		text:SetFont("Fonts\\FRIZQT__.TTF", 25)
		text:SetTextColor(255, 255, 0, 1)
		text:SetShadowOffset(2,-2)
		text:SetText(i)
	]]
	end
	
	-- Selected Tank Channel String
	self.TankChannelSelectedFontString = self.bg:CreateFontString(nil, "OVERLAY")
    self.TankChannelSelectedFontString:SetPoint("BOTTOMRIGHT", 30, 12)
    self.TankChannelSelectedFontString:SetFont("Fonts\\FRIZQT__.TTF", 11)
	self.TankChannelSelectedFontString:SetWidth(150)
	self.TankChannelSelectedFontString:SetJustifyH("LEFT")
    self.TankChannelSelectedFontString:SetText("TEST")	
	
	if TankAssignments_Settings["TankChannel"] == nil then
		TankAssignments_Settings["TankChannel"] = "r"
	end
	-- Tank Channel EditBox
	self.TankChannelEditBox = CreateFrame("EditBox", nil, self.bg,"InputBoxTemplate")
	self.TankChannelEditBox:SetPoint("BOTTOMRIGHT",-125,5)
	self.TankChannelEditBox:SetWidth(18)
	self.TankChannelEditBox:SetHeight(30)
	self.TankChannelEditBox:SetMaxLetters(1)
	self.TankChannelEditBox:SetAutoFocus(false)
	self.TankChannelEditBox:SetFrameStrata("MEDIUM")
	self.TankChannelEditBox:SetText(TankAssignments_Settings["TankChannel"])
	self.TankChannelEditBox:SetScript("OnTextChanged", function() PlaySound("igMainMenuOptionCheckBoxOn");
		TankAssignments_Settings["TankChannel"] = self.TankChannelEditBox:GetText()
		TankAssignments:SetTankChannelString()
		self.TankChannelEditBox:ClearFocus()
		end)
	self.TankChannelEditBox:SetScript("OnEnter", function() PlaySound("igMainMenuOptionCheckBoxOn");
		GameTooltip:SetOwner(self.TankChannelSelectedFontString, "ANCHOR_TOPLEFT");
		GameTooltip:SetText("Channel to announce TankAssignments");
		GameTooltip:AddLine("Enter a number or s=say, p=party, r=raid",1,1,1);
		GameTooltip:Show()
		end)
	self.TankChannelEditBox:SetScript("OnLeave", function() GameTooltip:Hide() end)
	if TankAssignments_Settings["TankChannel"] then self.TankChannelEditBox:SetText(TankAssignments_Settings["TankChannel"]) end
	
	-- create close button
	self.CloseButton = CreateFrame("Button",nil,self.bg,"UIPanelCloseButton")
	self.CloseButton:SetPoint("TOPLEFT",self:GetWidth()-23,2)
	self.CloseButton:SetWidth(24)
	self.CloseButton:SetHeight(24)
	self.CloseButton:SetFrameStrata('MEDIUM')
	self.CloseButton:SetScript("OnClick", function() 
		PlaySound("igMainMenuOptionCheckBoxOn"); 
		TankAssignments.ToolTip:Hide()
		TankAssignments.Settings["Animation"] = true
		TankAssignments.Settings["MainFrame"] = false

	end)
	-- Post button
	self.dbutton = CreateFrame("Button",nil,self.bg,"UIPanelButtonTemplate")
	self.dbutton:SetPoint("BOTTOM",0,10)
	self.dbutton:SetFrameStrata("MEDIUM")
	self.dbutton:SetWidth(145)
	self.dbutton:SetHeight(18)
	self.dbutton:SetText("Post TankAssignments")
	self.dbutton:SetScript("OnClick", function() 
		if IsRaidOfficer("player") then
			PlaySound("igMainMenuOptionCheckBoxOn"); 
			TankAssignments:PostAssignments() 
		end
	end)
	
	self.bg:Hide()
	self:Hide()
	TankAssignments.Settings["MainFrame"] = false
	TankAssignments.Settings["SizeX"] = 0
	TankAssignments.Settings["SizeY"] = 0	
	TankAssignments.Minimap:CreateMinimapIcon()	
end

-- minimap creation

function TankAssignments.Minimap:CreateMinimapIcon()
	local Moving = false
	
	function self:OnMouseUp()
		Moving = false;
	end
	
	function self:OnMouseDown()
		PlaySound("igMainMenuOptionCheckBoxOn")
		Moving = false;
		if (arg1 == "LeftButton") then 
			if TankAssignments:IsVisible() then 
				TankAssignments.ToolTip:Hide()
				TankAssignments.Settings["Animation"] = true
				TankAssignments.Settings["MainFrame"] = false
			else TankAssignments:Show() end
		elseif (arg1 == "RightButton") then
			TankAssignments:PostAssignments()
		else Moving = true;
		end
	end
	
	function self:OnUpdate()
		if Moving == true then
			local xpos,ypos = GetCursorPosition();
			local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom();
			xpos = xmin-xpos/UIParent:GetScale()+70;
			ypos = ypos/UIParent:GetScale()-ymin-70;
			local RHAIconPos = math.deg(math.atan2(ypos,xpos));
			if (RHAIconPos < 0) then
				RHAIconPos = RHAIconPos + 360
			end
			TankAssignments_Settings["MinimapX"] = 54 - (78 * cos(RHAIconPos));
			TankAssignments_Settings["MinimapY"] = (78 * sin(RHAIconPos)) - 55;
			
			TankAssignments.Minimap:SetPoint(
			"TOPLEFT",
			"Minimap",
			"TOPLEFT",
			TankAssignments_Settings.MinimapX,
			TankAssignments_Settings.MinimapY);
		end
	end
	
	function self:OnEnter()
		GameTooltip:SetOwner(TankAssignments.Minimap, "ANCHOR_LEFT");
		GameTooltip:SetText("Tank Assignments");
		GameTooltip:AddLine("Left Click to show/hide menu.",1,1,1);
		GameTooltip:AddLine("Right Click to post assignments.",1,1,1);
		GameTooltip:AddLine("Middle Button Click to move Icon.",1,1,1);
		GameTooltip:Show()
	end
	
	function self:OnLeave()
		GameTooltip:Hide()
	end

	self:SetFrameStrata("LOW")
	self:SetWidth(31) -- Set these to whatever height/width is needed 
	self:SetHeight(31) -- for your Texture
	self:SetPoint("CENTER", -75, -20)
	
	self.Button = CreateFrame("Button",nil,self)
	--self.Button:SetFrameStrata('HIGH')	
	self.Button:SetPoint("CENTER",0,0)
	self.Button:SetWidth(31)
	self.Button:SetHeight(31)
	self.Button:SetFrameLevel(8)
	self.Button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	self.Button:SetScript("OnMouseUp", self.OnMouseUp)
	self.Button:SetScript("OnMouseDown", self.OnMouseDown)
	self.Button:SetScript("OnUpdate", self.OnUpdate)
	self.Button:SetScript("OnEnter", self.OnEnter)
	self.Button:SetScript("OnLeave", self.OnLeave)
	
	local overlay = self:CreateTexture(nil, 'OVERLAY',self)
	overlay:SetWidth(53)
	overlay:SetHeight(53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint('TOPLEFT',0,0)
	
	local icon = self:CreateTexture(nil, "BACKGROUND")
	icon:SetWidth(20)
	icon:SetHeight(20)
	icon:SetTexture("Interface\\AddOns\\TankAssignments\\Icon")
	icon:SetTexCoord(0.18, 0.82, 0.18, 0.82)
	icon:SetPoint('CENTER', 0, 0)
	self.icon = icon
	
	TankAssignments.Minimap:SetPoint(
			"TOPLEFT",
			"Minimap",
			"TOPLEFT",
			TankAssignments_Settings.MinimapX,
			TankAssignments_Settings.MinimapY)

end

function TankAssignments:SetTankChannelString()
	local channelChar = self.TankChannelEditBox:GetText(); 
	if channelChar == "s" or  channelChar == "S" then self.TankChannelSelectedFontString:SetText("Say");
	elseif channelChar == "r" or  channelChar == "R" then self.TankChannelSelectedFontString:SetText("Raid");
	elseif channelChar == "p" or  channelChar == "P" then self.TankChannelSelectedFontString:SetText("Group");
	elseif channelChar == "g" or  channelChar == "G" then self.TankChannelSelectedFontString:SetText("Guild");
	elseif channelChar == "e" or  channelChar == "E" then self.TankChannelSelectedFontString:SetText("Emote");
	elseif channelChar == "rw" or  channelChar == "RW" then self.TankChannelSelectedFontString:SetText("Raid Warning");
	else local id, name = GetChannelName(channelChar); self.TankChannelSelectedFontString:SetText(name)
	end
end

function TankAssignments:GetSendChannel(chanName)
	if not chanName or chanName == "" or chanName == " " then
		return nil,nil
	end
	chanName = string.lower(chanName)
	if TankAssignments.ChanTable[chanName] then
		if type(TankAssignments.ChanTable[chanName])=="table" then
			local chan = TankAssignments.ChanTable[chanName][1]
			local bla = TankAssignments.ChanTable[chanName][2]
			return chan,bla
		else
			local chan = TankAssignments.ChanTable[chanName]
			return chan,chanName
		end
	else
		return "WHISPER",chanName
	end
end

function TankAssignments:GetMarkPos(mark)
	if(mark==1) then return 0, 0.25, 0, 0.25;	end
	if(mark==2)    then return 0.25, 0.5, 0,	0.25;	end
	if(mark==3)   then return 0.5,  0.75,    0,	0.25;	end
	if(mark==4)   then return 0.75, 1,       0,	0.25;	end
	if(mark==5)  then return 0,    0.25,    0.25,	0.5;	end
	if(mark==6)  then return 0.25, 0.5,     0.25,	0.5;	end
	if(mark==7)  then return 0.5,  0.75,    0.25,	0.5;	end
	if(mark==8) then return 0.75, 1,       0.25,	0.5;	end
	return 0,    0.25,    0.5,	0.75;	-- Returns empty next one, so blank
end

function TankAssignments:ClassPos(class)
	if(class=="Warrior") then return 0, 0.25, 0, 0.25;	end
	if(class=="Mage")    then return 0.25, 0.5, 0,	0.25;	end
	if(class=="Rogue")   then return 0.5,  0.75,    0,	0.25;	end
	if(class=="Druid")   then return 0.75, 1,       0,	0.25;	end
	if(class=="Hunter")  then return 0,    0.25,    0.25,	0.5;	end
	if(class=="Shaman")  then return 0.25, 0.5,     0.25,	0.5;	end
	if(class=="Priest")  then return 0.5,  0.75,    0.25,	0.5;	end
	if(class=="Warlock") then return 0.75, 1,       0.25,	0.5;	end
	if(class=="Paladin") then return 0,    0.25,    0.5,	0.75;	end
	return 0.25, 0.5, 0.5, 0.75	-- Returns empty next one, so blank
end

function TankAssignments:GetRaidID(name)
	if GetRaidRosterInfo(1) then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == name then
				return "raid"..i
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i=1,GetNumPartyMembers() do 
			if UnitName("party"..i) == name then
				return "party"..i
			end
		end	
		return "player"
	else
		return "player"
	end
end

function TankAssignments:GetClassColors(name,color)
	if color == "rgb" then
		if name == UnitName("player") then
			if UnitClass("player") == "Warrior" then return 0.78, 0.61, 0.43,1
			elseif UnitClass("player") == "Hunter" then return 0.67, 0.83, 0.45,1
			elseif UnitClass("player") == "Mage" then return 0.41, 0.80, 0.94,1
			elseif UnitClass("player") == "Rogue" then return 1.00, 0.96, 0.41,1
			elseif UnitClass("player") == "Warlock" then return 0.58, 0.51, 0.79,1
			elseif UnitClass("player") == "Druid" then return 1, 0.49, 0.04,1
			elseif UnitClass("player") == "Shaman" then return 0.0, 0.44, 0.87,1
			elseif UnitClass("player") == "Priest" then return 1.00, 1.00, 1.00,1
			elseif UnitClass("player") == "Paladin" then return 0.96, 0.55, 0.73,1
			end
		end
		if GetRaidRosterInfo(1) then
			for i=1,GetNumRaidMembers() do
				if UnitName("raid"..i) == name then
					if UnitClass("raid"..i) == "Warrior" then return 0.78, 0.61, 0.43,1
					elseif UnitClass("raid"..i) == "Hunter" then return 0.67, 0.83, 0.45,1
					elseif UnitClass("raid"..i) == "Mage" then return 0.41, 0.80, 0.94,1
					elseif UnitClass("raid"..i) == "Rogue" then return 1.00, 0.96, 0.41,1
					elseif UnitClass("raid"..i) == "Warlock" then return 0.58, 0.51, 0.79,1
					elseif UnitClass("raid"..i) == "Druid" then return 1, 0.49, 0.04,1
					elseif UnitClass("raid"..i) == "Shaman" then return 0.0, 0.44, 0.87,1	
					elseif UnitClass("raid"..i) == "Priest" then return 1.00, 1.00, 1.00,1
					elseif UnitClass("raid"..i) == "Paladin" then return 0.96, 0.55, 0.73,1
					end
				end
			end
		elseif GetNumPartyMembers() > 0 then
			for i=1,GetNumPartyMembers() do
				if UnitName("party"..i) == name then
					if UnitClass("Party"..i) == "Warrior" then return 0.78, 0.61, 0.43,1
					elseif UnitClass("party"..i) == "Hunter" then return 0.67, 0.83, 0.45,1
					elseif UnitClass("party"..i) == "Mage" then return 0.41, 0.80, 0.94,1
					elseif UnitClass("party"..i) == "Rogue" then return 1.00, 0.96, 0.41,1
					elseif UnitClass("party"..i) == "Warlock" then return 0.58, 0.51, 0.79,1
					elseif UnitClass("party"..i) == "Druid" then return 1, 0.49, 0.04,1
					elseif UnitClass("party"..i) == "Shaman" then return 0.0, 0.44, 0.87,1	
					elseif UnitClass("party"..i) == "Priest" then return 1.00, 1.00, 1.00,1
					elseif UnitClass("party"..i) == "Paladin" then return 0.96, 0.55, 0.73,1
					end
				end
			end	
		end
	elseif color == "cff" then
		if name == UnitName("player") then
			if UnitClass("player") == "Warrior" then return "|cffC79C6E"..name.."|r"
			elseif UnitClass("player") == "Hunter" then return "|cffABD473"..name.."|r"
			elseif UnitClass("player") == "Mage" then return "|cff69CCF0"..name.."|r"
			elseif UnitClass("player") == "Rogue" then return "|cffFFF569"..name.."|r"
			elseif UnitClass("player") == "Warlock" then return "|cff9482C9"..name.."|r"
			elseif UnitClass("player") == "Druid" then return "|cffFF7D0A"..name.."|r"
			elseif UnitClass("player") == "Shaman" then return "|cff0070DE"..name.."|r"
			elseif UnitClass("player") == "Priest" then return "|cffFFFFFF"..name.."|r"
			elseif UnitClass("player") == "Paladin" then return "|cffF58CBA"..name.."|r"
			end
		end
		if GetRaidRosterInfo(1) then
			for i=1,GetNumRaidMembers() do
				if UnitName("raid"..i) == name then
					if UnitClass("raid"..i) == "Warrior" then return "|cffC79C6E"..name.."|r"
					elseif UnitClass("raid"..i) == "Hunter" then return "|cffABD473"..name.."|r"
					elseif UnitClass("raid"..i) == "Mage" then return "|cff69CCF0"..name.."|r"
					elseif UnitClass("raid"..i) == "Rogue" then return "|cffFFF569"..name.."|r"
					elseif UnitClass("raid"..i) == "Warlock" then return "|cff9482C9"..name.."|r"
					elseif UnitClass("raid"..i) == "Druid" then return "|cffFF7D0A"..name.."|r"
					elseif UnitClass("raid"..i) == "Shaman" then return "|cff0070DE"..name.."|r"
					elseif UnitClass("raid"..i) == "Priest" then return "|cffFFFFFF"..name.."|r"
					elseif UnitClass("raid"..i) == "Paladin" then return "|cffF58CBA"..name.."|r"
					end
				end
			end
		else
			for i=1,GetNumPartyMembers() do
				if UnitName("party"..i) == name then
					if UnitClass("party"..i) == "Warrior" then return "|cffC79C6E"..name.."|r"
					elseif UnitClass("party"..i) == "Hunter" then return "|cffABD473"..name.."|r"
					elseif UnitClass("party"..i) == "Mage" then return "|cff69CCF0"..name.."|r"
					elseif UnitClass("party"..i) == "Rogue" then return "|cffFFF569"..name.."|r"
					elseif UnitClass("party"..i) == "Warlock" then return "|cff9482C9"..name.."|r"
					elseif UnitClass("party"..i) == "Druid" then return "|cffFF7D0A"..name.."|r"
					elseif UnitClass("party"..i) == "Shaman" then return "|cff0070DE"..name.."|r"
					elseif UnitClass("party"..i) == "Priest" then return "|cffFFFFFF"..name.."|r"
					elseif UnitClass("party"..i) == "Paladin" then return "|cffF58CBA"..name.."|r"
					end
				end
			end
		end
	elseif color == "class" then

		if (name == "Warrior") then 
			return 0.78, 0.61, 0.43
		end
		if(name=="Mage") then
			return 0.41, 0.80, 0.94
		end
		if(name=="Rogue") then 
			return 1.00, 0.96, 0.41
		end
		if(name=="Druid") then 
			return 1, 0.49, 0.04
		end
		if(name=="Hunter") then 
			return 0.67, 0.83, 0.45 
		end
		if(name=="Shaman") then 
			return 0.0, 0.44, 0.87
		end
		if(name=="Priest") then 
			return 1.00, 1.00, 1.00 
		end
		if(name=="Warlock") then 
			return 0.58, 0.51, 0.79
		end
		if(name=="Paladin") then 
			return 0.96, 0.55, 0.73
		end
	elseif color == "mark" then
		if name == "Skull" then return "|cffFFFFFF"..name.."|r" end
		if name == "Cross" then return "|cffFF0000"..name.."|r" end
		if name == "Square" then return "|cff00B4FF"..name.."|r" end
		if name == "Moon" then return "|cffCEECF5"..name.."|r" end
		if name == "Triangle" then return "|cff66FF00"..name.."|r" end
		if name == "Diamond" then return "|cffCC00FF"..name.."|r" end
		if name == "Circle" then return "|cffFF9900"..name.."|r" end
		if name == "Star" then return "|cffFFFF00"..name.."|r" end
	end
end

function TankAssignments:IsInRaid(name)
	if GetRaidRosterInfo(1) then
		for i=1,GetNumRaidMembers() do
			if UnitName("raid"..i) == name then
				return true
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i=1,GetNumPartyMembers() do 
			if UnitName("party"..i) == name then
				return true
			end
		end	
		if UnitName("player") == name then
			return true
		end
	else
		if UnitName("player") == name then
			return true
		end
	end
	return false
end

function TankAssignments:UpdateTanks()
	if GetRaidRosterInfo(1) then
		for i=1,8 do
			local index=0
			for k,v in pairs(TankAssignments.Frames[i]) do
				local frame = v
				frame:Hide()
			end
			for k,v in pairs(TankAssignments.Marks[i]) do
				TankAssignments.Frames[i][v] = TankAssignments.Frames[i][v] or TankAssignments:AddTankFrame(v,i)
				local frame = TankAssignments.Frames[i][v]	
				local unit = TankAssignments:GetRaidID(v)
				if not TankAssignments:IsInRaid(v) or (not UnitExists(unit) and not UnitIsConnected(unit)) then	
					frame:Hide()
					table.remove(TankAssignments.Marks[i],k)
					table.sort(TankAssignments.Marks[i])	
				end
				--DEFAULT_CHAT_FRAME:AddMessage("Hiding frame for "..v)
				frame:Hide()
			end
			for k,v in pairs(TankAssignments.Marks[i]) do
				TankAssignments.Frames[i][v] = TankAssignments.Frames[i][v] or TankAssignments:AddTankFrame(v,i)
				local frame = TankAssignments.Frames[i][v] 
				local unit = TankAssignments:GetRaidID(v)
				--frame.unit=unit
				index=index+1
				frame:SetPoint("RIGHT", 10+(105*index),0)
				frame.hp:SetText(UnitHealthMax(unit).." hp")
				frame.texture:SetVertexColor(TankAssignments:GetClassColors(v,"rgb"))
				if (not UnitExists(unit) or not UnitIsConnected(unit) or not UnitIsVisible(unit)) then
					frame.model:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
					frame.model:SetModelScale(4.25)
					frame.model:SetPosition(0, 0, -1)
				else
					frame.model:SetUnit(unit)
					frame.model:SetCamera(0)
					--DEFAULT_CHAT_FRAME:AddMessage("Setting Model")
				end
				frame:Show()
			end
		end
	else
		for i=1,8 do
			for k,v in pairs(TankAssignments.Frames[i]) do
				if v:IsVisible() then
					v:Hide()
				end
			end
			TankAssignments.Marks[i] = {}
		end
	end
end

function TankAssignments:SendTanks()
	if IsRaidOfficer("player") then
		--LoaMod:print("Sending ignore list")
		local sendstring = ""
		local n=0
		for mark in pairs(TankAssignments.Marks) do		
			for k,v in pairs(TankAssignments.Marks[mark]) do
				sendstring=sendstring..mark..v
			end
		end
		if sendstring ~= "" then
			SendAddonMessage("TankAssignmentsMarks",sendstring,"RAID")
			--DEFAULT_CHAT_FRAME:AddMessage(sendstring)
		end
	end
end

function TankAssignments:OpenToolTip(frame)
	if GetRaidRosterInfo(1) then
		for k,v in pairs(TankAssignments.Frames.ToolTip) do
			v:Hide()
		end
		local index=0
		local n=tonumber(frame)
		for i=1,GetNumRaidMembers() do	
			if (UnitExists("raid"..i) and UnitIsFriend("player","raid"..i) and UnitIsConnected("raid"..i)) then
				local name = UnitName("raid"..i)
				local f = false
				for k,v in pairs(TankAssignments.Marks[n]) do
					if name == v then
						f = true
					end
				end
				if not f then
					local unit = TankAssignments:GetRaidID(name)
					if TankAssignments_Settings[UnitClass(unit)] == 1 then
						index=index+1
						TankAssignments.Frames.ToolTip[name] = TankAssignments.Frames.ToolTip[name] or TankAssignments:AddFrame(name)
						local frame = TankAssignments.Frames.ToolTip[name]					
						frame:SetPoint("TOPLEFT",TankAssignments.ToolTip,"TOPLEFT", 2,25+(-25*index))
						frame.texture:SetVertexColor(TankAssignments:GetClassColors(name,"rgb"))
						if not UnitIsVisible(unit) then
							frame.model:SetModelScale(4.25)
							frame.model:SetPosition(0, 0, -1)
							frame.model:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
						else
							frame.model:SetUnit(unit)
							frame.model:SetCamera(0)
						end
						frame:Show()
					end
				end
			end
		end
		TankAssignments.Settings["active"] = frame
		TankAssignments.ToolTip:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"}) --border around the frame
		TankAssignments.ToolTip:SetBackdropColor(0,0,0,1)
		TankAssignments.ToolTip:SetWidth(102)
		TankAssignments.ToolTip:SetHeight(25*index)
		TankAssignments.ToolTip:SetPoint("TOPLEFT",frame,"TOPLEFT",-100,0)
		TankAssignments.ToolTip:EnableMouse(1)
		TankAssignments.ToolTip:SetScript("OnLeave", function()
			--DEFAULT_CHAT_FRAME:AddMessage("Leave")
			TankAssignments.ToolTip:Hide()
		end)	
		TankAssignments.ToolTip:SetFrameStrata('HIGH')
		TankAssignments.ToolTip:Show()
	end
end

function TankAssignments:AddTank(name, mark)
	local index
	mark = tonumber(mark)
	--DEFAULT_CHAT_FRAME:AddMessage(mark)
	if TankAssignments.Marks[mark] == nil then
		index = 1
	else
		index = getn(TankAssignments.Marks[mark])+1 
	end
	--DEFAULT_CHAT_FRAME:AddMessage("index: "..index)
	if index < 4 then
		TankAssignments.Frames[mark][name] = TankAssignments.Frames[mark][name] or TankAssignments:AddTankFrame(name,mark)
		local frame = TankAssignments.Frames[mark][name]
		local unit = TankAssignments:GetRaidID(name)
		frame:SetPoint("RIGHT", 10+(105*index),0)
		frame.texture:SetVertexColor(TankAssignments:GetClassColors(name,"rgb"))
		if not CheckInteractDistance(unit,4) then
			frame.model:SetModelScale(4.25)
			frame.model:SetPosition(0, 0, -1)
			frame.model:SetModel("Interface\\Buttons\\talktomequestionmark.mdx")
		else
			frame.model:SetUnit(unit)
			frame.model:SetCamera(0)
		end
		frame:Show()
		table.insert(TankAssignments.Marks[mark], name)
	end
end

function TankAssignments:AddFrame(name)

	local unit = TankAssignments:GetRaidID(name)
	local frame = CreateFrame('Button', name, TankAssignments.ToolTip)
	local backdrop = {
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			tile="false",
			tileSize="8",
			edgeSize="4",
			insets={
				left="2",
				right="2",
				top="0",
				bottom="0"
			}
	}
	--frame:SetFrameLevel(3)
	frame.model = CreateFrame("PlayerModel",nil,frame)
	frame.model:SetScript("OnShow",function() 
	if UnitIsVisible(unit) then this:SetCamera(0) end 
	end)
	frame.model:SetWidth(25)
	frame.model:SetHeight(25)
	frame.model:SetPoint("TOPLEFT",frame,"TOPLEFT", 2, 0)
	frame.model:SetUnit(unit)
	frame.model:SetCamera(0)
	frame.model:SetFrameLevel(3);	
	frame.model:Show()
	
	frame:SetWidth(100)
	frame:SetHeight(25)	
	
	frame.hpbar = CreateFrame('Button', nil, frame)
	frame.hpbar:SetWidth(frame:GetWidth()-27)
	frame.hpbar:SetHeight(24)
	frame.hpbar:SetPoint('TOPLEFT', 28,-1)
	frame.hpbar:SetFrameLevel(1)
	
	frame.texture = frame.hpbar:CreateTexture(nil, 'ARTWORK')
	frame.texture:SetWidth(frame:GetWidth()-27)
	frame.texture:SetHeight(24)
	frame.texture:SetPoint('TOPLEFT', 0,0)
	frame.texture:SetTexture("Interface\\AddOns\\TankAssignments\\LiteStep")
	frame.texture:SetGradientAlpha("Vertical", 1,1,1, 0, 1, 1, 1, 1)

	frame.highlight = frame.hpbar:CreateTexture(nil, 'ARTWORK')
	frame.highlight:SetWidth(frame:GetWidth()-27)
	frame.highlight:SetHeight(24)
	frame.highlight:SetPoint('TOPLEFT', 0,0)
	frame.highlight:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
	frame.highlight:SetVertexColor(0.5,0.5,0.5,1)
	frame.highlight:SetAlpha(0)
	--frame.highlight:SetGradientAlpha("Vertical", 1,1,1, 0, 1, 1, 1, 1)
	
	frame.name = frame.hpbar:CreateFontString(nil, "OVERLAY")
	frame.name:SetPoint("CENTER",0, 5)
	frame.name:SetFont("Fonts\\FRIZQT__.TTF", 12)
	frame.name:SetTextColor(1, 1, 1, 1)
	frame.name:SetShadowOffset(1,-1)
	frame.name:SetText(name)

	frame.hp = frame.hpbar:CreateFontString(nil, "OVERLAY")
	frame.hp:SetPoint("CENTER",0, -5)
	frame.hp:SetFont("Fonts\\FRIZQT__.TTF", 12)
	frame.hp:SetTextColor(1, 1, 1, 1)
	frame.hp:SetShadowOffset(1,-1)
	frame.hp:SetText(UnitHealthMax(unit).." hp")
	
	frame:SetScript("OnUpdate", function()
		frame.hp:SetText(UnitHealthMax(unit).." hp")
	end)

	frame:SetScript("OnClick", function()
		if IsRaidOfficer("player") then
			this:Hide()
			TankAssignments:AddTank(this:GetName(), TankAssignments.Settings["active"])
			TankAssignments:OpenToolTip(TankAssignments.Settings["active"])
			TankAssignments:SendTanks()
		end
	end)
	frame.unit = unit
	frame:SetScript("OnEnter", UnitFrame_OnEnter)
	frame:SetScript("OnLeave", UnitFrame_OnLeave)
	return frame
end

function TankAssignments:AddTankFrame(name, mark)
	--DEFAULT_CHAT_FRAME:AddMessage("AddTank "..name.." "..mark)
	local unit = TankAssignments:GetRaidID(name)
	local frame = CreateFrame('Button', mark..name, TankAssignments.bg)
	local backdrop = {
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			tile="false",
			tileSize="8",
			edgeSize="4",
			insets={
				left="2",
				right="2",
				top="0",
				bottom="0"
			}
	}
	frame:SetParent(mark)
	frame.model = CreateFrame("PlayerModel",nil,frame)
	frame.model:SetScript("OnShow",function() 
	if UnitIsVisible(unit) then this:SetCamera(0) end 
	end)
	frame.model:SetWidth(25)
	frame.model:SetHeight(25)
	frame.model:SetPoint("TOPLEFT",frame,"TOPLEFT", 2, 0)
	frame.model:SetUnit(unit)
	frame.model:SetCamera(0)
	frame.model:SetFrameLevel(3);	
	frame.model:Show()
	
	frame:SetWidth(100)
	frame:SetHeight(25)	
	
	frame.hpbar = CreateFrame('Button', nil, frame)
	frame.hpbar:SetWidth(frame:GetWidth()-27)
	frame.hpbar:SetHeight(24)
	frame.hpbar:SetPoint('TOPLEFT', 28,-1)
	frame.hpbar:SetFrameLevel(1)
	
	frame.texture = frame.hpbar:CreateTexture(nil, 'ARTWORK')
	frame.texture:SetWidth(frame:GetWidth()-27)
	frame.texture:SetHeight(24)
	frame.texture:SetPoint('TOPLEFT', 0,0)
	frame.texture:SetTexture("Interface\\AddOns\\TankAssignments\\LiteStep")
	
	frame.texture:SetGradientAlpha("Vertical", 1,1,1, 0, 1, 1, 1, 1)
	
	frame.name = frame.hpbar:CreateFontString(nil, "OVERLAY")
	frame.name:SetPoint("CENTER",0, 5)
	frame.name:SetFont("Fonts\\FRIZQT__.TTF", 12)
	frame.name:SetTextColor(1, 1, 1, 1)
	frame.name:SetShadowOffset(1,-1)
	frame.name:SetText(name)

	frame.hp = frame.hpbar:CreateFontString(nil, "OVERLAY")
	frame.hp:SetPoint("CENTER",0, -5)
	frame.hp:SetFont("Fonts\\FRIZQT__.TTF", 12)
	frame.hp:SetTextColor(1, 1, 1, 1)
	frame.hp:SetShadowOffset(1,-1)
	frame.hp:SetText(UnitHealthMax(unit).." hp")

	frame:SetScript("OnClick", function()
		if IsRaidOfficer("player") then
			for k, v in pairs(TankAssignments.Marks[mark]) do
				if v == name then
					--DEFAULT_CHAT_FRAME:AddMessage("Removing "..v.." from "..mark)
					tremove(TankAssignments.Marks[mark],k)
					table.sort(TankAssignments.Marks[mark])
					this:Hide()
					TankAssignments:SendTanks()
					TankAssignments:UpdateTanks()
				end
			end
		end
		--DEFAULT_CHAT_FRAME:AddMessage(mark..name)
	end)
	frame.unit = unit
	frame:SetScript("OnEnter", UnitFrame_OnEnter)
	frame:SetScript("OnLeave", UnitFrame_OnLeave)
	return frame
end

function TankAssignments:PostAssignments()
	local chanText = TankAssignments.TankChannelEditBox:GetText()
	local chan,chanNum = TankAssignments:GetSendChannel(chanText)
	local n=false
	for i=1,8 do
		if TankAssignments.Marks[i] ~= nil or getn( TankAssignments.Marks[i]) ~= 0 then
			n=true
		end
	end
	if n then
		SendChatMessage("-- TankAssignments 2.0 --", chan, nil,chanNum)
		local i = 8
		while i > 0 do
			local text = TankAssignments:GetClassColors(TankAssignments.RealMarks[i],"mark")
			if getn(TankAssignments.Marks[i]) ~= 0 then
				for k,v in pairs(TankAssignments.Marks[i]) do
					if k == 1 then
						text = text..": "..TankAssignments:GetClassColors(v,"cff")
					else
						text = text..", "..TankAssignments:GetClassColors(v,"cff")
					end
					if k == getn(TankAssignments.Marks[i]) then
						text=text.."."
					end
				end
				SendChatMessage(text, chan, nil,chanNum)
			end
			i=i-1
		end
	end
end

function TankAssignments:Slash(arg1)
	if arg1 == nil or arg1 == "" then
		TankAssignments:Show()
	else
		DEFAULT_CHAT_FRAME:AddMessage("TankAssignments: There are no other commands")
	end
end

SLASH_TA1, SLASH_TA2 = "/ta", "/tanksassignments"
function SlashCmdList.TA(msg, editbox)
	TankAssignments:Slash(msg)
end

TankAssignments:SetScript("OnEvent", TankAssignments.OnEvent)


function TankAssignments:Debug()

	for k,v in pairs(TankAssignments.Marks) do
	
		for i, name in pairs(TankAssignments.Marks[k]) do
			DEFAULT_CHAT_FRAME:AddMessage(k..": "..i.." - "..name)
		end
	end
end










