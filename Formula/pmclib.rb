class Pmclib < Formula
  desc "EOS specific build of pmclib"
  homepage "http://www2.iap.fr/users/kilbinge/CosmoPMC/"
  # homepage has been removed:
  #url "http://www2.iap.fr/users/kilbinge/CosmoPMC/pmclib_v1.01.tar.gz"
  # mirrored at:
  url "http://users.ph.tum.de/ga53yez/pmclib_v1.01.tar.gz"
  sha256 "4e7293ce9dfdd01091a8e27551fa7e0790ee92b657cf8c3d4a93cebe41c0fd87"

  depends_on "fftw"
  depends_on "gsl"

  patch :DATA

  def install
    # disable building MPI-related parts
    system "sed",
        "-i", "",
        "-e", "260,269d",
        "wscript"

    system "./waf", "--m64", "--prefix=#{prefix}", "configure"
    system "./waf", "build"
    system "./waf", "install"
    includes = [
	    "#{prefix}/include/pmclib/allmc.h",
	    "#{prefix}/include/pmclib/distribution.h",
	    "#{prefix}/include/pmclib/mcmc.h",
	    "#{prefix}/include/pmclib/parabox.h",
	    "#{prefix}/include/pmclib/pmc.h",
	    "#{prefix}/include/pmclib/tools.h",
    ]
    for f in includes do
	system "sed",
	   "-i", "",
	   "-e", "s/#include \"errorlist\\.h\"/#include <pmctools\\/errorlist.h>/",
           "-e", "s/#include \"io\\.h\"/#include <pmctools\\/io.h>/",
           "-e", "s/#include \"mvdens\\.h\"/#include <pmctools\\/mvdens.h>/",
           "-e", "s/#include \"maths\\.h\"/#include <pmctools\\/maths.h>/",
           "-e", "s/#include \"maths_base\\.h\"/#include <pmctools\\/maths_base.h>/",
	   f
    end
    system "sed",
        "-i", "",
        "-e", "s/\"extra\"/\" extra \"/p",
        "#{prefix}/include/pmctools/errorlist.h"
  end

  test do
    system "false"
  end
end
__END__
diff --git a/pmclib/src/optimize.c b/pmclib/src/optimize.c
index 1e628b8..e381050 100644
--- a/pmclib/src/optimize.c
+++ b/pmclib/src/optimize.c
@@ -46,7 +46,7 @@ double* optimize_get_best_pars(optimize_struct *opt, error **err) {
   
   testErrorRet(opt->cvg==0,-10001000,"did not converge",*err,__LINE__,NULL);
   res = opt->get_result(opt,err);
-  forwardError(*err,__LINE__,);
+  forwardError(*err,__LINE__,res);
   
   return res;
 }
