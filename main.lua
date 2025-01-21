#!/bin/lua

-- Will print cwd in format:
-- PERMS    SUBDIRSCOUNT    SIZE    FILENAME
-- directories have a / at the end and their size is also displayed using du

local function split (xs)
    local ret = {}
    for w in xs:gmatch("%S+") do
        table.insert(ret, w)
    end
    return ret
end

local PERMS = 1
local SUBDIRCOUNT = 2
local OWNER = 3
local GROUP = 4
local SIZE = 5 -- Always 4.0K on directory
local MONTH = 6
local DAY = 7
local TIME = 8
local FILENAME = 9

local filename = "UNIQUETMPLUA.txt"

os.execute("/bin/ls -lah > " .. filename)

local f = assert(io.open(filename, "r"), "FAILED TO OPEN FILE")

local currLine = f:read("*l")

while currLine ~= nil do -- !=
    local elems = split(currLine)
    if #elems == 9 and elems[FILENAME] ~= ".." and elems[FILENAME] ~= "." and elems[FILENAME] ~= filename then
        if elems[PERMS]:sub(1, 1) == "d" then -- Checking its a directory
            local newFname = "VERYTMPLAJKSDN.txt"
            local nf = assert(io.open(newFname, "w"))
            nf:write() -- To create the file
            nf:close()
            nf = assert(io.open(newFname, "r"))
            os.execute("/bin/du -ksh " .. elems[FILENAME] .. " > " .. newFname)
            elems[SIZE] = nf:read("*l"):match("(%w+)(.+)") -- Only reads the first word
            nf:close()
            os.remove(newFname)
            elems[FILENAME] = elems[FILENAME] .. "/"
        end
        io.stdout:write(elems[PERMS])
        io.stdout:write("\t")
        io.stdout:write(elems[SUBDIRCOUNT])
        io.stdout:write("\t")
        io.stdout:write(elems[SIZE])
        io.stdout:write("\t")
        io.stdout:write(elems[FILENAME])
        io.stdout:write("\n")
    end
    currLine = f:read("*l")
end
f:close()
os.remove(filename)
