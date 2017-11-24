* 카카오톡 플러스친구 연동 (플러스친구 : by)

https://github.com/plusfriend/auto_reply

```ruby
$ rails g controller kakao keyboard message

# routes.rb
Rails.application.routes.draw do
  get 'keyboard' => 'kakao#keyboard'

  post 'message' => 'kakao#message'
  
# kakao_controller.rb
def keyboard
  # keyboard ={
  #   :type => "buttons",
  #   :buttons => ["선택 1", "선택 2", "선택 3"]
  # }

  keyboard = {
    :type => "text"
    }
  render json: keyboard
end
  
def message
  user_msg = params[:content]
  result = {
    "message" => {
      "text" => user_msg
      }
    }

  render json: result
end

```

```ruby
# token 보안 해제
# application_controller.rb
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
end
```



- heroku 배포

  ```ruby
  # gemfile
  # 변경전
  #gem 'sqlite3'
  # 변경후
  gem 'sqlite3', :group => :development
  gem 'pg', :group => :production
  gem 'rails_12factor', :group => :production
  ```

  ```ruby
  # config/database.yml
  # 변경전
  # production:
  #   <<: *default
  #   database: db/production.sqlite3

  # 변경후  
  production:
    <<: *default
    adapter: postgresql
    encoding: unicode
  ```

  ```ruby
  # git을 생성해서 파일을 올려줍니다.
  $ git init
  $ git add .
  $ git commit -m "kakao_bot"

  # 헤로쿠에 로그인해서 앱을 만들어줍니다.
  $ heroku login
  $ heroku create

  # 우리의 프로젝트를 헤로쿠에 디플로이 합니다.
  $ git push heroku master
  ```

  - heroku deploy 후에

    플러스친구 관리자센터에서 스마트채팅들어가서 api형에서 앱url에 "https://hidden-basin-17134.herokuapp.com" 등록 

    ​



* module 생성 (플러스친구 : byby)

  ```ruby
  kby0618:~/workspace $ rails g model user chat_room:integer user_key
  kby0618:~/workspace $ rake db:migrate
  ```

  ```ruby
  # routes.rb
    get 'keyboard' => 'kakao#keyboard'

    post 'message' => 'kakao#message'
    
    post 'friend' => 'kakao#friend_add'
    
    delete 'friend/:user_key' => 'kakao#friend_del'
    
    delete 'chat_room/:user_key' => 'kakao#chat_room'

  # kakao_controller.rb
  require 'nokogiri'
  require 'open-uri'
  require 'msgmaker'
  require 'parser'

  class KakaoController < ApplicationController
    
    @@keyboard = Msgmaker::Keyboard.new
    @@message = Msgmaker::Message.new
    
    def keyboard
      render json: @@keyboard.getBtnKey(["로또","음악","고양이"])
    end

    def message
      basic_keyboard = @@keyboard.getBtnKey(["로또","음악","고양이"])
       
      user_msg = params[:content]
      msg = "기본메세지 입니다."
      
      if user_msg == "로또"
        lotto = (1..45).to_a.sample(6).to_s
        msg ={text: lotto}
      
      elsif user_msg =="음악"
        parse = Parser::Music.new
        msg = @@message.getMessage(parse.melon+[" 좋은 거 같아"," 강추!!"," 들어봐~"].sample)
       
      elsif user_msg =="고양이"
        parse = Parser::Animal.new
        # parse.cat # url을 가지고 있는 객체
        msg = @@message.getPicMessage("나만 고양이없어ㅠ.ㅠ", parse.cat)
        
      else
        msg = "???"
        
      end
      
     
      result = {
          message: msg,
          keyboard: basic_keyboard
      }
      
      render json: result
    end
    
    def friend_add 
      # 새로운 user를 저장해주세요.
      User.create(user_key: params[:user_key], chat_room:0)
     
      render nothing: true
    end
    
    def friend_del
      user = User.find_by(user_key: params[:user_key])
      user.destroy
      render nothing: true
    end
    
    def chat_room
      user = User.find_by(user_key: params[:user_key])
      user.plus
      user.save
      render nothing: true
    end
    
  end

  # helpers/msgmaker.rb
  module Msgmaker
      class Keyboard

          def getTextKey
              
              json = {
                  "type": "text"
              }
              return json
          end
          
          def getBtnKey(*arg)
          
              json = {
                "type": "buttons",
                  "buttons": []
              }
              
              arg.each do |a|
                  json[:buttons] = a
              end
              return json
          end
      end
      
      class Message
      
          def getMessage(text)
              json = {
                  "text": "#{text}"
              }
              return json
          end
          
          def getPicMessage(text,photo_url)
              
              json = {
                  "text": text,
                  "photo": {
                      "url": photo_url,
                      "width": 960,
                      "height": 960
                      
                  }
              }
              
              return json      
          end  
      end 
  end

  # helpers/parser.rb
  require 'nokogiri'
  require 'open-uri'
  require 'rest-client'

  module Parser
      class Music
          def melon
              doc = Nokogiri::HTML(open("http://www.melon.com/chart/index.htm"))    
              music_title = Array.new
        
              doc.css("#lst50 > td:nth-child(6) > div > div > div.ellipsis.rank01 > span > a").each do |title|
               music_title << title.text
              end
        
              return music_title.sample
          end
      end
      
      class Animal
          def cat
              cat_xml = RestClient.get 'http://thecatapi.com/api/images/get?format=xml&type=jpg'
              doc = Nokogiri::XML(cat_xml)
              cat_url = doc.xpath("//url").text
              
              return cat_url
          end
      end
  end

  ```

  ​