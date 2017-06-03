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