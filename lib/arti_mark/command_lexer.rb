module ArtiMark
  module CommandLexer
    def class_string(cls_array)
      if cls_array.size == 0
        ''
      else
        " class='#{cls_array.join(' ')}'"
      end
    end

    def class_array(cls_part)
      cls_array = []
      if !cls_part.nil? && cls_part.size > 0
        cls_array = cls_part[1..-1].split('.')
      end
      cls_array
    end

    def param_array(param_part)
      r = []
      if !param_part.nil? && param_part.size > 0
        r = param_part[1..-1].split(',')
      end
      r
    end

    def lex_line_command(line)
        line =~ /^(\w+?)((?:\.\w+?)*)((?:,[\w ]+?)*):(.*?)$/
        return { :cmd => $1, :cls => class_array($2), :params => param_array($3), :text => $4 }
    end

    def lex_block_command(line)
        line =~ /^(\w+?)((?:\.\w+?)*)((?:,[\w ]+?)*)\s*{\s*$/
        return { :cmd => $1, :cls => class_array($2), :params => param_array($3)}
    end
  end
end