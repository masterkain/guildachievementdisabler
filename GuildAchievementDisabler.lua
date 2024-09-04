local ADDON_NAME, addon = ...

-- List of guild achievements to be blocked (Horde and Alliance versions)
local hiddenAchievements = {
	[5126] = true, -- Dungeon Diplomat (Horde)
	[5128] = true, -- Classic Battles (Alliance)
	[5129] = true, -- Ambassadors (Horde)
	[5130] = true, -- Diplomacy (Horde)
	[5131] = true, -- Classic Battles (Horde)
	[5145] = true, -- Dungeon Diplomat (Alliance)
	[5812] = true, -- United Nations (Horde)
	[5892] = true, -- United Nations (Alliance)
	[6644] = true, -- Pandaren Embassy (Horde)
	[6664] = true, -- Pandaren Embassy (Alliance)
	[7843] = true, -- Diplomacy (Alliance)
	[7844] = true, -- Ambassadors (Alliance)

	-- Classy achievements
	[5151] = true, -- Classy Humans
	[5152] = true, -- Stay classy (Horde)
	[5153] = true, -- Classy Night Elves
	[5154] = true, -- Classy Gnomes
	[5155] = true, -- Classy Dwarves
	[5156] = true, -- Classy Draenei
	[5157] = true, -- Classy Worgen
	[5158] = true, -- Stay classy (Alliance)
	[5160] = true, -- Classy Orcs
	[5161] = true, -- Classy Tauren
	[5162] = true, -- Classy Trolls
	[5163] = true, -- Classy Blood Elves
	[5164] = true, -- Classy Undead
	[5165] = true, -- Classy Goblins
	[6624] = true, -- Classy Pandaren (Alliance)
	[6625] = true, -- Classy Pandaren (Horde)

	-- Slayer achievements
	[5031] = true, -- Horde Slayer (Alliance)
	[5167] = true, -- Orc Slayer (Alliance)
	[5168] = true, -- Tauren Slayer (Alliance)
	[5169] = true, -- Undead Slayer (Alliance)
	[5170] = true, -- Troll Slayer (Alliance)
	[5171] = true, -- Blood Elf Slayer (Alliance)
	[5172] = true, -- Goblin Slayer (Alliance)
	[5173] = true, -- Human Slayer (Horde)
	[5174] = true, -- Night Elf Slayer (Horde)
	[5175] = true, -- Dwarf Slayer Slayer (Horde)
	[5176] = true, -- Gnome Slayer (Horde)
	[5177] = true, -- Draenei Slayer (Horde)
	[5178] = true, -- Worgen Slayer (Horde)
	[5179] = true, -- Alliance Slayer (Horde)
	[6533] = true, -- Pandaren Slayer (Horde)
}

-- Create a frame to handle events
local frame = CreateFrame("Frame")

-- Mute and unmute sound for achievement alerts
local function MuteAchievementSound()
	local soundID = 569143 -- Sound file ID for the achievement alert
	MuteSoundFile(soundID)
	C_Timer.After(0.5, function()
		UnmuteSoundFile(soundID)
	end)
end

-- Debug function to catch unlisted guild achievements
local function LogUnlistedGuildAchievements(achievementID)
	local _, name, _, _, _, _, _, _, _, _, _, isGuildAch = GetAchievementInfo(achievementID)
	if isGuildAch and not hiddenAchievements[achievementID] then
		print("|cFFFF0000[DEBUG] Unlisted Guild Achievement: ID=" .. achievementID .. ", Name=" .. name .. "|r")
	end
end

-- Override the AddAlert function to block specific achievements and log unlisted ones
local original_AddAlert = AchievementAlertSystem.AddAlert
AchievementAlertSystem.AddAlert = function(self, achievementID, name, points, alreadyEarned, icon, rewardText)
	if hiddenAchievements[achievementID] then
		MuteAchievementSound() -- Mute sound for blocked achievements
		return -- Prevent the alert from being shown
	else
		LogUnlistedGuildAchievements(achievementID) -- Log unlisted guild achievements
	end
	return original_AddAlert(self, achievementID, name, points, alreadyEarned, icon, rewardText)
end

-- Event handler for ACHIEVEMENT_EARNED
frame:RegisterEvent("ACHIEVEMENT_EARNED")
frame:SetScript("OnEvent", function(self, event, achievementID)
	if hiddenAchievements[achievementID] then
		return -- Prevent the alert from being processed
	else
		LogUnlistedGuildAchievements(achievementID) -- Log unlisted guild achievements
	end
end)

-- Slash command to test achievement alerts
SLASH_TESTACHIEVEMENT1 = "/gad"
SlashCmdList["TESTACHIEVEMENT"] = function(id)
	id = tonumber(id)
	if id then
		local _, name, points, _, _, _, _, _, _, icon = GetAchievementInfo(id)
		if name then
			print("Triggered achievement. ID:", id)
			AchievementFrame_LoadUI()
			AchievementAlertSystem:AddAlert(id, name, points, 1, icon, 0)
		else
			print("Invalid achievement ID.")
		end
	else
		print("Provide a valid achievement ID.")
	end
end

print("|cFF99CC33Guild Achievement Disabler Loaded|r - Use /gad <achievementID> to test")
