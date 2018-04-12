class Eos < Formula
  desc "EOS"
  homepage "https://eos.github.io"
  head "https://github.com/eos/eos.git", :branch => "master"

  # build utilities
  depends_on "autoconf"
  depends_on "automake"
  depends_on "libtool"
  depends_on "pkg-config"

  # scientific libraries
  depends_on "pmclib"
  depends_on "gsl"
  depends_on "hdf5"
  depends_on "minuit2"

  # technical stuff
  depends_on "python3"
  depends_on "boost-python3"
  depends_on "yaml-cpp"

  def install
    system "./autogen.bash"
    system "./configure", "--enable-pmc", "--prefix=#{prefix}"
    system "make", "-j", "all"
    system "make", "install"
  end

  test do
    system "false"
  end
end
