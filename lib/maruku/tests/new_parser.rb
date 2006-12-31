require 'maruku'
require 'maruku/helpers'

require 'maruku/parse_span_better'

class Maruku


	class TestNewParser
		include Helpers
			
		# 5 accented letters in italian, encoded as UTF-8
		AccIta8 = "\303\240\303\250\303\254\303\262\303\271"

		# Same letters, written in ISO-8859-1 (one byte per letter)
		AccIta1 = "\340\350\354\362\371"
		
		# The word MA-RU-KU, written in katakana using UTF-8
		Maruku8 = "\343\203\236\343\203\253\343\202\257"
		
		def do_it(verbose, break_on_first_error)
		good_cases = [
			["",       [],         'Empty string gives empty list'],
			["a",      ["a"],      'Easy char'],
			[' ',      [' '],      'One char => one string'],
			['  ',     [' '],      'Two chars => one char'],
			['a  b',   ['a b'],    'Spaces are compressed'],
			['a  b',   ['a b'],    'Newlines are spaces'],
			["a\nb",   ['a b'],    'Newlines are spaces'],
			["a\n b",  ['a b'],    'Compress newlines 1'],
			["a \nb",  ['a b'],    'Compress newlines 2'],
			[" \nb",   [' b'],     'Compress newlines 3'],
			["\nb",    [' b'],     'Compress newlines 4'],
			["b\n",    ['b '],     'Compress newlines 5'],
			["\n",     [' '],      'Compress newlines 6'],
			["\n\n\n", [' '],      'Compress newlines 7'],
			
			[nil, :throw, "Should throw on nil input"],
			
			# Code blocks
			["`" ,   :throw,  'Unclosed single ticks'],
			["``" ,  :throw,  'Unclosed double ticks'],
			["`a`" ,     [md_code('a')],    'Simple inline code'],
			["`\'`" ,    [md_code('\'')],   ],
			["``a``" ,   [md_code('a')],    ],
			["``\\'``" , [md_code('\\\'')], ],
			
			# Newlines 
			["a  \n", ['a',md_el(:linebreak)], 'Two spaces give br.'],
			["a \n",  ['a '], 'Newlines 2'],
			["  \n",  [md_el(:linebreak)], 'Newlines 3'],
			["  \n  \n",  [md_el(:linebreak),md_el(:linebreak)],'Newlines 3'],
			["  \na  \n",  [md_el(:linebreak),'a',md_el(:linebreak)],'Newlines 3'],
			
			# Inline HTML
			["a < b", ['a < b'], '< can be on itself'],
			["<hr>",  [md_html('<hr />')], 'HR will be sanitized'],
			["<hr/>", [md_html('<hr />')], 'Closed tag is ok'],
			["<hr  />", [md_html('<hr />')], 'Closed tag is ok 2'],
			["<hr/>a", [md_html('<hr />'),'a'], 'Closed tag is ok 2'],
			["<em></em>a", [md_html('<em></em>'),'a'], 'Inline HTML 1'],
			["<em>e</em>a", [md_html('<em>e</em>'),'a'], 'Inline HTML 2'],
			["a<em>e</em>b", ['a',md_html('<em>e</em>'),'b'], 'Inline HTML 5'],
			["<em>e</em>a<em>f</em>", 
				[md_html('<em>e</em>'),'a',md_html('<em>f</em>')], 
				'Inline HTML 3'],
			["<em>e</em><em>f</em>a", 
				[md_html('<em>e</em>'),md_html('<em>f</em>'),'a'], 
				'Inline HTML 4'],
			
			# emphasis
			["**", :throw, 'Unclosed double **'],
			["\\*", ['*'], 'Escaping of *'],
			["a *b* ", ['a ', md_em('b'),' '], 'Emphasis 1'],
			["a *b*", ['a ', md_em('b')], 'Emphasis 2'],
			["a * b", ['a * b'], 'Emphasis 3'],
			["a * b*", :throw, 'Unclosed emphasis'],
			# same with underscore
			["__", :throw, 'Unclosed double __'],
			["\\_", ['_'], 'Escaping of _'],
			["a _b_ ", ['a ', md_em('b'),' '], 'Emphasis 4'],
			["a _b_", ['a ', md_em('b')], 'Emphasis 5'],
			["a _ b", ['a _ b'], 'Emphasis 6'],
			["a _ b_", :throw, 'Unclosed emphasis'],
			["_b_", [md_em('b')], 'Emphasis 7'],
			["_b_ _c_", [md_em('b'),' ',md_em('c')], 'Emphasis 8'],
			["_b__c_", [md_em('b'),md_em('c')], 'Emphasis 9'],
			# strong
			["**a*", :throw, 'Unclosed double ** 2'],
			["\\**a*", ['*', md_em('a')], 'Escaping of *'],
			["a **b** ", ['a ', md_strong('b'),' '], 'Emphasis 1'],
			["a **b**", ['a ', md_strong('b')], 'Emphasis 2'],
			["a ** b", ['a ** b'], 'Emphasis 3'],
			["a ** b**", :throw, 'Unclosed emphasis'],
			["**b****c**", [md_strong('b'),md_strong('c')], 'Emphasis 9'],
			# strong (with underscore)
			["__a_", :throw, 'Unclosed double __ 2'],
			["\\__a_", ['_', md_em('a')], 'Escaping of _'],
			["a __b__ ", ['a ', md_strong('b'),' '], 'Emphasis 1'],
			["a __b__", ['a ', md_strong('b')], 'Emphasis 2'],
			["a __ b", ['a __ b'], 'Emphasis 3'],
			["a __ b__", :throw, 'Unclosed emphasis'],
			["__b____c__", [md_strong('b'),md_strong('c')], 'Emphasis 9'],
			# extra strong
			["***a**", :throw, 'Unclosed triple *** '],
			["\\***a**", ['*', md_strong('a')], 'Escaping of *'],
			["a ***b*** ", ['a ', md_emstrong('b'),' '], 'Strong elements'],
			["a ***b***", ['a ', md_emstrong('b')]],
			["a *** b", ['a *** b']],
			["a ** * b", ['a ** * b']],
			["***b******c***", [md_emstrong('b'),md_emstrong('c')]],
			["a *** b***", :throw, 'Unclosed emphasis'],
			# same with underscores
			["___a__", :throw, 'Unclosed triple *** '],
			["\\___a__", ['_', md_strong('a')], 'Escaping of *'],
			["a ___b___ ", ['a ', md_emstrong('b'),' '], 'Strong elements'],
			["a ___b___", ['a ', md_emstrong('b')]],
			["a ___ b", ['a ___ b']],
			["a __ _ b", ['a __ _ b']],
			["___b______c___", [md_emstrong('b'),md_emstrong('c')]],
			["a ___ b___", :throw, 'Unclosed emphasis'],
			# mixing is bad
			["*a_", :throw, 'Mixing is bad'],
			["_a*", :throw],
			["**a__", :throw],
			["__a**", :throw],
			["___a***", :throw],
			["***a___", :throw],
			# links of the form [text][ref]
			["\\[a]",  ["[a]"], 'Escaping 1'],
			["\\[a\\]", ["[a]"], 'Escaping 2'],
			["[a]",   ["a"],   'Not a link'],
			["[a][]",   [ md_link(["a"],'')], 'Empty link'],
			["[a\\]][]", [ md_link(["a]"],'')], 'Escape inside link'],
			
			["[a",  :throw,   'Link not closed'],
			["[a][",  :throw,   'Ref not closed'],
			
			# links of the form [text](url)
			["\\[a](b)",  ["[a](b)"], 'Links'],
			["[a](url)",  [md_im_link(['a'],'url')], 'url'],
			["[a]( url )" ],
			["[a] (	url )" ],
			["[a] (	url)" ],
			
			["[a](ur:/l/ 'Title')",  [md_im_link(['a'],'ur:/l/','Title')],
			 	'url and title'],
			["[a] (	ur:/l/ \"Title\")" ],
			["[a] (	ur:/l/ \"Title\")" ],
			["[a]( ur:/l/ Title)", :throw, "Must quote title" ],

			["[a](url 'Tit\\\"l\\\\e')", [md_im_link(['a'],'url','Tit"l\\e')],
			 	'url and title escaped'],
			["[a] (	url \"Tit\\\"l\\\\e\")" ],
			["[a] (	url	\"Tit\\\"l\\\\e\"  )" ],
			['[a] (	url	"Tit\\"l\\\\e"  )' ],
		
			["[a](\"Title\")", :throw, "No url specified" ],
			["[a]()"],
			["[a](url \"Title)", :throw, "Unclosed quotes" ],
			["[a](url \"Title\\\")", :throw],
			["[a](url \"Title\" ", :throw],

			["[a](url \'Title\")", :throw, "Mixing is bad" ],
			["[a](url \"Title\')"],
			
			["[a](/url)", [md_im_link(['a'],'/url')], 'Funny chars in url'],
			["[a](#url)", [md_im_link(['a'],'#url')]],
			
			# Images
			["\\![a](url)",  ['!', md_im_link(['a'],'url') ], 'Escaping images'],
			
			["![a](url)",  [md_im_image(['a'],'url')], 'Image no title'],
			["![a]( url )" ],
			["![a] (	url )" ],
			["![a] (	url)" ],

			["![a](url 'ti\"tle')",  [md_im_image(['a'],'url','ti"tle')], 'Image with title'],
			['![a]( url "ti\\"tle")' ],

			["![a](url", :throw, 'Invalid images'],
			["![a( url )" ],
			["![a] ('url )" ],

			["![a][imref]",  [md_image(['a'],'imref')], 'Image with ref'],
			["![a][ imref]"],
			["![a][ imref ]"],
			["![a][\timref\t]"],
			
					
			["a<!-- -->b", ['a',md_html('<!-- -->'),'b'], 
				'HTML Comment'],

			["a<!--", :throw, 'Bad HTML Comment'],
			["a<!-- ", :throw, 'Bad HTML Comment'],

			["a <b", :throw, 'Bad HTML 1'],
			["<b",   :throw, 'Bad HTML 2'],
			["<b!",  :throw, 'Bad HTML 3'],
			
			["#{Maruku8}", [Maruku8], "Reading UTF-8"],
			["#{AccIta1}", [AccIta8], "Converting ISO-8859-1 to UTF-8", 
				{:encoding => 'iso-8859-1'}],
		]

			count = 1; last_comment=""; last_expected=:throw
			good_cases.each do |t|
				if not t[1]
					t[1] = last_expected
				else
					last_expected = t[1]
				end				
				if not t[2]
					t[2] = last_comment + " #{count+=1}"
				else
					last_comment = t[2]; count=1
				end
			end
				
			@verbose = verbose
			m = Maruku.new
			good_cases.each do |input, expected, comment|
					output = nil
					begin
						output = m.parse_span_better(input)
						#lines = Maruku.split_lines input
						#output = m.parse_lines_as_span(lines)
					rescue Exception => e
						if not expected == :throw
							ex = e.inspect+ "\n"+ e.backtrace.join("\n")
							s = comment+"\nInput:\n  #{input.inspect}" +
							    "\nExpected:\n  #{expected.inspect}" +
								"\nOutput:\n  #{output.inspect}\n#{ex}"
							print_status(comment,'CRASHED :-(',s)
							raise e if @break_on_first_error 
						else
							print_status(comment,'OK')
						end
					end
					
					if not expected == :throw
						if not (expected == output)
							s = comment+"\nInput:\n  #{input.inspect}" +
							    "\nExpected:\n  #{expected.inspect}" +
								"\nOutput:\n  #{output.inspect}"
							print_status(comment, 'FAILED', s)
							break if break_on_first_error
						else
							print_status(comment, 'OK')
						end
					else # I expected a raise
						if output
							s = comment+"\nInput:\n  #{input.inspect}" +
								"\nOutput:\n  #{output.inspect}"
							print_status(comment, 'FAILED (no throw)', s)
							break if break_on_first_error
						end
					end
					
			end
		end
		
		PAD=40
		def print_status(comment, status, verbose_text=nil)
			if comment.size < PAD
				comment = comment + (" "*(PAD-comment.size))
			end
			puts "- #{comment} #{status}"
			if @verbose and verbose_text
				puts verbose_text
			end
		end
		
	end # class Test
end

verbose = ARGV.include? 'v'
break_on_first = ARGV.include? 'b'
Maruku::TestNewParser.new.do_it(verbose, break_on_first)

