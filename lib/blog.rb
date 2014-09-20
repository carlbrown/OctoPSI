require "#{File.dirname(__FILE__)}/post"
require 'yaml'
require 'fileutils'

module OctoPSI
  class Blog
    def get_posts(max_to_return)
      posts.slice(0,max_to_return)
    end

    def get_recent_posts_response(max_to_return)
      return_value = []
      posts.slice(0,max_to_return).each { |p|
        response = p.web_response
        return_value << response
      }
      return_value
    end

    def get_categories
      return_value = []
      posts.each { |p|
        cats = p.get_categories
        if cats.is_a? Array
          return_value.concat(cats)
        elsif cats.is_a? String
          return_value << cats
        end

      }
      return_value.uniq

    end

    def load_post_names
      @post_file_names = Dir.glob("#{@source_dir}/_posts/*.{markdown,md}").sort{|x,y| y <=> x }
    end

    def post_file_names
      unless @post_file_names
        load_post_names
      end
      unless @post_file_names
        @post_file_names=[]
      end
      @post_file_names
    end

    def load_posts
      list=[]
      post_file_names.each {|post_name| list << Post.new(@url, name, @source_dir, post_name)}
      if list
        @posts = list.sort{|x,y|
          y.post_name <=> x.post_name
        }
      else
        @posts=[]
      end
    end

    def get_post_by_name(post_name)
      Post.new(@url, name, @source_dir, File.join(@source_dir,'_posts',post_name) + '.markdown')
    end

    def name
      File.basename(File.expand_path(File.join(@source_dir,'..')))
    end

    def posts
      unless @posts
        load_posts
      end
      @posts
    end

    def public_dir
      File.join(@source_dir, '..', 'public')
    end

    def base_url
      @url
    end

    def create_post(content, publish)
      new_post = Post.new(@url, name, @source_dir, content)
      saved = new_post.save
      if saved
        self.load_post_names
        self.load_posts
        return "#{name}/#{new_post.post_name}"
      end
      false
    end

    def newMediaObject(data)
      filename=data['name']
      filename.sub!(/^\//,'')
      if filename =~ /[^\/]\/[^\/]/
        #There's a slash in the filename, use that as the path
        upload_dir = File.dirname(filename)
        filename=File.basename(filename)
        unless File.exists?(File.join(@source_dir,upload_dir))
          FileUtils.mkdir_p(File.join(@source_dir,upload_dir))
        end
      else
        upload_dir = self.uploads_dir
      end
      new_url = File.join(self.base_url,upload_dir,filename)
      new_file_path = File.join(@source_dir,upload_dir,filename)
      File.open(new_file_path, 'wb') {|f|
        f.write(data['bits'])
      }
      File.join('/',upload_dir,filename)
    end

    def uploads_dir
      default_upload_dir='uploads'
      ['uploads','images','resources','resource','storage'].each{ |dir|
        if (File.exists?(File.join(@source_dir,dir)) && File.directory?(File.join(@source_dir,dir)))
          return dir
        end
      }
      FileUtils.mkdir_p(File.join(@source_dir,default_upload_dir))
      default_upload_dir
    end

    def initialize(source_dir)
      @source_dir = source_dir
      unless File.exists?(source_dir) && File.directory?(source_dir)
        raise ArgumentError, 'Source directory must exist'
      end
      unless File.exists?(File.join(source_dir, '..', '_config.yml'))
        raise ArgumentError, 'Octopress _config.yml file missing'
      end
      unless File.basename(source_dir) == 'source'
        raise ArgumentError, 'Source directory \'' +  File.basename(source_dir) + '\' must be named \'source\''
      end
      unless File.exists?(source_dir + '/_posts') && File.directory?(source_dir + '/_posts')
        raise ArgumentError, 'Source directory must contain \'_posts\' directory'
      end
      octopress_config_file = File.join(source_dir, '..', '_config.yml')
      config_bytes = File.open(octopress_config_file, 'r') {|f| f.read }

      @config=YAML.load(config_bytes)
      @url = @config['url']
    end

  end

end