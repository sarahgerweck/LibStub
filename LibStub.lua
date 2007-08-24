-- $Id$
local LIBSTUB_MAJOR = "LibStub"
local LIBSTUB_MINOR = "$Revision$"

local _G = getfenv()
local LibStub = _G[LIBSTUB_MAJOR]
if LibStub and LibStub._minor < LIBSTUB_MINOR then
	-- Upgrading
elseif not LibStub then
	-- First load
	LibStub = {
		libs = {},
		_minor = tonumber(LIBSTUB_MINOR:match("%d+")),
	}
	
	_G[LIBSTUB_MAJOR] = LibStub
end

function LibStub:NewLibrary(major, minor)
	if type(minor) == "string" then
		-- Convert revision strings into numbers
		minor = tonumber(minor:match("%d+"))
	end

	if type(minor) ~= "number" then
		error("Minor version must contain a number")
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
