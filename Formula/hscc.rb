class Hscc < Formula
  include Language::Python::Virtualenv

  desc "Hermes Spark Cluster Control — CLI and daemon for a DGX Spark fleet"
  homepage "https://github.com/pom11/hscc"
  url "https://github.com/pom11/hscc/archive/refs/tags/v2.13.0.tar.gz"
  sha256 "532af3aed6a6d9f361231304e7b6925b23057947f7d7c7cf077e43e2d4847991"
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
    # Homebrew stages this archive inside the extracted `hscc-#{version}/`
    # directory, so `buildpath` IS the repository root.
    odie "expected the release tarball to carry VERSION at its root" unless (buildpath/"VERSION").exist?

    # The FULL repository tree lands in libexec, renamed to a version-stable
    # path so nothing else has to learn the version: hscc_daemon/,
    # hscc-cluster/, hscc-project/, hscc-bootstrap/, hscc-cli/, VERSION,
    # requirements.txt, README.md, CHANGELOG.md. `hscc bootstrap` runs from
    # this tree later on. `.brew_home` is Homebrew's scratch $HOME, not repo
    # content, so it stays behind.
    tree = libexec/"hscc"
    buildpath.children.each do |child|
      next if child.basename.to_s == ".brew_home"

      tree.install child
    end

    venv = virtualenv_create(libexec/"venv", python3, system_site_packages: false)
    venv.pip_install resources
    # hscc-cli declares `hscc = "hscc_cli:main"` and its pyproject only finds
    # the `hscc_cli*` package, so this installs the wrapper and links its
    # console script into bin.
    venv.pip_install_and_link tree/"hscc-cli", build_isolation: true

    # How `import hscc_daemon` resolves — the CLI's own candidate scan, in
    # hscc-cli/hscc_cli/__init__.py, is:
    #
    #   1. Path(hscc_cli.__file__).resolve().parent.parent/"plugins"
    #   2. ~/.hermes/plugins
    #   3. four parents up from hscc_cli (the dev repo root)
    #
    # pip installs hscc_cli into venv/lib/pythonX.Y/site-packages, so candidate
    # 1 is `<venv>/.../site-packages/plugins`. That path itself must BE the
    # symlink to the libexec tree (which holds hscc_daemon/ next to VERSION), so
    # candidate 1 hits unconditionally. `install_symlink` is called on
    # site-packages — not on `plugins` — because it names the link after its
    # argument: calling it on `plugins` would mkpath `plugins/` and create
    # `plugins/hscc` inside it, candidate 1 would then miss, and on a machine
    # with a bootstrapped Hermes candidate 2 would silently win instead (an
    # import of whatever daemon lives in ~/.hermes/plugins, not of this keg).
    plugins = venv.site_packages/"plugins"
    odie "unexpected hscc_cli install layout at #{plugins}" if plugins.exist? || plugins.symlink?
    # Relative link inside the keg: site-packages -> ../../../../hscc.
    venv.site_packages.install_symlink tree => "plugins"
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
    assert_equal "hscc #{version}", shell_output("#{bin}/hscc --version").strip
    assert_match "usage", shell_output("#{bin}/hscc --help").downcase
  end
end
