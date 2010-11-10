module Utils
  def start_tx
    finish_tx if @tx
    @tx = Neo4j::Transaction.new
  end

  def finish_tx
    return if !@tx
    @tx.success
    @tx.finish
    @tx = nil
  end
end
