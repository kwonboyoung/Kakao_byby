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