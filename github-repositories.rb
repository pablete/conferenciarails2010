require "rubygems"
require "bundler/setup"

require "neo4j"
require "open-uri"
require "yaml"
require "pp"
$LOAD_PATH << './lib'
require "github_social"
include Utils
include Github

Neo4j::Config[:storage_path] = "db/github"
Neo4j.start
Kernel.at_exit { finish_tx }


def get_followers_with_repositories(depth, current_user)
  start_tx
  user = Githubber.find_or_create(current_user)
  if depth == 0
    return user
  end
  followers = fetch_followers(current_user)
  puts "%s followers:\n%s" % [current_user,followers.join(", ")]
  followers.each do |login|
    follower = get_followers_with_repositories(depth-1, login)
    start_tx
    follower.outgoing(:follows) << user
  end
  following = fetch_following(current_user)
  puts "%s is following:\n%s" % [current_user,following.join(", ")]
  following.each do |login|
    followed = get_followers_with_repositories(depth-1, login)
    start_tx
    user.outgoing(:follows) << followed
  end
  repositories = fetch_watched_repositories(current_user)
  puts "%s repositories:\n%s" % [current_user, repositories.join(", ")]
  repositories.each do |repository|
    start_tx
    repository = Repository.find_or_create(repository)
    #lets link it to the user
    user.outgoing(:watching) << repository
  end
  user
end

USERNAME   = "pablete"
GITHUBBERS = ["antoniogarrote", "ppeszko", "malditogeek"]

start_tx
get_followers_with_repositories(1, USERNAME)

GITHUBBERS.each do |githubber|
  start_tx
  get_followers_with_repositories(1, githubber)
end
finish_tx

graph = GraphvizGenerator.new
graph.create_image(Neo4j.all_nodes, {})

myrecommender = Recommender.new(USERNAME, GITHUBBERS)
puts "Recomendation based on a graph empiric method"
pp myrecommender.graph_top_n(10)
puts "Recomendation based collaborative filtering over selected users"
pp myrecommender.analytical_top_n(10)

