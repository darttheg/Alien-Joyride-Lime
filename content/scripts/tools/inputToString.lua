local inputToString = {}

inputToString.KeyName = {}
for name, val in pairs(Lime.Enum.Key) do
    inputToString.KeyName[val] = name
end

inputToString.MouseName = {}
for name, val in pairs(Lime.Enum.Mouse) do
    inputToString.MouseName[val] = name
end

---@param val integer
---@param mouse boolean
---@return string
function inputToString.ToString(val, mouse)
    if mouse then return inputToString.MouseName[val] else return inputToString.KeyName[val] end
end

return inputToString