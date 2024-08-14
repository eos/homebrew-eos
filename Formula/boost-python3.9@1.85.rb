class BoostPython39AT185 < Formula
    desc "C++ library for C++/Python3 interoperability"
    homepage "https://www.boost.org/"
    url "https://github.com/boostorg/boost/releases/download/boost-1.85.0/boost-1.85.0-b2-nodocs.tar.xz"
    sha256 "09f0628bded81d20b0145b30925d7d7492fd99583671586525d5d66d4c28266a"
    license "BSL-1.0"
    head "https://github.com/boostorg/boost.git", branch: "master"
  
    livecheck do
      formula "boost"
    end

    bottle do
      root_url "https://github.com/eos/homebrew-eos/releases/download/2024-08/"
      sha256 cellar: :any, sonoma: "a82b696dc83b9781d7993de1e40900b7f2191857619d16e9689d70beaf699403"
    end
  
    #depends_on "numpy" => :build
    depends_on "eos/eos/boost@1.85"
    depends_on "python@3.9"
  
    def python3
      "python3.9"
    end
  
    def install
      # "layout" should be synchronized with boost
      args = %W[
        -d2
        -j#{ENV.make_jobs}
        --layout=tagged-1.66
        --user-config=user-config.jam
        install
        threading=single
        link=shared
      ]
  
      # Boost is using "clang++ -x c" to select C compiler which breaks C++14
      # handling using ENV.cxx14. Using "cxxflags" and "linkflags" still works.
      args << "cxxflags=-std=c++20"
      args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++" if ENV.compiler == :clang
  
      # disable python detection in bootstrap.sh; it guesses the wrong include
      # directory for Python 3 headers, so we configure python manually in
      # user-config.jam below.
      inreplace "bootstrap.sh", "using python", "#using python"
  
      pyver = Language::Python.major_minor_version python3
      py_prefix = if OS.mac?
        Formula["python@#{pyver}"].opt_frameworks/"Python.framework/Versions"/pyver
      else
        Formula["python@#{pyver}"].opt_prefix
      end
  
      # Force boost to compile with the desired compiler
      (buildpath/"user-config.jam").write <<~EOS
        using #{OS.mac? ? "darwin" : "gcc"} : : #{ENV.cxx} ;
        using python : #{pyver}
                     : #{python3}
                     : #{py_prefix}/include/python#{pyver}
                     : #{py_prefix}/lib ;
      EOS
  
      system "./bootstrap.sh", "--prefix=#{prefix}",
                               "--libdir=#{lib}",
                               "--with-libraries=python",
                               "--with-python=#{python3}",
                               "--with-python-root=#{py_prefix}"
  
      system "./b2", "--build-dir=build-python3",
                     "--stagedir=stage-python3",
                     "--libdir=install-python3/lib",
                     "--prefix=install-python3",
                     "python=#{pyver}",
                     *args
  
      lib.install buildpath.glob("install-python3/lib/*.*")
      (lib/"cmake").install buildpath.glob("install-python3/lib/cmake/boost_python*")
      (lib/"cmake").install buildpath.glob("install-python3/lib/cmake/boost_numpy*")
      doc.install (buildpath/"libs/python/doc").children
    end
  
    test do
      (testpath/"hello.cpp").write <<~EOS
        #include <boost/python.hpp>
        char const* greet() {
          return "Hello, world!";
        }
        BOOST_PYTHON_MODULE(hello)
        {
          boost::python::def("greet", greet);
        }
      EOS
  
      pyincludes = shell_output("#{python3}-config --includes").chomp.split
      pylib = shell_output("#{python3}-config --ldflags --embed").chomp.split
      pyver = Language::Python.major_minor_version(python3).to_s.delete(".")
  
      system ENV.cxx, "-shared", "-fPIC", "-std=c++20", "hello.cpp", "-L#{lib}", "-lboost_python#{pyver}",
                      "-o", "hello.so", *pyincludes, *pylib
  
      output = <<~EOS
        import hello
        print(hello.greet())
      EOS
      assert_match "Hello, world!", pipe_output(python3, output, 0)
    end
  end