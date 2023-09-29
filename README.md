# resty-pos-helper
Openresty minimal rest service for POC

Requirements:
----------------------------------------------------------------
LUA-RESTY-JWT
	opm: 
		opm get SkyLothar/lua-resty-jwt
	luarocks: 
		luarocks install lua-resty-jwt
----------------------------------------------------------------
LUA-RESTY-NETTLE
	opm:
		get bungle/lua-resty-nettle
	luarocks:
		install lua-resty-nettle
	install from source:
		wget https://ftp.gnu.org/gnu/nettle/nettle-3.4.1.tar.gz
		tar -zxf nettle-3.4.1.tar.gz
		cd nettle-3.4.1
		./configure --prefix=/usr --enable-mini-gmp && make
		make install 
----------------------------------------------------------------
