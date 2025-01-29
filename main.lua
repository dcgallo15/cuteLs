#!/bin/lua

-- Will print cwd in format:
-- PERMS    LINKS    SIZE    FILENAME
-- directories have a / at the end and their size is also displayed using du

local function split (xs)
    local ret = {}
    for w in xs:gmatch("%S+") do
        table.insert(ret, w)
    end
    return ret
end

Black      = "\27[30m"
DarkRed    = "\27[31m"
DarkGreen  = "\27[32m"
DarkYellow = "\27[33m"
DarkBlue   = "\27[34m"
DarkMagenta= "\27[35m"
DarkCyan   = "\27[36m"
LightGray  = "\27[37m"
DarkGray   = "\27[90m"
Red        = "\27[91m"
Green      = "\27[92m"
Orange     = "\27[93m"
Blue       = "\27[94m"
Magenta    = "\27[95m"
Cyan       = "\27[96m"
White      = "\27[97m"

local function writeMsgCol(msg, color)
    io.stdout:write(color)
    io.stdout:write(msg)
    io.stdout:write("\27[0m")
end

-- FIXME: maybe implement some version of ennums 'go style' with 'iota'?
local PERMS = 1
local LINKS = 2
local OWNER = 3
local GROUP = 4
local SIZE = 5 -- Always 4.0K on directory
local MONTH = 6
local DAY = 7
local TIME = 8
local FILENAME = 9

local home = os.getenv("HOME")

local filename = home .. "/UNIQUETMPLUA.txt"

os.execute("/bin/ls -lah > " .. filename)

local f = assert(io.open(filename, "r"), "FAILED TO OPEN FILE")

local currLine = f:read("*l")

-- TODO:
-- add total space used at bottom
-- skip files that script cannot read and print appropriate message
-- make colors depend on permissions of the file

local isDir = false

local function callDu(elemFname, newFname)
    local tmp = os.execute("/bin/du -ksh " .. elemFname .. " > " .. newFname)
    if tmp == false then
        error("Cannot Call du")
    end
end

while currLine ~= nil do -- !=
    local elems = split(currLine)
    if #elems == 9 and elems[FILENAME] ~= ".." and elems[FILENAME] ~= "." and elems[FILENAME] ~= "UNIQUETMPLUA.txt" then
        if elems[PERMS]:sub(1, 1) == "d" then -- Checking its a directory
            local newFname = home .. "/VERYTMPLAJKSDN.txt"
            local nf = assert(io.open(newFname, "w"))
            nf:write() -- To create the file
            nf:close()
            nf = assert(io.open(newFname, "r"))
            if pcall(callDu, elems[FILENAME], newFname) then
                elems[SIZE] = nf:read("*l"):match("(%w+)(.+)") -- Only reads the first word
            else
                elems[SIZE] = "..."
            end
            nf:close()
            os.remove(newFname)
            elems[FILENAME] = elems[FILENAME] .. "/"
            isDir = true
        end
        writeMsgCol(elems[PERMS], Magenta)
        io.stdout:write("  ")
        writeMsgCol(elems[LINKS], Orange)
        io.stdout:write("  ")
        writeMsgCol(elems[SIZE], Cyan)
        io.stdout:write("\t")
        if isDir == true then
            writeMsgCol(elems[FILENAME], Blue)
        else
            io.stdout:write(elems[FILENAME])
        end
        io.stdout:write("\n")
        isDir = false
    end
    currLine = f:read("*l")
end
f:close()
os.remove(filename)
