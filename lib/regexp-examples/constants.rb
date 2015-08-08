# :nodoc:
module RegexpExamples
  # Configuration settings to limit the number/length of Regexp examples generated
  class ResultCountLimiters
    # The maximum variance for any given repeater, to prevent a huge/infinite number of
    # examples from being listed. For example, if @@max_repeater_variance = 2 then:
    # .* is equivalent to .{0,2}
    # .+ is equivalent to .{1,3}
    # .{2,} is equivalent to .{2,4}
    # .{,3} is equivalent to .{0,2}
    # .{3,8} is equivalent to .{3,5}
    MAX_REPEATER_VARIANCE_DEFAULT = 2

    # Maximum number of characters returned from a char set, to reduce output spam
    # For example, if @@max_group_results = 5 then:
    # \d is equivalent to [01234]
    # \w is equivalent to [abcde]
    MAX_GROUP_RESULTS_DEFAULT = 5

    class << self
      attr_reader :max_repeater_variance, :max_group_results
      def configure!(max_repeater_variance, max_group_results = nil)
        @max_repeater_variance = (max_repeater_variance || MAX_REPEATER_VARIANCE_DEFAULT)
        @max_group_results = (max_group_results || MAX_GROUP_RESULTS_DEFAULT)
      end
    end
  end

  def self.max_repeater_variance
    ResultCountLimiters.max_repeater_variance
  end
  def self.max_group_results
    ResultCountLimiters.max_group_results
  end

  # Definitions of various special characters, used in regular expressions.
  # For example, `/\h/.examples` will return the value of `Hex` in this module
  module CharSets
    Lower        = Array('a'..'z')
    Upper        = Array('A'..'Z')
    Digit        = Array('0'..'9')
    # Note: Punct should also include the following chars: $ + < = > ^ ` | ~
    # I.e. Punct = %w(! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \\ ] ^ _ ` { | } ~)
    # However, due to a ruby bug (!!) these do not work properly at the moment!
    Punct        = %w(! " # % & ' ( ) * , - . / : ; ? @ [ \\ ] _ { })
    Hex          = Array('a'..'f') | Array('A'..'F') | Digit
    Word         = Lower | Upper | Digit | ['_']
    Whitespace   = [' ', "\t", "\n", "\r", "\v", "\f"]
    Control      = (0..31).map(&:chr) | ["\x7f"]
    # Ensure that the "common" characters appear first in the array
    # Also, ensure "\n" comes first, to make it obvious when included
    Any          = ["\n"] | Lower | Upper | Digit | Punct | (0..127).map(&:chr)
    AnyNoNewLine = Any - ["\n"]
  end.freeze

  # Map of special regex characters, to their associated character sets
  BackslashCharMap = {
    'd' => CharSets::Digit,
    'D' => CharSets::Any - CharSets::Digit,
    'w' => CharSets::Word,
    'W' => CharSets::Any - CharSets::Word,
    's' => CharSets::Whitespace,
    'S' => CharSets::Any - CharSets::Whitespace,
    'h' => CharSets::Hex,
    'H' => CharSets::Any - CharSets::Hex,

    't' => ["\t"], # tab
    'n' => ["\n"], # new line
    'r' => ["\r"], # carriage return
    'f' => ["\f"], # form feed
    'a' => ["\a"], # alarm
    'v' => ["\v"], # vertical tab
    'e' => ["\e"], # escape
  }.freeze

  POSIXCharMap = {
    'alnum'  => CharSets::Upper | CharSets::Lower | CharSets::Digit,
    'alpha'  => CharSets::Upper | CharSets::Lower,
    'blank'  => [' ', "\t"],
    'cntrl'  => CharSets::Control,
    'digit'  => CharSets::Digit,
    'graph'  => (CharSets::Any - CharSets::Control) - [' '], #  Visible chars
    'lower'  => CharSets::Lower,
    'print'  => CharSets::Any - CharSets::Control,
    'punct'  => CharSets::Punct,
    'space'  => CharSets::Whitespace,
    'upper'  => CharSets::Upper,
    'xdigit' => CharSets::Hex,
    'word'   => CharSets::Word,
    'ascii'  => CharSets::Any
  }.freeze

  NamedPropertyCharMap = UnicodeCharRanges.new
end
