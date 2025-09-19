class Logger
  INFO_COLOR  = "\e[35m"
  WARN_COLOR  = "\e[33m"
  ERR_COLOR   = "\e[31m"
  DEBUG_COLOR = "\e[36m"
  RESET_COLOR = "\e[0m"

  def info(msg : String)
    puts "#{INFO_COLOR} info #{RESET_COLOR} #{msg}"
  end

  def warn(msg : String)
    puts "#{WARN_COLOR} warn #{RESET_COLOR} #{msg}"
  end

  def err(msg : String)
    puts "#{ERR_COLOR}error #{RESET_COLOR} #{msg}"
  end

  def debug(msg : String)
    puts "#{DEBUG_COLOR}debug #{RESET_COLOR} #{msg}"
  end
end
