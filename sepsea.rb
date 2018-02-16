# – File includes
require 'getoptlong'
require 'nmap'

require_relative "lib/helpers/constants"
require_relative "lib/helpers/colour"
require_relative "lib/classes/file_creator"
require_relative "lib/classes/nmap_runner"
require_relative "lib/classes/exploit_searcher"

@colour = Colour.new
options = {}

# – Method declarations
# Displays SEPSEA help
def help
  @colour.help_bold "Basic #{SOFTWARE_NAME} help and usage:"
  @colour.help " #{$0} <command> [--options]"
  @colour.help_bold "COMMANDS:"
  @colour.help " run, r: Run SEPSEA
 remove-projects: Remove all project directories"

  @colour.help_bold "MAIN OPTIONS:"
  @colour.help " --help, -h: Shows simple help
 --more, -m: Display more help for a command/option
 --ip-address, -i: Set victim ip address
 --exploit-mode, -m: Set mode to use
 --exploit-number, -n: Set number of exploits to use
 --desired-outcome, -o: Set desired outcome for a successful exploit"

   @colour.help_bold "ADDITIONAL OPTIONS:"
   @colour.help "Standard options:"
   @colour.help " --disable-colours: Disable colour output"
   @colour.help "Nmap specific options:"
   @colour.help " --nmap-verbose: Run nmap in verbose mode
 --syn-scan: Run a syn-scan during standard nmap scan
 --service-scan: Run a service-scan during standard nmap scan
 --os-fingerprint: Run a os-fingerprint scan during standard nmap scan
 --run-as-root: Run the nmap scan as root"

  exit
end

def more_help(option)
  @colour.help_bold "Displaying more help for command/option [#{option}]"
  case option
    ### Main commands
    when 'run', 'r'
      @colour.help "The '#{option}' command runs all sections of SecGen (requires the '--ip-address'/'-i' option to be set)"
    when 'remove-projects'
      @colour.help "The '#{option}' command deletes all project directories"

    ### Main options
    when '--help', '-h'
      @colour.help "The [#{option}] option displays generic a generic help and usage message"
    when '--more', '-m'
      @colour.help "The [#{option}] option displays more information on a specific option or command"
    when '--ip-address', '-i'
      @colour.help "The [#{option}] option sets the ip address of the victim computer"
    when '--exploit-mode', '-m'
      @colour.help "The [#{option}] option sets the desired exploit mode for #{SOFTWARE_NAME} (Visability, Speed, Chance of success)"
    when '--exploit-number', '-n'
      @colour.help "The [#{option}] option sets the number of exploits to try"
    when '--desired-outcome', '-o'
      @colour.help "The [#{option}] option sets the desired outcome of a successful exploit, e.g. shell/root"
    when 'disable-colours'
      @colour.help "The [#{option}] option disables colours in the console output"
    when 'nmap-verbose'
      @colour.help "The [#{option}] option runs the nmap scan in verbose mode"
    when 'syn-scan'
      @colour.help "The [#{option}] option runs a syn-scan during the standard nmap scan"
    when 'service-scan'
      @colour.help "The [#{option}] option runs a service-scan during the standard nmap scan"
    when 'os-fingerprint'
      @colour.help "The [#{option}] option runs an os-fingerprint scan during the standard nmap scan"
    when 'run-as-root'
      @colour.help "The [#{option}] option runs the nmap scan as root \n(option required for syn-scan, service-scan and os-fingerprint)\n[option will run as sudo/root password]"
    else
      @colour.help "The option [#{option}] is not recognised"
  end
end

def argument_checker(options, command)
  err = []
  case command
    when 'run'

      unless options.has_key? :ip_address
        err << "The option [--ip-address]/[-i] is required for the [run]/[r] command"
      end

      if (options.has_key? :syn_scan) && !(options.has_key? :run_as_root)
        err << "The option [--run-as-root] is required for the [--syn-scan] option to run"
      end

      if (options.has_key? :service_scan) && !(options.has_key? :run_as_root)
        err << "The option [--run-as-root] is required for the [--service-scan] option to run"
      end

      if (options.has_key? :os_fingerprint) && !(options.has_key? :run_as_root)
        err << "The option [--run-as-root] is required for the [--os-fingerprint] option to run"
      end

      if (options.has_key? :exploit_database) && !(['exploit-database','SEPSEA-database'].include? options[:exploit_database])
        err << "The option [--exploit-database] only takes the values ['exploit-database' or 'SEPSEA-database']"
      end

      if err.empty?
        return err
      else
        return err
      end

    else
      err << "Command not recognised in argument_checker section"
      return err
  end
end

def create_dir_structure(colour, projects_dir)
  FileCreator.create_main_project_directory(projects_dir) unless Dir.exist? projects_dir
  project_number = FileCreator.get_project_number(projects_dir)
  colour.notify "Project number has been selected, number set to '#{project_number}'"
  project_directory_path = "#{DIR_ROOT}/projects/project_##{project_number}"
  colour.notify "Project directory created in projects directory, project directory path is '#{project_directory_path}'"
  FileCreator.create_project_dir_structure(project_directory_path)
  return project_directory_path, project_number
end

def get_exploit_index_path(exploit_database)
  case exploit_database
    when 'exploit-database'
      return "#{DIR_ROOT}/exploits/database_indexes/exploit-database_index.csv"
    when 'SEPSEA-database'
      return "#{DIR_ROOT}/exploits/database_indexes/SEPSEA-database_index.csv"
    else
      return "#{DIR_ROOT}/exploits/database_indexes/exploit-database_index.csv"
  end
end

def run_nmap_scan(project_dir_path, options)
  if options.has_key? :run_as_root
    NmapRunner.nmap_run(project_dir_path, options)
  else
    NmapRunner.nmap_run(project_dir_path, options)
  end
end

def parse_nmap_xml(filename)
  machines = {}
  Nmap::XML.new(filename) do |xml|
    xml.each_host do |host|
      ip_address = host.ip.to_sym
      machines[ip_address] = {}

      host.each_port do |port|
        port_number = port.number
        port_protocol = port.protocol
        port_state = port.state
        port_service = port.service

        machines[ip_address][port_number] = {:protocol => port_protocol.to_s, :state => port_state.to_s, :service => port_service.to_s}

      end
    end
  end
  machines
end

def use_exploits(exploits, output_dir)
  puts "exploits: #{exploits}"
  if exploits.is_a? Array
    exploits.each { | exploit |
      exploit_path = exploit[:file]
      extension, exploit_exe_path = compile_exploit(exploit_path, output_dir)

      exploit_successful = run_exploit(extension, exploit_exe_path)
      if exploit_successful
        @colour.err "Exploit [#{exploit[:description]}] executed successfully"
      else
        @colour.err "Exploit [#{exploit[:description]}] failed to execute"
      end
    }
  else

    # exploit_exe_path = compile_exploit(exploit_path)
    # run_exploit(exploits)
  end
end

def compile_exploit(exploit_path, output_dir)
  file_path = exploit_path.split('.').first
  file_name = exploit_path.split('/').last
  extension = '.' + exploit_path.split('.').last
  full_exploit_path = "#{DIR_EXPLOITS}/exploit-database/#{exploit_path}"
  output_path = "#{output_dir}/#{file_name}.exploit"

  # puts "output_path: #{output_path}"

  case extension
    when '.py'
      # Python compile
      # output_path = "#{output_dir}/#{file_name}.exploit"
      FileUtils.cp(full_exploit_path, output_path)
    when '.rb'
      # Ruby compile
      # output_path = "#{output_dir}/#{file_name}.exploit"
      FileUtils.cp(full_exploit_path, output_path)
    when '.txt'
      # Text compile
      # output_path = "#{output_dir}/#{file_name}.exploit"
      FileUtils.cp(full_exploit_path, output_path)
    when '.c'
      # C compile
      # output_path = "#{output_dir}/#{file_name}.exploit"
      system "gcc #{full_exploit_path} -o #{output_path}"
  end
  return extension, output_path

  # output_path = exploit_path.split('.c').first
  # system "gcc #{exploit_path} #{exploit_path}"
end

def run_exploit(extension, exploit_path)
  outcome = nil

  case extension
    when '.py'
      outcome = system "python #{exploit_path}"
    when '.rb'
      outcome = system "ruby #{exploit_path}"
    when '.txt'
      # Run Text exploit file
    when '.c'
      outcome = system "./#{exploit_path}"
  end
  return outcome
end

opts = GetoptLong.new(
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
    [ '--more', GetoptLong::REQUIRED_ARGUMENT],
    [ '--ip-address', '-i', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--exploit-mode', '-m', GetoptLong::REQUIRED_ARGUMENT],
    [ '--exploit-number', '-n', GetoptLong::REQUIRED_ARGUMENT],
    [ '--desired-outcome', '-o', GetoptLong::REQUIRED_ARGUMENT],
    [ '--exploit-database', '-d', GetoptLong::REQUIRED_ARGUMENT],
    [ '--disable-colours', GetoptLong::OPTIONAL_ARGUMENT],
    [ '--syn-scan', GetoptLong::NO_ARGUMENT],
    [ '--service-scan', GetoptLong::NO_ARGUMENT ],
    [ '--os-fingerprint', GetoptLong::NO_ARGUMENT ],
    [ '--nmap-verbose', GetoptLong::NO_ARGUMENT],
    [ '--run-as-root', GetoptLong::NO_ARGUMENT],

# – Exploit mode (Visability, Speed, Chance of success)
# – Number of exploits to try (Arbetrary value/ 1+, set to full list length by default)
# – Desired outcome (shell/remote execution)
)

opts.each do |opt, arg|
  case opt
    ### Main options
    when '--help'
      help
      exit
    when '--more'
      more_help(arg)
      exit
    when '--ip-address', '-i'
      options[:ip_address] = arg
      @colour.notify "#{opt} option set to #{arg}"

    when '--exploit-mode', '-m'
      options[:exploit_mode] = arg
      @colour.notify "#{opt} option set to #{arg}"

    when '--exploit-number', '-n'
      options[:exploit_number] = arg
      @colour.notify "#{opt} option set to #{arg}"

    when '--desired-outcome', '-o'
      options[:desired_outcome] = arg
      @colour.notify "#{opt} option set to #{arg}"

    when '--exploit-database', '-d'
      options[:exploit_database] = arg
      @colour.notify "#{opt} option set to #{arg}"

    ### Other options
    when '--disable-colours'
      if arg.empty?
        @colour.disable_colours(true)
      else
        @colour.disable_colours(arg)
      end
    when '--syn-scan'
      options[:syn_scan] = true
      @colour.notify "#{opt} option set to true"
    when '--service-scan'
      options[:service_scan] = true
      @colour.notify "#{opt} option set to true"
    when '--os-fingerprint'
      options[:os_fingerprint] = true
      @colour.notify "#{opt} option set to true"
    when '--nmap-verbose'
      options[:nmap_verbose] = true
      @colour.notify "#{opt} option set to true"
    when '--run-as-root'
      options[:run_as_root] = true
      @colour.notify "#{opt} option set to true"
  end
end

# If less then one command present
if ARGV.length != 1
  @colour.err 'Missing main command, e.g. run'
  help
  exit
end

# Process main commands
case ARGV[0]
  when 'run', 'r'
    errors = argument_checker(options, 'run')
    if errors.empty?
      ##### Directory Structure #####
      project_directory_path, project_number = create_dir_structure(colour = @colour, projects_dir = DIR_PROJECTS)

      ##### Fingerprinting #####
      ##### Nmap Scan #####
      run_nmap_scan(project_directory_path, options)

      ##### Nmap Scan end #####
      ##### Fingerprinting end #####

      ##### Parse nmap file #####
      scan_data = parse_nmap_xml("#{project_directory_path}/scan_files/#{options[:ip_address]}.xml")

      # ports_to_exploit = {}

      ### Sort port data into open/closed
      scan_data.each do | ip_address, ports |
        ports.each do | port_number, port_info |
          ports.delete(port_number) if port_info[:state].eql? "closed"
        end
        scan_data.delete(ip_address) if scan_data[ip_address].empty?
      end

      ##### Parse nmap file end #####

      ##### Categorise and compare usable exploits #####
      @exploit_searcher = ExploitSearcher.new

      exploit_file = get_exploit_index_path(options[:exploit_database])

      ip_to_exploits = {}
      scan_data.each do | ip_address, ports |
        @colour.notify "Selecting exploits for machine with ip address [#{ip_address}]: port numbers #{ports.keys}"
        ip_to_exploits[ip_address] = @exploit_searcher.select_exploits_from_file(exploit_file, :port => ports.keys, :platform => ['windows','linux','windows'], :type => 'remote')
        # ip_to_exploits[ip_address] = @exploit_searcher.select_exploits_from_file(exploit_file, :file => 'platforms/windows/remote/1.c')

        # @colour.notify "All exploits selected for machine [#{ip_address}]: port numbers #{ports.keys}"
        # @colour.notify "Using selected exploits on machine [#{ip_address}]"
        # use_exploits(ip_to_exploits[ip_address], '/home/user/SEPSEA_test')
      end

      # @colour.notify "ip_to_exploits: #{ip_to_exploits}"
      ##### Categorise and compare usable exploits end #####

      else
      errors.each { |error|
        @colour.err error
      }
    end
  when 'remove-projects'
    @colour.notify "Removing all project directories"
    FileCreator.remove_project_files("#{DIR_PROJECTS}")
    @colour.notify "All project directories removed"
  else
    @colour.err "Command not valid: #{ARGV[0]}"
    help
    exit
end

# – Get command line arguments
'Done'
# – Fingerprinting
'Simple implemetation completed'
# – Categorise and compare usable exploits

# – Exploit software

# – Return results