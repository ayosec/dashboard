
# Load configuration

Config = {}

for item in [
  "TRAVIS_TOKEN",
  "GITHUB_FEEDS",
  "TWITTER_CONSUMER_KEY",
  "TWITTER_CONSUMER_SECRET",
  "TWITTER_ACCESS_TOKEN_KEY",
  "TWITTER_ACCESS_TOKEN_SECRET",
  "BASIC_AUTH"
]
  if value = process.env[item]
    Config[item] = value
  else
    console.log("#{item} is missing")
    process.exit(1)


# Twitter timeline

getTwitter = do ->
  twitter = require('twitter')
  client = new twitter
    consumer_key: Config.TWITTER_CONSUMER_KEY
    consumer_secret: Config.TWITTER_CONSUMER_SECRET
    access_token_key: Config.TWITTER_ACCESS_TOKEN_KEY
    access_token_secret: Config.TWITTER_ACCESS_TOKEN_SECRET

  (callback) -> client.get("/statuses/home_timeline.json", { include_rts: "true", count: 30 }, callback)

# GitHub feeds

getGitHub = do ->
  sources = Config.GITHUB_FEEDS.split(/\s+/)
  feedr = new require('feedr')
    
  (callback) ->
    items = []
    found = 0
    for feed in sources
      new feedr.Feedr().readFeeds source: { url: feed }, (err, result) ->
        if not err
          for item in result.source.feed.entry.sort((a,b) -> new Date(a).getTime() - new Date(b).getTime())
            items.push(item.content[0]["_"])

        found += 1
        if found == sources.length
          callback(items)

# Travis configuration

getTravis = do ->
  request = require('https').request
  options =
    host: "api.travis-ci.com",
    port: 443
    path: "/repos/"
    method: "GET",
    headers: { "Authorization": "token #{Config.TRAVIS_TOKEN}" }

  (callback) -> request(options,
    (res) ->
      data = ""
      res.on "data", (d) -> data = data.concat(d.toString())
      res.on "end", -> callback(JSON.parse(data))
  ).on("error", (error) ->
    console.log("Travis request error:", error)
    callback([])
  ).end()


# Web application

express = require('express')
app = express()

do ->
  [user, password] = Config.BASIC_AUTH.split(":")
  app.use express.basicAuth(user, password)

app.use(express.static(__dirname + '/public'))

app.get "/twitter", (req, res) -> getTwitter((data)-> res.json(data))
app.get "/github",  (req, res) -> getGitHub((data)-> res.json(data))
app.get "/travis",  (req, res) -> getTravis((data)-> res.json(data))

app.listen(process.env.PORT ? 9000)
