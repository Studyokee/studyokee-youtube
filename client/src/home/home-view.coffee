define [
  'backbone',
  'handlebars',
  'templates'
], (Backbone, Handlebars) ->
  HomeView = Backbone.View.extend(
    
    initialize: () ->

    render: () ->
      this.$el.html(Handlebars.templates['home'](this.model.get('settings').toJSON()))

      languageObject = this.model.get('settings').get('fromLanguage')
      $('.selectLanguage .displayLanguage').text(languageObject.display)
      $('.selectLanguage .dropdown-toggle').attr('data-selected', languageObject.language)

      this.$('.selectLanguage .dropdown-menu a').on('click', (event) ->
        display = $(this).text()
        language = $(this).attr('data-language')
        $('.selectLanguage .displayLanguage').text(display)
        $('.selectLanguage .dropdown-toggle').attr('data-selected', language)
        $('.try').attr('href', '/try_' + language + '?language=' + language)
        event.preventDefault()
      )

      return this
  )

  return HomeView