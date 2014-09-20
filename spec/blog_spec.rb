require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'tempfile'
require 'tmpdir'
require 'fileutils'
require 'stringex'

describe 'Octopsi' do
  it 'requires directory that exists as argument' do
    expect {
      blog = OctoPSI::Blog.new('/no/such/directory/')
    }.to raise_exception
  end
end

describe 'Octopsi' do
  it 'requires directory named "source" as argument' do
    Dir.mktmpdir do |dir|
      expect {
        blog = OctoPSI::Blog.new(dir)
      }.to raise_exception
    end
  end
end


describe 'Octopsi' do
  it 'requires directory containing posts as argument' do
    Dir.mktmpdir do |dir|
      Dir.mkdir(dir + '/source')
      expect {
        blog = OctoPSI::Blog.new(dir + '/source')
      }.to raise_exception
    end
  end
end

describe 'Octopsi' do
  it 'has a blog object with proper module namespacing' do
    Dir.mktmpdir do |dir|
      # puts "Tmpdir is #{dir}"
      Dir.mkdir(dir + '/source')
      File.open(dir + '/_config.yml', 'w') do |file|
        file.puts 'url: http://example.com'
      end
      Dir.mkdir(dir + '/source/_posts')
      blog = OctoPSI::Blog.new(dir + '/source')
      blog.should be
    end
  end
end

describe 'Octopsi' do
  it 'returns empty array for get_posts if dir is empty' do
    Dir.mktmpdir do |dir|
      # puts "Tmpdir is #{dir}"
      Dir.mkdir(dir + '/source')
      Dir.mkdir(dir + '/source/_posts')
      File.open(dir + '/_config.yml', 'w') do |file|
        file.puts 'url: http://example.com'
      end
      blog = OctoPSI::Blog.new(dir + '/source')
      posts = blog.get_posts(10)
      posts.count.should == 0
    end
  end
end


describe 'Octopsi' do
  it 'has a blog object with proper module namespacing' do
    blog = OctoPSI::Blog.new(File.expand_path(File.dirname(__FILE__) + '/fixtures/basic_blog_test/Blog1/source'))
    blog.should be
    posts = blog.get_posts(10)
    posts.count.should == 3
    posts[0].contents.should be
    posts[0].contents['title'].should == 'test post three'
    posts[0].contents['permalink'].should == 'http://example.com/blog/2014/09/09/test-post-three/'
    posts[0].body.should be
    web_reponse = posts[0].web_response
    web_reponse.should be
    web_reponse['title'].should == 'test post three'
  end
end
