require 'systemu'
require 'fileutils'
require 'debug'

class Cangallo
  class Kernel
    KERNELS_DIR="kernels"

    def self.initialize
      raise StandardError, "Cannot instantiate an instance of static class."
    end

    def self.current
      execute "uname -r"
    end

    # TO-DO add support for fedora family
    def self.download(version)
      execute "apt-get update && cd kernels && \
               apt-get download linux-image-#{version} linux-headers-#{version} linux-modules-#{version} && \
               dpkg-deb -x linux-image-#{version}*.deb #{version}/ && \
               dpkg-deb -x linux-headers-#{version}*.deb #{version}/ && \
               dpkg-deb -x linux-modules-#{version}*.deb #{version}/ && \
               rm linux-image-#{version}*.deb linux-headers-#{version}*.deb linux-modules-#{version}*.deb"

    end

    def self.kernel_path(version)
      File.join(Dir.pwd, KERNELS_DIR, version)
    end

    def self.delete(version)
      FileUtils.rm_rf(kernel_path(version))
    end

    def self.write_env(version)
      path = File.expand_path(".cangallo.env")
      env = <<~ENV
              export SUPERMIN_KERNEL=#{kernel_path(version)}/boot/vmlinuz-#{version}
              export SUPERMIN_MODULES=#{kernel_path(version)}/lib/modules/#{version}
            ENV
      File.write(path, env)
    end

    def self.supermin_kernel
      execute ". #{File.expand_path('.cangallo.env')} && echo $SUPERMIN_KERNEL"
    end

    def self.execute(command)
      status, stdout, stderr = systemu command
      status.success? ? stdout.strip : raise(StandardError, stderr)
    end
  end
end
