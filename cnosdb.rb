class Cnosdb < Formula
  desc "An Open Source Distributed Time Series Database with high performance, high compression ratio and high usability."
  homepage "https://www.cnosdb.com"
  version "1.0.2"
  url "https://github.com/cnosdb/cnosdb/releases/download/v1.0.2/cnosdb-1.0.2.tar.gz"
  sha256 "c5b56f7a8f232518279dda4d8ef3486c47ed8bf3ca4e127046311eb81060bb3a"
  license "MIT"
  head "https://github.com/cnosdb/cnosdb.git"

  livecheck do
    url "https://github.com/cnosdb/cnosdb/releases/latest"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
  end
  
  # 下面这些MD5值有问题，暂时不使用
  bottle do
    cellar :any_skip_relocation
    sha256 "85487c01ca5b011374652ddb0dd4396d7f60cbc0227c8acef71caefea59d49d0" => :catalina
    sha256 "84de2bb9137efe42a18464023160dbc620053aa43bfb7dc03aa5234a7d337bd3" => :mojave
    sha256 "791fb60441f7ff352f0e4e929d02b7d472af56b200630ff90d42c195865fec5a" => :high_sierra
  end

  depends_on "go" => :build

  def install
    ENV["GOBIN"] = buildpath
    system "go", "install", "-ldflags", "-X main.version=#{version}", "./..."
    bin.install %w[cnosdb-cli cnosdb-ctl cnosdb-meta cnosdb-inspect cnosdb-tools]
    etc.install "etc/config.sample.toml" => "cnosdb.conf"
    inreplace etc/"cnosdb.conf" do |s|
      s.gsub! "/var/lib/cnosdb/data", "#{var}/cnosdb/data"
      s.gsub! "/var/lib/cnosdb/meta", "#{var}/cnosdb/meta"
      s.gsub! "/var/lib/cnosdb/wal", "#{var}/cnosdb/wal"
    end
    (var/"cnosdb/data").mkpath
    (var/"cnosdb/meta").mkpath
    (var/"cnosdb/wal").mkpath
  end
  plist_options manual: "cnosdb --config #{HOMEBREW_PREFIX}/etc/cnosdb.conf"

  test do
    (testpath/"config.toml").write shell_output("#{bin}/cnosdb config")
    inreplace testpath/"config.toml" do |s|
      s.gsub! %r{/.*/.cnosdb/data}, "#{testpath}/cnosdb/data"
      s.gsub! %r{/.*/.cnosdb/meta}, "#{testpath}/cnosdb/meta"
      s.gsub! %r{/.*/.cnosdb/wal}, "#{testpath}/cnosdb/wal"
    end
    begin
      pid = fork do
        exec "#{bin}/cnosdb --config #{testpath}/config.toml"
      end
      sleep 6
      output = shell_output("curl -Is localhost:8086/ping")
      assert_match /X-CnosDB-Version:/, output
    ensure
      Process.kill("SIGTERM", pid)
      Process.wait(pid)
    end
  end
end
