# frozen_string_literal: true
module Zizia
  class MetadataDetailsController < ::ApplicationController
    with_themed_layout 'dashboard'

    def show
      @details = MetadataDetails.instance.details(work_attributes:
                                                     WorkAttributes.instance)

      @delimiter = Zizia::HyraxBasicMetadataMapper.new.delimiter

      respond_to do |format|
        format.html
        format.json { render json: @details.to_json }
        format.any { redirect_to action: :show }
      end
    end

    def profile
      @csv = MetadataDetails.instance.to_csv(work_attributes:
                                                WorkAttributes.instance)
      send_data @csv, type: 'text/csv', filename: "metadata-profile-#{Date.current}.csv"
    end
  end
end
