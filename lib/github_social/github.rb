module Github
  BASE = "http://github.com/api/v2/yaml"

  def fetch_followers(login)
    sleep(2)
    YAML::load(open("#{Github::BASE}/user/show/#{login}/followers"))["users"]
  end

  def fetch_following(login)
    sleep(2)
    YAML::load(open("#{Github::BASE}/user/show/#{login}/following"))["users"]
  end

  def fetch_user_repositories(login)
    sleep(2)
    repos = YAML::load(open("#{Github::BASE}/repos/show/#{login}"))["repositories"]
    repos.map { |r| "#{login}/#{r[:name]}" }
  end

  def fetch_watched_repositories(login)
    sleep(2)
    repos = YAML::load(open("#{Github::BASE}/repos/watched/#{login}"))["repositories"]
    repos.map { |r| "#{r[:owner]}/#{r[:name]}" }
  end

  def fetch__repository_watchers(login, repository)
    sleep(2)
    YAML::load(open("#{Github::BASE}/repos/show/#{login}/#{repository}/watchers"))["watchers"]
  end
end