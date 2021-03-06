#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2021-11-13 17:39:58 +0800
require 'rubytools/cubadoo'
require 'apexcharts'
require 'rubytools/string_ext'
require 'csv'
# require "cuba/render"
require 'erb'
WATCHLIST = %w[bitcoin ethereum bitcoin-cash chainlink litecoin ripple uniswap].freeze
# Cuba.plugin Cuba::Render

# configure :development do
  # Cuba.reset!
  # Cuba.use Rack::Reloader
# end

Scooby.class_eval do
  def menu
    WATCHLIST.each do |coin|
      a(href: coin) { coin }
      br
    end
  end
end
Cuba.class_eval do
  def not_found
    res.status=404
    res.write 'hala wala yan!'
  end
  def _layout(&block)
    Scooby.dooby do
      html do
        head do
          meta('http-equiv': 'refresh', content: '60')
          link(rel: 'stylesheet', type: 'text/css', href: '/media/style.css')
          # link(rel: 'stylesheet', type: 'text/css', href: '/css/style.css')
        end
        body do
          div(id: 'content') { block.call }
        end
      end
    end
  end

  def render_coin(coin, q = 1)
    render do
      p do
        p { [coin, q].join('/') }
        if q.to_i == 1
          div(class: 'inline_chart') { File.read("views/#{coin}.html") }
        else
          div(class: 'inline_chart') { File.read("views/#{coin}_7.html") }
          
        end
      end
    end
  end

  def candlestick_data(coin, days)
    filename = "#{coin}_#{days}.csv"
    return [] unless File.exists?(filename)
    data = CSV.read(filename,
                      headers: true,
                      converters: :numeric,
                      header_converters: :symbol)
    data.to_a[1..-1].map do |r|
      [Time.parse(r.first).strftime('%b-%d %H:%M'), r.values_at(1..4).map(&:to_f)]
    end
  end
  def  candlestick_options
    {
        animations: false, # Shortcut for chart: { animations: { enabled: false } }
        # chart: {
        # fontFamily: "Helvetica, Arial, sans-serif",
        # toolbar: {
        # show: false
        # }
        # },
        curve: 'straight', # Shortcut for stroke: { curve: "straight" }
        markers: {
          size: 10
        },
        # tooltip: false, # Shortcut for tooltip: { enabled: false }

        xtitle: 'no title',
        plot_options: {
          candlestick: {
            colors: {
              upward: '#9acd32', # yellow green
              downward: '#8b0000' # darkred
            }
          }
        }
      }
  end
end

include ApexCharts::Helper

Cuba.define do
  on get do
    on 'chart/:coin/:days' do |coin, days|
      plotdata=candlestick_data(coin, days)
      res.redirect '/404' if plotdata.empty?
      v = candlestick_chart(
              plotdata, 
              {class: 'candle', height: 350, style: 'display: inline-block; width: 100%;'}.merge(candlestick_options)
            )
      v.prepend %{<script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>}
      render(use_layout: true) { v }
    end

    on 'hoy' do
      res.write 'hi x!'
    end
    # on 'chainlink' do
    # render_coin('chainlink')
    # end
    # on 'ripple' do
    # render_coin('ripple')
    # end
    on 'crypto/:coin' do |coin|
      render(use_layout: true) do
        div(id: 'chart') do
          iframe(src: "/chart/#{coin}/1") { '' }
          iframe(src: "/chart/#{coin}/7") { '' }
          # iframe(src: "/coin/#{coin}/7") { '' }
        end
      end
    end

    on 'coin/:name/:q' do |name, q|
      # p [name, q]
      render_coin(name, q)
    end

    on root do
      res.redirect 'crypto/uniswap'
    end
    
    on default do
      res.write '<h1>not found</h1>'
    end
    
  end
end
