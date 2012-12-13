# -*- encoding: utf-8 -*-
require "arti_mark/version"
require "arti_mark/command_lexer"
require "arti_mark/base_parser"
require 'arti_mark/common_block_parser'
require "arti_mark/paragraph_parser"
require "arti_mark/div_parser"
require "arti_mark/article_parser"
require "arti_mark/section_parser"
require "arti_mark/head_parser"
require "arti_mark/block_image_parser"
require "arti_mark/list_parser"
require "arti_mark/ordered_list_parser"
require "arti_mark/universal_block_parser"
require 'arti_mark/syntax'
require 'arti_mark/context'

module ArtiMark
  class Document
    def initialize(param = {})
      @context = Context.new(param)
      @syntax = Syntax.new
    end 

    def convert(text)
      # split text to lines
      lines = text.strip.gsub(/　/, ' ').gsub(/\r?\n(\r?\n)+/, "\n\n").split(/\r?\n/).map { |line| line.strip } # text preprocess should be plaggable
      process_lines(lines, @context)
      @context.result
    end

    def toc
      @context.toc
    end
    
    def process_lines(lines, r)
      while (lines.size > 0)
        @syntax.parse(lines, r)
      end
      r
    end

  end
end
