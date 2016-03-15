# LOGIN AND SIGNUP ROUTES

require "bcrypt"


# LOGIN 
get '/login' do
    @backroute = "/"
    erb :login
end

# LOGIN POST
post '/login' do
    username = params[:username]
    pw = params[:pw]


    #Username or password not set
    if username == "" || pw == "" then
        redirect to("/login")
    end

    #Username unknown
    user = query_user(username)
    if user == nil then
        redirect to("/login")
    end

    #Invalid password
    if not valid_password?(pw, user["PWHash"]) then
        redirect to("/login")
    end

    login(user)
end


# LOGOUT
get "/logout" do
    logout()

    redirect to("/login")
end



# SIGNUP POST
post "/signup" do
    #Any field is empty
    if params[:username] == "" || params[:password] == "" || params[:name] == "" || params[:surname] == "" then
        redirect to ("/")
    end

    #Confirmation differs from password
    if params[:password] != params[:confirmation] then
        redirect to("/")
    end

    #Username already exists
    user = query_user(params[:username])
    if user != nil then
        redirect to("/")
    end

    #Insert user in db
    bday = DateTime.new(params[:bday_year].to_i, params[:bday_month].to_i, params[:bday_day].to_i).to_s
    insert_user(params[:username], password_hash(params[:password]), params[:name], params[:surname], bday)
    
    #Save user in file
    File.open("EXTRAS/users.txt", "a+") { |f| f.write("#{params[:username]}|#{params[:password]}\r\n")  }

    #Log In
    user = query_user(params[:username])
    login(user)
end