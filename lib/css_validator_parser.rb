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

require 'rexml/document'

class CssValidatorParser

  def initialize
    clear
  end

  def parse(response)
    xml = REXML::Document.new(response)
    @valid = (/true/.match(xml.root.elements["env:Body/m:cssvalidationresponse/m:validity"].get_text.value))? true : false

    xml.elements.each("env:Envelope/env:Body/m:cssvalidationresponse/m:result/m:errors/m:errorlist") do |error_list|
      uri = error_list.elements["m:uri"].get_text.value.strip
      init_uri(uri)

      error_list.elements.each("m:error") do |error|
        @results[uri][:errors] << {
                :type => error.elements["m:errortype"].nil? ? "" : error.elements["m:errortype"].get_text.value.strip,
                :line => error.elements["m:line"].nil? ? "" : error.elements["m:line"].get_text.value.strip,
                :context => error.elements["m:context"].nil? ? "" : error.elements["m:context"].get_text.value.strip,
                :subtype => error.elements["m:errorsubtype"].nil? ? "" : error.elements["m:errorsubtype"].get_text.value.strip,
                :skipped_string => error.elements["m:skippedstring"].nil? ? "" : error.elements["m:skippedstring"].get_text.value.strip,
                :message => error.elements["m:message"].nil? ? "" : error.elements["m:message"].get_text.value.strip
        }
      end
    end

    xml.elements.each("env:Envelope/env:Body/m:cssvalidationresponse/m:result/m:warnings/m:warninglist") do |warning_list|
      uri = warning_list.elements["m:uri"].get_text.value.strip
      init_uri(uri)

      warning_list.elements.each("m:warning") do |warning|
        @results[uri][:warnings] << {
                :level => warning.elements["m:level"].nil? ? "" : warning.elements["m:level"].get_text.value.strip,
                :line => warning.elements["m:line"].nil? ? "" : warning.elements["m:line"].get_text.value.strip,
                :message => warning.elements["m:message"].nil? ? "" : warning.elements["m:message"].get_text.value.strip
        }
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

end