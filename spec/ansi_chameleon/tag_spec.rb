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

    context 'with :name value given as string' do
      subject(:tag) { described_class.new(:name => 'tag-name') }
      it('should have that value set as string') { tag.name.should == 'tag-name' }
    end

    context 'with :name value given as symbol' do
      subject(:tag) { described_class.new(:name => :'tag-name') }
      it('should have that value set as string') { tag.name.should == 'tag-name' }
    end

    context 'with :parent value' do
      subject(:tag) { described_class.new(:parent => parent) }
      let(:parent) { stub(:parent) }
      it('should have that value set') { tag.parent.should equal(parent) }
    end
  end

  describe '#name=' do
    subject(:tag)

    context 'when called with a string' do
      before { tag.name = 'tag-name' }
      it('should store the value as string') { tag.name.should == 'tag-name' }
    end

    context 'when called with a symbol' do
      before { tag.name = :'tag-name' }
      it('should store the value as string') { tag.name.should == 'tag-name' }
    end

  end

end
