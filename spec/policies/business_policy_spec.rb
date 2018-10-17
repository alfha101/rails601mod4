require 'rails_helper'
# Now our time is limited and we limit our test to all end to
# end. So although as nicest it would to be able to do unit test
# on the policies. We're going to test all our policies inline
# with our integration test. So, the image policy that got
# generated is going to inherit from the application policy 
# and start of with just a really an empty shell of an 
# implementation. 
# TODO: En otras palabras, se eliminaron los dos archivos:
# thing_policy_spec e image_policy_spec:
# rm spec/policies/image_policy_spec.rb 




RSpec.describe BusinessPolicy do

  let(:user) { User.new }

  subject { described_class }

  permissions ".scope" do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :show? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :create? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :update? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :destroy? do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end
