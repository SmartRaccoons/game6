window.o.ViewGame = class Game extends window.o.View
  className: 'game-container'
  template: """"""

  load: ->
    if @game
      @game.remove()
    @game = new window.o.Game({
      container: @$el
    })
    @game.render()
    @game.map()

  remove: ->
    @game.remove()
    super
