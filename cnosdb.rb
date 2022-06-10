class Cnosdb < Formula
  desc "An Open Source Distributed Time Series Database with high performance, high compression ratio and high usability."
  homepage "https://www.cnosdb.com"
  version "1.0.2"
  url "https://github.com/cnosdb/cnosdb/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "ae412d0944b64c9b39dc1edc66f7b6f712b85bc5afad354c12b135ae71017100"
  license "MIT"
  head "https://github.com/cnosdb/cnosdb.git"

  livecheck do
    url "https://github.com/cnosdb/cnosdb/releases/latest"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
  end

  depends_on "go" => :build

  def install
    ENV["GOBIN"] = buildpath
    system "export GO111MODULE=on"
    system "export GOPROXY=https://goproxy.cn"
    system "go install ./..."
    bin.install %w[cnosdb-cli cnosdb-ctl cnosdb-meta cnosdb-inspect cnosdb-tools]
  end

  test do
    system "#{bin}/cnosdb-cli"
  end
end
