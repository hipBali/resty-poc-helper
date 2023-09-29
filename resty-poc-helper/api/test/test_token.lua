--
-- /api/test/token
-- 
-- (c) 2023, github.com/hipBali
--
-- curl "http://localhost:8888/api/test/token" -H "Authorization: Bearer ..."    
--

local json = require "cjson"
token_validator = require "api.test.common.validate_token"

requestHandler = {
	get = function(r) 
		return { token = token_validator() }                      
	end 
}
