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

  desc "upload <file>", "Upload RightScript from file"
  method_option :id, 
    :desc => "RightScript ID number to upload to.",
    :aliases => "-i",
    :type => :numeric
  method_option :name, 
    :desc => "RightScript Name to download",
    :aliases => "-n"
  def upload(file)
    raise ArgumentError.new("File #{file} does not exist") unless ::File.exists?(file)

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
      puts "The file #{filename} #{has_metadata ? " has " : "does not have "} metadata"
      has_metadata
    end
  end


  private
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

