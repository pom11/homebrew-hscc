cask "hscc-widgets" do
  version "1.2.0"
  sha256 "03cdf656cbb948335a742f9e4e76a4aabf66a2a34a62a1b7e75fc202603f7729"

  url "https://github.com/pom11/hscc/releases/download/apps-v1.2.0/HSCC-Widgets-1.2.0.zip"
  name "HSCC Widgets"
  desc "Menu bar client and desktop widgets for an HSCC cluster"
  homepage "https://github.com/pom11/hscc"

  # The app updates itself through Sparkle 2; the cask still pins every
  # release's version and sha256 so a fresh Homebrew install gets the same
  # notarized bytes as an in-app update.
  auto_updates true

  livecheck do
    url "https://github.com/pom11/hscc/releases"
    regex(/^apps-v?(\d+(?:\.\d+)+)$/i)
    strategy :github_releases
  end

  depends_on macos: :sonoma

  app "HSCC Widgets.app"

  zap trash: [
    "~/Library/Group Containers/group.com.hscc.ios",
    "~/Library/Containers/com.hscc.mac",
    "~/Library/Containers/com.hscc.mac.widgets",
    "~/Library/Preferences/com.hscc.mac.plist",
    "~/Library/Preferences/com.hscc.mac.widgets.plist",
    "~/Library/Preferences/group.com.hscc.ios.plist",
    "~/Library/Saved Application State/com.hscc.mac.savedState"
  ]
end
