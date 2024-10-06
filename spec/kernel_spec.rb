
# vim:ts=2:sw=2

#$: << 'lib/cangallo'
require 'spec_helper'
require 'kernel'
require 'fileutils'

RSpec.configure do |config|
  config.order = :defined
end

describe Cangallo::Kernel do
  before :all do
    @kerneldir = FileUtils.mkdir_p(Cangallo::Kernel::KERNELS_DIR).first
    @version = Cangallo::Kernel.current
  end

  after :all do
    FileUtils.rm_rf(@kerneldir)
  end

  context "static methods" do

    it 'downloads kernel' do
      Cangallo::Kernel.download( @version )
      expect(Dir).to exist("#{Dir.pwd}/#{@kerneldir}/#{@version}")
    end

    it 'deletes kernel' do
      Cangallo::Kernel.delete( @version )
      expect(Dir).not_to exist("#{Dir.pwd}/#{@kerneldir}/#{@version}")
    end

    it 'export kernel params to env' do
      Cangallo::Kernel.write_env( @version )
      expect(Cangallo::Kernel.supermin_kernel.include?(@version))
    end

  end
end
