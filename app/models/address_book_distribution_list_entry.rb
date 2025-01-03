# frozen_string_literal: true

class AddressBookDistributionListEntry < AddressBookEntry
  attr_accessor :name, :keywords, :description, :count

  def initialize(name: nil, key: nil, keywords: nil, description: nil, count: 0)
    @name = name
    @key = key
    @keywords = keywords
    @description = description
    @count = count
    super()
  end

  def key
    "dl_#{@key}"
  end
end
