class RAGE::SLParser

  token STRING PARAMETER_NAME DATE_TIME INTEGER FLOAT VARIABLE_IDENTIFIER

rule

  content:			'(' content_expressions ')'

  content_expressions:		content_expression
				| content_expressions content_expression

  content_expression:		identifying_expression
				| action_expression
				| proposition

  proposition:			wff

  wff:				atomic_formula
				| '(' unary_logic_op  wff ')'
				| '(' binary_logic_op wff wff ')'
				| '(' quantifier      variable wff ')'
				| '(' modal_op        agent wff ')'
				| '(' action_op       action_expression ')'
				| '(' action_op       action_expression wff ')'

  unary_logic_op:		'not'

  binary_logic_op:		'and'
				| 'or'
				| 'implies'
				| 'equiv'

  atomic_formula:		proposition_symbol
				| '(' binary_term_op term_or_ie term_or_ie ')'
				| '(' predicate_symbol term_or_ie_list ')'
				| 'true'
				| 'false'

  binary_term_op:		'='
				| 'result'

  quantifier:			'forall'
				| 'exists'

  modal_op:			'B'
				| 'U'
				| 'PG'
				| 'I'

  action_op:			'feasible'
				| 'done'

  term_or_ie_list:		term_or_ie
				| term_or_ie_list term_or_ie

  term_or_ie:			term
				| identifying_expression

  term:				variable
				| functional_term
				| action_expression
				| constant
				| sequence
				| set

  identifying_expression:	'(' referential_operator term_or_ie wff ')'

  referential_operator:		'iota'
				| 'any'
				| 'all'

  parameters:			parameter
				| parameters parameter

  functional_term:		'(' function_symbol ')'
				| '(' function_symbol term_or_ie_list ')'
				| '(' function_symbol parameters ')'

  constant:			numerical_constant
				| STRING
				| DATE_TIME

  numerical_constant:		INTEGER
				| FLOAT

  variable:			VARIABLE_IDENTIFIER

  action_expression:		'(' 'action' agent term_or_ie ')'
				| '(' '|' action_expression action_expression ')'
				| '(' ';' action_expression action_expression ')'

  proposition_symbol:		STRING

  predicate_symbol:		STRING

  function_symbol:		term_or_ie

  agent:			term_or_ie

  sequence:			'(' 'sequence' ')'
  				| '(' 'sequence' term_or_ie_list ')'

  set:				'(' 'set' ')'
				| '(' 'set' term_or_ie_list ')'

  parameter:			PARAMETER_NAME parameter_value

  parameter_value:		term_or_ie

end

---- header

require 'strscan'
require 'rage/content'

---- inner

  #
  # Parse a content string in FIPA SL and return a Content instance.
  #
  def parse(src)
    @content = Content.new
    @scanner = StringScanner.new(src)
    yyparse(self, :scan)
    @content
  end

  def scan
    until @scanner.eos? do
      if    @scanner.scan(/:[^-\x00-\x20()#\d:?][^\x00-\x20()]*/) # :Word
        yield :PARAMETER_NAME, @scanner.matched
      elsif @scanner.scan(/:"([^"]|\\")*"/)                       # :StringLiteral
        yield :PARAMETER_NAME, @scanner.matched
      elsif @scanner.scan(/\?[^-\x00-\x20()#\d:?][^\x00-\x20()]*/) # ?Word
        yield :VARIABLE_IDENTIFIER, @scanner.matched
      elsif @scanner.scan(/\?"([^"]|\\")*"/)                       # ?StringLiteral
        yield :VARIABLE_IDENTIFIER, @scanner.matched
      elsif @scanner.scan(/[-+]?\d+/) || @scanner.scan(/[-+]?0[xX][\dA-Fa-f]+/)
        yield :INTEGER, @scanner.matched
      elsif @scanner.scan(/[-+]?\d+\.\d*([eE][-+]?\d+)?/)
        yield :FLOAT, @scanner.matched
      elsif @scanner.scan(/[-+]?\d*\.\d+([eE][-+]?\d+)?/)
        yield :FLOAT, @scanner.matched
      elsif @scanner.scan(/[-+]?\d+([eE][-+]?\d+)/)
        yield :FLOAT, @scanner.matched
      elsif @scanner.scan(/[-+]?\d{8,8}T\d{9,9}[A-Za-z]?/)
        yield :DATE_TIME, @scanner.matched
      elsif @scanner.scan(/[^-\x00-\x20()#\d:?][^\x00-\x20()]*/)  # Word
        yield :STRING, @scanner.matched
      elsif @scanner.scan(/"([^"]|\\")*"/)                        # StringLiteral
        yield :STRING, @scanner.matched
      elsif @scanner.scan(/\s+/)
        # skip whitespace
      else
        yield @scanner.scan(/./), @scanner.matched
      end
    end
    yield false, '$'
  end

---- footer

if __FILE__ == $0
  parser = RAGE::SLParser.new
  parser.parse("((action (agent-identifier :name j) (deliver box017 (loc 12 19))))")
end

