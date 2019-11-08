var Zizia = {
  displayUploadedFile: function () {
    var DisplayUploadedFile = require('zizia/DisplayUploadedFile')
    new DisplayUploadedFile().display()
  },
  checkStatuses: function (options) {
    var results = []
    // Go through the list of thumbnails for the work based
    // on the deduplicationKey
    options.thumbnails.forEach(function (thumbnail) {
      $.ajax({
        type: 'HEAD',
        url: thumbnail,
        complete: function (xhr) {
          // Request only the headers from the thumbnail url
          // push the statuses into an array
          results.push(xhr.getResponseHeader('status'))
          // See how many urls are not returning 200
          var missingThumbnailCount = results.filter(
            function (status) {
              if (status !== '200 OK') { return true }
            }).length
          // If there are any not returning 200, the work is still being processed
          if (missingThumbnailCount > 0) {

          } else {
            Zizia.addSuccessClasses(options)
          }
        }
      })
    })
  },
  displayWorkStatus: function () {
    $('[id^=work-status]').each(function () {
	    var deduplicationKey = $(this)[0].id.split('work-status-')[1]
	    $.get('/pre_ingest_works/thumbnails/' + deduplicationKey, function (data) {
        data.deduplicationKey = deduplicationKey
        Zizia.checkStatuses(data)
      })
    })
  },
  addSuccessClasses: function (options) {
    $('#work-status-' + options.deduplicationKey + ' > span').removeClass('status-unknown')
    $('#work-status-' + options.deduplicationKey + ' > span').removeClass('glyphicon-question-sign')
    $('#work-status-' + options.deduplicationKey + ' > span').addClass('text-success')
    $('#work-status-' + options.deduplicationKey + ' > span').addClass('glyphicon-ok-sign')
  }
}
