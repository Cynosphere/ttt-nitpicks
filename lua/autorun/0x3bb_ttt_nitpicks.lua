if engine.ActiveGamemode() ~= "terrortown" then	return end

local SYNC_TAG = "0x3bb_ttt_nitpicks_sync"

-- {{{ debug
local TTT_NITPICKS_DEBUG = CreateConVar("ttt_nitpicks_debug", "0", {FCVAR_ARCHIVE}, "Prints debug messages for cvar changes. Value controls level, 0 to disable.", 0, 2)
local function DbgMsg(level, ...)
	level = level == nil and 1 or level
	if TTT_NITPICKS_DEBUG:GetInt() < level then return end

	Msg("[TTT Nitpicks] ") print(...)
end
-- }}}

-- {{{ cvars
local cvar_names = {}

local function CreateCvar(name, desc, default)
	default = default == nil and true or default

	cvar_names[#cvar_names + 1] = name

	return CreateConVar(name, default == true and "1" or "0", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, desc, 0, 1)
end

local TTT_NITPICKS_HOLSTERED_VIEWMODEL = CreateCvar("ttt_nitpicks_holstered_viewmodel", "Changes the holstered viewmodel to normal hands for compatibility with viewmodel addons such as VManip.")
local TTT_NITPICKS_MAGNETO_BINDS = CreateCvar("ttt_nitpicks_magneto_binds", "[TTT2 Only] Unflips Magneto-Stick binds to how they are in stock TTT.")
local TTT_NITPICKS_NO_SEE_CREDITS = CreateCvar("ttt_nitpicks_no_see_credits", "[TTT2 Only] Fix subjectively broken logic where all roles can see credits on a body in the death screen.")
-- }}}

-- {{{ backup logic
local backup_values = _G.___0x3bb_ttt_nitpicks_backup or {}
_G.___0x3bb_ttt_nitpicks_backup = backup_values

local function BackupAndSetWeapon(SWEP, key, new)
	local id = "wep:" .. SWEP.ClassName
	backup_values[id] = backup_values[id] or {}
	if backup_values[id][key] then return end
	DbgMsg(2, ("Backing up %q for %q"):format(key, id))

	backup_values[id][key] = SWEP[key]
	SWEP[key] = new
end

local function RestoreBackupWeapon(SWEP, key)
	local id = "wep:" .. SWEP.ClassName
	backup_values[id] = backup_values[id] or {}
	if not backup_values[id][key] then return end
	DbgMsg(2, ("Restoring %q for %q"):format(key, id))

	SWEP[key] = backup_values[id][key]
end

local function BackupAndSet(id, tbl, key, new)
	backup_values[id] = backup_values[id] or {}
	if backup_values[id][key] then return end
	DbgMsg(2, ("Backing up %q for %q"):format(key, id))

	backup_values[id][key] = tbl[key]
	tbl[key] = new
end

local function BackupAndSetFunction(id, tbl, key, new)
	backup_values[id] = backup_values[id] or {}
	if backup_values[id][key] then return end
	DbgMsg(2, ("Backing up %q for %q"):format(key, id))

	backup_values[id][key] = tbl[key]
	tbl[key] = new(backup_values[id][key])
end

local function RestoreBackup(id, tbl, key)
	backup_values[id] = backup_values[id] or {}
	if not backup_values[id][key] then return end
	DbgMsg(2, ("Restoring %q for %q"):format(key, id))

	tbl[key] = backup_values[id][key]
end
-- }}}

-- {{{ helpers
local function getupvalues(f)
	local i, t = 0, {}

	while true do
		i = i + 1
		local key, val = debug.getupvalue(f, i)
		if not key then break end
		t[key] = val
	end

	return t
end
-- }}}

-- {{{ main logic
local modifications = {
	holstered_viewmodel = function()
		local SWEP = weapons.GetStored("weapon_ttt_unarmed")

		if SWEP then
			if TTT_NITPICKS_HOLSTERED_VIEWMODEL:GetBool() then
				DbgMsg(1, "Applying Holstered Viewmodel Fixes")

				BackupAndSetWeapon(SWEP, "ViewModel", "models/weapons/c_arms.mdl")
				BackupAndSetWeapon(SWEP, "WorldModel", "")
				BackupAndSetWeapon(SWEP, "ViewModelFOV", 90)
				BackupAndSetWeapon(SWEP, "UseHands", true)

				BackupAndSetWeapon(SWEP, "Deploy", function(self)
					self:DrawShadow(false)

					return true
				end)
			else
				DbgMsg(1, "Restoring Holstered Viewmodel Fixes")

				RestoreBackupWeapon(SWEP, "ViewModel")
				RestoreBackupWeapon(SWEP, "WorldModel")
				RestoreBackupWeapon(SWEP, "ViewModelFOV")
				RestoreBackupWeapon(SWEP, "UseHands")
				RestoreBackupWeapon(SWEP, "Deploy")
			end
		end
	end,
	ttt2_magneto_stick = function()
		local SWEP = weapons.GetStored("weapon_zm_carry")

		if SWEP then
			if TTT_NITPICKS_MAGNETO_BINDS:GetBool() then
				DbgMsg(1, "Applying TTT2 Magneto-Stick Bind Fixes")

				BackupAndSetWeapon(SWEP, "PrimaryAttack", function(self)
					self:DoAttack(true)
				end)
				BackupAndSetWeapon(SWEP, "SecondaryAttack", function(self)
					self:DoAttack(false)
				end)

				local cvPropThrow = GetConVar("ttt_prop_throwing")
				BackupAndSetWeapon(SWEP, "RefreshTTT2HUDHelp", function(self)
					local ctarget = self:GetCarryTarget()
					local ctype = DetermineCarryType(ctarget)

					if ctype ~= CARRY_TYPE_NONE and IsValid(ctarget) then
						if ctype == CARRY_TYPE_RAGDOLL then
							self:AddTTT2HUDHelp(
								"magneto_stick_help_carry_rag_drop",
								self:CanPinCurrentRag() and "magneto_stick_help_carry_rag_pin"
								or "magneto_stick_help_carry_rag_drop"
							)
						elseif ctype == CARRY_TYPE_PROP or ctype == CARRY_TYPE_WEAPON then
							self:AddTTT2HUDHelp(
								"magneto_stick_help_carry_prop_drop",
								cvPropThrow:GetBool() and "magneto_stick_help_carry_prop_release"
								or "magneto_stick_help_carry_prop_drop"
							)
						end
					else
						self:AddTTT2HUDHelp(
							"magneto_help_secondary",
							"magneto_help_primary"
						)
					end
				end)
			else
				DbgMsg(1, "Restoring TTT2 Magneto-Stick Bind Fixes")

				RestoreBackupWeapon(SWEP, "PrimaryAttack")
				RestoreBackupWeapon(SWEP, "SecondaryAttack")
				RestoreBackupWeapon(SWEP, "RefreshTTT2HUDHelp")
			end
		end
	end,
}

local modifications_cl = {
	ttt2_no_see_credits = function()
		local upvalues = getupvalues(bodysearch.GetContentFromData)
		assert(upvalues ~= nil, "Failed to get upvalues of bodysearch.GetContentFromData")
		local DataToText = upvalues.DataToText
		assert(DataToText ~= nil, "Failed to get DataToText")

		if TTT_NITPICKS_NO_SEE_CREDITS:GetBool() then
			DbgMsg(1, "Applying TTT2 Credits Shown For All Roles Fixes")

			BackupAndSetFunction("bodysearch:DataToText", DataToText, "credits", function(orig)
				return function(data)
					if not data.credits or data.credits == 0 then return end

					local client = LocalPlayer()
					if not bodysearch.CanTakeCredits(client, data.rag) then return end

					return orig(data)
				end
			end)
		else
			DbgMsg(1, "Restoring TTT2 Credits Shown For All Roles Fixes")

			RestoreBackup("bodysearch:DataToText", DataToText, "credits")
		end
	end,
}

--local modifications_sv = {}

function DoModifications()
	for id, cb in pairs(modifications) do
		if id:StartsWith("ttt2_") and not TTT2 then continue end

		local ok, err = pcall(cb)
		if not ok then
			Msg("[TTT Nitpicks] ") print(("Failed to run callback for %q: %s"):format(id, err))
		end
	end

	if CLIENT then
		for id, cb in pairs(modifications_cl) do
			if id:StartsWith("ttt2_") and not TTT2 then continue end

			local ok, err = pcall(cb)
			if not ok then
				Msg("[TTT Nitpicks] ") print(("Failed to run callback for %q: %s"):format(id, err))
			end
		end
	--elseif SERVER then
	end
end

hook.Add("PreGamemodeLoaded", "0x3bb_ttt_nitpicks", function()
	timer.Simple(0, function()
		DoModifications()
	end)
end)

-- hotreload
if GAMEMODE then
	DoModifications()
end
-- }}}

-- {{{ cvar change + syncing
if CLIENT then
	net.Receive(SYNC_TAG, function()
		if GAMEMODE then
			DoModifications()
		end
	end)
elseif SERVER then
	util.AddNetworkString(SYNC_TAG)

	for _, name in ipairs(cvar_names) do
		cvars.AddChangeCallback(name, function()
			if GAMEMODE then
				DoModifications()
			end

			-- remove if facepunch/garrysmod#3740 ever gets fixed
			net.Start(SYNC_TAG)
			net.Broadcast()
		end, name)
	end
end
-- }}}
