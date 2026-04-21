local nameGen = {}

local title = {
    "Commander",
    "General",
    "Mighty",
    "PewPewer",
    "Zapster",
    "AlienMc",
    "Abductor",
    "Invader",
    "Crasher",
    "Destroyer",
    "Explody",
    "Blasty",
    "Fryer",
    "Detonator",
    "Brawler",
    "Astro",
    "CowEater",
    "Mercenary",
    "Squisher"
}

local alien = {
    "Zorp",
    "Zarp",
    'Glorp',
    "Blorb",
    "Bleeb",
    "Zoop",
    "Zleep",
    "Zlag",
    "Bleg",
    "Broog",
    "Boog",
    "Fleeb",
    "Flarp",
    "Florp",
    "Flarg"
}

local endings = {
    "oog",
    "eeg",
    "og",
    "y",
    "o"
}

---@return string
function nameGen.generate()
    local out = title[math.random(#title)] .. alien[math.random(#alien)]
    if math.random(5) <= 2 then
        out = out .. endings[math.random(#endings)]
    end
    return out .. string.format("%02d", math.random(1,99))
end

---@param name string
---@return boolean
function nameGen.isAllowed(name)
    return name:match("^[%a%d_%-%.]+$") ~= nil
end

---@param name string
---@return boolean
function nameGen.isValidAddress(name)
    if #name == 0 or #name > 253 then return false end
    return name:match("^[%a%d%.%-%:]+$") ~= nil
end

---@param port number
---@return boolean
function nameGen.isValidPort(port)
    return port >= 1 and port <= 65535 and math.floor(port) == port
end

---@param str string
---@return string
function nameGen.stripColors(str)
    return (str:gsub("<[^>]*>", ""))
end

return nameGen