define [
  'backbone'
], (Backbone) ->
  VocabularySliderModel = Backbone.Model.extend(
    defaults:
      words: []
      index: 0
      showDefinition: false

    initialize: () ->
      this.on('vocabularyUpdate', (unknown) =>
        # Only get new order if more words added
        if this.get('words')?.length < unknown.length - 1
          console.log('had ' + this.get('words').length + ' words')
          console.log('now has ' + unknown.length + ' words')
          this.set(
            words: this.getRandomOrder(unknown)
          )
      )

    remove: (index) ->
      words = this.get('words')
      if index < words.length
        word = words[index]
        words.splice(index, 1)
        this.set(
          words: words
          showDefinition: false
          index: index % words.length #if last word is removed
        )
        this.trigger('change')
        this.trigger('removeWord', word)

    getRandomOrder: (array) ->
      order = []

      if array.length is 0
        return []

      for i in [0..array.length-1]
        order.push(i)

      order.sort(() ->
        return Math.random() - 0.5
      )

      newArray = []
      for i in order
        newArray.push(array[i])

      return newArray

  )

  return VocabularySliderModel