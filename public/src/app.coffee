require [
  'backbone',
  'jquery',
  'settings',
  'home.model',
  'home.view',
  'edit.song.model',
  'edit.song.view',
  'create.classroom.model',
  'create.classroom.view',
  'edit.classroom.model',
  'edit.classroom.view',
  'classroom.model',
  'classroom.view'
], (Backbone, $, Settings, HomeModel, HomeView, EditSongModel, EditSongView, CreateClassroomModel, CreateClassroomView, EditClassroomModel, EditClassroomView, ClassroomModel, ClassroomView) ->

  AppRouter = Backbone.Router.extend(
    routes:
      '/': 'home'
      'songs/:id/edit': 'editSong'
      'classrooms/create': 'createClassroom'
      'classrooms/:id/edit': 'editClassroom'
      'classrooms/:id': 'viewClassroom'
      'login': 'login'
      '*actions': 'defaultRoute'
  )

  appRouter = new AppRouter

  userId = $('#data-dom').attr('data-user-id')

  settings = new Settings(
    userId: userId
  )
  toLogin = () ->
    $('.skee').html('<a href="/auth/facebook">Login with Facebook</a>')
    Backbone.history.navigate('login')


  appRouter.on('route:home', () ->
    view = new HomeView(
      model: new HomeModel(
        settings: settings
      )
    )
    $('.skee').html(view.render().el)
  )
  appRouter.on('route:editSong', (id) ->
    view = new EditSongView(
      model: new EditSongModel(
        settings: settings
        id: id
      )
    )
    $('.skee').html(view.render().el)
  )
  appRouter.on('route:createClassroom', () ->
    if not userId
      toLogin()
      return

    view = new CreateClassroomView(
      model: new CreateClassroomModel(
        settings: settings
      )
    )
    $('.skee').html(view.render().el)
  )
  appRouter.on('route:editClassroom', (id) ->
    if not userId
      toLogin()
      return

    view = new EditClassroomView(
      model: new EditClassroomModel(
        settings: settings
        id: id
      )
    )
    $('.skee').html(view.render().el)
  )
  appRouter.on('route:viewClassroom', (id) ->
    view = new ClassroomView(
      model: new ClassroomModel(
        settings: settings
        id: id
      )
    )
    $('.skee').html(view.render().el)
  )
  appRouter.on('route:login', () ->
    toLogin()
  )
  appRouter.on('route:defaultRoute', () ->
    view = new HomeView(
      model: new HomeModel(
        settings: settings
      )
    )
    $('.skee').html(view.render().el)
  )
  params =
    pushState: true
    root: '/'
  Backbone.history.start(params)