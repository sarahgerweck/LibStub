debugstack = debug.traceback
strmatch = string.match

loadfile("../LibStub.lua")()

local lib, oldMinor = LibStub:NewLibrary("Pants", 1)
assert(lib)
assert(not oldMinor)

function lib:MyMethod()
end
local MyMethod = lib.MyMethod
lib.MyTable = {}
local MyTable = lib.MyTable

local newLib, newOldMinor = LibStub:NewLibrary("Pants", 1) -- check equal
assert(not newLib)

local newLib, newOldMinor = LibStub:NewLibrary("Pants", 0) -- check less
assert(not newLib)

local newLib, newOldMinor = LibStub:NewLibrary("Pants", 2)
assert(newLib)
assert(newLib == lib)
assert(newOldMinor == 1)

assert(lib.MyMethod == MyMethod) -- verify that values were saved
assert(lib.MyTable == MyTable) -- verify that values were saved