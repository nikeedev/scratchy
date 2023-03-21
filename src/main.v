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

fn main() {
	vdotenv.load()
	// getusername := os.input("Write your Scratch username: ")
	// getpassword := os.input_password("Write your user's password: ")!

	user := User{username: os.getenv("USERNAMEenv"), password: os.getenv("PASSWORDenv")}
	// user := User{username: getusername, password: getpassword}
	// println(user)

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
	os.write_file("reponse.log", sessionid_response.body) !
	my_cookie := sessionid_response.cookies()[0]
	// println(my_cookie.cookie.value)


	mut status_conf := http.FetchConfig{
		url: "https://scratch.mit.edu/session/",
		data: '',
		method: .get
	}

	status_conf.header.add_custom('cookie', 'scratchsessionsid=${my_cookie};') !
	status_conf.header.add_custom('X-Requested-With', 'XMLHttpRequest') !
	status_conf.header.add_custom('Referer', 'https://scratch.mit.edu/session/') !

	mut session_response := http.fetch(status_conf) !
	println(session_response.body)
	session := json.decode(SessionInfo, session_response.body) !
	println(session)
}
