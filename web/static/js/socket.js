// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})


socket.connect()

// Now that you are connected, you can join channels with a topic:
const createSocket = (user_id) => {
  let channel = socket.channel(`user:${user_id}`, {})
  channel.join()
    .receive("ok", resp => {
       renderTweets(resp.tweets)
     })
    .receive("error", resp => { console.log("Unable to join", resp) })

  channel.on("user:add", renderTweet)

  document.querySelector('button').addEventListener('click', () => {
    const tweet = document.querySelector('textarea').value

    channel.push("user:add", {tweet : tweet})
  })

}

function renderTweets(tweets) {
  const renderedTweets = tweets.map(tweet => {
    return tweetTemplate(tweet)
  })
  document.querySelector('.collection').innerHTML = renderedTweets.join('')
}

function tweetTemplate(tweet) {
  return `
    <div class="tweets" style="margin-top: 10px; border-bottom: 2px solid #73bfc9">
      ${tweet.content}
    </div>
  `
}

function renderTweet(event) {
  const renderedTweet = tweetTemplate(event.tweet)
  document.querySelector('.collection').innerHTML += renderedTweet
}


window.createSocket = createSocket;
