module MaRuKu
  module Out
    module Mediawiki
      def render_mathml(kind, tex)
        # engine = get_setting(:html_math_engine)
        engine = "itex2mml"
        method = "convert_to_mathml_#{engine}"
        if self.respond_to? method
          mathml = self.send(method, kind, tex)
          return mathml || convert_to_mathml_none(kind, tex)
        end
        
        # TODO: Warn here
        raise "A method called #{method} should be defined."
        convert_to_mathml_none(kind, tex)
      end

      def to_wiki_inline_math
        fix_latex("$#{self.math.strip}$")
      end

      def to_wiki_equation
        if self.label
          fix_latex("\\begin{equation}\n#{self.math.strip}\n\\label{#{self.label}}\\end{equation}\n")
        else
          fix_latex("\\begin{displaymath}\n#{self.math.strip}\n\\end{displaymath}\n")
        end
      end

      def to_wiki_eqref
        "\\eqref{#{self.eqid}}"
      end

      def to_wiki_divref
        "\\ref{#{self.refid}}"
      end

      private

      def fix_latex(str)
        return str unless self.get_setting(:html_math_engine) == 'itex2mml'
        s = str.gsub("\\mathop{", "\\operatorname{")
        s.gsub!(/\\begin\{svg\}.*?\\end\{svg\}/m, " ")
        s.gsub!("\\array{","\\itexarray{")
        s.gsub("\\space{", "\\itexspace{")
      end
    end
  end
end
