require 'sinatra'
require 'sinatra/activerecord'
require 'bundler/setup'
require 'sinatra/flash'
require './models/user.rb'
require './models/post.rb'
require './models/profile.rb'

# set database: "sqlite3:testapp_signin.sqlite3"

enable :sessions

configure(:development){set :database, "sqlite3:testapp_signin.sqlite3"}


get '/' do 


    if session[:user_id]
        redirect '/feed'
    else
    erb :home
    end
end

get '/register' do
    erb :register
end
    

get '/feed' do
    if session[:user_id]
        @user = current_user
    erb :feed
    else 
        redirect '/'
    end

end

get '/profile' do
    if !session[:user_id]
        redirect '/'
    else @user =current_user
        erb :profile
    
    end
    

end

get '/posts' do
    @current_user = current_user
    erb :posts
end

get '/all_posts' do
    @post = Post.all.reverse
    erb :all_posts
end

post '/sign-in' do
    user = User.where(email: params[:email]).first

    if user && user.password == params[:password]
        session[:user_id] = user.id
        flash[:success] = "You have successfully logged in!"
        redirect '/feed'

    else
        flash[:error] = 'Invalid email or password'
        redirect '/'
    end
end

get '/sign_out' do 
    session[:user_id] = nil
    redirect '/'
end


post '/blog' do 

    if params[:post][:body].length > 0
        posted_at = Time.now
        user = current_user
        Post.create(body: params[:post][:body],posted_at: posted_at, user_id: user.id)
        redirect '/feed'
    end
    
end

post '/register' do
    if params[:user][:password] != params[:confirm_password]
        flash[:error] = "Passwords do not match!"
        redirect '/register'
        return
    end

    User.create(params[:user])
    user = current_user
    Profile.create(bio: params[:profile][:bio],profile: params[:profile][:location], user_id: user.id)

    redirect '/'

end

def current_user
    if session[:user_id]
        User.find(session[:user_id])
    end
end