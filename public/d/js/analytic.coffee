App.events.bind 'router:init', ->
  ga_wrap = (f)->
    try
      f.apply(this, arguments)
    catch e

  ga_wrap ->
    ga('create', 'UA-24527026-17', 'auto')
    # ga('set', '&uid', App.user.user.id)

  ga_wrap -> ga('send', 'pageview')
