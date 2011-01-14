local gwccFrame = CreateFrame("Frame", "gwccFrame", UIParent);
gwccFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

--  Create and stylize frame
gwccFrame:SetBackdrop( {
	bgFile = "Interface\\AddOns\\gWarlockCC\\Media\\flat.tga",
	edgeFile = "Interface\\AddOns\\gWarlockCC\\Media\\flat.tga",
	tile = false, tileSize = 0, edgeSize = 1,
	insets = {left = -1, right = -1, top = -1, bottom = -1}
} );
gwccFrame:RegisterForDrag("LeftButton");
gwccFrame:EnableMouse(true);
gwccFrame:SetMovable(true);
gwccFrame:SetScript("OnDragStart", gwccFrame.StartMoving);
gwccFrame:SetScript("OnDragStop", gwccFrame.StopMovingOrSizing);
gwccFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -100);
gwccFrame:SetBackdropColor(0.1, 0.1, 0.1, 1.0);
gwccFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1.0);
gwccFrame:SetWidth(120);
gwccFrame:SetHeight(65);
gwccFrame:Hide();


-- Constants
local UPDATE_INTERVAL = 0.5; --  Time in seconds

-- Variables
local timesincelastupdate = 0.0;
local isBanishing = false;
local isFearing = false;
local isSeducing = false;
local isFrameShowing = true;
local feartargetid = 0;
local gwccVisible = false;

local function CreateGWCCTimer(buttonName, buttonText, point, relativeFrame, pointRel)	
	frame = CreateFrame("StatusBar", buttonName, gwccFrame, nil);
	frame:SetPoint(point, relativeFrame, pointRel, 0, -5);
	frame:SetWidth(110);
	frame:SetHeight(15);
	frame:SetFrameLevel(gwccFrame:GetFrameLevel() + 1);
	frame:SetStatusBarTexture("Interface\\AddOns\\gWarlockCC\\Media\\flat.tga");
	frame:SetStatusBarColor(66/255, 66/255, 66/255);
	
	border = CreateFrame("Frame", nil, frame, nil);
	border:SetPoint(point, relativeFrame, pointRel, 0, -4);
	border:SetWidth(112);
	border:SetHeight(16);
	border:SetFrameLevel(frame:GetFrameLevel() + 1);
	border:SetBackdrop( {
	bgFile = "Interface\\AddOns\\gWarlockCC\\Media\\flat.tga",
	edgeFile = "Interface\\AddOns\\gWarlockCC\\Media\\flat.tga",
	tile = false, tileSize = 0, edgeSize = 1,
	insets = {left = -1, right = -1, top = -1, bottom = -1}
} );
	border:SetBackdropColor(0, 0, 0, 0);
	border:SetBackdropBorderColor(0.6, 0.6, 0.6, 1.0);
	
	t = frame:CreateFontString(nil, "OVERLAY", frame);
	t:SetFont("Interface\\AddOns\\gWarlockCC\\Media\\font.ttf", 10, "OUTLINE");
	t:SetText(buttonText);
	t:SetPoint("CENTER", frame, "CENTER", 0, 1);
	t:SetJustifyH("CENTER");
end

CreateGWCCTimer("gwcc_Fear", "Fear", "TOP", gwccFrame, "TOP");
gwcc_Fear:SetMinMaxValues(0, 20);
gwcc_Fear:SetValue(0);

CreateGWCCTimer("gwcc_Banish", "Banish", "TOP", gwcc_Fear, "BOTTOM");
gwcc_Banish:SetMinMaxValues(0, 30);
gwcc_Banish:SetValue(0);

CreateGWCCTimer("gwcc_Seduce", "Seduce", "TOP", gwcc_Banish, "BOTTOM");
gwcc_Seduce:SetMinMaxValues(0, 30);
gwcc_Seduce:SetValue(0);

local function OnEvent(self, event, ...)
	if(event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timeStamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName, spellSchool, amount, overkill = ...;
		
		if(eventType == "SPELL_AURA_REMOVED") then
			if(spellID == 5782 and sourceName == UnitName("player")) then
				isFearing = false;
				gwcc_Fear:SetValue(0);
			end
			
			if(spellID == 710 and sourceName == UnitName("player")) then
				isBanishing = false;
				gwcc_Banish:SetValue(0);
			end
			
			if(spellID == 6358 and sourceName == UnitName("pet")) then
				isSeducing = false;
				gwcc_Seduce:SetValue(0);
			end
			
		end
			
		if(eventType == "SPELL_AURA_APPLIED") then
			if(spellID == 5782 and sourceName == UnitName("player")) then --  Fear
				isFearing = true;
				gwcc_Fear:SetValue(20);
			end
			
			if(spellID == 710 and sourceName == UnitName("player")) then -- Banish
				isBanishing = true;
				gwcc_Banish:SetValue(30);
			end
			
			if(spellID == 6358 and sourceName == UnitName("pet")) then
				isSeducing = true;
				gwcc_Seduce:SetValue(30);
			end
		end		
	end
end


local function OnUpdate(self, elapsed)
	timesincelastupdate = timesincelastupdate + elapsed;
	
	--  Hide or show frames
	if(isFearing == true) then
		gwcc_Fear:Show();
	else
		gwcc_Fear:Hide();
	end
	
	if(isBanishing == true) then
		gwcc_Banish:Show();
	else
		gwcc_Banish:Hide();
	end
	
	if(isSeducing == true) then
		gwcc_Seduce:Show();
	else
		gwcc_Seduce:Hide();
	end
	
	if(UnitIsDead(feartargetid)) then
		isFearing = false;
		gwcc_Fear:SetValue(0);
	end
	
	if(timesincelastupdate >= UPDATE_INTERVAL) then
		if(isFearing == true) then
			local newtime = gwcc_Fear:GetValue() - UPDATE_INTERVAL;
			if(newtime < 0) then
				isFearing = false;
			else
				gwcc_Fear:SetValue(newtime);
			end
		end
		
		if(isBanishing == true) then
			local newtime = gwcc_Banish:GetValue() - UPDATE_INTERVAL;
			if(newtime < 0) then
				isBanishing = false;
			else
				gwcc_Banish:SetValue(newtime);
			end
		end
		
		if(isSeducing == true) then
			local newtime = gwcc_Seduce:GetValue() - UPDATE_INTERVAL;
			if(newtime < 0) then
				isSeducing = false;
			else
				gwcc_Seduce:SetValue(newtime);
			end
		end
		
		timesincelastupdate = 0;
	end
end

gwccFrame:SetScript("OnUpdate", OnUpdate);
gwccFrame:SetScript("OnEvent", OnEvent);

local function gwcc_Toggle()
	if(gwccVisible == true) then
		gwccFrame:Hide();
		gwccVisible = false;
	else
		gwccFrame:Show();
		gwccVisible = true;
	end
end

-- Create slash command
SLASH_GWARLOCKCC1 = "/gwcc";
SLASH_GWARLOCKCC2 = "/cc";
SlashCmdList["GWARLOCKCC"] = function() gwcc_Toggle(); end

