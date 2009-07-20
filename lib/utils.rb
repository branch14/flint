require 'date'

module Utils

  class << self

    def mount_USB
      if dev = %x[lshal |grep -e "block.device.*sdb" -B 5 |grep -e ^udi | grep -i volume | cut -d= -f 2 ].strip
        unless dev.empty?
        %x[thunar-volman -a #{dev}]
        # mount dev

        %x[lshal |grep -e "mount_poi.*media" ].match(/'(.*)'/)
#        return line.match(/'(.*-)'/)[1]
        return $1
        # return path
        end
      end
      false
    end

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
       return '/media/cdrom/' if cdrom?
      if path = mount_USB
        subpath = "hochzeit"
        keypath = File.join(path, subpath)
        if File.directory?(keypath)
          return keypath
        else
          return path
        end
      end
      return false
    end

    def cdrom?
      %x[mount /media/cdrom/]
      !Dir.glob('/media/cdrom/**').empty?
    end

    def usb?
      return '/media/usb' if !Dir.glob('/media/usb/**').empty?
      #output = %x[mount | grep 'uhelper=hal']
      #if md = output.match(/.* on (.*) type .*/)
      #  return md[1]
      #end
      #false
    end

    def mix_in_our_stuff(xmms)
      now = DateTime::now
      teatime   = (now >= DateTime.new(2009, 6, 19, 12) && now <= DateTime.new(2009, 6, 19, 18))
      reception = (now >= DateTime.new(2009, 6, 20, 16) && now <= DateTime.new(2009, 6, 20, 20))
      dinner    = (now >= DateTime.new(2009, 6, 20, 20) && now <= DateTime.new(2009, 6, 20, 23))
      latenight = (now >= DateTime.new(2009, 6, 20, 23) && now <= DateTime.new(2009, 6, 21, 06))
      coll = "Phil & Sophia"
      coll = "Phil & Sophia (TT)" if teatime 
      coll = "Phil & Sophia (Rc)" if reception
      coll = "Phil & Sophia (Di)" if dinner
      coll = "Phil & Sophia (LN)" if latenight
      xmms.append_from_collection coll
    end
    
  end

end
