-- $Id$
local LIBSTUB_MAJOR = "LibStub"
local LIBSTUB_MINOR = 1

local _G = getfenv()
local LibStub = _G[LIBSTUB_MAJOR]

-- same or older version, just leave
if LibStub and LibStub._minor >= LIBSTUB_MINOR then return end

-- check for upgrading
if not LibStub then
	-- First load
	LibStub = {
		libs = {},
		_minor = LIBSTUB_MINOR,
	}
	
	_G[LIBSTUB_MAJOR] = LibStub
else
	-- Upgrading
	LibStub._minor = LIBSTUB_MINOR
end

-- make sure we dont overwrite anything if we updated LibStub
local LibStub_mt = getmetatable(LibStub) or {}
setmetatable(LibStub, LibStub_mt)

function LibStub:NewLibrary(major, minor)
	if type(minor) == "string" then
		-- Convert revision strings into numbers
		minor = tonumber(minor:match("%d+"))
	end

	if type(minor) ~= "number" then
		error("Minor version must contain a number.", 2)
	end
	
	local entry = self.libs[major] or {}
	
	if entry.minor and entry.minor >= minor then 
		return nil 
	end
	
	self.libs[major] = entry
	
	entry.minor = minor
	entry.instance = entry.instance or {}
	
	return entry.instance
end

function LibStub:GetInstance(major)
	if type(major) ~= "string" then
		error(("Bad argument #2 to 'GetInstance' (string expected, got %s)"):format(type(major)), 2)
	end
	
	local entry = self.libs[major]
	
	if not entry then
		error(("Cannot find a library instance of %s."):format(major), 2)
	end
	
	return entry.instance
end

LibStub_mt.__call = LibStub.GetInstance
