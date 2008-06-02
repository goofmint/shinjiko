class Patch < ActiveRecord::Base
  belongs_to :patchset
  belongs_to :parent, :class_name => 'Patchset', :foreign_key => :parent_id
  belongs_to :issue
  has_many :comments
  
  def parse(name="<patch>")
    lineno = 0
    raw_chunk = []
    chunks = []
    old_range = new_range = nil
    in_prelude = true
    text = self.text.split(/\r\n|\r|\n/)
    text.each { |l|
      lineno += 1
      if in_prelude
        if l =~ /^\+{3}/
          in_prelude = false
        end
        next
      end
      
      # match pattern
      # @@ -28,29 +34,28 @@
      # @@ -28 +34 @@
      if l =~ /@@\s+\-(\d+)(,(\d+)|)\s+\+(\d+)(,(\d+)|)\s+@@/
        if raw_chunk.length > 0
          old_chunk = []
          new_chunk = []
          raw_chunk.each { |tag, rest|
            old_chunk << "#{tag} #{rest}" if [" ", "-"].index(tag)
            new_chunk << "#{tag} #{rest}" if [" ", "+"].index(tag)
          }
          old_i, old_j = old_range
          new_i, new_j = new_range
          if old_chunk.length != old_j - old_i || new_chunk.length != new_j - new_i
            logger.debug("%s:%s:2: previous chunk has incorrect length" % [name, lineno])
            return nil
          end
          chunks << [old_range, new_range, raw_chunk]
          raw_chunk = []
        end
        old_ln, old_n, new_ln, new_n = $1.to_i, ($3 || 1).to_i, $4.to_i, ($6 || 1).to_i
        
        old_i = old_n == 0 ? old_ln : old_ln - 1
        old_j = old_i + old_n
        old_range = [old_i, old_j]
        
        new_i = new_n == 0 ? new_ln : new_ln - 1
        new_j = new_i + new_n
        new_range = [new_i, new_j]
      else
        tag = l[0,1]
        rest = l[1..-1]
        if tag == " " and (rest == "No newline at end of file" || rest.nil?)
        elsif [" ", "-", "+"].index tag
          raw_chunk << [tag, rest]
        else
          logger.debug("%s:%d: indecypherable input: %r" % [name, lineno, __LINE__])
          break if chunks || raw_chunk
          return nil
        end
      end
    }
    
    if raw_chunk.length > 0
      old_chunk = []
      new_chunk = []
      raw_chunk.each { |tag, rest|
        old_chunk << "#{tag} #{rest}" if [" ", "-"].index(tag)
        new_chunk << "#{tag} #{rest}" if [" ", "+"].index(tag)
      }
      old_i, old_j = old_range
      new_i, new_j = new_range
      if old_chunk.length != old_j - old_i || new_chunk.length != new_j - new_i
        logger.debug("Length:#{old_chunk.length} #{old_j} #{old_i}")
        logger.debug("%s:%s:1: previous chunk has incorrect length" % [name, lineno])
        raw_chunk.each { |tag, rest|
          logger.debug("#{tag} #{rest}")
        }
        return nil
      end
      chunks << [old_range, new_range, raw_chunk]
      raw_chunk = []
    end
    logger.debug "Line no::#{lineno}"
    return chunks
  end
  
  def application_patch(chunks = nil)
    chunks = self.parse unless chunks
    logger.debug "chunk #{chunks}"
    return nil unless chunks
    content = self.get_content
    return nil unless content
    old_file = content.split(/\r\n|\r|\n/)
    new_file = content.split(/\r\n|\r|\n/)
    old_file << "" if old_file[-1] != ""
    new_file << "" if new_file[-1] != ""
    diff_line_count = 0
    chunks.each {|old_range, new_range, chunk|
      count = 0
      new_range[0] += diff_line_count
      old_range[1] += diff_line_count
      new_range[1] += diff_line_count
      for i in new_range[0]..[old_range[1], new_range[1]].max
        break unless chunk[count]
        new_file[i] = nil if chunk[count][0] == "-"
        if chunk[count][0] == "+"
          old_file = old_file[0..(i-1)] + [nil] + (old_file[i..-1] || [])
          new_file = new_file[0..(i-1)] + [chunk[count][1]] + (new_file[i..-1] || [])
        end
        count += 1
      end
      old_line_count = new_file.length
      new_line_count = 0
      new_file.each{ |l|
        new_line_count += 1 unless l.nil?
      }
      diff_line_count += old_line_count - new_line_count
    }
    [old_file, new_file]
  end
  
  def parseRevision
    self.text.split(/\r\n|\r|\n/).each { |l|
      break if l =~ /^@/
      if l =~ /^---\s.*\(.*\s(\d+)\)\s*$/
        return $1.to_i
      end
    }
    nil
  end
  
  def get_content
    return self.content if self.content
    self.content = self.issue.fetch self
    self.save
    self.content
  end
  
  def draft_comment(user)
    return nil unless user
    return @draft_comment if @draft_comment
    @draft_comment = self.comments.count(:conditions => ['user_id = ? and draft = 1', user.id])
  end
  
  def chunk
    chunks = self.parse
    return 0 unless chunks
    return chunks.length
  end
end
