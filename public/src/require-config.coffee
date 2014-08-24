requirejs.config(
  enforceDefine: true
  baseUrl: '/'
  paths:
    backbone: '/bower_components/backbone/backbone'
    jquery: '/bower_components/jquery/jquery'
    swfobject: '/bower_components/swfobject/swfobject/swfobject'
    underscore: '/bower_components/underscore/underscore'
    handlebars: '/bower_components/handlebars/handlebars'
    templates: 'lib/templates'
    purl: 'bower_components/purl/purl'
    yt: 'https://www.youtube.com/iframe_api?noext'
    'home.model': 'lib/home/home-model'
    'home.view': 'lib/home/home-view'
    'media.item.view': 'lib/media-item/media-item-view'
    'media.item.list.view': '/lib/media-item-list/media-item-list-view'
    'media.item.list.model': '/lib/media-item-list/media-item-list-model'
    'settings': '/lib/settings'
    'add.song.view': '/lib/add-song/add-song-view'
    'add.song.model': '/lib/add-song/add-song-model'
    'subtitles.scroller.view': '/lib/subtitles-scroller/subtitles-scroller-view'
    'subtitles.scroller.model': '/lib/subtitles-scroller/subtitles-scroller-model'
    'subtitles.player.model': '/lib/subtitles-player/subtitles-player-model'
    'subtitles.player.view': '/lib/subtitles-player/subtitles-player-view'
    'subtitles.controls.view': '/lib/subtitles-controls/subtitles-controls-view'
    'songs.data.provider':
      '/lib/songs-data-provider'
    'suggestions.model': '/lib/suggestions/suggestions-model'
    'suggestions.view': 'lib/suggestions/suggestions-view'
    'dictionary.view': 'lib/dictionary/dictionary-view'
    'dictionary.model': 'lib/dictionary/dictionary-model'
    'edit.songs.view': 'lib/edit-songs/edit-songs-view'
    'edit.songs.model': 'lib/edit-songs/edit-songs-model'
    'create.song.view': 'lib/create-song/create-song-view'
    'create.song.model': 'lib/create-song/create-song-model'
    'edit.song.view': 'lib/edit-song/edit-song-view'
    'edit.song.model': 'lib/edit-song/edit-song-model'
    'create.classroom.view': 'lib/create-classroom/create-classroom-view'
    'create.classroom.model': 'lib/create-classroom/create-classroom-model'
    'edit.classroom.view': 'lib/edit-classroom/edit-classroom-view'
    'edit.classroom.model': 'lib/edit-classroom/edit-classroom-model'
    'classroom.view': 'lib/classroom/classroom-view'
    'classroom.model': 'lib/classroom/classroom-model'
    'classrooms.view': 'lib/classrooms/classrooms-view'
    'classrooms.model': 'lib/classrooms/classrooms-model'
    'classroom.preview.view': 'lib/classroom-preview/classroom-preview-view'
    'classroom.preview.model': 'lib/classroom-preview/classroom-preview-model'
    'youtube.main.model': '/lib/youtube/youtube-main/youtube-main-model'
    'youtube.main.view': '/lib/youtube/youtube-main/youtube-main-view'
    'youtube.player.model': '/lib/youtube/youtube-player/youtube-player-model'
    'youtube.player.sync.model': '/lib/youtube/youtube-player/youtube-player-sync-model'
    'youtube.player.view': '/lib/youtube/youtube-player/youtube-player-view'
  shim:
    backbone:
      deps: [ 'underscore', 'jquery' ]
      exports: 'Backbone'
    underscore:
      exports: '_'
    purl:
      deps: [ 'jquery' ]
      exports: '$'
    handlebars:
      exports: 'Handlebars'
    swfobject:
      exports: 'swfobject'
    yt:
      exports: 'YT'
)