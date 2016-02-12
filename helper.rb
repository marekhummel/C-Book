enable :sessions
set :session_secret, "ja ist mir eigentlich ziemlich latz"

def password_hash(password)
    return BCrypt::Password.create(password).to_s
end

def valid_password?(password, hash)
    return BCrypt::Password.new(hash) == password
end

def current_user
    return session[:current_user]
end

def logged_in?
    return current_user != nil
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
    redirect to(original_request || "/overview")
end

def logout
    session[:current_user] = nil
    redirect to("/")
end
