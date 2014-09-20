require 'rubygems'

require 'yaml'
require 'stringex'

module OctoPSI
  class Post

    def initialize(base_url, blog_name, blog_source_dir, filename_or_hash)
      @base_url = base_url
      @blog_name = blog_name
      @blog_source_dir = blog_source_dir
      if filename_or_hash.is_a? Hash
        #perform initialization in first case
        self.populate_contents_from_hash(filename_or_hash)
      elsif filename_or_hash.is_a? String
        #perform initialization in second case
        @post_file = filename_or_hash
        @post_name = File.basename(@post_file,'.markdown')
        load_from_file
      else raise TypeError
      end
    end

    def populate_contents_from_hash(new_contents)
      #Save off stuff we need to keep if we have it
      categories=nil
      primary_category=nil
      if @contents
        if @contents['date']
          @creation_date=@contents['date']
        else
          @creation_date=Time.now
        end
        if @contents['primaryCategory']
          primary_category=@contents['primaryCategory']
        end
        if @contents['categories']
          categories=@contents['categories']
        end
      end
      @contents={}
      if categories
        @contents['categories']=categories
      end
      if primary_category
        @contents['primaryCategory']=primary_category
      end
      @post_name="#{Time.now.strftime('%Y-%m-%d')}-#{new_contents['title'].to_url}" unless @post_name
      @base_filename = "#{@post_name}.markdown"
      @post_file=File.join(@blog_source_dir, '_posts', @base_filename) unless @post_file
      ignore_keys=self.import_keys_to_skip
      new_contents.each_key { |key|
        next if ignore_keys.include? key
        @contents[key]=new_contents[key]
      }

      @body=new_contents['description']
      @contents['layout']='post'
      @contents['date']=@creation_date
      if new_contents['post_status']=='publish'
        self.draft=false
        @contents['published']=true
      else
        @contents['published']=false
        self.draft=true
      end
      if new_contents['comments']==1
        @contents['comments']=false
      else
        @contents['comments']=true
      end
      if new_contents['mt_keywords']
        new_keywords=new_contents['mt_keywords']
        new_keywords.sub!(/^\s*/,'')
        new_keywords.sub!(/\s*$/,'')
        if new_keywords.length > 0
          @contents['tags']=new_keywords.split(/\s*,\s*/)
        end
      end
    end

    def import_keys_to_skip
      ['description','post_status','mt_text_more','wp_more_text','mt_allow_pings','wp_slug','wp_password',
              'wp_author_id','wp_author_display_name','wp_post_format','sticky','wp_post_thumbnail','mt_tags',
              'comments','mt_convert_breaks','post_status','mt_keywords','mt_allow_comments','mt_excerpt','categories']
    end

    def post_name
      @post_name
    end

    def creation_date
      @creation_date
    end

    def modification_date
      @modification_date
    end

    def contents
      @contents
    end

    def draft
      @draft
    end

    def draft=(value)
      @draft = value
    end

    alias_method :isDraft?, :draft

    def keywords
      return_value = ''
      if @contents
        if @contents['tags']
          if @contents['tags'].is_a? String
            return_value = @contents['tags']
          elsif @contents['tags'].is_a? Array
            return_value = @contents['tags'].join(', ')
          end
        end
      end
      return_value
    end

    def tags
      return_value = []
      if @contents
        if @contents['tags']
          if @contents['tags'].is_a? String
            return_value << @contents['tags']
          elsif @contents['tags'].is_a? Array
            return_value.concat @contents['tags']
          end
        end
      end
      return_value
    end

    def postId
      @blog_name + '/' + @post_name
    end

    def post_file
      @post_file
    end

    def web_response
      {
          'dateCreated' => @contents['date'] || Date.today,
          'userid' => '0',
          'postId' => self.postId,
          'description' => @body || '',
          'title' => @contents['title'] || '',
          'link' => @contents['permalink'] || @base_url + '/' + File.basename(@post_name.split(/-/,4)[3], '.markdown'),
          'permalink' => @contents['permalink'] || @base_url + '/'+ File.basename(@post_name.split(/-/,4)[3], '.markdown'),
          'categories' => @contents['categories'] || [],
          'mt_excerpt' => '',
          'mt_text_more' => '',
          'wp_more_text' => '',
          'mt_allow_comments' => 1,
          'mt_allow_pings' => 0,
          'mt_keywords' => keywords,
          'wp_slug' => File.basename(@post_name.split(/-/,4)[3], '.markdown'),
          'wp_password' => '',
          'wp_author_id' => '0',
          'wp_author_display_name' => 'root',
          'date_created_gmt' => @contents['date'] || Date.today,
          'wp_post_format' => 'standard',
          'date_modified' => @contents['date'] || Date.today,
          'date_modified_gmt' => @contents['date'] || Date.today,
          'post_status' => self.draft && 'publish' || 'draft',
          'sticky' => false,
          'wp_post_thumbnail' => '',
      }
    end

    def get_categories
      return [] unless @contents
      @contents['categories'] || []
    end

    def category_hash
      return_value=[]
      if @contents
        @contents['categories'].each { |cat_name|
          cat_hash={
              'categoryId' => cat_name,
              'categoryName' => cat_name,
          }
          if @contents['primaryCategory']==cat_name
            cat_hash['isPrimary']=true
          else
            cat_hash['isPrimary']=false
          end
        }
      end
      return_value
    end

    def edit_content(content, publish)
      self.populate_contents_from_hash content
      if publish
        self.draft=false
        @contents['published']=true
      else
        @contents['published']=false
        self.draft=true
      end
      self.save
    end

    def replace_categories(categories)
      category_array=[]
      categories.each { |cat_hash|
        if cat_hash.is_a? Hash
          if cat_hash['categoryName']
            category_array << cat_hash['categoryName']
            if cat_hash['isPrimary']
              @contents['primaryCategory']=cat_hash['categoryName']
            end
          end
        end
      }
      @contents['categories']=category_array
      self.save
    end

    def save
      if @body !~ /\n$/
        @body.sub! /$/,"\n"
      end
      File.open(@post_file, 'w') {|f|
        f.write(@contents.to_yaml)
        f.write("---\n")
        f.write(@body)
      }
      true
    end

    def body
      @body
    end

    protected
    def load_from_file
      unless File.exists? @post_file
        STDERR.puts("No such file or directory #{@post_file}")
        return nil
      end
      unless File.file? @post_file
        STDERR.puts("Invalid filesystem object #{@post_file} must be a file")
        return nil
      end
      unless File.size? @post_file
        STDERR.puts("Cannot load empty file #{@post_file}")
        return nil
      end

      bytes = File.open(@post_file, 'r') {|f| f.read }

      unless bytes
        return nil
      end

      if bytes !~ /^---\s*\n/
        STDERR.puts("Cannot read file without leading Jekyll header #{@post_file}")
        return nil
      end

      bytes.sub(/^---\s*\n/,'')

      # file must begin with YAML
      parts = bytes.split(/\n---\s*\n/,2)
      if parts==nil || parts.count !=2
        STDERR.puts("can't find YAML header in #{@post_file}")
        return nil
      end
      parts[0] += "\n" #make sure there's a newline at the end
      begin
        @contents = YAML.load(parts[0])
        if @contents['post_status']=='publish'
          self.draft=true
        else
          self.draft=false
        end
        @body=parts[1]
      rescue Exception => e
        STDERR.puts("can't load YAML from #{@post_file}: #{e}")
        return nil
      end
    end
  end
end