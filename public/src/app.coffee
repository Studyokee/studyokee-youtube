require [
  'backbone',
  'jquery',
  'settings',
  'header.view',
  'footer.view',
], (Backbone, $, Settings, HeaderView, FooterView) ->

  AppRouter = Backbone.Router.extend(
    routes:
      '': 'getClassrooms'
      'classrooms/language/:from/:to': 'getClassrooms'
      'songs/:id/edit': 'editSong'
      'classrooms/create': 'createClassroom'
      'classrooms/:id/edit': 'editClassroom'
      'classrooms/:id': 'viewClassroom'
      'vocabulary/:from/:to': 'vocabulary'
      'login': 'login'
      '*actions': 'defaultRoute'
    execute: (callback, args) ->
      # cleanup keyboard events
      window.subtitlesControlsTeardown?()

      if callback then callback.apply(this, args)
  )

  appRouter = new AppRouter

  dataDom = $('#data-dom')
  user =
    id: dataDom.attr('data-user-id')
    displayName: dataDom.attr('data-user-display-name')
    photo: dataDom.attr('data-user-photo')
    firstName: dataDom.attr('data-user-first-name')

  settings = new Settings(
    user: user
  )

  homeHeaderView = new HeaderView(
    model: settings
    sparse: true
  )
  headerView = new HeaderView(
    model: settings
  )
  footerView = new FooterView(
    model: settings
  )

  appRouter.on('route:home', () ->
    require(['home.model', 'home.view'], (HomeModel, HomeView) ->
      this.view = new HomeView(
        model: new HomeModel(
          settings: settings
        )
      )
      homeHeaderView.setElement($('#skee header')).render()
      this.view.setElement($('#skee .main')).render()
      footerView.setElement($('#skee footer')).render()
    )
  )
  appRouter.on('route:editSong', (id) ->
    require(['edit.song.model', 'edit.song.view'], (EditSongModel, EditSongView) ->
      this.view = new EditSongView(
        model: new EditSongModel(
          settings: settings
          id: id
        )
      )
      headerView.setElement($('#skee header')).render()
      this.view.setElement($('#skee .main')).render()
      footerView.setElement($('#skee footer')).render()
    )
  )
  appRouter.on('route:createClassroom', () ->
    require(['create.classroom.model','create.classroom.view'], (CreateClassroomModel, CreateClassroomView) ->
      if not user.id
        Backbone.history.navigate('login', {trigger: true})
        return

      this.view = new CreateClassroomView(
        model: new CreateClassroomModel(
          settings: settings
        )
      )
      headerView.setElement($('#skee header')).render()
      this.view.setElement($('#skee .main')).render()
      footerView.setElement($('#skee footer')).render()
    )
  )
  appRouter.on('route:editClassroom', (id) ->
    require(['edit.classroom.model','edit.classroom.view'], (EditClassroomModel, EditClassroomView) ->
      console.log('open edit classroom')
      if not user.id
        Backbone.history.navigate('login', {trigger: true})
        return

      this.view = new EditClassroomView(
        model: new EditClassroomModel(
          settings: settings
          id: id
        )
      )
      headerView.setElement($('#skee header')).render()
      this.view.setElement($('#skee .main')).render()
      footerView.setElement($('#skee footer')).render()
    )
  )
  appRouter.on('route:viewClassroom', (id) ->
    require(['classroom.model','classroom.view'], (ClassroomModel, ClassroomView) ->
      this.view = new ClassroomView(
        model: new ClassroomModel(
          settings: settings
          id: id
        )
      )
      headerView.setElement($('#skee header')).render()
      this.view.setElement($('#skee .main')).render()
      footerView.setElement($('#skee footer')).render()
    )
  )
  appRouter.on('route:vocabulary', (from, to) ->
    require(['vocabulary.model','vocabulary.view'], (VocabularyModel, VocabularyView) ->
      console.log('open vocabulary')
      if not user.id
        Backbone.history.navigate('login', {trigger: true})
        return

      settings.setFromLangauge(from)
      this.view = new VocabularyView(
        model: new VocabularyModel(
          settings: settings
        )
      )
      headerView.setElement($('#skee header')).render()
      this.view.setElement($('#skee .main')).render()
      footerView.setElement($('#skee footer')).render()
    )
  )
  appRouter.on('route:login', () ->
    require(['login.view'], (LoginView) ->
      this.view = new LoginView(
        model: settings
      )
      homeHeaderView.setElement($('#skee header')).render()
      this.view.setElement($('#skee .main')).render()
      footerView.setElement($('#skee footer')).render()
    )
  )
  appRouter.on('route:getClassrooms', (from, to) ->
    require(['classrooms.model','classrooms.view'], (ClassroomsModel, ClassroomsView) ->
      settings.setFromLangauge(from)
      this.view = new ClassroomsView(
        model: new ClassroomsModel(
          settings: settings
        )
      )
      headerView.setElement($('#skee header')).render()
      this.view.setElement($('#skee .main')).render()
      footerView.setElement($('#skee footer')).render()
    )
  )
  appRouter.on('route:defaultRoute', () ->
    require(['home.model','home.view'], (HomeModel, HomeView) ->
      console.log('go to default route')
      this.view = new HomeView(
        model: new HomeModel(
          settings: settings
        )
      )
      headerView.setElement($('#skee header')).render()
      this.view.setElement($('#skee .main')).render()
      footerView.setElement($('#skee footer')).render()
      Backbone.history.navigate('classrooms/' + settings.get('fromLanguage').language + '/' + settings.get('toLanguage').language)
    )
  )
  params =
    pushState: true
    root: '/'
  Backbone.history.start(params)