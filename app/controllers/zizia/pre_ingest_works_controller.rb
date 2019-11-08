# frozen_string_literal: true

module Zizia
  class PreIngestWorksController < ::ApplicationController
    before_action :merge_abilities
    load_and_authorize_resource

    def thumbnails
      pre_ingest_work = Zizia::PreIngestWork.where(deduplication_key: pre_ingest_works_params[:deduplication_key]).first

      @thumbnails = if pre_ingest_work
                      pre_ingest_work.thumbnails
                    else
                      []
                    end

      respond_to do |format|
        format.json { render json: { thumbnails: @thumbnails } }
      end
    end

    private

      def pre_ingest_works_params
        params.permit(:deduplication_key, :format)
      end

      def merge_abilities
        current_ability.merge(Zizia::Ability.new(current_user))
      end
  end
end
