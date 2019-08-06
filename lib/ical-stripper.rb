# encoding: UTF-8
require 'sinatra'
require 'icalendar'

module ICalStripper
  class Web < Sinatra::Base
    REJECT_HEADERS = ["server", "transfer-encoding","content-security-policy", "strict-transport-security"]

    get '/calendar/**' do
      target_url = ENV['TARGET_URL'] || "http://localhost:8000"
      url = "#{target_url}/calendar#{params['splat'].join('/')}"
      puts "URL #{"*" * 10}: #{url}"
      resp = Faraday.get(url)

      headers resp.headers.select { |k,v| !REJECT_HEADERS.include?(k) }
      status resp.status

      icals = Icalendar::Calendar.parse(resp.body.force_encoding('utf-8'))

      if !!params["busy"]
        icals.each do |cal|
          cal.events.each do |event|
            event.attendee = []
            event.summary = 'busy'
            event.description = ''
            event.location = ''
            event.instance_variable_set("@custom_properties", {})
            event.instance_variable_set("@custom_components", {})
            event.organizer = ''
            event.resources = []
            event.related_to = []
            event.attach = []
            event.categories = []
          end
        end
      end


      icals.map(&:to_ical).join("\n").encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    end
  end
end
