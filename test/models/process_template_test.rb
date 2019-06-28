# == Schema Information
#
# Table name: process_templates
#
#  id           :bigint(8)        not null, primary key
#  discarded_at :datetime
#  document     :json             not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  account_id   :bigint(8)        not null
#  creator_id   :bigint(8)        not null
#
# Foreign Keys
#
#  fk_rails_...  (account_id => accounts.id)
#  fk_rails_...  (creator_id => users.id)
#

require "test_helper"

class ProcessTemplateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
