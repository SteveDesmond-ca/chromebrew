require 'package'

class Dbus < Package
  version '1.11.12'
  source_url 'https://dbus.freedesktop.org/releases/dbus/dbus-1.11.12.tar.gz'
  source_sha1 '2e2247398abb22115e724b5e955fece2307dddb0'

  depends_on 'expat'

  def self.build
    system "./configure"
    system "make"
  end

  def self.install
    system "make", "DESTDIR=#{CREW_DEST_DIR}", "install"
  end
end
