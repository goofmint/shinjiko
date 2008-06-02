require File.dirname(__FILE__) + '/../test_helper'

class PatchTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_patch
    text = <<EOS
--- old.bak     2008-05-26 09:27:01.000000000 +0900
+++ new 2008-05-26 09:22:10.000000000 +0900
@@ -1,6 +1,5 @@
-AAA
 BBB
-CCC
+AAA
 DDD
 EEE
 AAA
@@ -13,13 +12,13 @@
 H
 I
 J
-K
+
 L
-M
+MM
 N
 O
 AAA
 BBB
 CCC
 DDD
-EEE
+EEE
\ No newline at end of file
EOS
    
    old = <<EOS
AAA
BBB
CCC
DDD
EEE
AAA
BBB
CCC
DDD
EEE
F
G
H
I
J
K
L
M
N
O
AAA
BBB
CCC
DDD
EEE
EOS
    patch = Patch.new
    patch.text = text
    patch.content = old
    chunks = patch.parse
    new_file = patch.content.split(/\r\n|\r|\n/)
    chunks.each {|old_range, new_range, chunk|
      count = 0
      p "#{new_range[0]}..#{[old_range[1], new_range[1]].max}"
      for i in new_range[0]..[old_range[1], new_range[1]].max
        # p " -> #{chunk[count][1]}  ::  #{new_file[i]}"
        new_file[i] = nil if chunk[count][0] == "-"
        if chunk[count][0] == "+"
          new_file = new_file[0..(i-1)] + [chunk[count][1]] + new_file[i..-1]
        end
        count += 1
      end
      new_file.delete(nil)
    }
    #new_file.each { |l|
    #  next if l.nil?
    #  p l
    #}
  end
  
  def test_diff2
    require 'diff/lcs'
    require 'diff/lcs/hunk'
    patch = Patch.new
    difference = ""
    new = open("#{RAILS_ROOT}/new1").read
    old = open("#{RAILS_ROOT}/old1").read
    diffs = diff_as_string(old, new)
    patch.text = diffs
    patch.content = old
    diffs.split(/\n/).each { |l|
      p l
    }
    old2, new2 = patch.application_patch
    new2.each { |l|
      p l
    }
  end
  
  def diff_as_string(data_old, data_new, format=:unified, context_lines=3)
    data_old = data_old.split(/\n/).map! { |e| e.chomp }
    data_new = data_new.split(/\n/).map! { |e| e.chomp }
    output = ""
    diffs = Diff::LCS.diff(data_old, data_new)
    return output if diffs.empty?
    oldhunk = hunk = nil
    file_length_difference = 0
    diffs.each do |piece|
      begin
        hunk = Diff::LCS::Hunk.new(data_old, data_new, piece, context_lines,
                                   file_length_difference)
        file_length_difference = hunk.file_length_difference
        next unless oldhunk
        
        # Hunks may overlap, which is why we need to be careful when our
        # diff includes lines of context. Otherwise, we might print
        # redundant lines.
        if (context_lines > 0) and hunk.overlaps?(oldhunk)
          hunk.unshift(oldhunk)
        else
          output << oldhunk.diff(format)
        end
      ensure
        oldhunk = hunk
        output << "\n"
      end
    end
    
    #Handle the last remaining hunk
    output << oldhunk.diff(format) << "\n"
  end
end
