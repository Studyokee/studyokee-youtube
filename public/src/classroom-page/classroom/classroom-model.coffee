define [
  'media.item.list.model',
  'dictionary.model',
  'songs.data.provider',
  'youtube.player.model',
  'subtitles.scroller.model',
  'backbone'
], (MenuModel, DictionaryModel, SongsDataProvider, YoutubePlayerModel, SubtitlesScrollerModel, Backbone) ->
  
  ClassroomModel = Backbone.Model.extend(

    initialize: () ->
      this.dataProvider = new SongsDataProvider(this.get('settings'))

      this.menuModel = new MenuModel(
        settings: this.get('settings')
      )
      this.subtitlesScrollerModel = new SubtitlesScrollerModel(
        settings: this.get('settings')
      )
      this.youtubePlayerModel = new YoutubePlayerModel(
        settings: this.get('settings')
      )
      this.dictionaryModel = new DictionaryModel(
        settings: this.get('settings')
      )

      this.on('change:currentSong', () =>
        this.youtubePlayerModel.set(
          currentSong: this.get('currentSong')
        )

        this.subtitlesScrollerModel.set(
          currentSong: this.get('currentSong')
        )

        this.getSongData(this.get('currentSong')._id)
      )

      this.on('change:songData', () =>
        this.youtubePlayerModel.set(
          songData: this.get('songData')
        )
        this.subtitlesScrollerModel.set(
          songData: this.get('songData')
        )
      )

      this.youtubePlayerModel.on('change:i', () =>
        this.subtitlesScrollerModel.set(
          i: this.youtubePlayerModel.get('i')
        )
      )

      this.on('change:vocabulary', () =>
        this.subtitlesScrollerModel.set(
          vocabulary: this.get('vocabulary')
        )
      )

      this.dictionaryModel.on('vocabularyUpdate', (words) =>
        this.set(
          vocabulary: words
        )
      )

      this.on('change:classroom', () =>
        displayInfos = this.get('displayInfos')
        this.menuModel.set(
          rawData: displayInfos
        )

        title = this.getHash()
        currentSong = this.chooseSongFromInfos(displayInfos, title)

        this.set(
          currentSong: currentSong
        )
      )

      this.getClassroom()
      this.getVocabulary()

    # Given a list of song infos from API and a String
    # Returns the first song unless title given matches title of one of the songs
    chooseSongFromInfos: (infos, title) ->
      if infos?.length > 0
        songIndex = 0
        if title
          for info, index in infos
            if info.song.metadata.trackName is title
              songIndex = index
              break
        return infos[songIndex].song
    
      return null

    # Returns the hash in the url as a String, or null if no hash or empty hash
    getHash: () ->
      if window.location.hash.length > 0
        hash = window.location.hash.substring(1)
        if hash.length > 0
          return hash

      return null

    getClassroom: () ->
      $.ajax(
        type: 'GET'
        url: '/api/classrooms/' + this.get('id')
        dataType: 'json'
        success: (res) =>
          this.set(
            classroom: res.classroom
            displayInfos: res.displayInfos
          )
        error: (err) =>
          console.log('Error fetching classroom data')
      )

    getVocabulary: () ->
      fromLanguage = this.get('settings').get('fromLanguage').language
      toLanguage = this.get('settings').get('toLanguage').language
      $.ajax(
        type: 'GET'
        url: '/api/vocabulary/' + fromLanguage + '/' + toLanguage
        dataType: 'json'
        success: (res) =>
          this.set(
            vocabulary: res?.words
          )
        error: (err) =>
          console.log('Error getting user vocabulary')
      )

    # Retrieve the data for a song, but only update the model if it is the most recent
    # callback to protect when user switches quickly
    getSongData: (id, callback) ->
      if not id?
        return

      this.set(
        lastCallbackId: id
      )

      $.ajax(
        type: 'GET'
        url: '/api/songs/' + id
        dataType: 'json'
        success: (songData) =>
          if songData?._id is this.get('lastCallbackId')
            this.set(
              songData: songData
            )
        error: (err) =>
          console.log('Error fetching song data')
      )
  )

  return ClassroomModel