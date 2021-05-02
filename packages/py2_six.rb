require 'package'

class Py2_six < Package
  description 'Six is a Python 2 and 3 compatibility library.'
  homepage 'https://six.readthedocs.io/'
  @_ver = '1.15.0'
  version @_ver
  license 'MIT'
  compatibility 'all'
  source_url 'https://github.com/benjaminp/six.git'
  git_hashtag @_ver

  depends_on 'py2_setuptools' => :build

  def self.build
    system "python2 setup.py build #{PY2_SETUP_BUILD_OPTIONS}"
  end

  def self.install
    system "python2 setup.py install #{PY_SETUP_INSTALL_OPTIONS}"
  end
end
