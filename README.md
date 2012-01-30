AnsiChameleon
=============

AnsiChameleon is a Ruby Gem that **colorizes text terminal output** by converting custom HTML-like tags into color ANSI escape sequences.

Installation
------------

As a Ruby Gem, AnsiChameleon can be installed either by running

```bash
  gem install ansi_chameleon
```

or adding

```ruby
  gem "ansi_chameleon"
```

to the Gemfile and then invoking `bundle install`.

Usage
-----

For **single use**:

```ruby
  require "ansi_chameleon"

  puts AnsiChameleon.render(
    "There are <number>3</number> oranges on the table.",
    :number => { :fg_color => :blue }
  )
```

For **multiple use** this is more efficient:

```ruby
  require "ansi_chameleon"

  text_renderer = AnsiChameleon::TextRenderer.new(:number => { :fg_color => :blue })

  puts text_renderer.render("There are <number>2</number> oranges on the table.")
  puts text_renderer.render("Now, there is only <number>1</number> orange.")
```

Details
-------

In order to produce a colorized output AnsiChameleon needs a **text** and a **style sheet**.

### Text

Text to colorize is expected to include HTML-like tags of custom names, that will then be converted according to the rules defined in provided style sheet.

Tags not included in the style sheet but found in the text being rendered are put to the output without modification.

### Style sheet

A style sheet is simply a CSS-like Hash structure with keys that correspond to custom tag names and property names:

```ruby
  style_sheet = {
    # default style declarations (for text not wrapped in tags)
    :fg_color => :green,
    :bg_color => :black,

    :number => {
      # style declarations for <number> tag
      :fg_color => :blue,
    },
    :message => {
      # style declarations for <message> tag
      :fg_color => :red,
      :bg_color => :white,

      :number => {
        # style declarations for <number> tag nested in <message> tag
        :fg_color => :inherit
      }
    }
  }
```

Tag names in a style sheet can be written as either :symbols or "strings".

#### Properties

* `:foreground_color` (aliases: `:foreground`, `:fg_color`)
* `:background_color` (aliases: `:background`, `:bg_color`)

    Available color values: `:black`, `:red`, `:green`, `:yellow`, `:blue`, `:magenta`, `:cyan`, `:white`.

* `:effect`

    Available effect values: `:none`, `:bright`, `:underline`, `:blink`, `:reverse`.

Also, the `:inherit` value can be set for a property, which means that its value will be inherited from the surrounding tag (or be the default value).

Similarly to tag names, property names and values can be provided as :symbols or "strings".

License
-------

License is included in the LICENSE file.
