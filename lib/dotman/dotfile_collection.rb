module Dotman

DOTFILES_PATH = "#{ENV['HOME']}/.dotman/dotfiles.yml"

  class DotfileCollection

    def initialize(yaml)
      @yaml = yaml
    end

    attr_accessor :yaml

    def self.delete(alias_name)
      if dotfiles_yaml[alias_name] && dotfiles_yaml[alias_name]['folder_name']
        FileUtils.rm_rf(File.join(Dotman::Base.dotman_folder, dotfiles_yaml[alias_name]['folder_name']))
        dotfiles_yaml.delete(alias_name)
        save_dotfile_yaml
      end
    end

    def self.dotfiles_yaml
      @dotfiles_yaml ||= File.exist?(DOTFILES_PATH) ? YAML::load_file(DOTFILES_PATH) : Hash.new
    end

    def self.find_by_alias(alias_name)
      ensure_default_dotfile_configuration_exists
      new(dotfiles_yaml.fetch(alias_name))
    end

    def self.new_configuration(folder_name, alias_name = nil)
      alias_name = folder_name unless alias_name
      dotfiles_yaml.store(alias_name, {
          'folder_name' => folder_name 
        })
      save_dotfile_yaml
    end


    def all_dotfiles
      Dir.entries("#{Dotman::Base.dotman_folder}/#{@yaml['folder_name']}").select{|x| x =~ /\.{1}\w+[^git]/ }
    end

    private

    def self.ensure_default_dotfile_configuration_exists
      unless dotfiles_yaml && dotfiles_yaml['default']
        new_configuration('default')
      end
    end

    def self.save_dotfile_yaml
      File.open(DOTFILES_PATH, 'w') { |f| f.write dotfiles_yaml.to_yaml }
    end

  end
end
