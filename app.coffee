
# Load configuration

Config = {}

for item in [
  "TRAVIS_TOKEN",
  "GITHUB_FEEDS",
  "TWITTER_CONSUMER_KEY",
  "TWITTER_CONSUMER_SECRET",
  "TWITTER_ACCESS_TOKEN_KEY",
  "TWITTER_ACCESS_TOKEN_SECRET"
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

  (callback) -> client.get("/statuses/home_timeline.json", { include_rts: 1, count: 30 }, callback)

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
          for item in result.source.feed.entry
            items.push(item.content[0]["_"])

        found += 1
        if found == sources.length
          callback(items)


