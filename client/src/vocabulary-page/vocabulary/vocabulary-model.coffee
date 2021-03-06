define [
  'vocabulary.slider.model',
  'backbone'
], (VocabularySliderModel, Backbone) ->
  VocabularyModel = Backbone.Model.extend(
    defaults:
      known: []
      unknown: []

    initialize: () ->
      this.vocabularySliderModel = new VocabularySliderModel()
      this.vocabularySliderModelKnown = new VocabularySliderModel()

      this.vocabularySliderModel.on('removeWord', (word) =>
        this.remove(word)
      )

      this.vocabularySliderModel.on('updateWord', (word) =>
        this.updateWord(word)
      )

      this.on('vocabularyUpdate', () =>
        this.vocabularySliderModel.trigger('vocabularyUpdate', this.get('unknown'))
        this.vocabularySliderModelKnown.trigger('vocabularyUpdate', this.get('known'))
      )

      this.getVocabulary()

    getVocabulary: () ->
      userId = this.get('settings').get('user').id
      fromLanguage = this.get('settings').get('fromLanguage').language
      toLanguage = this.get('settings').get('toLanguage').language
      $.ajax(
        type: 'GET'
        url: '/api/vocabulary/' + fromLanguage + '/' + toLanguage
        dataType: 'json'
        success: (res) =>
          this.updateVocabulary(res)
        error: (err) =>
          console.log('Error: ' + err)
      )

    remove: (word) ->
      userId = this.get('settings').get('user').id
      fromLanguage = this.get('settings').get('fromLanguage').language
      toLanguage = this.get('settings').get('toLanguage').language
      $.ajax(
        type: 'PUT'
        url: '/api/vocabulary/' + fromLanguage + '/' + toLanguage + '/remove'
        data:
          word: word
        success: (res) =>
          this.updateVocabulary(res)
        error: (err) =>
          console.log('Error: ' + err)
      )

    updateWord: (word, def) ->
      if not word?
        return

      fromLanguage = this.get('settings').get('fromLanguage').language
      toLanguage = this.get('settings').get('toLanguage').language
      $.ajax(
        type: 'PUT'
        url: '/api/vocabulary/' + fromLanguage + '/' + toLanguage + '/update'
        data:
          word: word
        success: (res) =>
          # we just edit inline
          #this.updateVocabulary(res)
        error: (err) =>
          console.log('Error: ' + err)
      )

    updateVocabulary: (vocabulary) ->
      if vocabulary?.words?
        sortedWords = this.sortWords(vocabulary.words)

        this.set(
          known: sortedWords.known
          unknown: sortedWords.unknown
        )
        this.trigger('vocabularyUpdate', vocabulary.words)

    sortWords: (words) ->
      known = []
      unknown = []
      for word in words
        if word.known
          known.push(word)
        else
          unknown.push(word)

      sortedWords =
        known: known
        unknown: unknown

      return sortedWords

    addToVocabulary: (word, def) ->
      if not word?
        return

      fromLanguage = this.get('settings').get('fromLanguage').language
      toLanguage = this.get('settings').get('toLanguage').language
      $.ajax(
        type: 'PUT'
        url: '/api/vocabulary/' + fromLanguage + '/' + toLanguage + '/add'
        data:
          word: word
          def: def
        success: (res) =>
          this.updateVocabulary(res)
        error: (err) =>
          console.log('Error adding to vocabulary')
      )

  )

  return VocabularyModel
