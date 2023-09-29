--
-- JWT token genarator/validator
--
-- based on https://github.com/x25/luajwt
-- 
-- (c) 2023, github.com/hipBali/resty-poc-helper
-- 

local json = require "cjson"
local hmac = require "resty.hmac"
require "resty.core.base64"

local alg_sign = {
	['HS256'] = function(data, key) 
					local chd = hmac:new(key, hmac.ALGOS.SHA256) 
					chd:update(data)
					return chd:final() 
				end,
}

local alg_verify = {
	['HS256'] = function(data, signature, key) 
					return signature == alg_sign['HS256'](data, key) 
				end,
}

local _DEFAULT_SECRET_KEY = 'g$jDTLRtzCS3gyXs'

local M = {}

M._BEARER = 'Authorization'
M._XACCESS = 'x-access-token'

function M.encode(data, key, alg)
	if type(data) ~= 'table' then return nil, "Argument #1 must be table" end
	key = key or _DEFAULT_SECRET_KEY

	alg = alg or "HS256" 

	if not alg_sign[alg] then
		return nil, "Algorithm not supported"
	end

	local header = { typ='JWT', alg=alg }

	local segments = {
		header = ngx.encode_base64(json.encode(header)),
		data = ngx.encode_base64(json.encode(data))
	}

	local signing_input = segments.header.."."..segments.data

	local signature = alg_sign[alg](signing_input, key)

	segments.signature = ngx.encode_base64(signature)

	return ngx.encode_base64(json.encode(segments))
end

function M.decode(data, key, verify)
	-- if key and verify == nil then verify = true end
	if type(data) ~= 'string' then return nil, "Argument #1 must be string" end
	key = key or _DEFAULT_SECRET_KEY
	verify = verify or true
	
	local jwt_token
	local dc_data = ngx.decode_base64(data)
	if dc_data then
		jwt_token = json.decode(dc_data)
	else
		return nil, "Invalid token"
	end

	local headerb64, bodyb64, sigb64 = jwt_token.header, jwt_token.data, jwt_token.signature

	local ok, header, body, sig = pcall(function ()

		return	json.decode(ngx.decode_base64(headerb64)), 
			json.decode(ngx.decode_base64(bodyb64)),
			ngx.decode_base64(sigb64)
	end)	

	if not ok then
		return nil, "Invalid json"
	end

	if verify then

		if not header.typ or header.typ ~= "JWT" then
			return nil, "Invalid typ"
		end

		if not header.alg or type(header.alg) ~= "string" then
			return nil, "Invalid alg"
		end

		if body.exp and type(body.exp) ~= "number" then
			return nil, "exp must be number"
		end

		if body.nbf and type(body.nbf) ~= "number" then
			return nil, "nbf must be number"
		end

		if not alg_verify[header.alg] then
			return nil, "Algorithm not supported"
		end

		if not alg_verify[header.alg](headerb64 .. "." .. bodyb64, sig, key) then
			return nil, "Invalid signature"
		end

		if body.exp and os.time() >= body.exp then
			return nil, "Not acceptable by exp"
		end

		if body.nbf and os.time() < body.nbf then
			return nil, "Not acceptable by nbf"
		end
	end

	return body
end

local function getHeaderToken( hKey )
	hKey = hKey or M._BEARER
	local access_token = ngx.req.get_headers()[hKey]
	if access_token then
		if hKey == M._BEARER then
			return string.match(access_token, "Bearer%s+(.+)")
		else
			return access_token
		end
	end
end

function M.checkHeaderToken( tokenType, secret_key )
	local jwt_token	= getHeaderToken( tokenType ) 
	if jwt_token == nil then
		ngx.status = ngx.HTTP_UNAUTHORIZED
		ngx.header.content_type = "application/json; charset=utf-8"
		ngx.say("{\"error_code\":-2,\"error\":\"" .. (err or "Missing token") .. "\"}")
		ngx.exit(ngx.HTTP_UNAUTHORIZED) 
	end
	local res,err = M.decode(jwt_token, secret_key)
	if res == nil then
		ngx.status = ngx.HTTP_UNAUTHORIZED
		ngx.header.content_type = "application/json; charset=utf-8"
		ngx.say("{\"error_code\":-1,\"error\":\"" .. (err or "Unathorized") .. "\"}")
		ngx.exit(ngx.HTTP_UNAUTHORIZED) 
	else
		return res, err
	end
end

function M.checkToken( jwt_token, secret_key )
	return M.decode(jwt_token, secret_key)
end

return M