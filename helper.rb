# HELPER METHODS 



enable :sessions
set :session_secret, "ja ist mir eigentlich ziemlich latz"


# Hashes a plain password
def password_hash(password)
    return BCrypt::Password.create(password).to_s
end

# Checks whether a given plain password matches a given hash
def valid_password?(password, hash)
    return BCrypt::Password.new(hash) == password
end

# Returns the current user (hashtable)
def current_user
    return session[:current_user]
end

# Checks whether sb is logged in
def logged_in?
    return current_user != nil
end

# Log in
def login(user)
    session[:current_user] = user
    original_request = session[:original_request]
    session[:original_request] = nil
    redirect to(original_request || "/overview")
end

# Log out
def logout
    session[:current_user] = nil
end


