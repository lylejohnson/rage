#!/bin/env ruby
# -*- ruby -*-
#----------------------------------------------------------------------
# $Id: npreader.rb,v 1.1 2004/01/23 04:50:21 lyle Exp $
#----------------------------------------------------------------------
#
# NPReader.rb - Nested parenthesis (LISP syntax) parser.
# Copyright (C) 2001 Gordon James Miller
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by the
# Free Software Foundation; either version 2.1 of the License, or (at your
# option) any later version. 
#
# This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
# for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this library; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#----------------------------------------------------------------------
# 
# Implementation of a nested parenthesis parser.  The nested parenthesis
# format is most commonly seen in LISP but is very nice for expressing
# hierarchical data.  The two classes that are defined in this file are the
# NPParser and NPNode classes.  The NPParser class performs the work of
# constructing the NPNode objects that represent the data.  The NPNode class
# implements a simple container that holds a sequence of values (Strings and
# other NPNodes) and a reference to a parent.
#
# This file is also executable as a RUnit test.  See the block of code at the
# end of the file for details on how to use the class.
#
#----------------------------------------------------------------------
# 

class NPNode
  # A container for strings that reside between matching parenthesis.  Each
  # instance of this class contains a list of values that are either strings
  # or other NPNode objects representing nesting.
  #

  @@NORMAL_MODE = 0
  @@QUOTE_MODE = 1

  # The members of this group.
  #
  attr_reader :values

  # The parent of this group.
  #
  attr_reader :parent

  # The level of this group.  This is set by the constructor and is based upon
  # the level of the parent.
  #
  attr_reader :level

  # The state of this group.  This will either be NORMAL or QUOTE.  In QUOTE,
  # whitespace is absorbed.
  #
  attr_reader :state

  def close
    if ( @curval.size > 0 ) then
      @values.push( @curval.to_s )
      @curval.clear
    end
  end

  def initialize (parent)
    # Initialize a new instance that has the specified parent.  The parent can
    # be nil, in which case it is assumed that this is the top level node.  If
    # the parent is not nil, then this object is added as a child to the
    # parent. 
    #
    @parent = parent
    
    if ( @parent != nil ) then
      @parent.push(self)
    end

    @state = @@NORMAL_MODE
    @level = ( parent == nil ) ? 0 : @parent.level + 1

    @values = Array.new
    @curval = Array.new
  end

  def push (ch)
    
    if ( ch.kind_of? NPNode ) then
      # If this is an NPNode instance, just add it to the end of the values
      # array.
      #
      @values.push(ch)

    else
      if ( ch == "'" || ch == "\"" ) then
	# If this is a double quote, then we have to start a new value, toggle
	# the mode.
	#
	@state = ( @state + 1 ) % 2
	close

      elsif ( (@state != @@QUOTE_MODE) && ch =~ /[ \t\n\r]/ ) then
	# If this is a whitespace character and the length is greater than
	# zero, push the current value on the values array and clear the
	# current values string.
	#
	close

      else
	# Otherwise go ahead and push the character onto the end of the
	# current value.
	#
	@curval.push( ch )
      end
    end
  end

  def to_s 
    
    str = Array.new()
    return "(#{@values.join(' ')})"
  end


end

class NPReader
  # An implementation of a nested parenthesis reader.  This implementation
  # constructs an AST from a data source.  
  #

  def initialize ()
    # Initialize a new instance of the reader.  This does not start the
    # parsing, that is done with the parse method.
    #
    
  end

  def parse (string)
    # Parse the data contained in the string and return the reference to the
    # top level group.
    #

    @curgroup = nil
    @top = nil

    string.each_byte { |byte|
      
      ch = byte.chr

      if ( ch == '(' ) then
	@curgroup = NPNode.new(@curgroup)
	if ( @top == nil ) then 
	  @top = @curgroup
	end

      elsif ( ch == ')' ) then
	@curgroup.close
	@curgroup = @curgroup.parent
	
      else
	if ( @curgroup != nil ) then
	  @curgroup.push(ch)
	end

      end
    }

    return @top
  end
  
end


if ( __FILE__ == $0 ) then

  require "test/unit/testcase"
  require "test/unit/ui/console/testrunner"

  class  NPReaderTest < Test::Unit::TestCase
    # Runit test class for the npreader class
    #

    def test_parse_string

      # Set up the test string.  Make sure that the string meets the following
      # conditions:
      #  1 - nested parentheses
      #  2 - use of both single and double quotes
      #  3 - varying length values
      #
      data = <<-EOF
(animals 
  (dogs beagle dalmation "german shepherd")
  (cats persian 'maine coon')
  fish
)
      EOF

      parser = NPReader.new()
      ast = parser.parse(data)

      # Check the top level node making sure that it has the right number of
      # children and that its type is correct.
      #
      assert_not_nil( ast )
      assert_equal(4, ast.values.size)
      assert_kind_of(NPNode, ast)
      assert_equal(0, ast.level)

      # Now look at the first node, this should simply be a string with the
      # value "animals"
      #
      node = ast.values[0]
      assert_not_nil(node)
      assert_kind_of(String, node)
      assert_equal("animals", node)

      # Now look at the second node, this should be an NPNode with 4 children
      # (this is the dogs entry).
      #
      node = ast.values[1]
      assert_not_nil(node)
      assert_kind_of(NPNode, node)
      assert_equal(4, node.values.size)
      assert_equal("dogs", node.values[0])
      assert_equal("beagle", node.values[1])
      assert_equal("dalmation", node.values[2])
      assert_equal("german shepherd", node.values[3])
      
      # Now look at the third node, this should be an NPNode with 3 children
      # (this is the cats entry).
      #
      node = ast.values[2]
      assert_not_nil(node)
      assert_kind_of(NPNode, node)
      assert_equal(3, node.values.size)
      assert_equal("cats", node.values[0])
      assert_equal("persian", node.values[1])
      assert_equal("maine coon", node.values[2])

      # Now look at the last node, this should simply be a string with the
      # value "fish"
      #
      node = ast.values[3]
      assert_not_nil(node)
      assert_kind_of(String, node)
      assert_equal("fish", node)
    end
  end
  Test::Unit::UI::Console::TestRunner.run(NPReaderTest.suite)
end

