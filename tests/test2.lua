debugstack = debug.traceback
strmatch = string.match

loadfile("../LibStub.lua")()

for major in LibStub:IterateLibraries() do
	assert(major ~= "MyLib")
end

assert(not LibStub:GetLibrary("MyLib", true))
assert(not pcall(LibStub.GetLibrary, LibStub, "MyLib")) -- should error
local lib = LibStub:NewLibrary("MyLib", 1)
assert(lib)
assert(LibStub:GetLibrary("MyLib") == lib)

local good = false
for major, library in LibStub:IterateLibraries() do
	if major == "MyLib" then
		good = true
		assert(library == lib)
		break
	end
end
assert(good)
