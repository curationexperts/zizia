# frozen_string_literal: true
module Zizia
  class CsvImportDetailsController < ApplicationController
    load_and_authorize_resource
    with_themed_layout 'dashboard'

    def index
      @csv_import_details = Zizia::CsvImportDetail.order(:id).page csv_import_detail_params[:page]
    end

    def show
      @csv_import_detail = Zizia::CsvImportDetail.find(csv_import_detail_params["id"])
    end

    private

      def csv_import_detail_params
        params.permit(:id, :page)
      end
  end
end
