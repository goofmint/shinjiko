# -*- coding: utf-8 -*-
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def fold(str, length=60)
    if str.size > length
      NKF.nkf("-F#{length} -Ww", str).gsub(/\r?\n/){"\r\n"}
    else
      str.gsub(/\r?\n/){"\r\n"}
    end
  end
  
  def line_class(old = nil, new = nil, old_line = true)
    if old == new
      return old_line ? "oldequal" : "newequal"
    end
    if old.nil? && new
      return old_line ? "oldblank" : "newinsert"
    end
    return old_line ? "olddelete" : "newblank"
  end
  
  def timeago(time, options = {})
    start_date = options.delete(:start_date) || Time.new
    date_format = options.delete(:date_format) || :default
    delta_minutes = (start_date.to_i - time.to_i).floor / 60
    if delta_minutes.abs <= (8724*60) # eight weeks… I’m lazy to count days for longer than that
      distance = distance_of_time_in_words(delta_minutes);
      if delta_minutes < 0
        "#{distance} from now"
      else
        "#{distance} ago"
      end
    else
      return "on #{system_date.to_formatted_s(date_format)}"
    end
  end

  def distance_of_time_in_words(minutes)
    case
      when minutes < 1
        "less than a minute"
      when minutes < 50
        pluralize(minutes, "minute")
      when minutes < 90
        "about one hour"
      when minutes < 1080
        "#{(minutes / 60).round} hours"
      when minutes < 1440
        "one day"
      when minutes < 2880
        "about one day"
      else
        "#{(minutes / 1440).round} days"
    end
  end
  
  def trans(text)
    text.gsub(/(https?\:[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%]+)/, "<a href=\"#{'\\1'}\">#{'\\1'}</a>")
  end
end
