# frozen_string_literal: true

class MessengerDeliverJob < ActiveJob::Base
  queue_as :default

  def perform(url, params)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'

    # Forzamos la serialización a JSON estricto
    payload = params.to_json
    request.body = payload

    # Dejamos un log para ver exactamente qué salió
    Rails.logger.error ">>> ENVIANDO A ROCKETCHAT: #{payload}"

    http.request(request)
  rescue StandardError => e
    Rails.logger.error ">>> ERROR EN MESSENGER: #{e.message}"
  end
end
