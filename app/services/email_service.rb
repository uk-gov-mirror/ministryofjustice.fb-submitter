class EmailService
  def self.send( opts = {} )
    adapter.send(opts.merge(raw_message: RawMessage.new(opts)))
  end

  def self.adapter
    Adapters::AmazonSESAdapter
  end
end
