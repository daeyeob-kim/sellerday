class PoizonCredential < ApplicationRecord
  def expired?
    expires_at.nil? || expires_at <= Time.current
  end

  def refresh!
    return false unless refresh_token.present?

    # Call the service to get a new access token using the refresh token
    token_data = PoizonAuthService.refresh_access_token(refresh_token)

    if token_data && token_data[:access_token].present?
      update(
        access_token: token_data[:access_token],
        refresh_token: token_data[:refresh_token], # Refresh token might change or stay the same
        expires_at: Time.at(token_data[:created_at] + token_data[:expires_in])
      )
      true
    else
      false
    end
  end
end