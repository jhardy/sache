Sache
---
Find the perfect tool for your next Sass or Compass project by easily searching by tag, author or keyword.


#### Adding Your Own Extension to the Directory

* Add `sache.json` to your public repo.
* Visit [http://sache.in](http://sache.in) and click "Add Extension".
* Enter your Github project SSH URL in the input field and click "Add".

Once that's done you should see a success message to let you know its been added successfully.


#### Contributing

We love open-source projects and community so we've kept this repo open for anyone to contribute to. Feel free to open an issue or submit a pull request with an additional feature or even a bug fix. If you are going to contribute: create a new branch off of master and open a pull request against that so we can check out your work. Please make sure you've tested your work thouroughly before finalizing your pull request.

##### Running Sache Locally

* Make sure you install [Postgres](http://postgresapp.com/) so that you can run a local database.
* After you install Postgres, start it up and open Terminal.
* Close the repo by running: `git clone git@github.com:jhardy/sache.git`.
* Change into that directory and run: `bundle`.
* In Terminal, type: `psql`, this opens the Postgres command line.
* Type in: `CREATE DATABASE sachein_dev;`
* Press `ctrl + z` to exit Postgres.
* Now we need to migrate, run: `bundle exec rake db:migrate`.
* Once that's done you can start up the app by running: `bundle exec ruby app.rb`.
* If you are going to be changing Sass sheets, open a new Terminal window or tab and run: `compass watch`.

Now you can visit <http://localhost:4567> and edit to your hearts desire.

--

Built by [@hatefulcrawdad](https://github.com/hatefulcrawdad) and [@jhardy](https://github.com/jhardy) for the love of the amazing Sass Community. We love communicating via Github, but if you want to email us, please send it [sassy@sache.in](mailto:sassy@sache.in).
