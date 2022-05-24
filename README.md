# Chat

This is a very simple application based on [Elixir School's OTP Distribution
Lesson](https://elixirschool.com/en/lessons/advanced/otp_distribution). I
created this as an experiment to see how to dyno to dyno communication works in
a private space and if it could be used to run distributed Elixir/Erlang
applications.

## Deployment to a Heroku Private Space

Initialize a git repo and commit your code:
```
$ git init
$ git add .
$ git commit -m "Initial commit"
```

Create your private space:
```
$ heroku spaces:create --space < space name > --team < team name > --region=<region>
```

Create a Heroku application:
```
$ heroku create < app name > --space < space name > --buildpack hashnuke/elixir
$ git push heroku main
```

Generate a cookie/secret and then set the `ERLANG_COOKIE` config var:
```
$ heroku config:set ERLANG_COOKIE=$(mix chat.gen.secret) -a < app name >
```

Enable DNS Service Discovery:
```
$ heroku features:enable spaces-dns-discovery --app < app name >
$ heroku restart --app < app name >
```

### See the Distributed Messaging

_todo: update this section (and the code) to use actual DNS Service Discovery
rather than just the private IPs_

Review the logs of the dyno you wish to talk to. E.g. if you want to send a
moebi dyno a message, then run
```
$ heroku logs -a < app name > --tail --dyno=moebi
```

Take note of the fully qualified node name, e.g. "moebi@0.0.0.0" below
```
2022-05-24T03:49:16.612874+00:00 app[moebi.1]: Node name: moebi@0.0.0.0
```

Now, start up a one-off dyno running an iex session and then send the message.
Note: it takes significantly longer for things to start up in a private space
(like on the scale of minutes sometimes).
```
$ heroku run 'iex --name "amanda@$HEROKU_PRIVATE_IP" --cookie "$ERLANG_COOKIE" -S mix' -a < app name>
iex(amanda@0.0.0.1)1> Chat.send_message(:"moebi@0.0.0.0", "Hello from Amanda!")
chicken?
nil
iex(amanda@0.0.0.1)2>
```

If you are still tailing `moebi` logs, you should see
```
2022-05-24T04:01:03.861744+00:00 app[moebi.1]: Hello from Amanda!
```

### How It Works

In the Elixir School's distribution lesson, you create a simple mix project that
implements `Chat.send_message/2`. This function takes two arguments, first the
ndoe to send the message to, and second the message - a string which will then
be logged to stdout on the node that recieved the message. A special node,
`moebi` is implemented which will always respond to the caller with "chicken?"
(as in, you should expect that to be logged to your stdout if you send moebi a
message).

With a few changes, this application can be deployed to Heroku Private Space to
run as a distributed cluster:
- Adjust the special handling for `moebi` to not explicitly refer to
  `localhost`. You can see how I implemented this in the `Chat` module.
- Create a Procfile that defines the various node types and how they should
  start up. Make sure to specify a long name and a shared cookie (all nodes in a
  cluster must use the same cookie).

Plug is added simply because Heroku apps must have a web process type, and those
dynos must bind to `$PORT` within 60 seconds of start up. This application has a
slight modification on the typical Plug setup so that it only starts on `web`
dynos. You can see details in `Chat.Application.start/2`.

## Local Setup

Install the Elixir and Erlang versions needed for the project. These are
specified in the `.tool-versions` file, so if you have
[asdf](https://github.com/asdf-vm/asdf) intalled, you can simply run
`asdf install` from your local project directory.

Next, install the project's dependencies:
```
$ mix deps.get
```

Finally, you can start up a node with
```
$ iex --sname < short node name > -S mix
```

