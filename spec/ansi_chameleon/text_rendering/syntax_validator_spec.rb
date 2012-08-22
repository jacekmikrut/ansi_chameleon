require "spec_helper"

describe "AnsiChameleon::TextRendering instance" do
  describe "extended with AnsiChameleon::TextRendering::SyntaxValidator" do

    subject(:text_rendering) do
      AnsiChameleon::TextRendering.new(style_sheet_handler)
      .extend(AnsiChameleon::TextRendering::SyntaxValidator)
    end

    let(:style_sheet_handler) { stub(:style_sheet_handler, :value_for => nil) }

    before { AnsiChameleon::SequenceGenerator.stub(:generate => "sequence") }

    describe "#push_closing_tag" do
      context "if the opening tag hasn't been pushed" do
        it do
          lambda { text_rendering.push_closing_tag(stub(:tag, :name => 'tag', :original_string => '</tag>')) }
          .should raise_error(SyntaxError, "Encountered </tag> tag that had not been opened yet")
        end
      end
    end

    describe "#to_s" do
      context "when one tag has not been closed yet" do
        before do
          text_rendering.push_opening_tag(stub(:tag, :name => 'tag', :parent= => nil, :original_string => '<tag id="id" class="class">'))
        end

        it do
          lambda { text_rendering.to_s }
          .should raise_error(SyntaxError, 'Tag <tag id="id" class="class"> has been opened but not closed yet')
        end
      end

      context "when more than one tag have not been closed yet" do
        before do
          text_rendering.push_opening_tag(stub(:tag_1, :name => "tag_1", :parent= => nil, :original_string => '<tag_1 id="id1">'))
          text_rendering.push_opening_tag(stub(:tag_2, :name => "tag_2", :parent= => nil, :original_string => '<tag_2 id="id2">'))
        end

        it do
          lambda { text_rendering.to_s }
          .should raise_error(SyntaxError, 'Tags <tag_1 id="id1">, <tag_2 id="id2"> have been opened but not closed yet')
        end
      end
    end
  end
end
