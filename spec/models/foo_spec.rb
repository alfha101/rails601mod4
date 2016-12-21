require 'rails_helper'

describe Foo, type: :model do
  before(:all) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end
  before(:each) do
    DatabaseCleaner.start
  end
  after(:each) do
    DatabaseCleaner.clean
  end

  context "created Foo (let)" do
    let(:foo) { Foo.create(:name => "test") }

    it { expect(foo).to be_persisted }
    it { expect(foo.name).to eq("test") }
    it { expect(Foo.find(foo.id)).to_not be_nil }
  end

  context "created Foo (subject)" do
    subject { Foo.create(:name => "test") }

    it { is_expected.to be_persisted }
    it { expect(subject.name).to eq("test") }
    it { expect(Foo.find(subject.id)).to_not be_nil }
  end

  context "created Foo (eager)" do
    let!(:before_count) { Foo.count }
    let(:foo)          { Foo.create(:name => "test") }

    it { expect(foo).to be_persisted }
    it { expect(foo.name).to eq("test") }
    it { expect(Foo.find(foo.id)).to_not be_nil }
    it { foo; expect(Foo.count).to eq(before_count + 1) }
  end
end