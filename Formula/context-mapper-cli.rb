class ContextMapperCli < Formula
  desc "Command-line interface for Context Mapper"
  homepage "https://github.com/ContextMapper/context-mapper-cli"
  url "https://search.maven.org/remotecontent?filepath=org/contextmapper/context-mapper-cli/6.12.0/context-mapper-cli-6.12.0.tar"
  version "6.12.0"
  sha256 "1a3e2a6a48b428c32831c8f43e6152f45e2538836bad8852cea7e0ca6c04f6b6"
  license "Apache-2.0"

  depends_on "openjdk"

  def install
    libexec.install Dir["*"]
    (bin/"cm").write_env_script libexec/"bin/cm", JAVA_HOME: formula_opt_prefix("openjdk")
  end

  test do
    assert_match "Context Mapper CLI v#{version}", shell_output("#{bin}/cm validate -h")
  end
end
