# Head-only formula, needs to be installed with
# brew install --HEAD
require 'formula'

class DoxygenTorch < Formula
  url 'https://raw.github.com/akfidjeland/doxygen-torch/master/doxygen-torch-0.1.2.tar.gz'
  version "0.1.2"
  sha1 'e7160b08f3e28197f7b0bb0575c2fe7b68e5ba91'
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
