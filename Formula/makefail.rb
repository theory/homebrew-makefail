require 'pp'
class Makefail < Formula
  desc "Testing case for Homebrew `make` bug"
  version "1"
  url "https://raw.githubusercontent.com/theory/homebrew-makefail/master/tryme.tgz"
  sha256 "493bf653887db204f3063674fc581b79a2c286ad5e3c77f0d29a5b28808b7f50"
  depends_on 'cpanminus' => :build
  bottle :unneeded

  option 'with-install-debug', "Turns on debug output for `make install`"
  option 'with-install-verbose', "Turns on verbose output for `make install`"
  option "with-fix", "Tweak environment to fix the bug"

  def install
    # Install dependencies.
    system *%W[cpanm --quiet --notest --local-lib-contained tryit List::MoreUtils::XS Exporter::Tiny]

    if build.with? "fix"
      ENV["MAKEFLAGS"] = ""
    end

    if build.with? "install-debug"
      # Enable debugging output for `make install`. Build will appear successful
      # (if empty), but log will have have full debugging output.
      system *%W[cpanm --verbose --notest --local-lib-contained tryit --install-args -d List::MoreUtils]
    elsif build.with? "install-verbose"
      pp ENV
      # Enable echoing commands and ExtUtils::Install verbosity.
      system *%W[cpanm --verbose --notest --local-lib-contained tryit --install-args], 'NOECHO="" VERBINST=1', "List::MoreUtils"
    else
      # No debugging. Unless --with-fix build will fail because List::MoreUtils will not be installed.
      system *%W[cpanm --verbose --notest --local-lib-contained tryit --installdeps .];
    end
  end
end
