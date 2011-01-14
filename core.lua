--  Create Frame
local gwccFrame = CreateFrame("Frame", "gwccFrame", UIParent);
gwccFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

--  Stylize frame
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
gwccFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 186, -171);
gwccFrame:SetBackdropColor(0.1, 0.1, 0.1, 1.0);
gwccFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1.0);
gwccFrame:SetWidth(120);
gwccFrame:SetHeight(65);
gwccFrame:Hide();


-- Constants
local UPDATE_INTERVAL = 0.5; --  Time in seconds

-- Variables
local timeSinceLastUpdate = 0.0;
local isBanishing = false;
local isFearing = false;
local isSeducing = false;
local isFrameShowing = true;
local feartargetid = 0;
local gwccVisible = false;
local gwcc = {};
gwcc['bars'] = {};

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
	t:SetPoint("CENTER", frame, "CENTER", 2, 1);
	t:SetJustifyH("CENTER");
	t:SetHeight(15);
	t:SetWidth(108);
	
	gwcc['bars'][buttonName] = frame;
	gwcc['bars'][buttonName]['text'] = t;
end

--  Create timer frames
CreateGWCCTimer("gwcc_Fear", "Fear", "TOP", gwccFrame, "TOP");
gwcc_Fear:SetMinMaxValues(0, 20);
gwcc_Fear:SetValue(0);
--gwcc_Fear:SetScript("OnEnter", function() gwcc['bars']['gwcc_Fear']['text']:SetText("LOLWUT"); end);
--gwcc_Fear:SetScript("OnLeave", function() gwcc['bars']['gwcc_Fear']['text']:SetText("Fear"); end);

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
			if(spellID == 5782 and sourceName == UnitName("player")) then --  Fear
				isFearing = false;
				gwcc_Fear:SetValue(0);
				gwcc['bars']['gwcc_Fear']['text']:SetText("Fear");
			end
			
			if(spellID == 710 and sourceName == UnitName("player")) then --  Banish
				isBanishing = false;
				gwcc_Banish:SetValue(0);
				gwcc['bars']['gwcc_Banish']['text']:SetText("Banish");
			end
			
			if(spellID == 6358 and sourceName == UnitName("pet")) then --  Seduce
				isSeducing = false;
				gwcc_Seduce:SetValue(0);
				gwcc['bars']['gwcc_Seduce']['text']:SetText("Seduce");
			end
			
		end
			
		if(eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH") then
			if(spellID == 5782 and sourceName == UnitName("player")) then --  Fear
				isFearing = true;
				gwcc_Fear:SetValue(20);
			end
			
			if(spellID == 710 and sourceName == UnitName("player")) then --  Banish
				isBanishing = true;
				gwcc_Banish:SetValue(30);
			end
			
			if(spellID == 6358 and sourceName == UnitName("pet")) then --  Seduce
				isSeducing = true;
				gwcc_Seduce:SetValue(30);
				
			end
		end		
	end
end


local function OnUpdate(self, elapsed)
	timeSinceLastUpdate = timeSinceLastUpdate + elapsed;
	
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
	
	if(timeSinceLastUpdate >= UPDATE_INTERVAL) then
		if(isFearing == true) then
			local newtime = gwcc_Fear:GetValue() - UPDATE_INTERVAL;
			if(newtime < 0) then
				isFearing = false;
			else
				gwcc_Fear:SetValue(newtime);
				gwcc['bars']['gwcc_Fear']['text']:SetText("Fear: " .. floor(newtime) .. "s");
			end
		end
		
		if(isBanishing == true) then
			local newtime = gwcc_Banish:GetValue() - UPDATE_INTERVAL;
			if(newtime < 0) then
				isBanishing = false;
			else
				gwcc_Banish:SetValue(newtime);
				gwcc['bars']['gwcc_Banish']['text']:SetText("Banish: " .. floor(newtime) .. "s");
			end
		end
		
		if(isSeducing == true) then
			local newtime = gwcc_Seduce:GetValue() - UPDATE_INTERVAL;
			if(newtime < 0) then
				isSeducing = false;
			else
				gwcc_Seduce:SetValue(newtime);
				gwcc['bars']['gwcc_Seduce']['text']:SetText("Seduce: " .. floor(newtime) .. "s");
			end
		end
		
		timeSinceLastUpdate = 0;
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

--  Create slash command
SLASH_GWARLOCKCC1 = "/gwcc";
SLASH_GWARLOCKCC2 = "/cc";
SlashCmdList["GWARLOCKCC"] = function() gwcc_Toggle(); end

