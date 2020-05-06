class EmailPayload < ActiveRecord::Base
  serialize :attachments, Array
end
