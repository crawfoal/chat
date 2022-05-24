# Chat

This is a very simple application based on [Elixir School's OTP Distribution
Lesson](https://elixirschool.com/en/lessons/advanced/otp_distribution). I
created this as an experiment to see how to dyno to dyno communication works in
a private space and if it could be used to run distributed Elixir/Erlang
applications.

## Deployment

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

todo: update this section (and the code) to use actual DNS Service Discovery
rather than just the private IPs

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

### How It Works

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

### See the Distributed Messaging

