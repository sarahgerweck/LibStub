--$ID$
local LIBSTUB_MAJOR = "LibStub"
local LIBSTUB_MINOR = "$Revision$"

local _G = getfenv()
local LibStub = _G[LIBSTUB_MAJOR]
if LibStub and LibStub._minor < LIBSTUB_MINOR then
   -- Upgrading
else
   -- First load
   LibStub = {
      libs = {}
   }
   _G[LIBSTUB_MAJOR] = LibStub
end

function LibStub:NewLibrary(major, minor)
   minor = assert(tonumber(minor:match("%d+")), "MinorVersion must contain a numeric.") 
    
   local slot = self.libs[major] or {}
   
   if slot.minor and slot.minor > minor then 
      return nil 
   end
   
   self.libs[major] = slot
   
   slot.minor = minor
   slot.instance = slot.instance or {}
   
   return slot.instance
end
