# Copyright (c) 2009 Kevin Menard <nirvdrum@gmail.com>
# This code was heavily influenced by Edgar Gonzalez's work on another W3C
# SOAP parsing project.  His software is licensed as follows:

# Portions copyright (c) 2006 Edgar Gonzalez <edgar@lacaraoscura.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'
require 'nokogiri'

class CssValidatorParser

  def initialize
    clear
  end

  def parse(response)
    xml = Nokogiri::XML(response)
    xml.remove_namespaces!

    xml.xpath("//Envelope/Body/cssvalidationresponse/result/errors/errorlist").each do |error_list|
      uri = error_list.at_xpath(".//uri").content.strip
      init_uri(uri)

      error_list.xpath('.//error').each do |error|
        error_hash = {}
        error.children.each do |error_component|
          next if error_component.name == 'text'

          error_hash[translate_name(error_component.name)] = error_component.content.strip
        end

        # Store errors for URI under :errors key.
        @results[uri][:errors] << error_hash
      end
    end

    xml.xpath("//Envelope/Body/cssvalidationresponse/result/warnings/warninglist").each do |warning_list|
      uri = warning_list.at_xpath(".//uri").content.strip
      init_uri(uri)

      warning_list.xpath('.//warning').each do |warning|
        warning_hash = {}
        warning.children.each do |warning_component|
          next if warning_component.name == 'text'

          warning_hash[translate_name(warning_component.name)] = warning_component.content.strip
        end

        # Store warnings for URI under :warnings key.
        @results[uri][:warnings] << warning_hash
      end
    end
  end

  def clear
    @results = {}
  end

  def keys
    @results.keys
  end

  def [](uri)
    @results[uri]
  end

  private

  def init_uri(uri)
    @results[uri] ||= {}
    @results[uri][:errors] ||= []
    @results[uri][:warnings] ||= []
  end

  def translate_name(name)
    case name
      when 'errortype' then :type
      when 'errorsubtype' then :subtype
      when 'skippedstring' then :skipped_string
      else name.to_sym
    end
  end

end