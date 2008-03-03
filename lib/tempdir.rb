#
# tempfile - manipulates temporary directories
#

require 'delegate'
require 'tmpdir'
require 'fileutils'

# A class for managing temporary directories.  This library is written to be
# thread safe.
class Tempdir < DelegateClass(Dir)
  MAX_TRY = 10
  @@cleanlist = []

  # Creates a temporary dir of mode 0700 in the temporary directory whose name
  # is basename.pid.n. A Tempdir object works just like a Dir object.
  #
  # If tmpdir is omitted, the temporary directory is determined by
  # Dir::tmpdir provided by 'tmpdir.rb'.
  # When $SAFE > 0 and the given tmpdir is tainted, it uses
  # /tmp. (Note that ENV values are tainted by default)
  def initialize(basename, tmpdir=Dir::tmpdir)
    if $SAFE > 0 and tmpdir.tainted?
      tmpdir = '/tmp'
    end

    n = failure = 0
    
    begin
      Thread.critical = true

      begin
        tmpname = File.join(tmpdir, make_tmpname(basename, n))
        n += 1
      end while @@cleanlist.include?(tmpname) or File.exist?(tmpname)

      Dir.mkdir(tmpname, 0700)
    rescue
      failure += 1
      retry if failure < MAX_TRY
      raise "cannot generate tempfile `%s'" % tmpname
    ensure
      Thread.critical = false
    end

    @data = [tmpname]
    @clean_proc = Tempdir.callback(@data)
    ObjectSpace.define_finalizer(self, @clean_proc)

    @tmpdir = Dir.new(tmpname)
    @tmpname = tmpname
    @@cleanlist << @tmpname
    @data[1] = @@cleanlist

    super(@tmpdir)
    if block_given?
      yield self
      @clean_proc.call
    end
    self
  end

  def make_tmpname(basename, n)
    sprintf('%s.%d.%d', basename, $$, n)
  end
  private :make_tmpname

  class << self
    def callback(data)	# :nodoc:
      pid = $$
      lambda {
        if pid == $$ 
          path, tmpdir, cleanlist = *data
          ObjectSpace.undefine_finalizer(tmpdir)
          FileUtils.rm_rf path
          cleanlist.delete(path) if cleanlist
        end
      }
    end
  end
end
