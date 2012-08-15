require "spec_helper"

describe AnsiChameleon::Tag do

  it { should respond_to(:name) }
  it { should respond_to(:name=) }
  it { should respond_to(:parent) }
  it { should respond_to(:parent=) }

  describe 'after initialization' do
    context 'without parameters' do
      its(:name) { should be_nil }
      its(:parent) { should be_nil }
    end

    context 'with :name value' do
      subject(:tag) { described_class.new(:name => 'tag-name') }
      it('should have that value set') { tag.name.should == 'tag-name' }
    end

    context 'with :parent value' do
      subject(:tag) { described_class.new(:parent => parent) }
      let(:parent) { stub(:parent) }
      it('should have that value set') { tag.parent.should equal(parent) }
    end
  end

end
