require "set"

class Recommender

  attr_accessor :username, :githubbers

  def initialize(username, githubbers)
    @githubbers = githubbers
    @username   = username

    the_most_similar = most_similar(username, githubbers)

    @most_similar = Githubber.find("login: #{the_most_similar}").first
    @githubber    = Githubber.find("login: #{username}").first
  end

  def graph_top_n(n)
    recommendation = @most_similar.outgoing(:watching).reduce([]) do |acum, repository|
      if repository.incoming(:watching).include?(@githubber)
        acum
      else
        acum << [repository.incoming(:watching).size, repository[:full_name] ]
      end
    end
    recommendation.sort!{|a,b| b.first <=> a.first}
    recommendation[0..n]
  end

  def analytical_top_n(n)
    @all_scores = similarities.collect do |elem|
      user, score = elem
      current_user = Githubber.find("login: #{user}").first
      Repository.all.map do |repo|
        if repo.incoming(:watching).include?(current_user)
           score
        else
           0
        end
      end
    end

    @scores_for_repos = @all_scores.transpose.map do |list|
      list.reduce(0) {|acum,item| acum=acum+item}
    end

    @repos_full_name = Repository.all.map do |repo|
      repo[:full_name]
    end
    recommendation = @scores_for_repos.zip(@repos_full_name).sort{|a,b| b.first <=> a.first}
    recommendation[0..n]
  end



private

  # Using Jaccard Similarity
  def similarity(user1, user2)
    origin = Githubber.find("login: #{user1}").first
    a = Set.new( origin.outgoing(:watching).map { |repo| repo[:full_name] } )

    destination = Githubber.find("login: #{user2}").first
    b = Set.new( destination.outgoing(:watching).map { |repo| repo[:full_name] } )

    #puts "common repositories: %s" % a.intersection(b).to_a.join(", ")
    jaccard = 0
    unless (a.union(b)).size  == 0
      jaccard = (0.0 + (a.intersection(b)).size) / (a.union(b)).size
    end
    jaccard
  end

  def most_similar(user, group)
    group = group-[user]
    friends_with_similarity = group.map do |friend|
      [similarity(user, friend),friend]
    end
    friends_with_similarity.sort{|a,b| b.first <=> a.first}.first.last
  end

  def similarities
    @githubbers.map{|other| [other, similarity(@username, other)] }
  end

  def similarities_hash
    @githubbers.zip(similarities)
  end

end




