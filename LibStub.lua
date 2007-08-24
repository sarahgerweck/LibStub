-- $Id$
local LIBSTUB_MAJOR = "LibStub"
local LIBSTUB_MINOR = 1

local _G = getfenv()
local LibStub = _G[LIBSTUB_MAJOR]

-- Check to see is this version of the library is obsolete
-- If so, return immediate without taking further action
if LibStub and LibStub.minor >= LIBSTUB_MINOR then return end

-- If this is the first LibStub being instantiated, create it
if not LibStub then
	LibStub = {
		libs = {},
	}
end

-- Begin library implementation
LibStub.minor = LIBSTUB_MINOR

-- Get the metatable from LibStub, if one is already set
local LibStub_mt = getmetatable(LibStub) or {}
setmetatable(LibStub, LibStub_mt)

-- LibStub:NewLibrary(major, minor)
-- major (string) - the major version of the library
-- minor (string or number ) - the minor version of the library
-- 
-- returns nil if a newer or same version of the lib is already present
-- returns empty library object or old library object if upgrade is needed

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

-- LibStub:GetInstance(major, optional)
-- major (string) - the major version of the library
-- silent (boolean) - if true, library is optional, silently return nil if its not found
--
-- throws an error if the library can not be found
-- returns the library object if found

function LibStub:GetInstance(major, silent)
	if type(major) ~= "string" then
		error(("Bad argument #2 to 'GetInstance' (string expected, got %s)"):format(type(major)), 2)
	end
	
	local entry = self.libs[major]
	
	if not entry then
		if silent then return nil
		else error(("Cannot find a library instance of %s."):format(major), 2) end
	end
	
	return entry.instance
end

-- Set up the metatable to allow LibStub("MajorVersion")
LibStub_mt.__call = LibStub.GetInstance

local function safecall(func,...)
	local success, err = pcall(func,...)
	if not success then 
		geterrorhandler()(err:find("%.lua:%d+:") and err or (debugstack():match("\n(.-: )in.-\n") or "") .. err) 
		return
	end
	-- return first return value from the function called by pcall if pcall was succesful
	return err
end

-- LibStub:FinalizeLibrary(major, callback)
--
-- major (string) - The major version of the library 
-- callback (function)  - A function to be called when a new library is loaded.
--   If this function returns a true value, then after being called, it will
--   be removed from the callback registry.
--
function LibStub:FinalizeLibrary(major, callback )
	if type(major) ~= "string" then
		error(("Bad argument #2 to 'FinalizeLibrary' (string expected, got %s)"):format(type(major)), 2)
	end

	if type(callback) ~= "function" and type(callback) ~= "nil" then
		error(("Bad argument #3 to 'FinalizeLibrary' (function or nil expected, got %s)"):format(type(callback)), 2)
	end
	
	local entry = self.libs[major]
	
	if not entry then
		error(("Cannot finalize an unregistered instance of  %s."):format(major), 2)
	end

	-- TODO: upgrade old namespaces that have been embedded

	-- Store the function and the callback function in the registry
	entry.callback = callback

	-- Iterate through all libraries, and call any callback functions
	for key, lib in pairs(self.libs) do
		-- Don't trigger the callback of the registering library
		if lib ~= entry and type(lib.callback) == "function" then
			local unregister = safecall(lib.callback, major, entry.instance)
			
			-- If the callback returns a true value, unregister it
			if unregister then
				lib.callback = nil
			end
		end
	end
end
