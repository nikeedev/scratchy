module main
import net.http
// import term
// import time
import json
import os
import zztkm.vdotenv


/// For Authentication
struct User {
mut:
	username  string
	password  string
}
///

struct SessionInfo {
	user struct {
    	id int
    	banned bool
    	username string
    	token string
    	thumbnailUrl string
    	dateJoined string
    	email string
  	}
  	permissions struct {
		admin bool
		scratcher bool
		new_scratcher bool
		invited_scratcher bool
		social bool
		educator bool
		educator_invitee bool
		student bool
	}
	flags struct {
		must_reset_password bool
		must_complete_registration bool
		has_outstanding_email_confirmation bool
		show_welcome bool
		confirm_email_banner bool
		unsupported_browser_banner bool
		project_comments_enabled bool
		gallery_comments_enabled bool
		userprofile_comments_enabled bool
		everything_is_totally_normal bool
	}
}

struct ApiInfo {
    id int
    username string
    scratchteam bool
    history struct {
        joined string
    }
    profile struct {
        id int
        status string
        bio string
        country string
    }
}

fn main() {
	vdotenv.load()
	getusername := os.input("Write your Scratch username: ")
	getpassword := os.input_password("Write your user's password: ")!

	// user := User{username: os.getenv("USERNAMEenv"), password: os.getenv("PASSWORDenv")}
	user := User{username: getusername, password: getpassword}

	mut login_conf := http.FetchConfig{
		url: 'https://scratch.mit.edu/login/'
		data: json.encode(user)
		method: .post
	}

	login_conf.cookies['scratchcsrftoken'] = 'a'

	login_conf.header.add_custom('X-Requested-With', 'XMLHttpRequest') !
    login_conf.header.add_custom('X-CSRFToken', 'a') !
	login_conf.header.add_custom('Referer', 'https://scratch.mit.edu') !
	login_conf.header.add_custom('Cookie', 'scratchcsrftoken=a;') !
	login_conf.header.add_custom('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36') !
	login_conf.header.add_custom('Content-Type', 'application/json') !

	mut sessionid_response := http.fetch(login_conf) !
	// println(sessionid_response)
	os.write_file("login_response.json", sessionid_response.body) !
	my_cookie := sessionid_response.cookies()[0].value
	// println(my_cookie)


	mut status_conf := http.FetchConfig{
		url: "https://scratch.mit.edu/session/",
		data: '',
		method: .get
	}

	status_conf.header.add_custom('cookie', 'scratchsessionsid=${my_cookie};') !
	status_conf.header.add_custom('X-Requested-With', 'XMLHttpRequest') !
	status_conf.header.add_custom('Referer', 'https://scratch.mit.edu/session/') !
	status_conf.header.add_custom('Content-Type', 'application/json') !


	mut session_response := http.fetch(status_conf) !
	// println(session_response.body)
	os.write_file("session_response.json", session_response.body) !
	session := json.decode(SessionInfo, session_response.body) !
	println(session)

	println("\n")
	mut api_conf := http.FetchConfig{
		url: "https://api.scratch.mit.edu/users/${user.username}",
		data: '',
		method: .get
	}

	api_conf.header.add_custom('cookie', 'scratchsessionsid=${my_cookie};') !
	api_conf.header.add_custom('X-Requested-With', 'XMLHttpRequest') !
	api_conf.header.add_custom('Referer', 'https://api.scratch.mit.edu/') !
	api_conf.header.add_custom('Content-Type', 'application/json') !

	mut api_response := http.fetch(api_conf) !
	//println(api_response.body)
	os.write_file("api_response.json", api_response.body) !
	apis := json.decode(ApiInfo, api_response.body) !
	println(apis)
	println("\n\n")
}
