class Hscc < Formula
  include Language::Python::Virtualenv

  desc "Hermes Spark Cluster Control — CLI and daemon for a DGX Spark fleet"
  homepage "https://github.com/pom11/hscc"
  url "https://github.com/pom11/hscc/archive/refs/tags/v2.14.0.tar.gz"
  sha256 "cdc2e7e014f58d3fe05e8692878ef662a2ba2849b940b4c7979a3ae66eb0dce1"
  license "MIT"

  livecheck do
    url "https://github.com/pom11/hscc/releases"
    strategy :github_latest
  end

  depends_on "python@3.13"

  # Runtime dependencies, exactly requirements.txt of the pinned release
  # (PyYAML>=6.0, rich>=13,<16, psutil>=5.9, httpx==0.28.1) plus the transitive
  # requirements of rich and of httpx, pinned as resources so neither needs any
  # network resolution.
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

  # httpx's own transitive closure, same reason as markdown-it-py/mdurl/pygments
  # above. `pip_install resources` runs with pip's `--no-deps`, so every package in
  # the set has to be declared here or it simply is not in the venv.
  #
  # The versions mirror the venv that Hermes' own board-read path runs on today
  # (~/.hermes/hermes-agent/venv): httpx 0.28.1 with anyio 4.12.1, idna 3.18,
  # certifi 2026.5.20. anyio 4.12.1 needs typing_extensions only for
  # python_version < "3.13" and its imports of it are all guarded by that same
  # version check, so on this formula's python@3.13 the closure stays these seven.
  # (A newer anyio gains a `typing_extensions>=4.16` requirement that reaches down
  # to < "3.15", which would pull an eighth package in.)
  resource "certifi" do
    url "https://files.pythonhosted.org/packages/f3/ce/ee2ecad540810a79593028e88299baeae54d346cc7a0d94b6199988b89b1/certifi-2026.5.20.tar.gz"
    sha256 "69dea482ab64caa7b9f6aba1c6bf48bb6a5448d1c0f1b17ab42ad8c763a5344d"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/cd/63/9496c57188a2ee585e0f1db071d75089a11e98aa86eb99d9d7618fc1edce/idna-3.18.tar.gz"
    sha256 "ffb385a7e039654cef1ab9ef32c6fafe283c0c0467bba1d9029738ce4a14a848"
  end

  resource "sniffio" do
    url "https://files.pythonhosted.org/packages/a2/87/a6771e1546d97e7e041b6ae58d80074f81b7d5121207425c964ddf5cfdbd/sniffio-1.3.1.tar.gz"
    sha256 "f4324edc670a0f49750a81b895f35c3adb843cca46f0530f79fc1babb23789dc"
  end

  resource "h11" do
    url "https://files.pythonhosted.org/packages/01/ee/02a2c011bdab74c6fb3c75474d40b3052059d95df7e73351460c8588d963/h11-0.16.0.tar.gz"
    sha256 "4e35b956cf45792e4caa5885e69fba00bdbc6ffafbfa020300e549b208ee5ff1"
  end

  resource "httpcore" do
    url "https://files.pythonhosted.org/packages/06/94/82699a10bca87a5556c9c59b5963f2d039dbd239f25bc2a63907a05a14cb/httpcore-1.0.9.tar.gz"
    sha256 "6e34463af53fd2ab5d807f399a9b45ea31c3dfa2276f15a2c3f00afff6e176e8"
  end

  resource "anyio" do
    url "https://files.pythonhosted.org/packages/96/f0/5eb65b2bb0d09ac6776f2eb54adee6abe8228ea05b20a5ad0e4945de8aac/anyio-4.12.1.tar.gz"
    sha256 "41cfcc3a4c85d3f05c932da7c26d0201ac36f72abd4435ba90d0464a3ffed703"
  end

  resource "httpx" do
    url "https://files.pythonhosted.org/packages/b1/df/48c586a5fe32a0f01324ee087459e112ebb7224f646c0b5023f5e79e9956/httpx-0.28.1.tar.gz"
    sha256 "75e98c5f16b0f35b567856f597f06ff2270a374470a5c2392242528e3e3e42fc"
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
