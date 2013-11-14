
# UI

#--------------------------------------------------------------------------------#

# Prints a title.
#
def title(string)
  puts
  puts "-" * 80
  puts cyan(string)
  puts "-" * 80
  puts
end

def subtitle(string)
  puts green(string)
end

def error(string)
  raise "[!] #{red(string)}"
end

# Colorizes a string to green.
#
def green(string)
  "\033[0;32m#{string}\e[0m"
end

# Colorizes a string to yellow.
#
def yellow(string)
  "\033[0;33m#{string}\e[0m"
end

# Colorizes a string to red.
#
def red(string)
  "\033[0;31m#{string}\e[0m"
end

def cyan(string)
  "\033[0;36m#{string}\033[0m"
end

