define [
  'backbone',
  'youtube.sync.model',
  'underscore',
  'jquery'
], (Backbone, SyncModel, _, $) ->
  EditSongModel = Backbone.Model.extend(

    initialize: () ->
      this.syncModel = new SyncModel()

      this.getSong()
      #this.getDictionary()

    getSong: () ->
      $.ajax(
        type: 'GET'
        url: '/api/songs/' + this.get('id')
        dataType: 'json'
        success: (song) =>
          this.set(
            data: song
          )
          this.trigger('change')
          this.syncModel.set(
            currentSong: song
          )
        error: (err) =>
          console.log('Error: ' + err)
      )

    saveSubtitles: (subtitlesText) ->
      subtitles = []

      if subtitlesText and subtitlesText.length > 0
        lines = subtitlesText.split('\n')
        ts = 0
        for line in lines
          subtitle =
            text: line
            ts: ts
          subtitles.push(subtitle)
          ts += 1500

      song = this.get('data')
      song.subtitles = subtitles

      success = () =>
        this.trigger('change')
      this.saveSong(song, success)

    saveSync: () ->
      subtitles = this.syncModel.get('currentSong').subtitles
      song = this.get('data')
      song.subtitles = subtitles
      success = () =>
        this.trigger('change')
      this.saveSong(song, success)

    saveTranslation: (translationText) ->
      translation = translationText?.split('\n')
      song = this.get('data')
      if song.translations?.length > 0
        song.translations[0].data = translation
      else
        firstTranslation =
          language: this.get('settings').get('toLanguage').language
          data: translation
        song.translations = [firstTranslation]

      success = () =>
        this.trigger('change')
      this.saveSong(song, success)

    saveSong: (song, success) ->
      console.log(JSON.stringify(song))
      $.ajax(
        type: 'PUT'
        url: '/api/songs/' + this.get('id')
        data:
          song: song
        success: (res) =>
          #this.getSong()
          success?()
        error: (err) =>
          console.log('Error: ' + err)
      )

  )

  return EditSongModel
