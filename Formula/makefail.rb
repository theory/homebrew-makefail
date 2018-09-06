class Makefail < Formula
  desc "Testing case for Homebrew `make` bug"
  version "1"
  url "https://raw.githubusercontent.com/theory/homebrew-makefail/master/tryme.tgz"
  sha256 "493bf653887db204f3063674fc581b79a2c286ad5e3c77f0d29a5b28808b7f50"
  depends_on 'cpanminus' => :build
  bottle :unneeded

  def install
    system *%W[cpanm --quiet --notest --local-lib-contained tryit List::MoreUtils::XS Exporter::Tiny];
    system *%W[cpanm --verbose --notest --local-lib-contained tryit --install-args -d --build-args -d --install-args -d --installdeps .];
  end
end
