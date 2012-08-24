require "spec_helper"

describe "Single use" do

  it "should properly render the output" do
    AnsiChameleon.render(
      '<poetry class="short">There are <number>3</number> oranges on the table.</poetry>',
      'poetry.short' => { :effect => :bright }, 'number' => { :fg_color => :blue }
    )
    .should == "\e[0m\e[37m\e[40m\e[1m\e[37m\e[40mThere are \e[1m\e[34m\e[40m3\e[1m\e[37m\e[40m oranges on the table.\e[0m\e[37m\e[40m\e[0m"
  end
end

describe "Multiple use" do

  it "should properly render the output" do
    text_renderer = AnsiChameleon::TextRenderer.new("poetry.short" => { :effect => :bright }, "number" => { :fg_color => :blue })

    text_renderer.render('<poetry class="short">There are <number>2</number> oranges on the table.</poetry>')
    .should == "\e[0m\e[37m\e[40m\e[1m\e[37m\e[40mThere are \e[1m\e[34m\e[40m2\e[1m\e[37m\e[40m oranges on the table.\e[0m\e[37m\e[40m\e[0m"

    text_renderer.render('<poetry class="short">Now, there is only <number>1</number> orange.</poetry>')
    .should == "\e[0m\e[37m\e[40m\e[1m\e[37m\e[40mNow, there is only \e[1m\e[34m\e[40m1\e[1m\e[37m\e[40m orange.\e[0m\e[37m\e[40m\e[0m"
  end
end

describe "Rendering text" do

  shared_examples_for "properly rendered text" do
    it "should properly render the text" do
      AnsiChameleon.render( "There are <number>3</number> oranges on the table.", style_sheet)
      .should == "\e[0m\e[37m\e[40mThere are \e[0m\e[34m\e[40m3\e[0m\e[37m\e[40m oranges on the table.\e[0m"
    end
  end

  context "when the style sheet property names are of the String class" do
    let(:style_sheet) { { "number" => { "fg_color" => :blue } } }
    include_examples "properly rendered text"
  end

  context "when the style sheet property names are of the Symbol class" do
    let(:style_sheet) { { "number" => { :fg_color => :blue } } }
    include_examples "properly rendered text"
  end

  context "when the style sheet property values are of the String class" do
    let(:style_sheet) { { "number" => { :fg_color => "blue" } } }
    include_examples "properly rendered text"
  end
end

describe "Text with a syntax error:" do

  context "lack of the closing tag" do
    it do
      lambda { AnsiChameleon.render("There are <number>3 oranges on the table.", {}) }
      .should raise_error(SyntaxError, "Tag <number> has been opened but not closed yet")
    end
  end

  context "trying to close a tag that has not been opened" do
    it do
      lambda { AnsiChameleon.render("There are <number>3</amount> oranges on the table.", {}) }
      .should raise_error(SyntaxError, "Encountered </amount> tag that had not been opened yet")
    end
  end
end
