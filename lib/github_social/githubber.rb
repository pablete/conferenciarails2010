class Githubber
  include Neo4j::NodeMixin

  property :login, :name, :email, :gravatar_id, :company, :location, :created_at, :blog
  property :public_repo_count, :public_gist_count, :following_count, :followers_count

  index :login
  index :name
  index :location
  index :company

  def gravatar
    "http://www.gravatar.com/avatar/#{self.gravatar_id}"
  end

  def self.find_or_create(login)
    raise "Usage find_or_create('GITHUB_LOGIN')" if login.nil?
    result = find("login: #{login}").first
    if result.nil?
      sleep(2)
      puts "fetching #{login}"
      user = YAML::load(open("#{Github::BASE}/user/show/#{login}"))["user"]
      user.each_pair {|key, value| user[key] = value.to_s}
      result = new(user)
    end
    result
  end

  def self.find_by_ids(*ids)
    result = ids.map { |id| Neo4j::Node.load(id) }
    if ids.length == 1
      result.first
    else
      result
    end
  end

end