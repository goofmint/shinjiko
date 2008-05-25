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
    old_last  = new_last  = 0
    in_prelude = true
    self.text.split(/\r\n|\r|\n/).each { |l|
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
          old_chunk = new_chunk = []
          raw_chunk.each { |tag, rest|
            old_chunk << rest if [" ", "-"].index(tag)
            new_chunk << rest if [" ", "+"].index(tag)
          }
          old_i, old_j = old_range
          new_i, new_j = new_range
          if old_chunk.length != old_j - old_i || new_chunk.length != new_j - new_i
            logger.debug("%s:%s: previous chunk has incorrect length" % [name, lineno])
            return nil
          end
          chunks << [old_range, new_range, old_chunk, new_chunk]
          raw_chunk = []
        end
        old_ln, old_n, new_ln, new_n = $1.to_i, ($3 || 1).to_i, $4.to_i, ($6 || 1).to_i
        
        old_i = old_n == 0 ? old_ln : old_ln - 1
        old_j = old_i + old_n
        old_range = [old_i, old_j]
        
        new_i = new_n == 0 ? new_ln : new_ln - 1
        new_j = new_i + new_n
        new_range = [new_i, new_j]
        
        if old_i < old_last || new_i < new_last
          logger.debug("%s:%s: chunk header out of order: %r" % [name, lineno, line])
          return nil
        end
        if old_i - old_last != new_i - new_last
          logger.debug("%s:%s: inconsistent chunk header: %r" % [name, lineno, line])
          return nil
        end
        old_last = old_j
        new_last = new_j
      else
        tag = l[0,1]
        rest = l[1..-1]
        if [" ", "-", "+"].index tag
          raw_chunk << [tag, rest]
        elsif tag == "\\" and rest == " No newline at end of file"
          if raw_chunk.length > 0
            last_tag, last_rest = raw_chunk[-1]
          end
        else
          logging.warn("%s:%d: indecypherable input: %r" % [name, lineno, line])
          break if chunks || raw_chunk
          return nil
        end
      end
    }
    
    if raw_chunk.length > 0
      old_chunk = []
      new_chunk = []
      logger.debug "raw_chunk #{raw_chunk.length}"
      raw_chunk.each { |tag, rest|
        old_chunk << rest if [" ", "-"].index(tag)
        new_chunk << rest if [" ", "+"].index(tag)
      }
      old_i, old_j = old_range
      new_i, new_j = new_range
      if old_chunk.length != old_j - old_i || new_chunk.length != new_j - new_i
        logger.debug("%s:%s: previous chunk has incorrect length" % [name, lineno])
        return nil
      end
      chunks << [old_range, new_range, old_chunk, new_chunk]
      raw_chunk = []
    end
    logger.debug "Line no::#{lineno}"
    return chunks
  end
end
