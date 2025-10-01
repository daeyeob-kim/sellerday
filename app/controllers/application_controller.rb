class ApplicationController < ActionController::Base
  helper_method :poizon_connected?

  private

  def poizon_connected?
    PoizonCredential.exists?
  end
end