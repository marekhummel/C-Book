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




# Returns the full name of an user
def get_fullname(user, short)
	if (short && user["ID"] == current_user()["ID"]) then
		return "Du"
	end

    return user["Name"] + " " + user["Surname"]
end

# Checks whether the given user is an admin
def is_admin?(user)
    return user["IsAdmin"] != 0
end



# Formats the timespan defined by two datetimes
def format_duration_datetimes(starttime, endtime) 
    if (starttime.full_date == endtime.full_date)
        return starttime.full_date + ", " + starttime.full_time + " - " + endtime.full_time
    end

    return starttime.format! + "  -  " + endtime.format!
end
