-- Adapted from https://gist.github.com/haggen/2fd643ea9a261fea2094
local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 97, 122 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 48,  57 do table.insert(charset, string.char(i)) end

local function implode(list, delimiter)
  local len = #list
  if len == 0 then
    return ""
  end
  local string = list[1]
  for i = 2, len do
    string = string .. delimiter .. list[i]
  end
  return string
end

Util = {
  charset = charset,
  implode = implode
}

-- Slightly adapted from:
-- https://github.com/crawl/crawl/blob/master/crawl-ref/source/dat/dlua/util.lua
function Util.randomWeighted(list, weightfn)
  if type(weightfn) ~= "function" then
    local weightkey = weightfn or "weight"
    weightfn = function (table)
                 return table[weightkey]
               end
  end
  local cweight = 0
  local chosen = nil
  for i,e in pairs(list) do
    local wt = weightfn(e) or 10
    cweight = cweight + wt
    if math.random(0,cweight-1) < wt then
      chosen = e
    end
  end
  return chosen
end

function Util.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

return Util