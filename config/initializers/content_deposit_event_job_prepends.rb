module ContentDepositEventJobPrepends
  def action
    super
    if repo_object.deduplication_key
      pre_ingest_work = Zizia::PreIngestWork.find_by(deduplication_key: repo_object.deduplication_key)
      pre_ingest_work.status = 'attached'
      pre_ingest_work.save
    end
  end
end
