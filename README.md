neo4j-github
============

An example application to show uses of neo4j ruby gem.


Installation
-------------

    rvm use jruby
    gem install bundler
    git clone http://github.com/pablete/conferenciarails2010.git
    cd conferenciarails2010
    bundle install

Run the examples
----------------

### github followers

 edit github-followers.rb
 and change

    USERNAME = "pablete"
    GITHUBBERS = ["antoniogarrote", "ppeszko", "malditogeek"]

 add some of your favorite githubbers. (note: first time use no more than 5 users)

    ruby github-followers.rb
 wait for the script to fetch the users

 open Gephi app (http://gephi.org/)
 open import output/github.dot

### github repositories

 edit github-repositories.rb
 and change

    USERNAME = "pablete"
    GITHUBBERS = ["antoniogarrote", "ppeszko", "malditogeek"]

 add some of your favorite githubbers. (note: first time use no more than 5 users)

    ruby github-repositories.rb
 wait for the script to fetch the users and repositories

 open Gephi app (http://gephi.org/)
 open import output/github.dot

### github all followers 2 level depth

  edit github-followers-all.rb
  and change

    USERNAME = "pablete"
    GITHUBBERS = ["antoniogarrote", "ppeszko", "malditogeek"]

  add some of your favorite githubbers. (note: first time use no more than 5 users)

    ruby github-followers-all.rb
  wait for the script to fetch the users and repositories

  open Gephi app (http://gephi.org/)
  open import output/github.dot


