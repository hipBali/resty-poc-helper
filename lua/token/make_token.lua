-- 
-- lua/common/make_token.lua
--
-- Header token generator script
-- 
-- (c) 2023, github.com/hipBali/resty-poc-helper
--
-- lua '{"username":"user1","role":"REPORT","minutes":1440}'  [ 'http://localhost:8888/api/test/token' ] 
--

local json = require "cjson"
local dateutils = require "lua.common.dateutils"
local jwtutils = require "lua.token.utils"

local params = {}
if arg[1] then
	local jp = json.decode(arg[1])
	params.username = jp.username
	params.role = jp.role
	params.minutes = jp.minutes
end
local pload = {
	valid_until = dateutils.addMinutes(tonumber(params.minutes)),
	username = params.username,
	role = params.role,
	create_date = dateutils.getDate()
}
local accToken = jwtutils.encode(pload) -- with default secret key

io.stderr:write("[USAGE]\n")
io.stderr:write('curl -H "Authorization: Bearer '..accToken..'" '..(arg[2] or ""))
io.stderr:write("\n")
io.stderr:write("[TOKEN]\n")
io.stdout:write(accToken)
