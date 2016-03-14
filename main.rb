# MAIN ROUTES, PROGRAMM START


require 'sinatra'
require 'sinatra/reloader' if development?

require_relative "db/sql"           # sql connector
require_relative "login_signup"     # login / signup routes
require_relative "helper"           # helper methods
require_relative "sqlcmds"          # sql commands
require_relative "DateTime"         # extended datetime class




# Home
get '/' do
    #Only show main page when not logged in
    if logged_in? then
        @backroute = "/overview"
        redirect to("/overview")
    else
        @backroute = "/"
        erb :home
    end
end




# Overview of all users (admin only)
get '/useroverview' do
    @useroverview = sql("SELECT * FROM User;")

    @backroute = "/"
    erb :useroverview
end



# Overview of all appointments (admin only)
get '/appointmentoverview' do
    @appointmentoverview = sql("SELECT Appointment.Title, User.Name, User.Surname, Appointment.Start, Appointment.End " + 
                               "FROM User, Appointment, UserAppointment " +
                               "WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID;")

    @backroute = "/"
    erb :appointmentoverview    
end





# Account settings
get '/account' do
    erb :account
end














# *****************
# ***  OVERVIEW ***
# ***************** 



# Personal overview for a user
get '/overview' do
    userid = current_user()["ID"].to_i

    @appointments = query_appointments_of_user(userid)

    @backroute = "/overview"
    erb :overview
end














# ************************
# ***  APPOINTMENT NEW ***
# ************************ 



# Add new appointment for the current user
get '/appointment/new' do
 
    # Get an empty appointment
    @app = create_empty_appointment()

    #Get the other users
    @otherusers = sql("SELECT ID, Username, Name, Surname FROM User WHERE Username != '#{current_user()["Username"]}';")
    @contributors = []

    #Set necessary vars
    @headline = "Neues Ereignis"
    @action = "/appointment_new"
    @method = "post"


    @backroute = "/overview"
    erb :appointment_edit
end



# Add the new appointment
post '/appointment_new' do
    #concat params
    title = params[:title]
    startTime = DateTime.new(params[:startyear].to_i, params[:startmonth].to_i, params[:startday].to_i, params[:starthours].to_i, params[:startmins].to_i, params[:startsecs].to_i).to_s
    endTime = DateTime.new(params[:endyear].to_i, params[:endmonth].to_i, params[:endday].to_i, params[:endhours].to_i, params[:endmins].to_i, params[:endsecs].to_i).to_s


    #Get all contributors
    conts = []
    for p in params do
        key = p[0]

        #Only the params starting with "cont-"
        if key.start_with?('cont-') then
            contid = key.split('-')[1].to_i     #take the second half of the string, indicating the id of the contributor
            conts.push(contid)
        end
    end

    #Add appointment
    insert_appointment(title, startTime, endTime, conts)

    #Redirect
    redirect to("/overview")
end
















# ***************************
# ***  APPOINTMENT DETAIL ***
# *************************** 




# Open appointment for editing / deleting and a general better overview
get '/appointment/:id' do
    userid = current_user()["ID"]
    appid = params[:id]

    @appointment = query_appointment(appid)

    # Stop if this appointment doesn't exist
    return if @appointment == nil

    @contributors = sql("SELECT User.Name, User.Surname " +
                        "FROM User, Appointment, UserAppointment " + 
                        "WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID " +
                        "AND Appointment.ID = '#{appid}';")

    ua = sql("SELECT * FROM UserAppointment WHERE UserID = '#{userid}' AND AppointmentID = '#{appid}';")
    @user_is_creator = (ua[0]["UserIsCreator"] != 0) 

    @backroute = "/overview"
    erb :appointment_detail
end










# *************************
# ***  APPOINTMENT EDIT ***
# ************************* 


# Open appointment for editing / deleting and a general better overview
get '/appointment/:id/edit' do
    @appid = params[:id]

    
    # Get appointment
    @app = sql("SELECT * FROM Appointment WHERE ID='#{@appid}' LIMIT 1;")[0]
    @app["Start"] = DateTime.iso8601(@app["Start"])
    @app["End"] = DateTime.iso8601(@app["End"])


    # Get all users and the contrubutors of the appointment
    @otherusers = sql("SELECT ID, Username, Name, Surname FROM User WHERE Username != '#{current_user()["Username"]}';")
    @contributors = sql("SELECT User.ID " +
                        "FROM User, Appointment, UserAppointment " + 
                        "WHERE UserAppointment.UserID = User.ID AND UserAppointment.AppointmentID = Appointment.ID " +
                        "AND Appointment.ID = '#{@appid}';")


    #Set necessary vars
    @headline = "Ereignis bearbeiten"
    @action = "/appointment_edit"
    @method = "put"


    @backroute = "/appointment/" + @appid
    erb :appointment_edit
end




# Delete the selected appointment
delete '/appointment_delete' do

    #Delete
    id = params[:id]
    delete_appointment(id)

    #Redirect
    redirect to("/overview")
end




# Unsubscribe the user from the selected appointment
delete '/appointment_unsubscribe' do

    #Delete
    id = params[:id]
    unsubscribe_user_from_appointment(current_user()["ID"], id)

    #Redirect
    redirect to("/overview")
end




# Edit the selected appointment
put '/appointment_edit' do

    #Edit
    id = params[:id]

    #concat params
    title = params[:title]
    startTime = DateTime.new(params[:startyear].to_i, params[:startmonth].to_i, params[:startday].to_i, params[:starthours].to_i, params[:startmins].to_i, params[:startsecs].to_i).to_s
    endTime = DateTime.new(params[:endyear].to_i, params[:endmonth].to_i, params[:endday].to_i, params[:endhours].to_i, params[:endmins].to_i, params[:endsecs].to_i).to_s

    #Get all contributors
    conts = [current_user()["ID"]]
    for p in params do
        key = p[0]

        if key.start_with?('cont-') then
            contid = key.split('-')[1].to_i
            conts.push(contid)
        end
    end


    #Update
    edit_appointment(id, title, startTime, endTime, conts)

    #Redirect
    redirect to("/overview")
end