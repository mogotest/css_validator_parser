# Copyright (c) 2009 Kevin Menard <nirvdrum@gmail.com>
# This code was heavily influenced by Edgar Gonzalez's work on another W3C
# SOAP parsing project.  His software is licensed as follows:

# Copyright (c) 2006 Edgar Gonzalez <edgar@lacaraoscura.com>
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

  attr_reader :errors, :warnings, :informations, :valid

  def initialize
    clear
  end

  def parse(response)
    xml = REXML::Document.new(response)
    @valid = (/true/.match(xml.root.elements["env:Body/m:cssvalidationresponse/m:validity"].get_text.value))? true : false
    unless @valid
      xml.elements.each("env:Envelope/env:Body/m:cssvalidationresponse/m:result/m:errors/m:errorlist/m:error") do |error|
        @errors << {
                :type => error.elements["m:type"].nil? ? "" : error.elements["m:type"].get_text.value,
                :line => error.elements["m:line"].nil? ? "" : error.elements["m:line"].get_text.value,
                :column => error.elements["m:column"].nil? ? "" : error.elements["m:column"].get_text.value,
                :text => error.elements["m:text"].nil? ? "" : error.elements["m:text"].get_text.value,
                :element => error.elements["m:element"].nil? ? "" : error.elements["m:element"].get_text.value
        }
      end
    end
    xml.elements.each("env:Envelope/env:Body/m:cssvalidationresponse/m:result/m:warnings/m:warninglist/m:warning") do |warning|
      @warnings << {
              :type => warning.elements["m:type"].nil? ? "" : warning.elements["m:type"].get_text.value,
              :line => warning.elements["m:line"].nil? ? "" : warning.elements["m:line"].get_text.value,
              :column => warning.elements["m:column"].nil? ? "" : warning.elements["m:column"].get_text.value,
              :text => warning.elements["m:text"].nil? ? "" : warning.elements["m:text"].get_text.value,
              :element => warning.elements["m:element"].nil? ? "" : warning.elements["m:element"].get_text.value
      }
    end
    xml.elements.each("env:Envelope/env:Body/m:cssvalidationresponse/m:result/m:informations/m:infolist/m:information") do |info|
      @informations << {
              :type => info.elements["m:type"].nil? ? "" : info.elements["m:type"].get_text.value,
              :line => info.elements["m:line"].nil? ? "" : info.elements["m:line"].get_text.value,
              :column => info.elements["m:column"].nil? ? "" : info.elements["m:column"].get_text.value,
              :text => info.elements["m:text"].nil? ? "" : info.elements["m:text"].get_text.value,
              :element => info.elements["m:element"].nil? ? "" : info.elements["m:element"].get_text.value
      }
    end
  end

  def clear
    @response = nil
    @valid = false
    @errors = []
    @warnings = []
    @informations = []
  end

end