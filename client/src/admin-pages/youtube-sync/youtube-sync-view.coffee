define [
  'subtitles.controls.view',
  'youtube.sync.subtitles.view',
  'backbone',
  'handlebars',
  'templates'
], (SubtitlesControlsView, YoutubeSubtitlesSyncView, Backbone, Handlebars) ->
  YoutubeSyncView = Backbone.View.extend(
    className: 'youtube-sync'
    
    initialize: () ->
      this.playerId = 'ytPlayerSync'

      this.subtitlesControlsView = new SubtitlesControlsView(
        model: this.model
        allowToggleVideo: true
      )
      this.youtubeSubtitlesSyncView = new YoutubeSubtitlesSyncView(
        model: this.model
      )

      this.subtitlesControlsView.on('hideVideo', () =>
        this.$('.video-container').hide()
      )
      this.subtitlesControlsView.on('showVideo', () =>
        this.$('.video-container').show()
      )

      this.listenTo(this.model, 'change:syncing', () =>
        this.renderSyncButton()
      )

    render: () ->
      this.$el.html(Handlebars.templates['youtube-sync'](this.model.toJSON()))
      this.$('.controls-container').html(this.subtitlesControlsView.render().el)
      this.$('.subtitles-container').html(this.youtubeSubtitlesSyncView.render().el)

      this.$('.toggleSync').on('click', () =>
        if this.model.get('syncing')
          this.model.set(
            syncing: false
          )
        else
          this.model.set(
            syncing: true
          )
      )

      this.renderSyncButton()

      postRender = () =>
        this.postRender()
      setTimeout(postRender)

      return this

    renderSyncButton: (syncing) ->
      toggleSync = this.$('.toggleSync')
      if this.model.get('syncing')
        toggleSync.addClass('btn-primary')
        toggleSync.removeClass('btn-default')
        toggleSync.attr('title', 'Sync Off')
        toggleSync.html('Sync Off')
      else
        toggleSync.removeClass('btn-primary')
        toggleSync.addClass('btn-default')
        toggleSync.attr('title', 'Sync On')
        toggleSync.html('Sync On')

    calculateYTPlayerHeight: () ->
      ytPlayerWidth = this.$('#' + this.playerId).width()
      ytPlayerHeight = ytPlayerWidth * 0.75
      this.$('#' + this.playerId).height(ytPlayerHeight + 'px')

    postRender: () ->
      onReady = () =>
        this.model.set(
          ytPlayerReady: true
        )
        this.model.trigger('change:currentSong')

      onStateChange = (state) =>
        fn = () =>
          this.model.onStateChange(state)
        setTimeout(fn)

      onAPIReady = () =>
        height = this.$el.height()
        width = height * (4/3)
        params =
          height: height
          width: width
          playerVars:
            modestbranding: 1
            fs: 0
            showInfo: 0
            rel: 0
            controls: 0
            # theme: 'light'
            # color: 'white'
          events:
            'onReady': onReady
            'onStateChange': onStateChange
        this.model.ytPlayer = new YT.Player(this.playerId, params)

      if typeof(YT) == 'undefined' || typeof(YT.Player) == 'undefined'
        window.onYouTubeIframeAPIReady = onAPIReady
        $.getScript('//www.youtube.com/iframe_api?noext')
      else
        onAPIReady()
  )

  return YoutubeSyncView