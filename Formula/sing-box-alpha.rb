class SingBoxBeta < Formula
  desc "Universal proxy platform"
  homepage "https://sing-box.sagernet.org"
  version "1.14.0-alpha.26" # VERSION_PLACEHOLDER

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/SagerNet/sing-box/releases/download/v#{version}/sing-box-#{version}-darwin-arm64.tar.gz"
    sha256 "HASH_ARM64_PLACEHOLDER" # arm64_sha
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/SagerNet/sing-box/releases/download/v#{version}/sing-box-#{version}-darwin-amd64.tar.gz"
    sha256 "HASH_AMD64_PLACEHOLDER" # amd64_sha
  end

  def install
    bin.install "sing-box"
  end

  test do
    system "#{bin}/sing-box", "version"
  end
end