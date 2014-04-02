module MaRuKu
  module Out
    module MediaWiki
      def render_mathml(kind, tex)
        engine = get_setting(:html_math_engine)
        method = "convert_to_mathml_#{engine}"
        if self.respond_to? method
          mathml = self.send(method, kind, tex)
          return mathml || convert_to_mathml_none(kind, tex)
        end
        
        # TODO: Warn here
        raise "A method called #{method} should be defined."
        convert_to_mathml_none(kind, tex)
      end

      def to_wiki_inline_math(context)
        "$#{self.math.strip}$"
      end

      def to_wiki_equation(context)
        if self.label
          "\\begin{equation}\n#{self.math.strip}\n\\label{#{self.label}}\\end{equation}\n"
        else
          "\\\[ #{self.math.strip} \\\]\n\n"
        end
      end

      def to_wiki_eqref(context)
        "\\eqref{#{self.eqid}}"
      end

      def to_wiki_divref(context)
        "\\ref{#{self.refid}}"
      end
    end
  end
end
