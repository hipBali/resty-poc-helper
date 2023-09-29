--
-- /api/test/test
-- 
-- (c) 2023, github.com/hipBali/resty-poc-helper
--
-- curl http://localhost:8888/api/test/test 
--
-- curl http://localhost:8888/api/test/test?error=123
--

requestHandler = { 
	get = function(r)
		if not r.param.error then
			return {code=0, value="Hello world", params=r.param}                     
		end
		resty_error(r.param.error,"Error result requested")
	end
}