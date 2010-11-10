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

def get_followers(depth, current_user)
  raise "are you sure you are going to crawl more than level 2 follow graph?" if depth > 2
  start_tx
  user = Githubber.find_or_create(current_user)
  if depth == 0
    return user
  end
  followers = fetch_followers(current_user)
  puts "%s followers:\n%s" % [current_user,followers.join(", ")]
  followers.each do |login|
    follower = get_followers(depth-1, login)
    start_tx
    follower.outgoing(:follows) << user
  end
  following = fetch_following(current_user)
  puts "%s is following:\n%s" % [current_user,following.join(", ")]
  following.each do |login|
    followed = get_followers(depth-1, login)
    start_tx
    user.outgoing(:follows) << followed
  end
  user
end

USERNAME = "pablete"

# NOTE: Carefull with adding more than 2 levels of followers
start_tx
get_followers(2, USERNAME)
finish_tx

graph = GraphvizGenerator.new
graph.create_image(Neo4j.all_nodes, {})

Kernel.at_exit { finish_tx }
