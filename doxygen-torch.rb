# Head-only formula, needs to be installed with
# brew install --HEAD
require 'formula'

class DoxygenTorch < Formula
  url 'https://raw.github.com/akfidjeland/doxygen-torch/master/doxygen-torch-0.1.1.tar.gz'
  version "0.1.1"
  sha1 '90db15f4ee8bd13ede6698abb6a5bec2d7911440'
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
