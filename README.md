# resty-poc-helper
Openresty Rest Api POC builder helper.

- working Rest API service creating within 10 minutes
- modifying endpoint script without service restart
- JWT token handling 

## **Requirements**

- OpenResty®
- lua-resty-jwt 
- [lua-resty-nettle]  (required for password handling) 

*LUA-RESTY-JWT*

- opm:

```
opm get SkyLothar/lua-resty-jwt
```

- luarocks: 

```
luarocks install lua-resty-jwt
```

*LUA-RESTY-NETTLE*

- opm:

```
opm get bungle/lua-resty-nettle
```

- luarocks:

```
luarocks install lua-resty-nettle
```

- install from source:

  ​	

  ```
  wget https://ftp.gnu.org/gnu/nettle/nettle-3.4.1.tar.gz
  tar -zxf nettle-3.4.1.tar.gz
  cd nettle-3.4.1
  ./configure --prefix=/usr --enable-mini-gmp && make
  make install 
  ```


## Configuration

### conf/nginx-dev.conf

This configuration file allows you to use Rest API calls without an access token. 

```shell
$ cd resty-poc-helper
$ sh start.sh dev
start resty-poc application with profile: dev

$ sh stop.sh dev
stop resty-poc application with profile: dev
```

### conf/nginx-release.conf

This configuration file requires a valid JWT token in the request header to access Rest API endpoints. 

```shell
$ sh start.sh
start resty-poc application with profile: release

$ sh stop.sh
stop resty-poc application with profile: release
```

## JWT tokens

Creating tokens

```lua
local dateutils = require "lua.common.dateutils"
local jwtutils = require "lua.common.tokenutils"
local pload = {
	valid_until = dateutils.addHours(2),
    foo = "bar"
}
io.stdout:write(jwtutils.encode(pload,"Very_Secret_Key"))
```

Verifying tokens

```lua
pload = jwtutils.decode(jwt_token,"Very_Secret_Key")
io.stdout:write(pload.valid_until)
```

Validating header tokens

```lua
local user_token = jwt_utils.checkHeaderToken(jwtutils._BEARER) -- or jwtutils._XACCES
```

## Usage

**Create your first rest api response**

Create a new request handler and save it as api/mytest.lua

``` lua
requestHandler = {
  get = function(r)
    return "hello world"
  end
}
```

Register the new request handler in conf/resty.json

``` json
{  
  "api/mytest": "api/mytest.lua"
}
```

Start OpenResty service in with development config

```shell
$ sh start.sh dev
start resty-poc application with profile: dev
```

Test your endpoint with CURL

```shell
$ curl http://localhost:8888/api/mytest
"hello world"
```

**Accessing request parameters and body data**

The http request will served by requestHandler methods. This simple example shows how can you catch various http requests.
```lua
requestHandler = { 
	get = function(r)
		return {r.param}
	end,
	post = function(r)
		return {params=r.param,body=r.data}
	end
}
```

The request parameter is a lua table which contains the request parameters, body and token details
```lua
local params = r.param
local body = r.data
local payload = r.token -- for release config only!
```

At the development stage you'll need *lua/common/validate_token.lua* module to access payload data

```lua
token_validator = require "api.test.common.validate_token"
requestHandler = {
	get = function(r) 
		local payload = token_validator()
        return "ok"
	end
}
```

To generate token use the *make_token* script

```sh
$ sh make_token.sh '{"username":"myUser","role":"myRole","minutes":1440}'
$ curl -H "Authorization: Bearer eyJoZWFkZXIiOiJleUowZVhBaU9pSktWMVFpTENKaGJHY2lPaUpJVXpJMU5pSjkiLCJkYXRhIjoiZXlKamNtVmhkR1ZmWkdGMFpTSTZJakl3TWpNdE1Ea3RNamxVTURFNk1UazZNVEVpTENKMWMyVnlibUZ0WlNJNkltMTVWWE5sY2lJc0luSnZiR1VpT2lKdGVWSnZiR1VpTENKMllXeHBaRjkxYm5ScGJDSTZJakl3TWpNdE1Ea3RNekJVTURFNk1UazZNVEVpZlE9PSIsInNpZ25hdHVyZSI6ImlHMURtd0NST3RIOUxBZGpSSmdBbzdXc2dUS1FJYytzdzU5VW95T1lFKzQ9In0=" http://localhost:8888/api/test/token
{"token":{"username":"myUser","valid_until":"2023-09-30T01:19:11","create_date":"2023-09-29T01:19:11","role":"myRole"}}
```

**Examples**

/api/test/test.lua - simple GET requuest

```lua
requestHandler = { 
	get = function(r)
		if not r.param.error then
			return {code=0, value="Hello world", params=r.param}                     
		end
		resty_error(r.param.error,"Error result requested")
	end
}
```

```shell
$ curl http://localhost:8888/api/test/test
{"code":0,"params":{},"value":"Hello world"}
$ curl http://localhost:8888/api/test/test/45601
{"params":{"id":45601},"value":"Hello world","code":0}
$ curl http://localhost:8888/api/test/test?error=123
{"error":"Error result requested","error_code":"123"}
```

/api/test/test_method.lua - test for GET and POST methods

```lua
requestHandler = { 
	get = function(r)
		return {r.param}
	end,
	post = function(r)
		return{params=r.param, body=r.data}
	end
}
```

```shell
$ curl http://localhost:8888/api/test/method?name=john
{"name":"john"}
$ curl -X POST http://localhost:8888/api/test/test/333 -d hello=world
{"body":"hello=world","params":{"id":"333"}}
```

/api/test/test_db.lua - database query result test 

```lua
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
```

**Typical 'POC' usage** - lua script 

```lua
local result = { user={ id=33, name="John Doe", salary="12300" } }

local function my_POC_result(data,payload)
    if not payload or payload.role ~= "REPORTER" then
        return _, "Invalid role"
    elseif data.id < 100 then
        return _, "User not found"
    end
	return result
end

local function my_POC_byid(param)
	if tonumber(param.id) ~= 33 then
        return _, "User not found"
    end
	return result
end

requestHandler = {}

requestHandler.post = function(r)
    local res, err = my_POC_result(r.data,r.token)
    if res then
        return { result = res }                      
    end
    resty_error(99,err)	
end

requestHandler.get = function(r)
    local res, err = my_POC_byid(r.param)
    if res then
        return { result = res }                      
    end
    resty_error(99,err)	
end
```





