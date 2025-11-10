#! /usr/bin/env ruby

require 'net/http'
require 'json'
require 'uri'

# Fetch the JSON data from the URL
url = URI('https://abnib.co.uk/today.json')
response = Net::HTTP.get(url)
birthdays = JSON.parse(response)

# Retrieve environment variables
whapi_token = ENV['WHAPI_CLOUD_TOKEN']
whapi_newsletter_id = ENV['WHAPI_CLOUD_NEWSLETTER_ID']

# Validate environment variables
if whapi_token.nil? || whapi_token.empty?
  puts "Error: WHAPI_CLOUD_TOKEN environment variable is not set"
  exit 1
end

if whapi_newsletter_id.nil? || whapi_newsletter_id.empty?
  puts "Error: WHAPI_CLOUD_NEWSLETTER_ID environment variable is not set"
  exit 1
end

# Define the Whapi API endpoint
whapi_url = URI('https://gate.whapi.cloud/messages/text')

# Iterate over each birthday entry and send a WhatsApp message
birthdays.each do |birthday|
  message_body = birthday['desc']

  # Prepare the HTTP request
  http = Net::HTTP.new(whapi_url.host, whapi_url.port)
  http.use_ssl = true
  request = Net::HTTP::Post.new(whapi_url)
  request['Accept'] = 'application/json'
  request['Content-Type'] = 'application/json'
  request['Authorization'] = "Bearer #{whapi_token}"
  request.body = {
    to: whapi_newsletter_id,
    body: message_body
  }.to_json

  # Send the request
  response = http.request(request)

  # Output the response status
  if response.code.to_i >= 200 && response.code.to_i < 300
    puts "✓ Sent message: '#{message_body}' - Response: #{response.code} #{response.message}"
  else
    puts "✗ Failed to send message: '#{message_body}' - Response: #{response.code} #{response.message}"
    puts "  Response body: #{response.body}"
  end
end
