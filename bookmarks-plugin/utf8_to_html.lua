-- Converts UTF-8 string to an ASCII string with HTML numeric entities for any codepoint outside the ASCII range
-- This prevents rendering issues with bookmark names
return function(input)
  if type(input) ~= "string" then
    error("Expected string, got " .. type(input), 2)
  end

  local output = {}
  local i = 0
  local len = #input

  while i < len do
    i = i + 1
    local c = string.byte(input, i)

    -- 1-byte sequence: 0xxxxxxx
    if c & 0x80 == 0 then
      table.insert(output, string.char(c))

    -- 2-byte sequence: 110xxxxx 10xxxxxx
    elseif c & 0xE0 == 0xC0 then
      i = i + 1
      local c2 = string.byte(input, i)
      if c2 == nil or c2 & 0xC0 ~= 0x80 then
        error("Invalid UTF-8 string at byte " .. i, 2)
      end
      local v = ((c & 0x1F) << 6) | (c2 & 0x3F)   -- FIX: was 0x7F
      table.insert(output, "&#" .. v .. ";")

    -- 3-byte sequence: 1110xxxx 10xxxxxx 10xxxxxx
    elseif c & 0xF0 == 0xE0 then
      i = i + 1
      local c2 = string.byte(input, i)
      if c2 == nil or c2 & 0xC0 ~= 0x80 then
        error("Invalid UTF-8 string at byte " .. i, 2)
      end
      i = i + 1
      local c3 = string.byte(input, i)
      if c3 == nil or c3 & 0xC0 ~= 0x80 then
        error("Invalid UTF-8 string at byte " .. i, 2)
      end
      local v = ((c & 0x0F) << 12) | ((c2 & 0x3F) << 6) | (c3 & 0x3F)  -- FIX: was 0x7F
      table.insert(output, "&#" .. v .. ";")

    -- 4-byte sequence: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
    elseif c & 0xF8 == 0xF0 then
      i = i + 1
      local c2 = string.byte(input, i)
      if c2 == nil or c2 & 0xC0 ~= 0x80 then
        error("Invalid UTF-8 string at byte " .. i, 2)
      end
      i = i + 1
      local c3 = string.byte(input, i)
      if c3 == nil or c3 & 0xC0 ~= 0x80 then
        error("Invalid UTF-8 string at byte " .. i, 2)
      end
      i = i + 1
      local c4 = string.byte(input, i)
      if c4 == nil or c4 & 0xC0 ~= 0x80 then
        error("Invalid UTF-8 string at byte " .. i, 2)
      end
      local v = ((c & 0x07) << 18) | ((c2 & 0x3F) << 12) | ((c3 & 0x3F) << 6) | (c4 & 0x3F)  -- FIX: was 0x7F
      table.insert(output, "&#" .. v .. ";")

    else
      error("Invalid UTF-8 leading byte 0x" .. string.format("%02X", c) .. " at byte " .. i, 2)
    end
  end

  return table.concat(output)
end