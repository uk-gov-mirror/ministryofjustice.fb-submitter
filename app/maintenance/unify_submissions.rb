class UnifySubmissions
  def maybe_patch!(h)
    if v = h['answer']
      h['answer'] = 'positive' if v == '1'
      h['answer'] = 'negative' if v == '0'
    end
    if v = h['key']
      if v =~ /^.*negativeorpositive$/
        h['key'] = 'theme'
      end
      if v =~ /^.+id$/
        h['key'] = 'id'
      end
      if v =~ /^.+log$/
        h['key'] = 'log'
      end
    end
  end
  
  def transform_payload(p)
    case p
    when Hash
      maybe_patch!(p)
      p.inject({}) do |h, (k, v)|
        h[k] = transform_payload(v)
        h
      end
    when Array
      p.map do |v|
        transform_payload(v)
      end
    end
    p
  end
  
  def run
    Submission.transaction do
      Submission.all.each do |sub|
        sub.payload = transform_payload(sub.payload)
        # pp Hashdiff.diff(sub.payload, transform_payload(Marshal.load(Marshal.dump(sub.payload))))
        sub.save!
      end
    end
  end
end
