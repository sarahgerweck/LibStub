-- $Id$
local _G = getfenv()
local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 1
local LibStub = _G[LIBSTUB_MAJOR]

-- Check to see is this version of the library is obsolete
if not LibStub or LibStub.minor < LIBSTUB_MINOR then 
	if not LibStub then 
		LibStub = {libs = {},}
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
		minor = tonumber(minor) or assert(tonumber(minor:match("%d+")), "Minor version must either be a number or contain a number.")
	
		local entry = self.libs[major] or {}
	
		if entry.minor and entry.minor >= minor then return nil end
	
		self.libs[major] = entry
		entry.minor, entry.instance = minor, entry.instance or {}
	
		return entry.instance
	end

	-- LibStub:GetLibrary(major, [silent])
	-- major (string) - the major version of the library
	-- silent (boolean) - if true, library is optional, silently return nil if its not found
	--
	-- throws an error if the library can not be found
	-- returns the library object if found
	function LibStub:GetLibrary(major, silent)
		assert(type(major) == "string", ("Bad argument #2 to 'GetLibrary' (string expected, got %s)"):format(type(major)))
	
		local entry = silent and self.libs[major] or assert(self.libs[major], ("Cannot find a library instance of %s."):format(major))
	
		return entry and entry.instance or nil
	end

	local function safecall(func,...)
		local success, err = pcall(func,...)
		if success then return err end
		
		if not err:find("%.lua:%d+:") then err = (debugstack():match("\n(.-: )in.-\n") or "") .. err end 
		geterrorhandler()(err)
	end

	-- LibStub:FinalizeLibrary(major, [callback])
	--
	-- major (string) - The major version of the library 
	-- callback (function)  - A function to be called when a new library is loaded.
	-- If this function returns a true value, then after being called, it will be removed from the callback registry.
	function LibStub:FinalizeLibrary(major, callback)
		assert(type(major) == "string", ("Bad argument #2 to 'GetLibrary' (string expected, got %s)"):format(type(major)))
		assert(not callback or type(callback) == "function", ("Bad argument #3 to 'FinalizeLibrary' (function or nil expected, got %s)"):format(type(callback)))
	
		local entry = assert(self.libs[major], ("Cannot finalize an unregistered instance of  %s."):format(major))
	
		entry.callback = callback
	
		for key, lib in pairs(self.libs) do
			if lib ~= entry and type(lib.callback) == "function" then
				if safecall(lib.callback, major, entry.instance) then lib.callback = nil end
			end
		end
	end
	
	-- LibStub:IterateLibrary()
	-- 
	-- Returns an iterator for the currently registered libraries
	function LibStub:IterateLibraries() return pairs(self.libs) end
	
	LibStub.minor = LIBSTUB_MINOR
	getmetatable(LibStub).__call = LibStub.GetLibrary
end