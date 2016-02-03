get '/signin' do
	@usernames = sql("SELECT Username, PWHash, Name, Surname FROM User;")

	@@backroute = "/"
	erb :signin
end


post '/signin' do
	username = params[:username]
	pw = params[:pw]

	dbrow = sql("SELECT * FROM User WHERE Username = '" + username + "';")

	if dbrow.size == 0 then
		redirect to("/signin/failed/")
	else
		id = dbrow[0]["ID"]
		redirect to("/users/#{id}")
	end

end


get '/signin/failed' do

	@@backroute = "/signin"
	erb :signinfailed
end