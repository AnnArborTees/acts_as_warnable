class Warning < ActiveRecord::Base
  belongs_to :warnable, polymorphic: true
end
