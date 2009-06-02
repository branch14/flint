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
      %x[umount /media/usb]
    end

    def source
      return '/media/usb/mp3test/' unless Dir.glob('/media/usb/mp3test/**').empty? # testing
      return '/media/cdrom/' if cdrom?
      return '/media/usb/' if usb?
      return false
    end

    def cdrom?
      !Dir.glob('/media/cdrom/**').empty?
    end

    def usb?
      !Dir.glob('/media/usb/**').empty?
    end
    
  end

end
