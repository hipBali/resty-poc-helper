--
-- /api/test/db
-- 
-- (c) 2023, github.com/hipBali
--
-- curl http://localhost:8888/api/test/test_db?firstname=John
--

local json = require "cjson"
local testDB = require "api.test.common.db"

local function db_test(param)
	return testDB.query(string.format("SELECT * FROM users where firstname='%s'", tostring(param.firstname)))
end

requestHandler = { 
	get = function(r)
		local res, err = db_test(r.param)
		if res then
			return { result = res }                      
		end
		resty_error(99,err)	
	end
}