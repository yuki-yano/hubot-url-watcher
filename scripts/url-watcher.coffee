# Description:
#   send the URL contained in the message to #general
#
# Notes:
#   None
#

request = require 'request'
cheerio = require 'cheerio'
iconv   = require 'iconv'

msg_url = (token, text) ->
  "https://slack.com/api/chat.postMessage?token=#{token}&channel=%23general&text=#{text}&pretty=1&username=url%5Fwatcher"

to_utf8 = (body) ->
  charset = body.toString('ascii').match /<meta[^>]*charset\s*=\s*["']?([-\w]+)["']?/i
  return new iconv.Iconv(charset[1], 'UTF-8//TRANSLIT//IGNORE').convert(body) if charset
  body

extract_title = (body) ->
  $ = cheerio.load to_utf8(body).toString().replace(/<!\[CDATA\[([^\]]+)]\]>/ig, "$1")
  $("title").text().replace(/\r?\n/, '')

text = (title, url, channel) ->
  encodeURIComponent "#{title} from ##{channel}\n#{url}"

module.exports = (robot) ->
  robot.hear /(https?:\/\/[^\s　]+)/, (msg) ->
    url = msg.match[1]
    channel = msg.envelope.room

    request { url: url }, (error, response, body)->
      if error
        request.get(msg_url(process.env.HUBOT_SLACK_TOKEN, url), (err, res, body) ->)
      else
        title = extract_title(body)
        request.get(msg_url(process.env.HUBOT_SLACK_TOKEN, text(title, url, channel)), (err, res, body) ->)
