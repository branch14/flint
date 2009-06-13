module Utils

  class << self

    def umount_and_eject
      umount_usb
      eject_cdrom
    end

    def eject_cdrom
      %x[eject]
    end
    
    def umount_usb
      %x[umount #{usb?}]
    end

    def source
      return '/media/usb/mp3test/' unless Dir.glob('/media/usb/mp3test/**').empty? # testing
      return '/media/cdrom/' if cdrom?
      if path = usb?
        return path
      end
      return false
    end

    def cdrom?
      !Dir.glob('/media/cdrom/**').empty?
    end

    def usb?
      #!Dir.glob('/media/usb/**').empty?
      output = %x[mount | grep 'uhelper=hal']
      if md = output.match(/.* on (.*) type .*/)
        return md[1]
      end
      false
    end
    
  end

end
