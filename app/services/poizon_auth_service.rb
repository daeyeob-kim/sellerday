require 'uri'
require 'json'
require 'securerandom'
require 'digest' # For MD5 hashing
require 'httparty' # For making HTTP requests

class PoizonAuthService
  CLIENT_ID = ENV['POIZON_CLIENT_ID'] # Read from environment variable
  CLIENT_SECRET = ENV['POIZON_CLIENT_SECRET'] # Read from environment variable
  REDIRECT_URI = ENV['POIZON_REDIRECT_URI'] # Read from environment variable
  TOKEN_URL = 'https://open.poizon.com/api/v1/h5/passport/v1/oauth2/token'
  REFRESH_TOKEN_URL = 'https://open.poizon.com/api/v1/h5/passport/v1/oauth2/refresh_token'
  GET_PRODUCT_LIST_URL = 'https://open.poizon.com/dop/api/v1/pop/api/v1/merchant/new/product/getList'

  def self.authorization_url
    params = {
      response_type: 'code',
      client_id: CLIENT_ID,
      redirect_uri: REDIRECT_URI,
      scope: 'all'
    }
    "https://open.poizon.com/authorize?#{URI.encode_www_form(params)}"
  end

  def self.exchange_code_for_token(code)
    # Real API call
    response = HTTParty.post(TOKEN_URL, body: {
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      authorization_code: code
    }.to_json, headers: { 'Content-Type' => 'application/json' })

    puts "요청"
    if response.success?
      puts response.inspect
      parsed_response = response.parsed_response
      { # Convert string keys to symbol keys
        access_token: parsed_response['data']['accessToken'],
        refresh_token: parsed_response['data']['refreshToken'],
        expires_in: parsed_response['data']['expiresIn'],
        token_type: parsed_response['data']['tokenType'],
        scope: parsed_response['data']['scope'],
        created_at: Time.now.to_i
      }
    else
      puts "요청 실패"
      Rails.logger.error "Poizon token exchange failed: #{response.code} - #{response.body}"
      { error: "Token exchange failed", details: response.body }
    end
  end

  def self.refresh_access_token(refresh_token)
    # Real API call
    response = HTTParty.post(REFRESH_TOKEN_URL, body: {
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      refresh_token: refresh_token
    }.to_json, headers: { 'Content-Type' => 'application/json' })

    if response.success?
      parsed_response = response.parsed_response
      { # Convert string keys to symbol keys
        access_token: parsed_response['data']['accessToken'],
        refresh_token: parsed_response['data']['refreshToken'],
        expires_in: parsed_response['data']['expiresIn'],
        token_type: parsed_response['data']['tokenType'],
        scope: parsed_response['data']['scope'],
        created_at: Time.now.to_i
      }
    else
      Rails.logger.error "Poizon token refresh failed: #{response.code} - #{response.body}"
      { error: "Token refresh failed", details: response.body }
    end
  end

  def self.get_new_product_list(business_params = {})
    poizon_credential = PoizonCredential.last # Assuming one credential for now
    return { error: "Poizon credentials not found." } unless poizon_credential

    # General parameters
    general_params = {
      app_key: CLIENT_ID,
      access_token: poizon_credential.access_token,
      timestamp: (Time.now.to_f * 1000).to_i, # Milliseconds
      language: 'ko', # Assuming Korean for now
      timeZone: 'Asia/Seoul' # Assuming Seoul for now
    }

    all_params = general_params.merge(business_params)

    # Generate real sign
    all_params[:sign] = generate_sign(all_params, CLIENT_SECRET)

    # Construct the URL with all parameters
    uri = URI(GET_PRODUCT_LIST_URL)
    uri.query = URI.encode_www_form(all_params)

    # Real API call
    response = HTTParty.get(uri.to_s)

    if response.success?
      parsed_response = response.parsed_response
      # Convert string keys to symbol keys for consistency with controller
      parsed_response.deep_symbolize_keys
    else
      Rails.logger.error "Poizon get_new_product_list failed: #{response.code} - #{response.body}"
      { error: "Failed to get product list", details: response.body }
    end
  end

  private

  def self.generate_sign(params, app_secret)
    # 1. Construct Initial JSON Object (already done by merging params)
    # 2. Sort Parameters
    # Ensure keys are strings for consistent sorting and URL encoding
    string_keys_params = params.transform_keys(&:to_s)
    sorted_params = string_keys_params.sort_by { |k, _| k }.to_h

    # 3. Create stringA
    string_a_parts = []
    sorted_params.each do |key, value|
      # Only include non-empty values
      next if value.nil? || (value.respond_to?(:empty?) && value.empty?)

      # Handle JSON array values
      formatted_value = if value.is_a?(Array)
                          value.to_json # Convert array to JSON string
                        else
                          value.to_s
                        end
      string_a_parts << "#{key}=#{URI.encode_www_form_component(formatted_value)}"
    end
    string_a = string_a_parts.join('&')

    # 4. Create stringSignTemp
    string_sign_temp = string_a + app_secret

    # 5. Calculate MD5 Hash
    md5_hash = Digest::MD5.hexdigest(string_sign_temp)

    # 6. Convert to Uppercase
    md5_hash.upcase
  end
end
