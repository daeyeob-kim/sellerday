class DashboardsController < ApplicationController
  def index
    @products = []
    if poizon_connected?
      product_list_response = PoizonAuthService.get_new_product_list

      if product_list_response[:code] == 200 && product_list_response[:data] && product_list_response[:data][:contents]
        puts "--- Poizon Product List API 요청 성공 ---"
        puts "응답 내용: #{product_list_response.inspect}"
        puts "-------------------------------------"

        @products = product_list_response[:data][:contents].map do |product_data|
          # Extract relevant info from globalSpuInfo and other fields
          spu_info = product_data[:globalSpuInfo] || {}
          {
            id: product_data[:id],
            name: spu_info[:productName] || product_data[:productName], # Use globalSpuInfo's name if available
            brand: spu_info[:brandName],
            status: product_data[:statusDesc],
            article_number: spu_info[:articleNumber] || product_data[:articleNumber]
          }
        end
      else
        flash.now[:alert] = "상품 목록을 가져오는 데 실패했습니다: #{product_list_response[:msg]}"
      end
    else
      flash.now[:alert] = "Poizon에 연결되지 않았습니다. 상품 목록을 보려면 먼저 연결해주세요."
    end
  end
end
