require "bcrypt"


get '/login' do
	@usernames = sql("SELECT Username, PWHash, Name, Surname FROM User;")

	@@backroute = "/"
	erb :login
end


post '/login' do
	username = params[:username]
	pw = params[:pw]


    if username == "" || pw == "" then
        redirect to("/login")
    end

    user = query_user(username)
    if user == nil then
        redirect to("/login")
    end

    if not valid_password?(pw, user["PWHash"]) then
        redirect to("/login")
    end

    login(user)
end


get '/login/failed' do

	@@backroute = "/login"
	erb :loginfailed
end


get "/logout" do
    logout
end





get "/signup" do
    erb :signup
end

post "/signup" do
	if params[:username] == "" || params[:password] == "" then
		redirect to ("/signup")
	end

	if params[:password] != params[:confirmation] then
		redirect to("/signup")
	end

	user = query_user(params[:username])
	if user == nil then
		user = { "Username" => params[:username] }
	else
		redirect to("/signup")
	end

	user["Name"] = "A"
	user["Surname"] = "B"
	user["DateOfBirth"] = "01-01-1900"


	user["PWHash"] = password_hash(params[:password])
	insert_user(user["Username"], user["PWHash"], user["Name"], user["Surname"], user["DateOfBirth"])
	
	user = query_user(user["Username"])
	
	login(user)
end








enable :sessions
set :session_secret, "ja ist mir eigentlich ziemlich latz"

def password_hash(password)
    BCrypt::Password.create(password).to_s
end

def valid_password?(password, hash)
    BCrypt::Password.new(hash) == password
end

def current_user
    session[:current_user]
end

def logged_in?
    current_user != nil
end

set(:login) do |required|
    condition do
        if required and not logged_in? then
            session[:original_request] = request.path_info
            redirect to("/login")
        end
    end
end

def login(user)
    session[:current_user] = user
    original_request = session[:original_request]
    session[:original_request] = nil
    redirect to(original_request || "/")
end

def logout
    session[:current_user] = nil
    redirect to("/")
end







def query_user(name)
	benutzer = sql "SELECT * FROM User WHERE Username='" + name + "' LIMIT 1;"
	if benutzer.size != 1 then
	    return nil
	else
	    return benutzer[0]
	end
end

def query_user_by_id(id)
	benutzer = sql "SELECT * FROM User WHERE ID='" + id.to_s + "' LIMIT 1;"
	if benutzer.size != 1 then
		return nil
	else
	    return benutzer[0]
	end
end

def insert_user(username, hash, name, surname, bday)
	sql ("INSERT INTO User (Username, PWHash, Name, Surname, DateOfBirth) VALUES ('#{username}','#{hash}', '#{name}', '#{surname}', '#{bday}');")
end