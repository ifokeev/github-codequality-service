Micro server that watches Github pull requests and comments on code violations.

Based on [https://github.com/GratifyCommerce/watchdog](Watchdog)

- Free alternative to [Hound](https://houndci.com): deploy it on a free Heroku dyno.
- No need to configure a CI server: useful if your CI server has limitations, or if you want to introduce automated code checks in a team with minimal effort.
- Based on [Pronto](https://github.com/mmozuras/pronto) and [Sinatra](http://www.sinatrarb.com).

## Deploying to Heroku

0. Choose a Github user (or create a [dedicated one](https://github.com/vicidog)) that will be linked to watchdog when commenting pull requests. Make sure the user has access to any private repository you want to analyze.

0. [Create a Github access token](https://github.com/settings/tokens) for this user and make sure the `read:repo_hook` scope is ticked. Note that token down for later.

0. Install the [Heroku Toolbelt](https://toolbelt.heroku.com) CLI. If on OSX:

```
brew install heroku-toolbelt
```

0. Login to Heroku if it is not already the case:

```
heroku login
```

0. Go to the watchdog directory and deploy:

```
heroku create your_app_name

heroku config:set GITHUB_USERNAME=your_github_username \
                  GITHUB_PASSWORD=your_github_password \
                  GITHUB_ACCESS_TOKEN=your_github_access_token

# The commands below may take a while to execute
heroku buildpacks:add https://github.com/heroku/heroku-buildpack-apt
heroku buildpacks:add heroku/nodejs
heroku buildpacks:add heroku/ruby

git push heroku master
```

0. https://your_app_name.herokuapp.com should display "{success: true}".

0. Go to the Github project(s) you want to analyze, add the https://your_app_name.herokuapp.com/pull_request_events webhook, and make it trigger only for Pull Request events.

    You can also do this organization-wide for all your projects by going to https://github.com/organizations/your_organization/settings/hooks.

0. Profit.

## Contributing

To run the server on your local machine, you will need to install [Ruby](https://www.ruby-lang.org) with the version indicated in [this file](https://raw.githubusercontent.com/VicinityCommerce/watchdog/master/.ruby-version) and install bundler.

Then:

0. Install CMake. If on OS X:

```
brew install cmake
```

0. Install dependencies:

```
bundle
```

0. Copy `.env.example` to `.env` and fill in the variables with real values.

0. Run the server:

```
bundle exec rackup
```

0. [http://localhost:9292](http://localhost:9292) should display "{success: true}".

0. If you want to test the `POST` [http://localhost:9292/pull_request_events](http://localhost:9292/pull_request_events) webhook with real Github data, you will need to use a tool like [ngrok](https://ngrok.com) to make your server publicly reachable. For ngrok, the command would be `ngrok http 9292`.
