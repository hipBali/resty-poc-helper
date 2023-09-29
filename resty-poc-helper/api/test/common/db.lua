-- 
-- (c) 2023, github.com/hipBali/resty-poc-helper
-- 
local local_ct = {
	host = "127.0.0.1",
	port = 3306,
	database = "test",
	user = "test",
	password = os.getenv("DBPASS") or "test",
	charset = "utf8",
    max_packet_size = 64 * 1024 * 1024,
}
---------------------------------
local m = require "lua.common.mysqldb"
m.init(local_ct)
return m
---------------------------------