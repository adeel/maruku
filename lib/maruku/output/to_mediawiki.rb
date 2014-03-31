module MaRuKu::Out::MediaWiki

  # there are spacing issues with line wrapping
  DefaultLineLength = 10**10

  def to_wiki(context={})
    children_to_wiki(context)
  end

  def to_wiki_header(context)
    s = "=" * @level
    "#{s} #{children_to_wiki(context)} #{s}\n\n"
  end

  def to_wiki_inline_code(context)
    "<code>#{@raw_code}</code>"
  end

  def to_wiki_code(context)
    "<pre>#{@raw_code}</pre>\n\n"
  end

  def to_wiki_quote(context)
    line_length = (context[:line_length] || DefaultLineLength) - 2
    s = wrap(@children, line_length, context)
    "<blockquote>\n#{s}</blockquote>\n\n"
  end

  def to_wiki_hrule(context)
    "<hr/>\n"
  end

  def to_wiki_emphasis(context)
    "''#{children_to_wiki(context)}''"
  end

  def to_wiki_strong(context)
    "'''#{children_to_wiki(context)}'''"
  end

  def to_wiki_immediate_link(context)
    "[#{@url}]"
  end

  def to_wiki_email_address(context)
    "[#{@email}]"
  end

  def to_wiki_entity(context)
    "&#{@entity_name};"
  end

  def to_wiki_linebreak(context)
    "\n"
  end

  def to_wiki_paragraph(context)
    line_length = context[:line_length] || DefaultLineLength
    wrap(@children, line_length, context)+"\n"
  end

  def to_wiki_div(context)
    m = "<div"
    attributes.each do |k, v|
      m << " #{k.to_s}=\"#{v.to_s}\""
    end
    m << ">\n" << children_to_wiki(context).strip << "\n</div>\n\n"
  end

  def to_wiki_im_link(context)
    "[#{@url} #{children_to_wiki(context)}]"
  end

  def to_wiki_link(context)
    id = self.ref_id || children_to_s
    if ref = @doc.refs[sanitize_ref_id(id)] || @doc.refs[sanitize_ref_id(children_to_s)]
      url = ref[:url] if ref[:url]
      title = children_to_wiki(context)
      if ref[:title]
        title = ref[:title]
      end
    else
      maruku_error "Could not find ref_id = #{id.inspect} for #{self.inspect}\n" +
        "Available refs are #{@doc.refs.keys.inspect}"
      tell_user "Not creating a link for ref_id = #{id.inspect}.\n"
      return children_to_wiki(context)
    end

    "[#{url} #{title}]"
  end

  def to_wiki_im_image(context)
    "[[Image:#{@url}|#{children_to_wiki(context)}]]"
  end

  # def to_wiki_image(context)
  #   "![#{children_to_wiki(context)}][#{@ref_id}]"
  # end

  # def to_wiki_ref_definition(context)
  #   "[#{@ref_id}] #{@url}#{" \"#{@title}\"" if @title}"
  # end

  # def to_wiki_abbr_def(context)
  #   "*[#{self.abbr}]: #{self.text}\n"
  # end

  def to_wiki_ol(context)
    len = (context[:line_length] || DefaultLineLength) - 2
    md = ""
    self.children.each_with_index do |li, i|
      w = wrap(li.children, len-2, context)
      s = "# " + w
      md += s
    end
    md + "\n"
  end

  def to_wiki_ul(context)
    len = (context[:line_length] || DefaultLineLength) - 2
    md = ""
    self.children.each_with_index do |li, i|
      w = wrap(li.children, len-2, context)
      s = "* " + w
      md += s
    end
    md + "\n"
  end

  # Convert each child to html
  def children_to_wiki(context)
    array_to_wiki(@children, context)
  end

  def wrap(array, line_length, context)
    out = ""
    line = ""
    array.each do |c|
      if c.kind_of?(MaRuKu::MDElement) &&  c.node_type == :linebreak
        out << line.strip << "  \n"; line="";
        next
      end

      pieces =
        if c.kind_of? String
          c
        elsif c.kind_of?(MaRuKu::MDElement)
          method = "to_wiki_#{c.node_type}"
          method = "to_wiki" unless c.respond_to?(method)
          [c.send(method, context)].flatten
        else
          [c.to_wiki(context)].flatten
        end

      #     puts "Pieces: #{pieces.inspect}"
      pieces.each do |p|
        if p.size + line.size > line_length
          out << line.strip << "\n";
          line = ""
        end
        line << p
      end
    end
    out << line.strip << "\n" if line.size > 0
    out << ?\n if not out[-1] == ?\n
    out
  end


  def array_to_wiki(array, context, join_char='')
    e = []
    array.each do |c|
      if c.is_a?(String)
        e << c
      else
        method = c.kind_of?(MaRuKu::MDElement) ?
        "to_wiki_#{c.node_type}" : "to_wiki"

        if not c.respond_to?(method)
          #raise "Object does not answer to #{method}: #{c.class} #{c.inspect[0,100]}"
          #       tell_user "Using default for #{c.node_type}"
          method = 'to_wiki'
        end

        #     puts "#{c.inspect} created with method #{method}"
        h =  c.send(method, context)

        if h.nil?
          raise "Nil md for #{c.inspect} created with method #{method}"
        end

        if h.kind_of?Array
          e = e + h
        else
          e << h
        end
      end
    end
    e.join(join_char)
  end

end
