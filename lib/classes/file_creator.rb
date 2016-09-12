require 'fileutils'

class FileCreator
  def self.get_project_number(project_directory)
    project_number = 0
    Dir.entries(project_directory).select{ |project|
      tmp_project_number = (project.split('#')[-1]).to_i
      if tmp_project_number > project_number
        project_number = tmp_project_number
      end
    }
    project_number = project_number + 1
    return project_number
  end

  def self.create_project_dir_structure(directory_path_root)
    #
    # / project_#_#{Project_number}
    #   / scan_files
    #     / nmap_files
    #   / project_files
    #   /
    #
    # if
    Dir.mkdir directory_path_root
    Dir.mkdir "#{directory_path_root}/scan_files"
    Dir.mkdir "#{directory_path_root}/project_files"
  end

  def self.remove_project_files(project_files_directory)
    FileUtils.rm_r("#{project_files_directory}", :secure => true)
    Dir.mkdir "#{project_files_directory}"
  end
end