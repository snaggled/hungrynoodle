require 'rubygems'
require 'find'   
require 'sqlite3'       
require 'fileutils'      
require 'nokogiri'   
require 'logger'
           
# This class provides a simple mechanism to find and cache a list 
# of files on your system (much like slocate). It is configured by thge 
# associated hungrynoodle.xml file - and expects only 2 parameters:
# * <dir>The directory to be searched/cached</dir>
# * <regex>The regular expression detailing the files to be cached</regex>   
# The class uses sqlite3 by default for storage of its information and logs
# debug information to hungrynoodle.txt
# Author::    Philip Mcmahon  (mailto:philip@packetnode.com)
# Copyright:: Copyright (c) 2011 Packetnode, LLC
# License::   Distributes under the same terms as Ruby
                        
class HungryNoodle                 
  include ObjectSpace
         
  # Initialize. db_name refers to the name of the sqlite database
  def initialize(db_name = "file_cache.db")       
    @dirs = []     
    @log = Logger.new('hungrynoodle.txt')
    @db = SQLite3::Database.open(db_name)        
    #@db.execute("drop table files")
    @db.execute("create table if not exists files(
                                      id integer primary key autoincrement, 
                                      basename varchar, 
                                      atime datetime,
                                      expand_path varchar,
                                      ctime datetime,
                                      dirname varchar,
                                      extname varchar,
                                      mtime datetime,
                                      size integer)") 
    f = File.open("hungrynoodle.xml")
    doc = Nokogiri::XML(f)    
    @dirs << doc.xpath("//dir").children.first.text     
    @regex = Regexp.compile(doc.xpath("//regex").children.first.text)
    f.close       
    define_finalizer(self, proc { @db.close; @log.close })
  end  
       
  # Insert a file into the sqlite cache. Files are tested for their
  # existence in the cache first via the exists? method 
  def insert(file)
     if exists?(file)
       @log.debug "#{file} already exists in cache"
     else  
       @log.debug "Inserting #{file} into cache"                 
       @db.execute("insert into files (basename, 
                                     atime, 
                                     expand_path, 
                                     ctime, 
                                     dirname, 
                                     extname, 
                                     mtime, 
                                     size) values 
                                     ('#{File.basename(file).sub("'", "''")}', 
                                     '#{File.atime(file)}', 
                                     '#{File.expand_path(file).sub("'", "''")}', 
                                     '#{File.ctime(file)}', 
                                     '#{File.dirname(file).sub("'", "''")}', 
                                     '#{File.extname(file)}', 
                                     '#{File.mtime(file)}', 
                                     '#{File.size(file)}')") 
     end
   end   
             
   # Does this file exists in the cache ? This method performs a lookup
   # based on filename and size. If a matching file is found, the contents
   # are compared to check if the files are identical.
   def exists?(file)         
     @log.debug("Processing file: #{file}")      
     @records = @db.execute("select * from files where basename = 
      '#{File.basename(file).sub("'", "''")}' and size = '#{File.size(file)}'")
     @records.each do |record|  
      return true if FileUtils.compare_file(file, record[3]) 
     end
     false
   end  
                   
   # Find all files in the configured (see hungrynoodle.xml) directory
   # and regex. All matching files are inserted into the cache unless
   # they already exist.
   def find_and_insert
     excludes = []     
     for dir in @dirs
       Find.find(dir) do |path|
         if FileTest.directory?(path)
           if excludes.include?(File.basename(path))
             Find.prune 
           else
             next
           end
         else    
           if path =~ @regex     
             insert(path)
           end
         end
       end
     end
   end  
end       

# __main__
file_cache = HungryNoodle.new
file_cache.find_and_insert

                 

