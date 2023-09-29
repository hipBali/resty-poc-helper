-- 
-- lua/api/test/common/validate_token.lua
-- 
-- (c) 2023, github.com/hipBali/resty-poc-helper
-- 

local jwt_utils = require "lua.common.tokenutils"
local validator = function()

	local user_token = jwt_utils.checkToken(jwt_utils._SPRING_AUTH_KEY)
	if user_token.valid_until then
		local cur_date = os.date("%Y-%m-%dT%T")
		local tok_date = os.date(user_token.valid_until)
		if tok_date > cur_date then
			return user_token
		else
			ngx.status = ngx.HTTP_UNAUTHORIZED
			ngx.header.content_type = "application/json; charset=utf-8"
			ngx.say("{\"error_code\":-4,\"error\":\"Expired token\"}")
			ngx.exit(ngx.HTTP_UNAUTHORIZED)
		end
	end
	ngx.status = ngx.HTTP_UNAUTHORIZED
	ngx.header.content_type = "application/json; charset=utf-8"
	ngx.say("{\"error_code\":-3,\"error\":\"Unknown token\"}")
	ngx.exit(ngx.HTTP_UNAUTHORIZED)

end

return validator