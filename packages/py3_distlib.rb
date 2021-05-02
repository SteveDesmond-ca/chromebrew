require 'package'

class Py3_distlib < Package
  description 'Appdirs is a small Python module for determining appropriate platform-specific directories.'
  homepage 'https://bitbucket.org/pypa/distlib/'
  @_ver = '0.3.1'
  version @_ver
  license 'MIT'
  compatibility 'all'
  source_url 'https://bitbucket.org/pypa/distlib.git'
  git_hashtag @_ver

  depends_on 'py3_setuptools' => :build

  def self.build
    system "python3 setup.py build #{PY3_SETUP_BUILD_OPTIONS}"
  end

  def self.install
    system "python3 setup.py install #{PY_SETUP_INSTALL_OPTIONS}"
  end
end
