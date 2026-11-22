cask "hscc-widgets" do
  version "1.4.4"
  sha256 "6b9352723059259daa0ba55d603ce39dd6c4f81e1869777d99f555695485475b"

  url "https://github.com/pom11/hscc/releases/download/apps-v1.4.4/HSCC-Widgets-1.4.4.zip"
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
