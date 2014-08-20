define [
  'dictionary.model',
  'youtube.main.model',
  'video.item.list.model',
  'backbone'
], (DictionaryModel, MainModel, MenuModel, Backbone) ->
  ClassroomModel = Backbone.Model.extend(

    initialize: () ->
      this.mainModel = new MainModel(
        settings: this.get('settings')
      )

      this.menuModel = new MenuModel(
        settings: this.get('settings')
      )

      this.dictionaryModel = new DictionaryModel(
        fromLanguage: this.get('settings').get('fromLanguage')
        toLanguage: this.get('settings').get('toLanguage')
        settings: this.get('settings')
      )

      this.getClassroom()

    lookup: (query) ->
      this.dictionaryModel.set(
        query: query
      )

    getClassroom: () ->
      $.ajax(
        type: 'GET'
        url: '/api/classrooms/' + this.get('id')
        dataType: 'json'
        success: (res) =>
          this.set(
            data: res.classroom
          )
          this.menuModel.set(
            rawData: res.displayInfos
          )
          if this.menuModel.get('data')?.length > 0
            firstItem = this.menuModel.get('data')[0]
            this.mainModel.trigger('changeSong', firstItem)
        error: (err) =>
          console.log('Error: ' + err)
      )
  )

  return ClassroomModel