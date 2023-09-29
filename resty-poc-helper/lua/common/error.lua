-- 
-- lua/common/error.lua
--
-- resty_error()
-- 
-- (c) 2023, github.com/hipBali/resty-poc-helper
-- 

local json = require "cjson"
function resty_error(error_code, err_string)
	ngx.status = ngx.HTTP_NOT_FOUND
	ngx.say(json.encode{error_code=error_code or -9999, error=err_string or "Unknown error"})
	ngx.exit(ngx.HTTP_OK)
end