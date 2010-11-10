class Repository
  include Neo4j::NodeMixin

  property :pushed_at, :has_wiki, :open_issues, :description, :fork, :has_issues, :created_at
  property :forks, :watchers, :private, :name, :url, :owner, :homepage, :has_downloads

  #if it is a fork
  property :parent, :source

  #extra property
  property :full_name

  index    :full_name

  def self.find_or_create(full_name)
    login, repository = full_name.split("/")
    raise "Usage find_or_create('GITHUB_LOGIN/REPOSITORY_NAME')" if (login.nil? || repository.nil?)
    result = find("full_name: #{full_name}").first
    if result.nil?
      sleep(2)
      puts "fetching #{full_name}"
      repo = YAML::load(open("#{Github::BASE}/repos/show/#{login}/#{repository}"))["repository"]
      repo.each_pair {|key, value| repo[key] = value.to_s}
      repo[:full_name] = full_name
      result = new(repo)
     #if it belongs to a fork
      if repo.has_key?(:parent)
        result.outgoing(:forked_from) << Repository.find_or_create(repo[:parent])
      end
    end
    result
  end

  def self.all
    all = Neo4j.all_nodes.reduce([]) do |acum, node|
      if node.class.to_s == "Repository"
        acum << node
      else
        acum
      end
    end
    all
  end

end
