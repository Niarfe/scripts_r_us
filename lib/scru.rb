require 'pp'
require 'stringio'
require 'yaml'

class Scru < Thor
  desc "get_metadata <file>", "Gets the metadata from target file"

  def get_metadata(file)
    raise ArgumentError.new("File #{file} does not exist") unless ::File.exists?(file)
    yaml_metadata = nil
    File.open(file) do |file|
      in_metadata = false
      metadata = StringIO.new
      file.each_line do |line|
        if in_metadata
          metadata << line[2 .. -1]
          break if line.start_with?('# ...')
        elsif line.start_with?('# ---')
          metadata << line[2 .. -1]
          in_metadata = true
        end
      end
      metadata.rewind
      yaml_metadata = YAML.load(metadata) || {}
    end
    pp yaml_metadata
    yaml_metadata
  end

  desc "list", "List RightScripts"
  method_option :filter, 
    :desc => "Filter names according to regular expression",
    :aliases => "-f"
  def list
  end

  desc "upload <files>", "Upload RightScript from file or directory"
  method_option :force,
    :desc => "Force upload of files without metadata",
    :type => :boolean,
    :aliases => "-f"
  def upload(*files)
    file_list = get_file_list(files) 
    failed = verify_file_list(file_list)
    if failed.length > 0
      puts "The following files have no metadata: "
      failed.each { |f| puts f }
      puts 
      if options[:force]
        puts "Force flag is set, uploading all files anyways"
      else
        puts "Please run 'scru set_metadata <file or directory>' to add metadata for files"
        puts "Or else pass the --force flag to upload anyways"
      end
      exit 1
    end
    file_list.each do |f|
      push_to_rightscale(file_list)
    end
  end
  
  desc "set_metadata <files>", "Add metadata to files, if it doesn't exist"
  def set_metadata(*files)
    file_list = get_file_list(files)
    files_no_metadata = verify_file_list(file_list)
    files_no_metadata.each do |file|
      insert_metadata(file)
    end
  end

  desc "download <file>", "Download RightScript to file"
  method_option :id, 
    :desc => "RightScript ID number to download",
    :aliases => "-i",
    :type => :numeric
  method_option :name, 
    :desc => "RightScript Name to download",
    :aliases => "-n"
  def download
    raise ArgumentError.new("Either name or id must be supplied") unless options[:name] || options[:id]
  end

  desc "has_meatadata?", "Test if a script has a metadata block"
  def has_metadata?( filename )
    raise ArgumentError.new("File #{filename} does not exist") unless ::File.exists?(filename)

    File.open(filename) do |file|
      has_metadata = false
      in_metadata = false
      file.each_line do |line|
        if in_metadata
          has_metadata = true if line.start_with?('# ...')
        else
          in_metadata = true if line.start_with?('# ---')
        end
      end
      puts "The file #{filename} #{has_metadata ? "has" : "does not have"} metadata"
      has_metadata
    end
  end


  private
  def verify_file_list(files)
    failed = []
    files.each do |file|
      unless has_metadata?(file)
        failed << file
      end
    end
    failed
  end

  def get_file_list(files)
    file_list = []
    files.each do |file|
      raise ArgumentError.new("File #{file} does not exist") unless ::File.exists?(file)
      if ::File.directory?(file)
         puts "Skipping #{file}, it is a directory"
      else
        file_list |= [file]
      end
    end
  end

  def insert_metadata(file)
    file_no_extension = File.basename(file,File.extname(file))
    metadata_lines    = [
      "# ---",
      "# RightScript Name: #{file_no_extension}",
      "# Description: ",
      "# Packages: ",
      "# ...",
      "# "
    ]
    file_lines = File.read(file).split("\n")
    if file_lines.length == 0
      puts "Skipping #{file}, is empty"
      return
    end
    if file_lines.first.include?("#!")
      file_lines.insert(1, "", metadata_lines)
    else
      file_lines.insert(0, metadata_lines)
    end
    File.open(file, "w") do |f|
      puts "Saving file #{file}"
      f.puts(file_lines.join("\n"))
    end
  end

  def list_files(dir, filter = "*")
    Dir.glob(File.expand_path("#{dir}/##{filter}")).each do |file| 
      puts file
    end
  end

  def push_to_rightscale(file)
    puts "Pushing #{file} up to RightScale"
  end

  def get_from_rightcale( script_name )
    puts "Get #{script_name} from RightScale"
  end 
end

