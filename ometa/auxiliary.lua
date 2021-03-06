local tostring, tonumber, select, type, getmetatable, setmetatable, rawget = tostring, tonumber, select, type, getmetatable, setmetatable, rawget
local bit = require('bit')
local band, bor, lshift = bit.band, bit.bor, bit.lshift
local Types = require('types')
local Any, Array = Types.Any, Types.Array
local Auxiliary = {pattern = function (input, p, drop)
local r = input.stream:pattern(p)
if not r then
return false
end
local success, res = input:collect(#r - (drop or 0))
return success, (res:concat())
end, apply = function (input, ruleRef, fallback, ...)
ruleRef = input.grammar[ruleRef]
if not ruleRef then
if not fallback then
return false
end
ruleRef = type(fallback) == 'string' and input.grammar[fallback] or fallback
end
if ... then
return input:applyWithArgs(ruleRef, ...)
else
return input:apply(ruleRef)
end
end}
return Auxiliary
