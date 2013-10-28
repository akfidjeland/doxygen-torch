# Head-only formula, needs to be installed with
# brew install --HEAD
require 'formula'

class DoxygenTorch < Formula
  url 'https://raw.github.com/akfidjeland/doxygen-torch/tarball/v0.1.3'
  version "0.1.3"
  sha1 '735b1d0625781a6591e071312ba8757a6fe8a49c'
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
