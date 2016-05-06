# The public interface for Maruku.
#
# @example Render a document fragment
# Maruku.new("## Header ##").to_html
# # => "<h2 id='header'>header</h2>"
class Maruku < MaRuKu::MDDocument
  def initialize(s = nil, meta = {})
    super()
    self.attributes.merge! meta
    if get_setting(:html_math_generate_ids)
      self.math_id_prefix = "mathml_#{s ? Digest::SHA1.hexdigest(s) : rand(10000)}_"
      self.math_id_counter = 0
    end
    
    parse_doc(s) if s
  end

  def to_s
    warn "Maruku#to_s is deprecated and will be removed or changed in a near-future version of Maruku."
    super
  end
end
