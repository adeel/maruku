module MaRuKu::Out::MediaWiki

  def to_wiki(context={})
    children_to_wiki(context)
  end

  def to_wiki_header(context)
    s = "=" * @level
    "\n#{s} #{children_to_wiki(context)} #{s}\n"
  end

  def to_wiki_inline_code(context)
    wrap_with_attrs @raw_code, {:tag => "code"}
  end

  def to_wiki_code(context)
    wrap_with_attrs @raw_code, {:tag => "pre"}
  end

  def to_wiki_quote(context)
    wrap_with_attrs children_to_wiki(context), {:tag => "blockquote"}
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
    wrap_with_attrs children_to_wiki(context)
  end

  def to_wiki_div(context)
    wrap_with_attrs children_to_wiki(context)
  end

  def to_wiki_im_link(context)
    if url.start_with? "#"
      "[[#{url}|#{children_to_wiki(context)}]]"
    else
      "[#{@url} #{children_to_wiki(context)}]"
    end
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

    if url.start_with? "#"
      "[[#{url}|#{title}]]"
    else
      "[#{url} #{title}]"
    end
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
    out = ""
    self.children.each_with_index do |li, i|
      w = array_to_wiki(li.children, context)
      s = "# " + w.strip + "\n\n"
      out += s
    end
    wrap_with_attrs out
  end

  def to_wiki_ul(context)
    out = ""
    self.children.each_with_index do |li, i|
      w = array_to_wiki(li.children, context)
      s = "* " + w.strip + "\n\n"
      out += s
    end
    wrap_with_attrs out
  end

  def to_wiki_li(context)
    wrap_with_attrs "* " + children_to_wiki(context).strip
  end

  def wrap_with_attrs(content, options={})
    tag = options.fetch("tag", "div")
    object = options.fetch("object", self)
    content = "\n#{content.strip}\n"
    attrs = MaRuKu::Out::HTML::filter_attributes(tag, @attributes)
    if attrs.empty? or tag != "div"
      content
    else
      MaRuKu::Out::HTML::wrap_with_attrs(tag, content, @attributes) + "\n\n"
    end
  end

  # Convert each child to html
  def children_to_wiki(context)
    array_to_wiki(@children, context)
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
