require 'rails_helper'

RSpec.describe PoizonAuthService, type: :service do
  describe '.authorization_url' do
    it 'generates the correct authorization URL' do
      expected_client_id = '1268a63b0c924c85b402df204eedaf90'
      expected_redirect_uri = 'http://localhost:3000/auth/poizon/callback'
      expected_base_url = 'https://open.poizon.com/authorize'

      url = PoizonAuthService.authorization_url
      uri = URI.parse(url)
      query_params = URI.decode_www_form(uri.query).to_h

      expect(uri.scheme).to eq('https')
      expect(uri.host).to eq('open.poizon.com')
      expect(uri.path).to eq('/authorize')

      expect(query_params['response_type']).to eq('code')
      expect(query_params['client_id']).to eq(expected_client_id)
      expect(query_params['redirect_uri']).to eq(expected_redirect_uri)
      expect(query_params['scope']).to eq('all')
    end
  end

  describe '.exchange_code_for_token' do
    it 'returns a mock access token structure' do
      code = 'mock_auth_code_123'
      token_data = PoizonAuthService.exchange_code_for_token(code)

      expect(token_data).to be_a(Hash)
      expect(token_data).to have_key(:access_token)
      expect(token_data).to have_key(:refresh_token)
      expect(token_data).to have_key(:expires_in)
      expect(token_data).to have_key(:token_type)
      expect(token_data).to have_key(:scope)
      expect(token_data).to have_key(:created_at)

      expect(token_data[:access_token]).to start_with('mock_access_token_')
      expect(token_data[:refresh_token]).to start_with('mock_refresh_token_')
      expect(token_data[:expires_in]).to be_an(Integer)
      expect(token_data[:token_type]).to eq('Bearer')
      expect(token_data[:scope]).to eq('all')
      expect(token_data[:created_at]).to be_an(Integer)
    end
  end
end
