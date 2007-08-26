-- $Id$
-- LicenseText
local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 1
local LibStub = _G[LIBSTUB_MAJOR]

-- Check to see is this version of the library is obsolete
if not LibStub or LibStub.minor < LIBSTUB_MINOR then 
	if not LibStub then 
		LibStub = {libs = {}, minors = {}, } 
		_G[LIBSTUB_MAJOR] = LibStub
	end

	-- LibStub:NewLibrary(major, minor)
	-- major (string) - the major version of the library
	-- minor (string or number ) - the minor version of the library
	-- 
	-- returns nil if a newer or same version of the lib is already present
	-- returns empty library object or old library object if upgrade is needed
	function LibStub:NewLibrary(major, minor)
		assert(type(major) == "string", "Bad argument #2 to 'NewLibrary' (string expected)")
		assert(minor, "Minor version must either be a number or contain a number.")
		minor = tonumber(minor) or assert(tonumber(minor:match("%d+")), "Minor version must either be a number or contain a number.")
		
		if self.minors[major] and self.minors[major] >= minor then return nil end
		self.minors[major], self.libs[major] = minor, self.libs[major] or {}
		return self.libs[major]
	end

	-- LibStub:GetLibrary(major, [silent])
	-- major (string) - the major version of the library
	-- silent (boolean) - if true, library is optional, silently return nil if its not found
	--
	-- throws an error if the library can not be found
	-- returns the library object if found
	function LibStub:GetLibrary(major, silent)
		assert(type(major) == "string", "Bad argument #2 to 'GetLibrary' (string expected)")
        if not silent and not self.libs[major] then error(('Library "%s" instance not found'):format(major), 2) end
		return self.libs[major]
	end

	-- LibStub:IterateLibraries()
	-- 
	-- Returns an iterator for the currently registered libraries
	function LibStub:IterateLibraries() 
		return pairs(self.libs) 
	end
	
	LibStub.minor = LIBSTUB_MINOR
	setmetatable(LibStub, { __call = LibStub.GetLibrary })
end