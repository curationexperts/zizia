# frozen_string_literal: true
module Zizia
  class CsvImportDetailsController < ApplicationController
    helper_method :sort_column, :sort_direction, :user
    load_and_authorize_resource
    with_themed_layout 'dashboard'

    def index
      @csv_import_details = if csv_import_detail_params[:user] && user_id
                              Zizia::CsvImportDetail
                                .order(sort_column + ' ' + sort_direction)
                                .where(depositor_id: user_id).page csv_import_detail_params[:page]
                            else
                              Zizia::CsvImportDetail
                                .order(sort_column + ' ' + sort_direction).page csv_import_detail_params[:page]
                            end
    end

    def show
      @csv_import_detail = Zizia::CsvImportDetail
                           .find(csv_import_detail_params[:id])
      @pre_ingest_works = Kaminari.paginate_array(@csv_import_detail.pre_ingest_works, total_count: @csv_import_detail.pre_ingest_works.count).page(csv_import_detail_params[:page]).per(10)
    end

    private

      def user_id
        User.find_by(email: csv_import_detail_params[:user]).id
      end

      def sort_column
        Zizia::CsvImportDetail.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
      end

      def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
      end

      def csv_import_detail_params
        params.permit(:id, :page, :sort, :direction, :user)
      end
  end
end
