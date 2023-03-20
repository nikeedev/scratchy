module main
import net.http
import term
import time
import json
import os
import zztkm.vdotenv

struct MyCookie {
mut:
	cookie http.Cookie
}

/// For Authentication
struct User {
mut:
	username  string
	password  string
}
///


fn main() {
	vdotenv.load()

	my_cookie = MyCookie{}
	user := User{username: os.getenv("USERNAMEenv"), password: os.getenv("PASSWORDenv")}

	mut conf := http.FetchConfig{
		url: 'https://scratch.mit.edu/login/'
		data: json.encode(user)
		method: .po
	}
	conf.cookies['scratchcsrftoken'] = 'a'

	conf.header.add_custom('X-Requested-With', 'XMLHttpRequest') !
    conf.header.add_custom('X-CSRFToken', 'a') !
	conf.header.add_custom('Referer', 'https://scratch.mit.edu') !
	// conf.header.add_custom('Cookie', 'scratchcsrftoken=a;') !
	conf.header.add_custom('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36') !
	conf.header.add_custom('Content-Type', 'application/json') !

	mut response := http.fetch(conf) !
	println(response)
	os.write_file("reponse.log", response.body) !
	my_cookie.cookie = response.cookies()[0]
	println(my_cookie.cookie.value)

}
