window.o.ViewGame = class Game extends window.o.View
  className: 'game-container'
  template: """"""

  constructor: ->
    super
    @_game = new window.o.Game()

  load: ->
    @_game.clear()
    @_game.render({
      container: @$el
    })
