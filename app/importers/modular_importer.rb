# frozen_string_literal: true

require 'zizia'

class ModularImporter
  DEDUPLICATION_FIELD = 'identifier'

  def initialize(csv_import)
    @csv_import = csv_import
    @csv_file = csv_import.manifest.to_s
    @collection_id = csv_import.fedora_collection_id
    @user_id = csv_import.user_id
    @user_email = User.find(csv_import.user_id).email
    @row = 0 # Row number doesn't seem to be recorded in the mappper -- there is an attribute for it. record.mapper.row_number is always nil
  end

  def import
    raise "Cannot find expected input file #{@csv_file}" unless File.exist?(@csv_file)
    file = File.open(@csv_file)

    @csv_import.save
    csv_import_detail = Zizia::CsvImportDetail.find_or_create_by(csv_import_id: @csv_import.id)
    csv_import_detail.collection_id = @collection_id
    csv_import_detail.depositor_id = @user_id
    csv_import_detail.batch_id = @csv_import.id
    csv_import_detail.deduplication_field = DEDUPLICATION_FIELD
    csv_import_detail.update_actor_stack = @csv_import.update_actor_stack
    csv_import_detail.save!

    attrs = {
      csv_import_detail: csv_import_detail
    }

    Rails.logger.info "[zizia] event: start_import, batch_id: #{@csv_import.id}, collection_id: #{@collection_id}, user: #{@user_email}"
    importer = Zizia::Importer.new(parser: Zizia::CsvParser.new(file: file), record_importer: Zizia::HyraxRecordImporter.new(attributes: attrs))

    importer.records.each do |record|
      pre_ingest_work = Zizia::PreIngestWork.new(csv_import_detail_id: csv_import_detail.id)
      @row += 1

      pre_ingest_file = Zizia::PreIngestFile.new(row_number: @row,
                                                 pre_ingest_work: pre_ingest_work,
                                                 filename: record.mapper.files.first,
                                                 size: File.join(ENV['IMPORT_PATH'], record.mapper.files.first).size)
      pre_ingest_work.save!
      pre_ingest_file.save!
    end
    csv_import_detail.save!
    importer.import
    file.close
  end
end
