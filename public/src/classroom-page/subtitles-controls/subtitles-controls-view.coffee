define [
  'backbone',
  'handlebars',
  'templates'
], (Backbone, Handlebars) ->

  SubtitlesControlsView = Backbone.View.extend(
    tagName:  "div"
    className: "controls"

    initialize: (options) ->
      this.options = options
      this.listenTo(this.model, 'change:state', () =>
        togglePlayButtonIcon = this.$('.toggle-play .glyphicon')
        if this.model.get('state') is 3
          togglePlayButtonIcon.removeClass('glyphicon-play')
          togglePlayButtonIcon.removeClass('glyphicon-pause')
          togglePlayButtonIcon.addClass('glyphicon-spin')
        else
          if this.model.get('playing')
            togglePlayButtonIcon.removeClass('glyphicon-play')
            togglePlayButtonIcon.removeClass('glyphicon-spin')
            togglePlayButtonIcon.addClass('glyphicon-pause')
            this.updateProgressBar()
          else
            togglePlayButtonIcon.removeClass('glyphicon-pause')
            togglePlayButtonIcon.removeClass('glyphicon-spin')
            togglePlayButtonIcon.addClass('glyphicon-play')
            clearTimeout(this.progressTick)
      )
      this.listenTo(this.model, 'change:currentSong', () =>
        this.$('.progress-bar').width('0%')
      )
      this.listenTo(this.model, 'change:i', () =>
        this.setProgressBar()
      )
      this.listenTo(this.model, 'change:loadingVideo', () =>
        this.render()
      )

      this.onKeyDownEvent = (event) =>
        if $(event.target).is('input')
          return
        this.onKeyDown(event)
      $(window).on('keydown', this.onKeyDownEvent)
      window.subtitlesControlsTeardown = this.teardown

    teardown: ->
      console.log('teardown keyboard')
      $(window).off('keydown', this.onKeyDownEvent)

    render: () ->
      this.$el.html(Handlebars.templates['subtitles-controls'](this.model.toJSON()))
      this.$('.pause').hide()

      if not this.options.allowToggleVideo
        this.$('.toggle-video').remove()
      if not this.options.allowHideTranslation
        this.$('.toggle-translation').remove()

      this.enableButtons()

      this.$('[data-toggle="popover"]').popover()

      return this

    setProgressBar: () ->
      percentage = this.model.getCurrentPercentageComplete()
      time = this.convertSecondsToTime(this.model.getCurrentTime()/1000)
      duration = this.convertSecondsToTime(this.model.getDuration())
      this.$('.progress-bar').width(percentage + '%')
      this.$('.progress-timer').html(time + '/' + duration)

    convertSecondsToTime: (seconds) ->
      partOne = Math.floor(seconds / 60)
      partTwo = Math.floor(seconds) % 60
      if partTwo < 10
        partTwo = '0' + partTwo

      if isNaN(partOne) or isNaN(partTwo)
        return '0:00'

      return partOne + ':' + partTwo

    updateProgressBar: () ->
      clearTimeout(this.progressTick)
      this.setProgressBar()
      next = () =>
        this.updateProgressBar()
      this.progressTick = setTimeout(next, 100)

    toStart: () ->
      console.log('SUBTITLES CONTROL TO START')
      this.model.toStart()

    prev: () ->
      console.log('SUBTITLES CONTROL PREV')
      this.model.prev()

    next: () ->
      console.log('SUBTITLES CONTROL NEXT')
      this.model.next()

    togglePlay: () ->
      if this.model.get('playing')
        console.log('SUBTITLES CONTROL PAUSE')
        this.model.pause()
      else
        console.log('SUBTITLES CONTROL PLAY')
        this.model.play()

    toggleTranslation: () ->
      console.log('SUBTITLES CONTROL TOGGLE TRANSLATION')
      this.trigger('toggleTranslation')

      toggleTranslationButton = this.$('.toggle-translation')
      if (!toggleTranslationButton.hasClass('active'))
        toggleTranslationButton.addClass('active')
        toggleTranslationButton.find('.buttonText').text('Show English')
      else
        toggleTranslationButton.removeClass('active')
        toggleTranslationButton.find('.buttonText').text('Hide English')

    enableButtons: () ->
      this.$('.toStart').on('click', () =>
        this.toStart())
      this.$('.prev').on('click', () =>
        this.prev())
      this.$('.next').on('click', () =>
        this.next())
      this.$('.toggle-play').on('click', () =>
        this.togglePlay())
      this.$('.toggle-translation').on('click', (event) =>
        this.toggleTranslation()
        event.preventDefault())


    onKeyDown: (event) ->
      if event.which is 37
        this.prev()
        event.preventDefault()
      if event.which is 39
        this.next()
        event.preventDefault()
      if event.which is 32
        this.togglePlay()
        event.preventDefault()
  )

  return SubtitlesControlsView