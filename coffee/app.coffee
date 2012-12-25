
$ ->
  world = {
    tweets: ko.observable([]),
    builds: ko.observable([]),
    gits: ko.observable([])
  }

  update = ->
    $.get "/twitter", (data) ->
      # Fix retweets
      world.tweets(t.retweeted_status ? t for t in data)

    $.get "/travis", (data) ->
      world.builds(data)

    $.get "/github", (data) ->
      world.gits(data)

  do update
  setInterval update, 60000 # 1 minute

  ko.applyBindings(world)
