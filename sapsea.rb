# – File includes
require 'getoptlong'

require_relative "lib/helpers/constants"
require_relative "lib/helpers/colour"

colour = Colour.new

# – Method declarations
# Displays SEPSEA help
def help
  colour.help "help:
   #{$0} [--options] <command>

   OPTIONS:
   --help, -h: Shows simple help

   COMMANDS:
   run, r: Run SEPSEA"
  exit
end

# at least one command
if ARGV.length < 1
  colour.err 'Missing command'
  help
  exit
end

# process command
case ARGV[0]
  when 'run', 'r'
  else
    colour.err "Command not valid: #{ARGV[0]}"
    help
    exit
end

# – Get command line arguments

# – Fingerprinting

# – Categorise and compare usable exploits

# – Exploit software

# – Return results

# require 'getoptlong'
# require 'fileutils'
#
# require_relative 'lib/helpers/constants.rb'
# require_relative 'lib/helpers/print.rb'
# require_relative 'lib/helpers/gem_exec.rb'
# require_relative 'lib/readers/system_reader.rb'
# require_relative 'lib/readers/module_reader.rb'
# require_relative 'lib/output/project_files_creator.rb'