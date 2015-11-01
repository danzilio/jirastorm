require 'jirastorm/stormboard/idea'
require 'jirastorm/stormboard/storm'
require 'rest-client'
require 'json'

module JiraStorm
  module Stormboard
    def self.headers(**params)
      headers = { x_api_key: JiraStorm[:stormboard_key] }
      headers[:params] = params if params
      return headers
    end

    def self.get(endpoint, **params)
      response = RestClient::Request.execute(method: :get, url: "#{JiraStorm[:stormboard_url]}/#{endpoint}", headers: headers(params))
      JSON.load(response.body)
    end

    def self.post(endpoint, **data)
      response = RestClient::Request.execute method: :post, url: "#{JiraStorm[:stormboard_url]}/#{endpoint}", payload: data.to_json, headers: {content_type: :json, accept: :json, x_api_key: JiraStorm[:stormboard_key]}
      JSON.load(response.body)
    end

    def self.put(endpoint, **params)
      response = RestClient::Request.execute(method: :put, url: "#{JiraStorm[:stormboard_url]}/#{endpoint}", headers: headers(params))
      JSON.load(response.body)
    end

    def self.delete(endpoint, **params)
      response = RestClient::Request.execute(method: :delete, url: "#{JiraStorm[:stormboard_url]}/#{endpoint}", headers: headers(params))
      JSON.load(response.body)
    end
  end
end
