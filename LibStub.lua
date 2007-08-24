-- $Id$
local _G = getfenv()
local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 1
local LibStub = _G[LIBSTUB_MAJOR]

-- Check to see is this version of the library is obsolete
if not LibStub or LibStub.minor < LIBSTUB_MINOR then 
	if not LibStub then 
		LibStub = { libs = {},}
		setmetatable(LibStub, {})
		_G[LIBSTUB_MAJOR] = LibStub
	 end

	-- LibStub:NewLibrary(major, minor)
	-- major (string) - the major version of the library
	-- minor (string or number ) - the minor version of the library
	-- 
	-- returns nil if a newer or same version of the lib is already present
	-- returns empty library object or old library object if upgrade is needed
	function LibStub:NewLibrary(major, minor)
		if type(minor) == "string" then
			minor = tonumber(minor:match("%d+"))
		end
		if type(minor) ~= "number" then
			error("Minor version must contain a number.", 2)
		end
	
		local entry = self.libs[major] or {}
	
		if entry.minor and entry.minor >= minor then return nil end
	
		self.libs[major] = entry
		entry.minor, entry.instance = minor, entry.instance or {}
	
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
			if silent then return nil end
			error(("Cannot find a library instance of %s."):format(major), 2)
		end
	
		return entry.instance
	end

	local function safecall(func,...)
		local success, err = pcall(func,...)
		if success then return err end
		
		if not err:find("%.lua:%d+:") then err = (debugstack():match("\n(.-: )in.-\n") or "") .. err end 
		geterrorhandler()(err)
	end

	-- LibStub:FinalizeLibrary(major, callback)
	--
	-- major (string) - The major version of the library 
	-- callback (function)  - A function to be called when a new library is loaded.
	--   If this function returns a true value, then after being called, it will be removed from the callback registry.
	function LibStub:FinalizeLibrary(major, callback )
		if type(major) ~= "string" then
			error(("Bad argument #2 to 'FinalizeLibrary' (string expected, got %s)"):format(type(major)), 2)
		end
		if type(callback) ~= "function" and type(callback) ~= "nil" then
			error(("Bad argument #3 to 'FinalizeLibrary' (function or nil expected, got %s)"):format(type(callback)), 2)
		end
	
		local entry = self.libs[major]
	
		if not entry then error(("Cannot finalize an unregistered instance of  %s."):format(major), 2) end
	
		entry.callback = callback
	
		for key, lib in pairs(self.libs) do
			if lib ~= entry and type(lib.callback) == "function" then
				if safecall(lib.callback, major, entry.instance) then lib.callback = nil end
			end
		end
	end
	
	LibStub.minor = LIBSTUB_MINOR
	getmetatable(LibStub).__call = LibStub.GetInstance
end
