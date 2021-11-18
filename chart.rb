#!/usr/bin/env ruby
# Id$ nonnax 2021-11-13 17:39:58 +0800
require 'cubadoo'
# require "cuba/render"
# require "erb"
WATCHLIST=%w[bitcoin ethereum bitcoin-cash chainlink litecoin ripple uniswap]
# Cuba.plugin Cuba::Render
Scooby.class_eval do
  def menu
      WATCHLIST.each do |coin|
        a( href: coin ){coin}
        br
      end
  end
end
Cuba.class_eval do
  def render_coin(coin)
      render do
        html do
          head do
            meta( 'http-equiv': "refresh", content: "60")
            link( rel: "stylesheet", href:"/media/styles.css")
          end
          body do
            div(class: 'inline_menu') do
              menu 
            end
            p do
              h2{ coin}
              div(class: 'inline_chart'){ File.read("views/#{coin}.html") }
              div(class: 'inline_chart'){ File.read("views/#{coin}_7.html")}          
            end
          end
        end
      end
  end
end

Cuba.define do  
  on get do
    on 'bitcoin' do
      render_coin('bitcoin')
    end
    on 'ethereum' do
      render_coin('ethereum')
    end
    on 'bitcoin-cash' do
      render_coin('bitcoin-cash')
    end
    on 'litecoin' do
      render_coin('litecoin')
    end
    on 'chainlink' do
      render_coin('chainlink')
    end
    on 'ripple' do
      render_coin('ripple') 
    end
    on 'uniswap' do
      render_coin('uniswap') 
    end
    on root do      
      res.redirect 'litecoin'
    end 
  end
end
