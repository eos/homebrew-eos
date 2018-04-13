class Eos < Formula
  desc "EOS"
  homepage "https://eos.github.io"
  head "https://github.com/eos/eos.git", :branch => "master"

  # system software
  depends_on "autoconf"
  depends_on "automake"
  depends_on "libtool"
  depends_on "pkg-config"
  depends_on "boost"
  depends_on "yaml-cpp"

  # scientific libraries
  depends_on "pmclib"
  depends_on "gsl"
  depends_on "hdf5"
  depends_on "minuit2"

  # python software
  depends_on "python3"
  depends_on "boost-python"

  def install
    system "./autogen.bash"
    system "./configure", "--enable-pmc", "--enable-python", "--prefix=#{prefix}"
    system "make", "-j", "all"
    system "make", "install"
  end

  test do
    system "make", "check", "-j", "VERBOSE=1"
  end
end
