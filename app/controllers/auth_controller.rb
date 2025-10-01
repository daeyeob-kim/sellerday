class AuthController < ApplicationController
  def redirect_to_poizon
    redirect_to PoizonAuthService.authorization_url, allow_other_host: true
  end

  def callback
    code = params[:code]
    if code.present?
      token_data = PoizonAuthService.exchange_code_for_token(code)

      # Calculate expires_at based on expires_in
      expires_at = Time.at(token_data[:created_at] + token_data[:expires_in])

      # Destroy existing credentials if any, to ensure only one active credential
      PoizonCredential.destroy_all

      poizon_credential = PoizonCredential.create!(
        access_token: token_data[:access_token],
        refresh_token: token_data[:refresh_token],
        expires_at: expires_at
      )

      flash[:notice] = "Poizon 인증이 성공적으로 완료되었습니다! 토큰이 저장되었습니다."
      redirect_to root_path
    else
      flash[:alert] = "Poizon 인증에 실패했습니다. 코드 없음."
      redirect_to root_path
    end
  end

  def disconnect
    PoizonCredential.destroy_all
    flash[:notice] = "Poizon 연결이 해제되었습니다."
    redirect_to root_path
  end
end
