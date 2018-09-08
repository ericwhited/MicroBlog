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
        "no account"
    end

end

get '/profile' do
    if !session[:user_id]
        redirect '/'
    else @user =current_user
        erb :profile
    
    end
    

end

get '/all_posts' do
    @post = Post.all.reverse
    erb :all_posts
end

get "/posts/:id" do
    @post = Post.find(params[:id])
    @body = @post.body
    erb :"posts/view_post"
   end

get '/make_a_profile' do
    if !session[:user_id]
        "no session"
    else user = current_user
    erb :make_a_profile
    redirect '/feed'
    end
end

get '/edit_profile' do
    if session[:user_id]
        @user = current_user
        erb :edit_profile
    else 
        redirect '/'
    end
end
get "/posts/:id/edit" do
  @post = Post.find(params[:id])
  erb :"posts/edit_post"
end

put "/posts/:id" do
    @post = Post.find(params[:id])
    @post.update(params[:post])
    redirect "/posts/#{@post.id}"
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

get '/delete_account' do
    @user = current_user
    erb :delete_account
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
    user = User.where(fname: params[:user][:fname]).first
    Profile.create(bio: params[:profile][:bio], location: params[:profile][:location], user_id: user.id)

    redirect '/'

end

# this allows you to submit and edit your profile!
post '/edit_profile' do
    user = current_user
    user.profile.update_attributes(bio: params[:profile][:bio],location: params[:profile][:location])
    redirect '/feed'
end
# edit a post
post "/posts/:id" do
    @post = Post.find(params[:id])
    @post.update(params[:post])
    redirect "/posts/#{@post.id}"
  end
  post "/posts/:id/delete" do
    @post = Post.find(params[:id])
    @post.destroy
    redirect "/posts"
  end

post '/delete_account' do
    user = current_user
    Profile.where(user_id: user.id).destroy_all
    User.delete(user.id)
    "User delted"
end

def current_user
    if session[:user_id]
        User.find(session[:user_id])
    end
end