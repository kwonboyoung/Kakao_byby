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
