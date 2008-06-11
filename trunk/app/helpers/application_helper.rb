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
        _("%{distance} from now") % { :distance => distance}
      else
        _("%{distance} ago") % { :distance => distance}
      end
    else
      return "on #{system_date.to_formatted_s(date_format)}"
    end
  end

  def distance_of_time_in_words(minutes)
    case
    when minutes < 1
      _("less than a minute")
    when minutes < 50
      n_("%{minutes} minute", "%{minutes} minutes", minutes) % { :minutes => minutes}
    when minutes < 90
      "about one hour"
    when minutes < 1080
      n_("%{time} hour", "%{time} hours", (minutes / 60).round) % { :time => (minutes / 60).round}
    when minutes < 1440
      _("one day")
    when minutes < 2880
      _("about one day")
    else
      n_("%{day} day", "%{day} days", (minutes / 1440).round) % { :day => (minutes / 1440).round}
    end
  end
  
  def trans(text)
    h(text).gsub(/(https?\:[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%]+)/, "<a href=\"#{'\\1'}\">#{'\\1'}</a>")
  end
end
