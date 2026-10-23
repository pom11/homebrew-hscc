class Hscc < Formula
  include Language::Python::Virtualenv

  desc "Hermes Spark Cluster Control — CLI and daemon for a DGX Spark fleet"
  homepage "https://github.com/pom11/hscc"
  url "https://github.com/pom11/hscc/archive/refs/tags/v2.12.0.tar.gz"
  sha256 "f17b764350c2bf45f5b55d50c9ca386a5cbc10b1f57c4ef05f2805eb3e2a745a"
  license "MIT"

  livecheck do
    url "https://github.com/pom11/hscc/releases"
    strategy :github_latest
  end

  depends_on "python@3.13"

  # Runtime dependencies, exactly requirements.txt of the pinned release
  # (PyYAML>=6.0, rich>=13,<16, psutil>=5.9) plus rich's own transitive
  # requirements, pinned as resources so `rich` needs no network resolution.
  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/05/8e/961c0007c59b8dd7729d542c61a4d537767a59645b82a0b521206e1e25c2/pyyaml-6.0.3.tar.gz"
    sha256 "d76623373421df22fb4cf8817020cbb7ef15c725b9d5e45f17e189bfc384190f"
  end

  resource "rich" do
    url "https://files.pythonhosted.org/packages/c0/8f/0722ca900cc807c13a6a0c696dacf35430f72e0ec571c4275d2371fca3e9/rich-15.0.0.tar.gz"
    sha256 "edd07a4824c6b40189fb7ac9bc4c52536e9780fbbfbddf6f1e2502c31b068c36"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/aa/c6/d1ddf4abb55e93cebc4f2ed8b5d6dbad109ecb8d63748dd2b20ab5e57ebe/psutil-7.2.2.tar.gz"
    sha256 "0746f5f8d406af344fd547f1c8daa5f5c33dbc293bb8d6a16d80b4bb88f59372"
  end

  resource "markdown-it-py" do
    url "https://files.pythonhosted.org/packages/06/ff/7841249c247aa650a76b9ee4bbaeae59370dc8bfd2f6c01f3630c35eb134/markdown_it_py-4.2.0.tar.gz"
    sha256 "04a21681d6fbb623de53f6f364d352309d4094dd4194040a10fd51833e418d49"
  end

  resource "mdurl" do
    url "https://files.pythonhosted.org/packages/d6/54/cfe61301667036ec958cb99bd3efefba235e65cdeb9c84d24a8293ba1d90/mdurl-0.1.2.tar.gz"
    sha256 "bb413d29f5eea38f31dd4754dd7377d4465116fb207585f97bf925588687c1ba"
  end

  resource "pygments" do
    url "https://files.pythonhosted.org/packages/49/2e/ced460408999b33da6b31b0021b0f37d329e202d4169aeb164493778f25b/pygments-2.21.0.tar.gz"
    sha256 "610ca751c9bc2492b38eb9a38a7fbc93edbbb2d7182edaf34e66ae493dee5c8c"
  end

  # The pinned sdists build through PEP 517 backends (flit-core, poetry-core,
  # hatchling, setuptools, Cython) that are not themselves pinned here: pip
  # resolves them in a build-isolated environment, which needs the network.
  # This is the same trade-off homebrew-core's `awscli` makes.
  allow_network_access! :build

  def install
    source_root = buildpath/"hscc-#{version}"
    odie "expected the release tarball to extract into hscc-#{version}/" unless (source_root/"VERSION").exist?

    # The FULL repository tree lands in libexec, renamed to a version-stable
    # path so nothing else has to learn the version. `hscc bootstrap` runs from
    # this tree later on (hscc-bootstrap/bootstrap.sh, hscc_daemon/, ...).
    libexec.install source_root => "hscc"
    tree = libexec/"hscc"

    venv = virtualenv_create(libexec/"venv", python3, system_site_packages: false)
    venv.pip_install resources
    # hscc-cli declares `hscc = "hscc_cli:main"` and its pyproject only finds
    # the `hscc_cli*` package, so this installs the wrapper and links its
    # console script into bin.
    venv.pip_install_and_link tree/"hscc-cli", build_isolation: true

    # How `import hscc_daemon` resolves — the CLI's own candidate scan, in
    # hscc-cli/hscc_cli/__init__.py, is:
    #
    #   1. Path(hscc_cli.__file__).parent.parent/"plugins"
    #   2. ~/.hermes/plugins
    #   3. four parents up from hscc_cli (the dev repo root)
    #
    # pip installs hscc_cli into venv/lib/pythonX.Y/site-packages, so candidate
    # 1 is `<venv>/.../site-packages/plugins`. That is the candidate this layout
    # satisfies: the symlink below makes it point at the libexec tree, which
    # holds hscc_daemon/ next to VERSION. It is created BEFORE any candidate
    # check matters (the scan runs at import time) and it must exist, because on
    # a machine where ~/.hermes/plugins is present candidate 2 would otherwise
    # win and import whichever daemon happens to be bootstrapped there — or, on
    # a clean machine, nothing would resolve at all.
    plugins = venv.site_packages/"plugins"
    odie "unexpected hscc_cli install layout at #{plugins}" if plugins.exist?
    plugins.install_symlink tree
  end

  def caveats
    <<~EOS
      Next step (configures Hermes plugins, skills, roles and the daemon; it
      writes to ~/.hermes and ~/.hscc, which `brew install` deliberately does not):

        hscc bootstrap --yes

      If your hscc build predates the `bootstrap` verb, run the bundled script
      from the installed tree instead:

        #{libexec}/hscc/hscc-bootstrap/bootstrap.sh --yes
    EOS
  end

  test do
    # --version reads #{libexec}/hscc/VERSION through hscc_daemon.__file__ and
    # exits before any dispatch, so this proves the import chain AND that no
    # bootstrap step was needed.
    assert_equal "hscc #{version}", shell(bin/"hscc", "--version").strip
    assert_match "usage", shell(bin/"hscc", "--help").downcase
  end
end
