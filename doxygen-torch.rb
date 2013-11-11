# Head-only formula, needs to be installed with
# brew install --HEAD
require 'formula'

class DoxygenTorch < Formula
  url 'https://github.com/akfidjeland/doxygen-torch/archive/v0.1.3.tar.gz'
  version "0.1.4"
  sha1 'ff9cb9dcb01ed4467d213b1faf8343e5a06d9690'
  homepage 'https://github.com/akfidjeland/doxygen-torch'
  head 'https://github.com/akfidjeland/doxygen-torch.git'

  depends_on 'cmake' => :build
  depends_on 'doxygen'

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    system "echo hello | lua2dox /dev/stdin"
  end
end
