-- lua/common/pwutils.lua
--
-- Password hash utilities
-- 
-- (c) 2023, github.com/hipBali/resty-poc-helper
-- 
 
local pbkdf2 = require "resty.nettle.pbkdf2"
local ngx_re = require "ngx.re"
local random = require "resty.random"

local function hex(str,spacer)
  return (string.gsub(str,"(.)", function (c)
    return string.format("%02X%s",string.byte(c), spacer or "")
  end))
end

local function dehex(hexstr)
   return (hexstr:gsub("%x%x", function(digits) return string.char(tonumber(digits, 16)) end))
end

local m = {}

local ITERATIONS = 1000
local HASH_BYTE_LEN = 24
local SALT_BYTE_SIZE = 24

function m.checkPassword(hpass, pass)
	local res, err = ngx_re.split(hpass, ":")
	local iterations = res[1]
	local salt = res[2]
	local hash = res[3]
	local testHash = pbkdf2.hmac_sha1(pass, tonumber(iterations), dehex(salt), string.len(hash)/2);
	return hex(testHash):upper() == hash:upper() 
end

function m.hashPassword(pass)
	local iterations = ITERATIONS
	local salt = random.bytes(SALT_BYTE_SIZE)
	local hash = pbkdf2.hmac_sha1(pass, iterations, salt, HASH_BYTE_LEN)
	return string.format("%d:%s:%s", iterations, hex(salt), hex(hash))
end

return m