require "rubygems"
require "bundler/setup"

require "graphviz"

class GraphvizGenerator
  FILENAME = "output.png"
  SVG_FILENAME = "output.svg"

  def create_image(nodes, opts = {})
    g = GraphViz::new("G", :bgcolor => '#EDF5FF')

    Neo4j::Transaction.run do
      users_hash = Hash.new
      repos_hash = Hash.new

      nodes.each do |node|
        node["login"] = "root"  if node["login"].nil?
        node["login"] = "noude" if node["login"]=="node"
        if node.class.to_s == "Githubber"
          users_hash[node["login"]] = g.add_node(node["login"], :color => 'red', :fillcolor => 'white', :style => 'filled')
        end
        if node.class.to_s == "Repository"
          repos_hash[node["full_name"]] = g.add_node(node["full_name"], :color => 'blue', :fillcolor => 'white', :style => 'filled')
        end
      end

      nodes.each do |node|
        if node.class.to_s == "Githubber"
          node.incoming(:follows).each do |follower|
            g.add_edge(users_hash[follower["login"]], users_hash[node["login"]])
          end
          node.outgoing(:follows).each do |followed|
            g.add_edge(users_hash[node["login"]], users_hash[followed["login"]])
          end
          node.outgoing(:watching).each do |repository|
            g.add_edge(users_hash[node["login"]], repos_hash[repository["full_name"]])
          end
        end
      end
    end

   #g.output( :svg => SVG_FILENAME, :use => "dot")
   #g.output(:png => FILENAME)
   g.output(:dot => "output/github.dot")

  end

end