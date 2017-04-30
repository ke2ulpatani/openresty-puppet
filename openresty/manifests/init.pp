class openresty {
	
	$dependency = [ 'libreadline-dev', 'libncurses5-dev', 'libpcre3-dev', 'libssl-dev', 'perl', 'make', 'build-essential', 'curl' ]

	$pathVar = [ '/usr/bin', '/usr/sbin', '/usr/lib', '/bin' ]

	if $osfamily != 'Debian' {
	 exec { 'apt-update':
				command => '/usr/bin/yum -y -q update',
				user => root
			}
	}
	else {
	 exec { 'apt-update':
				command => '/usr/bin/apt-get update -y',
				user => root
			}
	}

	package { $dependency: 
			require => Exec['apt-update'],
			ensure => 'installed'
	} ->

	exec { 'openresty-src':
		command => 'wget https://openresty.org/download/openresty-1.11.2.3.tar.gz',
		path => $pathVar,
		cwd => '/tmp/'
	} ->

	exec { 'untar-src':
		  cwd     => '/tmp/',
		  path    => $pathVar,
		  command => 'tar -zxf openresty-1.11.2.3.tar.gz'
	} ->

	exec { 'configure-openresty':
	      cwd => '/tmp/openresty-1.11.2.3',
	      user => 'root',
		  command => '/tmp/openresty-1.11.2.3/configure --with-pcre --with-pcre-jit --with-luajit --without-http_echo_module --without-http_xss_module --without-http_coolkit_module --without-http_set_misc_module --without-http_form_input_module --without-http_encrypted_session_module --without-http_srcache_module --without-http_lua_module --without-http_lua_upstream_module --without-http_headers_more_module --without-http_array_var_module --without-http_memc_module --without-http_redis2_module --without-http_redis_module --without-http_rds_json_module --without-http_rds_csv_module --without-ngx_devel_kit_module --without-lua_cjson --without-lua_redis_parser --without-lua_rds_parser --without-lua_resty_dns --without-lua_resty_memcached --without-lua_resty_redis --without-lua_resty_mysql --without-lua_resty_upload --without-lua_resty_upstream_healthcheck --without-lua_resty_string --without-lua_resty_websocket --without-lua_resty_limit_traffic --without-lua_resty_lock --without-lua_resty_lrucache --without-lua_resty_core --without-select_module --without-poll_module --without-http_charset_module --without-http_gzip_module --without-http_ssi_module --without-http_access_module --without-http_auth_basic_module --without-http_autoindex_module --without-http_geo_module --without-http_map_module --without-http_rewrite_module --without-http_split_clients_module --without-http_referer_module --without-http_proxy_module --without-http_fastcgi_module --without-http_uwsgi_module --without-http_scgi_module --without-http_memcached_module --without-http_limit_conn_module --without-http_limit_req_module --without-http_empty_gif_module --without-http_browser_module --without-http_upstream_hash_module --without-http_upstream_ip_hash_module --without-http_upstream_least_conn_module --without-http_upstream_keepalive_module --without-http_upstream_zone_module --without-http --without-http-cache --without-mail_pop3_module --without-mail_imap_module   --without-stream_access_module --without-stream_map_module --without-stream_return_module --without-stream_upstream_hash_module --without-stream_upstream_least_conn_module --without-stream_upstream_zone_module'
	} ->

	exec { 'make':
		 cwd => '/tmp/openresty-1.11.2.3',
		 path => $pathVar,
		 command => 'make',
		 user => root
	} ->

	exec { 'make-install':
	      cwd => '/tmp/openresty-1.11.2.3',
		  path => $pathVar,		
		  command => 'make install',
		  user => root
	} ->

	exec { 'export-path':
	  command => "/bin/bash -c 'export PATH=/usr/local/openresty/bin:/usr/local/openresty/nginx/sbin:$PATH'",
	} ->

	file { 'export-path-profile':
	    path => '/etc/profile.d/append-openresty-path.sh',
	    ensure => 'present',
	    mode    => '644',
	    content => 'PATH=$PATH:/usr/local/openresty/bin:/usr/local/openresty/nginx/sbin'
	}

}