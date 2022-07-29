#!/usr/bin/env ruby
# encoding: utf-8

require 'net/http'
require 'json'
require 'uri'
require 'base64'
require 'open-uri'
require 'dotenv'
require 'resolv-replace'
Dotenv.load('.env')

#Get vars from .env file
api_key = ENV["API_KEY"]
user = ENV["USER"]

#Require for url encoding
require 'erb'
include ERB::Util

#Get last last.fm scrobble
def last_scrobble(api_key,user)

  uri = URI.parse("http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=#{user}&api_key=#{api_key}&format=json")
  request = Net::HTTP::Get.new(uri)

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  #Only parse json if a 200 response, otherwise set to default status
  case response.code
  when "200"
    #Return current track json blob
    current_track_json = JSON.parse(response.body)
    artist = current_track_json["recenttracks"]["track"][0]["artist"]["#text"]
    track = current_track_json["recenttracks"]["track"][0]["name"]
    album = current_track_json["recenttracks"]["track"][0]["album"]["#text"]

  else
    #Default status if nothing is playing
    current_track = "Nothing currently playing"
    track="Nothing"
    artist="currently"
    album ="playing"
  end

  return artist,album,track
end

#Run endlessly checking track every 5 minutes and setting status
#Start with current_status nil to always fetch current playing track on first run
current_status = nil
begin
  #Build status
  artist,album,track = last_scrobble(api_key,user)

  # Ansi color code variables
  black="\e[30m"
  blue="\e[34m"
  cyan="\e[36m"
  grey="\e[30;1m"
  green="\e[32m"
  magenta="\e[35m"
  red="\e[31m"
  white="\e[37m"
  yellow="\e[33m"
  reset="\e[0m"

  puts "#{grey}#{track}#{reset}"
  puts "#{cyan}#{artist}#{reset} - #{magenta}#{album}#{reset}"
end
