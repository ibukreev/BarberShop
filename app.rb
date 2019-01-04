#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'pony' 



get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School!!!</a>"			
end

get '/about' do
	erb :about 
end 

get '/visit' do 
	erb :visit
end 

get '/contacts' do 
	erb :contacts 
end 

post '/visit' do
	@username      = params[:username] 
	@phone	       = params[:phone]
	@datetime      = params[:datetime]
	@pick_a_barber = params[:pick_a_barber]
	@color 		   = params[:colorpicker]
	
	hh = { :username => 'Введите имя',
		   :phone => 'Введите номер телефона',
		   :datetime => 'Введите дату и время' }

	# Первый вариант вызова ошибки
	#hh.each do |key, value|
	#	if params[key] == ''
	#		@error = hh[key]
	#		return erb :visit
	#	end
	#end

	#Второй вариант валидации
	@error = hh.select {|key, _| params[key] == ""}.values.join(", ")
	
	if @error != ''
		return erb :visit
	end

	#f = File.open './public/users.txt', 'a'
    #f.write "Клиент: #{@username}, Контакт: #{@phone}, Время и дата: #{@datetime}, Парикмахер: #{@pick_a_barber}, Цвет: #{@color}\n"
    #f.close

	#erb :visit
	erb "Ok! Клиент: #{@username}, Контакт: #{@phone}, Время и дата: #{@datetime}, Парикмахер: #{@pick_a_barber}, Цвет: #{@color}\n"
end 

post '/contacts' do 
	@name 	 = params[:name]
	@mail 	 = params[:mail]
	@message = params[:message]

	Pony.mail(
      :from => @name + "<" + @mail + ">",
      :to => 'bukreewitaliy@gmail.com',
      :subject => @name + " от барбершопа",
      :body => @message,
      :via => :smtp,
      :via_options => { 
        :address              => 'smtp.gmail.com', 
        :port                 => '587', 
        :user_name            => 'bukreewitaliy@gmail.com', 
        :password             => 'pvot vuwj cdvw plbo', 
        :authentication       => :plain, 
        :domain               => 'localhost.localdomain'
      })
	
	# Валидация
	aa = { :name => 'Введите имя',
		   :mail => 'Введите свою почту',
		   :message => 'Введите сообщение' }
	
	@error = aa.select {|key, _| params[key] == ""}.values.join(", ")
	
	if @error != ''
		return erb :contacts
	end

	erb :contacts
end