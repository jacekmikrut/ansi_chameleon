require "spec_helper"

describe AnsiChameleon::Tag do

  it { should respond_to(:name) }
  it { should respond_to(:name=) }
  it { should respond_to(:parent) }
  it { should respond_to(:parent=) }
  it { should respond_to(:original_string) }
  it { should respond_to(:original_string=) }

  describe 'after initialization' do
    context 'without parameters' do
      its(:name) { should be_nil }
      its(:parent) { should be_nil }
      its(:original_string) { should be_nil }
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

    context 'with :original_string value' do
      subject(:tag) { described_class.new(:original_string => original_string) }
      let(:original_string) { '<tag>' }
      it('should have that value set') { tag.original_string.should equal(original_string) }
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

  describe '#==' do
    subject(:tag   ) { described_class.new(:name => 'name', :parent => parent) }
        let(:other ) { described_class.new(:name => 'name', :parent => parent) }
        let(:parent) { stub(:parent) }

    context 'when tags have the same names and parents' do
      it { expect(tag == other).to be_true }
    end

    context 'when tag names are different' do
      before { other.name = 'different name' }
      it { expect(tag == other).to be_false }
    end

    context 'when tag parents are different' do
      before { other.parent = stub(:different_parent) }
      it { expect(tag == other).to be_false }
    end

    context 'when compared to nil' do
      it { expect(tag == nil).to be_false }
    end
  end
end
