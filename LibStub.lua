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

function LibStub:FinalizeLibrary(major, exports, callback )
	if type(major) ~= "string" then
		error(("Bad argument #2 to 'FinalizeLibrary' (string expected, got %s)"):format(type(major)), 2)
	end

	if type(exports) == "function" then
		callback = exports
		exports = nil
	end

	if type(exports) ~= "table" and type(exports) ~= "nil" then
		error(("Bad argument #3 to 'FinalizeLibrary' (function, table or nil expected, got %s)"):format(type(exports)), 2)
	end

	if type(callback) ~= "function" and type(callback) ~= "nil" then
		error(("Bad argument #4 to 'FinalizeLibrary' (function or nil expected, got %s)"):format(type(callback)), 2)
	end
	
	local entry = self.libs[major]
	
	if not entry then
		error(("Cannot find a library instance of %s."):format(major), 2)
	end

	-- TODO: upgrade old namespaces that have been embedded

	-- store current exports and callback
	entry.exports = exports
	entry.callback = callback

	-- shout out to all callbacks
	for k, lib in pairs( self.libs ) do
		if lib ~= entry and type(lib.callback) == "function" and lib.callback(major, entry.instance) then
			-- some true value was received from the callback, unregister it
			lib.callback = nil
		end
	end
end
