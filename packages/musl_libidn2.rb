require 'package'

class Musl_libidn2 < Package
  description 'GNU Libidn is a fully documented implementation of the Stringprep, Punycode and IDNA 2003 specifications.'
  homepage 'https://www.gnu.org/software/libidn/'
  version '2.3.2'
  license 'GPL-2+ and LGPL-3+'
  compatibility 'all'
  source_url "https://ftpmirror.gnu.org/libidn/libidn2-#{version}.tar.gz"
  source_sha256 '76940cd4e778e8093579a9d195b25fff5e936e9dc6242068528b437a76764f91'

  binary_url({
    aarch64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/musl_libidn2/2.3.2_armv7l/musl_libidn2-2.3.2-chromeos-armv7l.tpxz',
     armv7l: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/musl_libidn2/2.3.2_armv7l/musl_libidn2-2.3.2-chromeos-armv7l.tpxz',
       i686: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/musl_libidn2/2.3.2_i686/musl_libidn2-2.3.2-chromeos-i686.tpxz',
     x86_64: 'https://gitlab.com/api/v4/projects/26210301/packages/generic/musl_libidn2/2.3.2_x86_64/musl_libidn2-2.3.2-chromeos-x86_64.tpxz'
  })
  binary_sha256({
    aarch64: '05013c0c7e71e590b2b7d7c55519ff837a09f187330612c142f2bb7e2632b5a6',
     armv7l: '05013c0c7e71e590b2b7d7c55519ff837a09f187330612c142f2bb7e2632b5a6',
       i686: '5652db6b61a1b4245a8b72aa27da31cffcdb15de4a3b7bb724b07264f022b505',
     x86_64: '0813b2ae14c7349e1112f4e93ca5cd76e5a0ba5bee4c51b1db2f74c8e86006c7'
  })

  depends_on 'musl_native_toolchain' => :build
  depends_on 'musl_libunistring' => :build

  @abi = ''
  @arch_ssp_cflags = ''
  @arch_c_flags = ''
  @arch_cxx_flags = ''
  case ARCH
  when 'aarch64', 'armv7l'
    @abi = 'eabihf'
  when 'i686'
    @arch_ssp_cflags = '-fno-stack-protector'
  when 'x86_64'
  end

  @cflags = "-B#{CREW_PREFIX}/musl/include -flto -pipe -O3 -ffat-lto-objects -fipa-pta -fno-semantic-interposition -fdevirtualize-at-ltrans #{@arch_c_flags} #{@arch_ssp_cflags} -fcommon"
  @cxxflags = "-B#{CREW_PREFIX}/musl/include -flto -pipe -O3 -ffat-lto-objects -fipa-pta -fno-semantic-interposition -fdevirtualize-at-ltrans #{@arch_cxx_flags} #{@arch_ssp_cflags} -fcommon"
  @ldflags = "-L#{CREW_PREFIX}/musl/lib -flto -static"
  @cmake_ldflags = '-flto'
  @musldep_cmake_options = "PATH=#{CREW_PREFIX}/musl/bin:#{CREW_PREFIX}/musl/#{ARCH}-linux-musl#{@abi}/bin:#{ENV['PATH']} \
        CC='#{CREW_PREFIX}/musl/bin/#{ARCH}-linux-musl#{@abi}-gcc' \
        CXX='#{CREW_PREFIX}/musl/bin/#{ARCH}-linux-musl#{@abi}-g++' \
        LD=#{CREW_PREFIX}/musl/bin/#{ARCH}-linux-musl#{@abi}-ld.gold \
        AR=#{CREW_PREFIX}/musl/bin/ar \
        CFLAGS='#{@cflags}' \
        CXXFLAGS='#{@cxxflags}' \
        CPPFLAGS='-I#{CREW_PREFIX}/musl/include -fcommon' \
        LDFLAGS='#{@cmake_ldflags}' \
        cmake \
        -DCMAKE_INSTALL_PREFIX='#{CREW_PREFIX}/musl' \
        -DCMAKE_LIBRARY_PATH='#{CREW_PREFIX}/musl/lib' \
        -DCMAKE_C_COMPILER=#{CREW_PREFIX}/musl/bin/#{ARCH}-linux-musl#{@abi}-gcc \
        -DCMAKE_CXX_COMPILER=#{CREW_PREFIX}/musl/bin/#{ARCH}-linux-musl#{@abi}-g++ \
        -DCMAKE_INCLUDE_DIRECTORIES_BEFORE=ON \
        -DINCLUDE_DIRECTORIES=#{CREW_PREFIX}/musl/include \
        -DCMAKE_C_FLAGS='#{@cflags}' \
        -DCMAKE_CXX_FLAGS='#{@cxxflags}' \
        -DCMAKE_EXE_LINKER_FLAGS='#{@cmake_ldflags}' \
        -DCMAKE_SHARED_LINKER_FLAGS='#{@cmake_ldflags}' \
        -DCMAKE_STATIC_LINKER_FLAGS='#{@cmake_ldflags}' \
        -DCMAKE_MODULE_LINKER_FLAGS='#{@cmake_ldflags}' \
        -DPROPERTY_INTERPROCEDURAL_OPTIMIZATION=TRUE \
        -DCMAKE_BUILD_TYPE=Release"

  @musldep_env_options = "PATH=#{CREW_PREFIX}/musl/bin:#{ENV['PATH']} \
      CC='#{CREW_PREFIX}/musl/bin/#{ARCH}-linux-musl#{@abi}-gcc' \
      CXX='#{CREW_PREFIX}/musl/bin/#{ARCH}-linux-musl#{@abi}-g++' \
      LD=#{CREW_PREFIX}/musl/bin/#{ARCH}-linux-musl#{@abi}-ld.gold \
      PKG_CONFIG_LIBDIR=#{CREW_PREFIX}/musl/lib/pkgconfig \
      CFLAGS='#{@cflags}' \
      CXXFLAGS='#{@cxxflags}' \
      CPPFLAGS='-I#{CREW_PREFIX}/musl/include -fcommon' \
      LDFLAGS='#{@ldflags}'"

  def self.patch
    FileUtils.rm_f 'doc/idn2.1'
  end

  def self.build
    system "#{@musldep_env_options} ./configure --prefix=#{CREW_PREFIX}/musl \
        --disable-shared \
        --disable-doc \
        --disable-rpath \
        --disable-gtk-doc \
        --disable-gtk-doc-pdf"
    system 'make'
  end

  def self.install
    ENV['CREW_FHS_NONCOMPLIANCE_ONLY_ADVISORY'] = '1'
    warn_level = $VERBOSE
    $VERBOSE = nil
    load "#{CREW_LIB_PATH}lib/const.rb"
    $VERBOSE = warn_level
    system 'make', "DESTDIR=#{CREW_DEST_DIR}", 'install'
  end
end
