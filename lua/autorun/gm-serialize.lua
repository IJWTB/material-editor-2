--[[
    GM-Serialize :: Library Script
        by MiBShidobu
]]--

serialize = {
    VERSION = "3.0.0"
}

local g_StringBuf = ""

local g_CharMap = {
    ["nil"]			= string.char(0x0000C0),
    ["true"]		= string.char(0x0000C1),
    ["false"]		= string.char(0x0000C2),

    ["double"]		= string.char(0x0000C3),

    ["uint8"]		= string.char(0x0000CA), -- 0x000000-7F = fixed_uint
    ["uint16"]		= string.char(0x0000CB),
    ["uint32"]		= string.char(0x0000CC),

    ["int8"]		= string.char(0x0000CD), -- 0x0000E0-FF = fixed_int
    ["int16"]		= string.char(0x0000CE),
    ["int32"]		= string.char(0x0000CF),

    ["raw8"]		= string.char(0x0000D1), -- 0x0000A0-BF = fixed_raw
    ["raw16"]		= string.char(0x0000D2),
    ["raw32"]		= string.char(0x0000D3),

    ["array16"]		= string.char(0x0000D4), -- 0x000080-8F = fixed_array
    ["array32"]		= string.char(0x0000D5),

    ["map16"]		= string.char(0x0000D6), -- 0x000090-9F = fixed_map
    ["map32"]		= string.char(0x0000D7),

    ["angle"]		= string.char(0x0000DA),
    ["vector"]		= string.char(0x0000DB),
    ["color"]		= string.char(0x0000DC),

    ["entity8"]		= string.char(0x0000DD),
    ["entity16"]	= string.char(0x0000DE),
    ["null"]		= string.char(0x0000DF)
}

local g_ValueConv = {
    ["uint16"] = function (value)
        return string.char(
            math.floor (value / 256) % 256,
            value % 256
        )
    end,

    ["uint32"] = function (value)
        return string.char(
            math.floor (value / 16777216) % 256,
            math.floor (value / 65536) % 256,
            math.floor (value / 256) % 256,
            value % 256
        )
    end,

    ["double"] = function (value)
        -- Not my code, got it from a pastebin from friendo. If anyone has original source, pls gibe so I can link and credit!
        local function grab_byte(v)
            return math.floor(v / 256), string.char(math.fmod(math.floor(v), 256))
        end

        local sign = 0
        if value < 0 then
            sign = 1
            value = -value
        end

        local mantissa, exponent = math.frexp(value)
        if value == 0 then -- zero
            mantissa, exponent = 0, 0

        elseif value == 1 / 0 then
            mantissa, exponent = 0, 2047

        else
            mantissa = (mantissa * 2 - 1) * math.ldexp(0.5, 53)
            exponent = exponent + 1022
        end

        local v, byte = "" -- convert to bytes
        value = mantissa

        for i = 1,6 do
            value, byte = grab_byte(value)
            v = v..byte -- 47:0
        end

        value, byte = grab_byte(exponent * 16 + value)
        v = v..byte -- 55:48

        value, byte = grab_byte(sign * 128 + value)
        v = v..byte -- 63:56

        return v
    end,
}

local g_TypeMap = nil
g_TypeMap = {
    ["Angle"] = function (value)
        g_StringBuf = g_StringBuf..g_CharMap.angle..g_ValueConv.double(value.pitch)..g_ValueConv.double(value.yaw)..g_ValueConv.double(value.roll)
    end,

    ["boolean"] = function (value)
        if value then
            g_StringBuf = g_StringBuf..g_CharMap["true"]

        else
            g_StringBuf = g_StringBuf..g_CharMap["false"]
        end
    end,

    ["Color"] = function (value)
        g_StringBuf = g_StringBuf..g_CharMap.color..string.char(value.r)..string.char(value.g)..string.char(value.b)..string.char(value.a)
    end,

    ["Entity"] = function (value)
        if IsValid(value) then
            local index = value:EntIndex()
            if index < 256 then
                g_StringBuf = g_StringBuf..g_CharMap.entity8..string.char(index)

            else
                g_StringBuf = g_StringBuf..g_CharMap.entity16..g_ValueConv.uint16(index)
            end

        else
            g_StringBuf = g_StringBuf..g_CharMap.null
        end
    end,

    ["nil"] = function (value)
        g_StringBuf = g_StringBuf..g_CharMap["nil"]
    end,

    ["number"] = function (value)
        if math.floor(value) == value then
            if value >= 0 then
                if value < 127 then
                    g_StringBuf = g_StringBuf..string.char(value)

                elseif value < 256 then
                    g_StringBuf = g_StringBuf..g_CharMap.uint8..string.char(value)

                elseif value < 65536 then
                    g_StringBuf = g_StringBuf..g_CharMap.uint16..g_ValueConv.uint16(value)

                else
                    g_StringBuf = g_StringBuf..g_CharMap.uint32..g_ValueConv.uint32(value)
                end

            else
                if value >= -32 then
                    g_StringBuf = g_StringBuf..string.char(0x0000E0 + ((value + 256) % 32))

                elseif value >= -128 then
                    g_StringBuf = g_StringBuf..g_CharMap.int8..string.char(value + 256)

                elseif value >= -32768 then
                    g_StringBuf = g_StringBuf..g_CharMap.int16..g_ValueConv.uint16(value + 65536)

                else
                    g_StringBuf = g_StringBuf..g_CharMap.int32..g_ValueConv.uint32(value + 4294967296)
                end
            end

        else
            g_StringBuf = g_StringBuf..g_CharMap.double..g_ValueConv.double(value)
        end
    end,

    ["string"] = function (value)
        local length = #value
        if length < 32 then
            g_StringBuf = g_StringBuf..string.char(0x0000A0 + length)

        elseif length < 256 then
            g_StringBuf = g_StringBuf..g_CharMap.raw8..string.char(length)

        elseif length < 65536 then
            g_StringBuf = g_StringBuf..g_CharMap.raw16..g_ValueConv.uint16(length)

        else
            g_StringBuf = g_StringBuf..g_CharMap.raw32..g_ValueConv.uint32(length)
        end

        g_StringBuf = g_StringBuf..value
    end,

    ["table"] = function (value)
        if IsColor(value) then
            g_TypeMap.Color(value)

        else
            local map = false
            local count = 0
            local max = 0

            for key, _ in pairs(value) do
                if type(key) == "number" and key == (max + 1) then
                    if key > max then
                        max = key
                    end

                else
                    map = true
                end

                count = count + 1
            end

            if map then
                if count < 16 then
                    g_StringBuf = g_StringBuf..string.char(0x000090 + count)

                elseif count < 65536 then
                    g_StringBuf = g_StringBuf..g_CharMap.map16..g_ValueConv.uint16(count)

                else
                    g_StringBuf = g_StringBuf..g_CharMap.map32..g_ValueConv.uint32(count)
                end

                for key, store in pairs(value) do
                    g_TypeMap.variable(key)
                    g_TypeMap.variable(store)
                end

            else
                if max < 16 then
                    g_StringBuf = g_StringBuf..string.char(0x000080 + max)

                elseif max < 65536 then
                    g_StringBuf = g_StringBuf..g_CharMap.array16..g_ValueConv.uint16(max)

                else
                    g_StringBuf = g_StringBuf..g_CharMap.array32..g_ValueConv.uint32(max)
                end

                for index=1, max do
                    g_TypeMap.variable(value[index])
                end
            end
        end
    end,

    ["variable"] = function (value)
        local vartype = type(value)
        if not g_TypeMap[vartype] then
            error("GM-Serialize: Unsupported encoding type '"..vartype.."'")
        end

        g_TypeMap[vartype](value)
    end,

    ["Vector"] = function (value)
        g_StringBuf = g_StringBuf..g_CharMap.vector..g_ValueConv.double(value.x)..g_ValueConv.double(value.y)..g_ValueConv.double(value.z)
    end
}

g_TypeMap["NextBot"]	= g_TypeMap["Entity"]
g_TypeMap["NPC"]		= g_TypeMap["Entity"]
g_TypeMap["Player"]		= g_TypeMap["Entity"]
g_TypeMap["Vehicle"]	= g_TypeMap["Entity"]
g_TypeMap["Weapon"]		= g_TypeMap["Entity"]

function serialize.Encode(variable)
    g_StringBuf = ""
    g_TypeMap.variable(variable)

    return g_StringBuf
end

local g_TypeRef = nil
local g_RefConv = {
    ["uint16"] = function (cursor)
        local byteone, bytetwo = string.byte(g_StringBuf, cursor, cursor + 1)
        return (byteone * 256) + bytetwo
    end,

    ["uint32"] = function (cursor)
        local byteone, bytetwo, bytethree, bytefour = string.byte(g_StringBuf, cursor, cursor + 3)
        return ((byteone * 65536) * 256) + (bytetwo * 65536) + (bytethree * 256) + bytefour
    end,

    ["double"] = function (cursor)
        local function bitstofrac(ary)
            local x = 0
            local cur = 0.5
            for i,v in ipairs(ary) do
                x = x + cur * v
                cur = cur / 2
            end

            return x   
        end

        local function bytestobits(ary)
            local out = {}
            for i, v in ipairs(ary) do
                for j=0, 7, 1 do
                    table.insert(out, bit.band(bit.rshift(v, 7 - j), 1))
                end
            end

            return out
        end

        local bytes = string.char(string.byte(g_StringBuf, cursor, cursor + 7))

        -- Samething as the double for converting to double encoding, not mine, got from friendo pastbin.
        -- Find source, and will link!

        -- sign:1bit
        -- exp: 11bit (2048, bias=1023)
        local sign = math.floor(bytes:byte(8) / 128)
        local exp = bit.band(bytes:byte(8), 127) * 16 + bit.rshift(bytes:byte(7), 4) - 1023 -- bias

        -- frac: 52 bit
        local fracbytes = {
            bit.band(bytes:byte(7), 15),
            bytes:byte(6), bytes:byte(5),
            bytes:byte(4), bytes:byte(3),
            bytes:byte(2), bytes:byte(1) -- big endian
        }

        local bits = bytestobits(fracbytes)

        for i=1,4 do
            table.remove(bits,1)
        end

        if sign == 1 then
            sign = -1

        else
            sign = 1
        end

        local frac = bitstofrac(bits)
        if exp == -1023 and frac==0 then
            return 0
        end

        if exp == 1024 and frac==0 then
            return 1 / 0 * sign
        end

        local real = math.ldexp(1 + frac, exp)

        return real * sign
    end,

    ["array"] = function (cursor, max)
        local ret = {}
        for index=1, max do
            cursor, ret[index] = g_TypeRef.variable(cursor)
        end

        return cursor, ret
    end,

    ["map"] = function (cursor, max)
        local ret = {}
        for index=1, max do
            cursor, key = g_TypeRef.variable(cursor)
            cursor, value = g_TypeRef.variable(cursor)

            ret[key] = value
        end

        return cursor, ret
    end
}

g_TypeRef = {
    ["variable"] = function (cursor)
        local enctype = string.byte(g_StringBuf[cursor])
        if g_TypeRef[enctype] then
            return g_TypeRef[enctype](cursor)

        elseif enctype < 0x0000C0 then
            if enctype < 0x000080 then
                return g_TypeRef["fixed_uint"](cursor)

            elseif enctype < 0x000090 then
                return g_TypeRef["fixed_array"](cursor)

            elseif enctype < 0x0000A0 then
                return g_TypeRef["fixed_map"](cursor)
            end

            return g_TypeRef["fixed_raw"](cursor)

        elseif enctype > 0x0000DF and enctype < 0x000100 then
            return g_TypeRef["fixed_int"](cursor)
        end

        error("GM-Serialize: Unsupported encoded type '0x"..string.upper(string.format("%06x", enctype)).."'")
    end,

    ["fixed_uint"] = function (cursor)
        return cursor + 1, string.byte(g_StringBuf[cursor])
    end,

    ["fixed_int"] = function (cursor)
        return cursor + 1, (256 - string.byte(g_StringBuf[cursor])) * -1
    end,

    ["fixed_raw"] = function (cursor)
        local length = string.byte(g_StringBuf[cursor]) - 0x0000A0
        local last = cursor + length + 1
        return last, string.sub(g_StringBuf, cursor + 1, last - 1)
    end,

    ["fixed_array"] = function (cursor)
        local max = string.byte(g_StringBuf[cursor]) - 0x000080
        return g_RefConv.array(cursor + 1, max)
    end,

    ["fixed_map"] = function (cursor)
        local max = string.byte(g_StringBuf[cursor]) - 0x000090
        return g_RefConv.map(cursor + 1, max)
    end,

    [0x0000C0] = function (cursor) -- Nil
        return cursor + 1, nil
    end,

    [0x0000C1] = function (cursor) -- True
        return cursor + 1, true
    end,

    [0x0000C2] = function (cursor) -- False
        return cursor + 1, false
    end,

    [0x0000C3] = function (cursor) -- Double
        return cursor + 9, g_RefConv.double(cursor + 1)
    end,

    [0x0000CA] = function (cursor) -- UInt8
        return cursor + 2, string.byte(g_StringBuf[cursor + 1])
    end,

    [0x0000CB] = function (cursor) -- UInt16
        return cursor + 3, g_RefConv.uint16(cursor + 1)
    end,

    [0x0000CC] = function (cursor) -- UInt32
        return cursor + 5, g_RefConv.uint32(cursor + 1)
    end,

    [0x0000CD] = function (cursor) -- Int8
        return cursor + 2, string.byte(g_StringBuf[cursor + 1]) - 256
    end,

    [0x0000CE] = function (cursor) -- Int16
        return cursor + 3, g_RefConv.uint16(cursor + 1) - 65536
    end,

    [0x0000CF] = function (cursor) -- Int32
        return cursor + 5, g_RefConv.uint32(cursor + 1) - 4294967296
    end,

    [0x0000D1] = function (cursor) -- Raw8
        local length = string.byte(g_StringBuf[cursor + 1])
        local start = cursor + 2
        local last = start + length

        return last, string.sub(g_StringBuf, start, last - 1)
    end,

    [0x0000D2] = function (cursor) -- Raw16
        local length = g_RefConv.uint16(cursor + 1)
        local start = cursor + 3
        local last = start + length

        return last, string.sub(g_StringBuf, start, last - 1)
    end,

    [0x0000D3] = function (cursor) -- Raw32
        local length = g_RefConv.uint32(cursor + 1)
        local start = cursor + 5
        local last = start + length

        return last, string.sub(g_StringBuf, start, last - 1)
    end,

    [0x0000D4] = function (cursor) -- Array16
        local max = g_RefConv.uint16(cursor + 1)
        return g_RefConv.array(cursor + 3, max)
    end,

    [0x0000D5] = function (cursor) -- Array32
        local max = g_RefConv.uint32(cursor + 1)
        return g_RefConv.array(cursor + 5, max)
    end,

    [0x0000D6] = function (cursor) -- Map16
        local max = g_RefConv.uint16(cursor + 1)
        return g_RefConv.map(cursor + 3, max)
    end,

    [0x0000D7] = function (cursor) -- Map32
        local max = g_RefConv.uint32(cursor + 1)
        return g_RefConv.map(cursor + 5, max)
    end,

    [0x0000DA] = function (cursor) -- Angle
        return cursor + 25, Angle(g_RefConv.double(cursor + 1), g_RefConv.double(cursor + 9), g_RefConv.double(cursor + 17))
    end,

    [0x0000DB] = function (cursor) -- Vector
        return cursor + 25, Vector(g_RefConv.double(cursor + 1), g_RefConv.double(cursor + 9), g_RefConv.double(cursor + 17))
    end,

    [0x0000DC] = function (cursor) -- Color
        return cursor + 5, Color(string.byte(g_StringBuf, cursor + 1, cursor + 4))
    end,

    [0x0000DD] = function (cursor) -- Entity8
        return cursor + 2, Entity(string.byte(g_StringBuf[cursor + 1]))
    end,

    [0x0000DE] = function (cursor) -- Entity16
        return cursor + 3, Entity(g_RefConv.uint16(cursor + 1))
    end,

    [0x0000DF] = function (cursor) -- NULL
        return cursor + 1, NULL
    end
}

function serialize.Decode(str)
    local strtype = type(str)
    if strtype == "string" then
        g_StringBuf = str

        local _, variable = g_TypeRef.variable(1)
        return variable
    end

    error("GM-Serialize: Invalid decoding typed '"..strtype.."'")
end