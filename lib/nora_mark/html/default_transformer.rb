module NoraMark
  module Html
    DEFAULT_TRANSFORMER = TransformerFactory.create do
      rename 'd', 'div'
      rename 'art', 'article'
      rename 'arti', 'article'
      rename 'sec', 'section'
      rename 'sect', 'section'
      rename 'sp', 'span'

      modify(/\A(l|link)\Z/) do
        @node.name = 'a'
        (@node.attrs ||= {}).merge!({href: [@node.params[0].text]})
      end

      modify 'ruby' do
        @node.append_child inline 'rp', '('
        @node.append_child inline 'rt', escape_html(@node.params[0].text.strip)
        @node.append_child inline 'rp', ')'
      end

      modify 'tcy' do
        @node.name = 'span'
        @node.classes = ['tcy']
      end

      modify 'img' do
        @node.body_empty = true
        (@node.attrs ||= {}).merge!({src: [@node.params[0].text ]})        
        @node.attrs.merge!({alt: [ escape_html(@node.params[1].text.strip)]}) if (@node.p.size > 1 && @node.params[1].text.size > 0)
      end

      replace 'image' do
        newnode = block('figure',
                        class_if_empty:'img-wrap',
                        ids: @node.ids,
                        children: [ inline('img', nil, attrs: {src: [ @node.params[0].text.strip],  alt: [ (@node.params[1].text ||'').strip ] }) ],
                        template: @node)
        if !@node.children_empty?
          if @node.n[:caption_before] 
            newnode.prepend_child inline('figcaption', @node.children)
          else
            newnode.append_child inline('figcaption', @node.children)
          end
        end
        newnode
      end

      replace({type: :OrderedList}) do
        block('ol', template: @node)
      end

      replace({type: :UnorderedList}) do
        block('ul', template: @node)
      end

      replace({type: :UlItem}) do
        block('li', template: @node)
      end

      replace({type: :OlItem}) do
        block('li', template: @node)
      end

      replace({type: :DefinitionList}) do
        block('dl', template: @node)
      end

      replace({type: :DLItem}) do
        [
         block('dt', @node.p[0], n: {chop_last_space: true}),
         block('dd', @node.children)
        ]
      end

      replace({type: :Breakline}) do
        newnode = block('br')
        newnode.body_empty = true
        newnode
      end

      replace({type: :HeadedSection}) do
        block('section', [ block("h#{@node.level}", @node.heading, ids: @node.n[:heading_id], n: {chop_last_space: true}) ] + @node.children, template: @node)
      end

      replace ({type: :CodeInline}) do
        inline('code', @node.content, line_no: @node.line_no, template: @node)
      end
      
      replace ({type: :PreformattedBlock}) do
        new_node = block('pre')
        if @node.codelanguage
          new_node.attrs = {'data-code-language' => [@node.codelanguage]}
          new_node.classes =  (@node.classes ||[]) << "code-#{@node.codelanguage}"
        end
        if @node.name == 'code'
          code = block('code', text(@node.content.join("\n"), raw_text: true))
          new_node.children = [ code ]
        else
          new_node.children = [ text(@node.content.join("\n"), raw_text: true) ]
        end
        if (@node.p || []).size> 0
          method = @node.n[:caption_after] ? :prepend : :append
          new_node = new_node.wrap block('div', classes: ['pre'], children: [ block('p', children: @node.p.shift, classes: ['caption']) ]), method
        end
        new_node
      end
    end
    DEFAULT_TRANSFORMER.extend Util
  end
end
