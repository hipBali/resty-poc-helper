-- 
-- lua/common/db.lua
-- resty mysql
--
--
-- Resty MySql helper
-- 
-- (c) 2023, github.com/hipBali/resty-poc-helper
-- 

local mysql = require "resty.mysql"
local json = require "cjson"

local default_ct = {
	host = "127.0.0.1",
	port = 3306,
	database = "myDatabase",
	user = "myUser",
	password = os.getenv("DBPASS") or "myPassword",
	charset = "utf8",
	max_packet_size = 64 * 1024 * 1024,
}
-----------------------------

local m = {}

local query_timeout = 2000 -- 2 sec

local function db_error(err)
	ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
	ngx.say(json.encode{error=err or "unknown reason..."})
	ngx.exit(ngx.HTTP_OK)
end

function m.init(ct)
	default_ct = ct
end

function m.query(sql)
	local db, err = mysql:new()
	if not db then
		db_error(err)
	end
	db:set_timeout(query_timeout) 
	local ok, err, errcode, sqlstate = db:connect(default_ct)
	if not ok then
		db_error(err)
	end
	local res, err, errcode, sqlstate = db:query(sql)
	if not res then
		db_error(err)
	end
	local ok, err = db:close()
	if not ok then
	    db_error(err)
	end
	return res
end

return m
