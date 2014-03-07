require "nora_mark/version"
require 'nora_mark/html/generator'
require 'nora_mark/node'
require 'nora_mark/node_set'
require 'nora_mark/parser'
require 'securerandom'

module NoraMark
  class Document < Node
    attr_accessor :document_name
    private_class_method :new 

    def self.parse(string_or_io, param = {})
      instance = new param
      src = (string_or_io.respond_to?(:read) ? string_or_io.read : string_or_io).encode 'utf-8'
      yield instance if block_given?
      instance.instance_eval do 
        @preprocessors.each do
          |pr|
          src = pr.call(src)
        end
        @parser = Parser.new(src)
        if (!@parser.parse)
          raise @parser.raise_error
        end
        @content = @parser.result
        self.organize
      end
      instance
    end

    def preprocessor(&block)
      @preprocessors << block
    end

    def html
      if @html.nil?
        @html = @html_generator.convert(self, @render_parameter)
      end
      @html
    end

    def render_parameter(param = {})
      @render_parameter.merge! param
      self
    end
    
    def initialize(param = {})
      @preprocessors = [
                        Proc.new { |text| text.gsub(/\r?\n(\r?\n)+/, "\n\n") },
                       ]
      @html_generator = Html::Generator.new(param)
      @document_name = param[:document_name] || "noramark_#{SecureRandom.uuid}"
      @render_parameter = {}
    end 


  end
end
