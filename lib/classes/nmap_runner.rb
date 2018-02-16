class NmapRunner
  def self.nmap_run(project_dir_path, options)
    # Run as root
    if options.has_key? :run_as_root
      Nmap::Program.sudo_scan do |nmap|
        nmap.syn_scan = options[:syn_scan] if options.has_key? :syn_scan
        nmap.service_scan = options[:service_scan] if options.has_key? :service_scan
        nmap.os_fingerprint = options[:os_fingerprint] if options.has_key? :os_fingerprint
        nmap.xml = "#{project_dir_path}/scan_files/#{options[:ip_address]}.xml"
        nmap.verbose = options[:nmap_verbose] if options.has_key? :nmap_verbose

        if options.has_key? :ports && options[:ports].kind_of?(Array)
          nmap.ports = options[:ports]
        else
          nmap.ports = [20,21,22,23,25,80,110,443,512,522,8080,1080]
        end
        nmap.targets = "#{options[:ip_address]}"
      end
    # Run without root
    else
      Nmap::Program.scan do |nmap|
        nmap.syn_scan = options[:syn_scan] if options.has_key? :syn_scan
        nmap.service_scan = options[:service_scan] if options.has_key? :service_scan
        nmap.os_fingerprint = options[:os_fingerprint] if options.has_key? :os_fingerprint
        nmap.xml = "#{project_dir_path}/scan_files/#{options[:ip_address]}.xml"
        nmap.verbose = options[:nmap_verbose] if options.has_key? :nmap_verbose

        if options.has_key? :ports && options[:ports].kind_of?(Array)
          nmap.ports = options[:ports]
        else
          nmap.ports = [20,21,22,23,25,80,110,443,512,522,8080,1080]
        end
        nmap.targets = "#{options[:ip_address]}"
      end
    end
  end
end