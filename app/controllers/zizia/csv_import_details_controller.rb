# frozen_string_literal: true
module Zizia
  class CsvImportDetailsController < ApplicationController
    helper_method :sort_column, :sort_direction
    load_and_authorize_resource
    with_themed_layout 'dashboard'

    def index
      @csv_import_details = Zizia::CsvImportDetail.order(sort_column + ' ' + sort_direction).page csv_import_detail_params[:page]
    end

    def show
      @csv_import_detail = Zizia::CsvImportDetail.find(csv_import_detail_params['id'])
    end

    private

      def sort_column
        Zizia::CsvImportDetail.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
      end

      def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
      end

      def csv_import_detail_params
        params.permit(:id, :page, :sort, :direction)
      end
  end
end
