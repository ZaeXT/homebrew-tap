class SingBoxBeta < Formula
  desc "Universal proxy platform"
  homepage "https://sing-box.sagernet.org"
  version "1.14.0-beta.14" # VERSION_PLACEHOLDER
  url "https://github.com/SagerNet/sing-box/archive/refs/tags/v#{version}.tar.gz"
  sha256 "8ebbfb6f8ec85387c9a80c3571ff4a464653b583bb2ad1eaa9eb89dc0f812e1f" # source_sha
  license "GPL-3.0-or-later"
  head "https://github.com/SagerNet/sing-box.git", branch: "main"

  depends_on "go" => :build

  on_linux do
    depends_on "lld" => :build
    depends_on "llvm" => :build
  end

  conflicts_with "sing-box", because: "both install the same binaries"

  def install
    tags = File.read("release/DEFAULT_BUILD_TAGS").strip.split(",")
    ldflags_shared = File.read("release/LDFLAGS").strip

    if OS.linux?
      ENV["CC"] = Formula["llvm"].opt_bin/"clang"
      ENV["CXX"] = Formula["llvm"].opt_bin/"clang++"
      ENV["CGO_ENABLED"] = "1"
      ENV["CGO_LDFLAGS"] = "-fuse-ld=#{Formula["lld"].opt_bin}/ld.lld"
    end

    ldflags = "-s -w -X github.com/sagernet/sing-box/constant.Version=#{version} #{ldflags_shared} -buildid="
    system "go", "build", *std_go_args(output: bin/"sing-box", ldflags: ldflags, tags: tags), "./cmd/sing-box"
    generate_completions_from_executable(bin/"sing-box", shell_parameter_format: :cobra)
  end

  service do
    run [opt_bin/"sing-box", "run", "--config", etc/"sing-box/config.json", "--directory", var/"lib/sing-box"]
    run_type :immediate
    keep_alive true
  end

  test do
    ss_port = free_port
    (testpath/"shadowsocks.json").write <<~JSON
      {
        "inbounds": [
          {
            "type": "shadowsocks",
            "listen": "::",
            "listen_port": #{ss_port},
            "method": "2022-blake3-aes-128-gcm",
            "password": "8JCsPssfgS8tiRwiMlhARg=="
          }
        ]
      }
    JSON
    server = spawn bin/"sing-box", "run", "-D", testpath, "-c", testpath/"shadowsocks.json"

    sing_box_port = free_port
    (testpath/"config.json").write <<~JSON
      {
        "inbounds": [
          {
            "type": "mixed",
            "listen": "::",
            "listen_port": #{sing_box_port}
          }
        ],
        "outbounds": [
          {
            "type": "shadowsocks",
            "server": "127.0.0.1",
            "server_port": #{ss_port},
            "method": "2022-blake3-aes-128-gcm",
            "password": "8JCsPssfgS8tiRwiMlhARg=="
          }
        ]
      }
    JSON
    system bin/"sing-box", "check", "-D", testpath, "-c", "config.json"
    client = spawn bin/"sing-box", "run", "-D", testpath, "-c", "config.json"

    begin
      sleep 3
      system "curl", "--socks5", "127.0.0.1:#{sing_box_port}", "github.com"
    ensure
      Process.kill "TERM", server
      Process.kill "TERM", client
      Process.wait server
      Process.wait client
    end
  end
end
