module FileSetAttachedEventJobPrepends
  def action
    if repo_object.kind_of?(FileSet)
      pre_ingest_work_id = Zizia::PreIngestWork.find_by(deduplication_key: curation_concern.deduplication_key)
      pre_ingest_file = Zizia::PreIngestFile.find_by(size: repo_object.files.first.size,
                                                     filename: repo_object.files.first.original_name,
                                                     pre_ingest_work_id: pre_ingest_work_id)
      pre_ingest_file.status = 'attached'
      pre_ingest_file.save
    end
  end
end
