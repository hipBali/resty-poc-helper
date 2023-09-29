--
-- /api/test/method
-- 
-- (c) 2023, github.com/hipBali/resty-poc-helper
--
-- curl http://localhost:8888/api/test/method
--
-- curl -X WTF http://localhost:8888/api/test/method
--
requestHandler = { 
	get = function(r)
		return r.param
	end,
	post = function(r)
		return {params=r.param, body=r.data}
	end
}