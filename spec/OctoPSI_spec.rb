require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'tempfile'
require 'tmpdir'
require 'fileutils'
require 'stringex'



describe 'Octopsi' do
  it 'Populates blog objects correctly' do
    parent = OctoPSI::OctoPSI.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/basic_blog_test/'))
    parent.blogs.should be
    parent.blogs.keys.count.should==2
    parent.blogs['Blog1'].name.should == 'Blog1'
    parent.blogs['Blog2'].name.should == 'Blog2'
    parent.blogs['Blog1'].get_posts(10).count.should==3
    parent.blogs['Blog2'].get_posts(10).count.should==1
  end
end

describe 'Octopsi' do
  it 'Gets Recent Posts Response' do
    parent = OctoPSI::OctoPSI.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/basic_blog_test/'))
    parent.blogs.should be
    parent.blogs.keys.count.should==2
    blog = parent.blogs['Blog1']
    blog.should be
    blog.name.should == 'Blog1'
    blog.base_url.should == 'http://example.com'

    recents = parent.getRecentPosts('Blog1',nil,nil,30)
    recents.count.should == 3
  end
end

describe 'Octopsi' do
  it 'Gets Post Info' do
    parent = OctoPSI::OctoPSI.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/basic_blog_test/'))
    parent.blogs.should be
    parent.blogs.keys.count.should==2
    blog = parent.blogs['Blog1']
    blog.should be
    blog.name.should == 'Blog1'
    blog.base_url.should == 'http://example.com'

    first_post = blog.get_post_by_name('2014-09-07-test-post-one')
    first_post.should be
    categories = first_post.get_categories

    cats = parent.getPostCategories('Blog1/2014-09-07-test-post-one',nil,nil)
    cats.should be
    cats.count.should == 2

    all_cats = parent.getCategoryList('Blog1',nil,nil)
    all_cats.should be
    all_cats.count.should == 5

    recent =  parent.getRecentPosts('Blog1',nil,nil,3)
  end
end

describe 'Octopsi' do
  it 'Gets Category Info' do
    parent = OctoPSI::OctoPSI.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/basic_blog_test/'))
    parent.blogs.should be
    parent.blogs.keys.count.should==2
    blog = parent.blogs['Blog1']
    blog.should be
    blog.name.should == 'Blog1'
    blog.base_url.should == 'http://example.com'

    cat_list = parent.getCategoryList(blog.name,nil,nil)
    cat_list.count.should == 5

    posts=blog.get_posts(30)
    posts.count.should == 3
    post1=posts[0]
    cat_list_post1 = parent.getPostCategories(post1.postId,nil,nil)
    cat_list_post1.count.should == 3

    post1_from_parent=parent.getPost(post1.postId,nil,nil,nil)
    post1.postId.should be
    post1_from_parent['postId'].should be
    post1.postId.should == post1_from_parent['postId']

  end
end


describe 'Octopsi' do
  it 'Creates a New Post' do
    Dir.mktmpdir do |dir|
      # puts "Tmpdir is #{dir}"
      Dir.mkdir(File.join(dir, 'base'))
      testDir=File.expand_path(File.dirname(__FILE__) + '/fixtures/basic_blog_test/')
      FileUtils.cp_r Dir.glob("#{testDir}/*"), File.join(dir, 'base')
      parent = OctoPSI::OctoPSI.new(dir + '/base')
      parent.blogs.should be
      parent.blogs.keys.count.should==2
      blog = parent.blogs['Blog1']
      blog.should be
      blog.name.should == 'Blog1'
      blog.base_url.should == 'http://example.com'

      posts=blog.get_posts(30)
      posts.count.should == 3

      first_post = posts[0]
      first_post.should be
      first_post.post_name.should == '2014-09-09-test-post-three'

      content=  {
          'dateCreated' => Date.today,
          'userid' => '0',
          'description' => "This is a test post\n\nTesting\nTesting",
          'title' => 'Test Post From RSpec',
      }

      parent.newPost(blog.name,nil,nil,content, true)

      blog.load_post_names
      blog.load_posts
      posts=blog.get_posts(30)
      posts.count.should == 4

      first_post = posts[0]
      first_post.should be
      first_post.post_name.should == "#{Time.now.strftime('%Y-%m-%d')}-#{'Test Post From RSpec'.to_url}"

    end
  end
end

describe 'Octopsi' do
  it 'Has Filters' do
    Dir.mktmpdir do |dir|
      # puts "Tmpdir is #{dir}"
      Dir.mkdir(File.join(dir, 'base'))
      testDir=File.expand_path(File.dirname(__FILE__) + '/fixtures/basic_blog_test/')
      FileUtils.cp_r Dir.glob("#{testDir}/*"), File.join(dir,'base')
      parent = OctoPSI::OctoPSI.new(dir + '/base')

      filters = parent.supportedTextFilters
      filters.should be
      filters.count.should == 1
    end
  end
end


describe 'Octopsi' do
  it 'Sets Category Info' do
    Dir.mktmpdir do |dir|
      # puts "Tmpdir is #{dir}"
      Dir.mkdir(File.join(dir, 'base'))
      testDir=File.expand_path(File.dirname(__FILE__) + '/fixtures/basic_blog_test/')
      FileUtils.cp_r Dir.glob("#{testDir}/*"), File.join(dir, 'base')
      parent = OctoPSI::OctoPSI.new(dir + '/base')

      parent.blogs.should be
      parent.blogs.keys.count.should==2
      blog = parent.blogs['Blog1']
      blog.should be
      blog.name.should == 'Blog1'
      blog.base_url.should == 'http://example.com'

      cat_list = parent.getCategoryList(blog.name,nil,nil)
      cat_list.count.should == 5

      posts=blog.get_posts(30)
      posts.count.should == 3
      post1=posts[0]
      cat_list_post1 = parent.getPostCategories(post1.postId,nil,nil)
      cat_list_post1.count.should == 3

      replacement_cats = [
          {'categoryName' => 'newCat1',
           'categoryId' => 'newCat1'},
          {'categoryName' => 'newCat2',
           'categoryId' => 'newCat2'}
      ]
      replacement_cats.concat(cat_list_post1)
      replacement_cats.count.should == 5

      parent.setPostCategories(post1.postId,nil,nil,replacement_cats)

      new_parent = OctoPSI::OctoPSI.new(dir + '/base')

      new_parent.blogs.should be
      new_parent.blogs.keys.count.should==2
      new_blog = parent.blogs['Blog1']
      new_blog.should be
      new_blog.name.should == 'Blog1'
      new_blog.base_url.should == 'http://example.com'
      new_posts=new_blog.get_posts(30)
      new_post1=new_posts[0]

      new_blog_cat_list = new_parent.getPostCategories(new_post1.postId,nil,nil)
      new_blog_cat_list.count.should == 5

      new_cat_list = new_parent.getCategoryList(new_blog.name,nil,nil)
      new_cat_list.count.should == 7
    end


  end
end

describe 'Octopsi' do
  it 'Edits Post' do
    Dir.mktmpdir do |dir|
      # puts "Tmpdir is #{dir}"
      Dir.mkdir(File.join(dir, 'base'))
      testDir=File.expand_path(File.dirname(__FILE__) + '/fixtures/basic_blog_test/')
      FileUtils.cp_r Dir.glob("#{testDir}/*"), File.join(dir, 'base')
      parent = OctoPSI::OctoPSI.new(dir + '/base')

      parent.blogs.should be
      parent.blogs.keys.count.should==2
      blog = parent.blogs['Blog1']
      blog.should be
      blog.name.should == 'Blog1'
      blog.base_url.should == 'http://example.com'

      posts=blog.get_posts(30)
      posts.count.should == 3
      post1=posts[0]

      post1_hash = parent.getPost(post1.postId,nil,nil)

      old_description = post1.body

      new_description = old_description + "\n and this is a test"

      post1_hash['description'] = new_description

      parent.editPost(post1.postId,nil,nil,post1_hash,true)

      retrived_post = parent.getPost(post1.postId,nil,nil)

      retrived_post['description'].should == new_description

    end


  end
end

describe 'Octopsi' do
  it 'Uploads Image' do
    Dir.mktmpdir do |dir|
      # puts "Tmpdir is #{dir}"
      Dir.mkdir(File.join(dir, 'base'))
      testDir=File.expand_path(File.dirname(__FILE__) + '/fixtures/basic_blog_test/')
      FileUtils.cp_r Dir.glob("#{testDir}/*"), File.join(dir, 'base')
      parent = OctoPSI::OctoPSI.new(dir + '/base')

      parent.blogs.should be
      parent.blogs.keys.count.should==2
      blog = parent.blogs['Blog1']
      blog.should be
      blog.name.should == 'Blog1'
      blog.base_url.should == 'http://example.com'

      testImageFile =File.expand_path(File.dirname(__FILE__) + '/fixtures/upload_test/500_x_500_SMPTE_Color_Bars.png')

      testImageFileBytes = File.open(testImageFile, 'rb') {|f| f.read }


      data = {
          'name' => '500_x_500_SMPTE_Color_Bars.png',
          'bits' => testImageFileBytes
      }
      new_url = parent.newMediaObject(blog.name,nil,nil,data)

      new_url.should be
      path = new_url['url']

      # puts File.join(dir + '/base',blog.name,'source',path)

      File.exists?(File.join(dir + '/base',blog.name,'source',path)).should == true


    end
  end

end


describe 'Octopsi' do
  it 'Uploads Image' do
    Dir.mktmpdir do |dir|
      # puts "Tmpdir is #{dir}"
      Dir.mkdir(File.join(dir, 'base'))
      testDir=File.expand_path(File.dirname(__FILE__) + '/fixtures/basic_blog_test/')
      FileUtils.cp_r Dir.glob("#{testDir}/*"), File.join(dir, 'base')
      parent = OctoPSI::OctoPSI.new(dir + '/base')

      parent.blogs.should be
      parent.blogs.keys.count.should==2
      blog = parent.blogs['Blog1']
      blog.should be
      blog.name.should == 'Blog1'
      blog.base_url.should == 'http://example.com'
      posts=blog.get_posts(30)
      posts.count.should == 3
      post1=posts[0]

      response = parent.deletePost(nil,post1.postId,nil,nil,true)
      response.should == false #don't allow deletes, yet, for safety
    end
  end
end
