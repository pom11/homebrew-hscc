cask "hscc-widgets" do
  version "1.4.1"
  sha256 "f7bce0d98bd384e9a324667a9eb4f7666967ee3229cc01cf460a6c0ff114ea88"

  url "https://github.com/pom11/hscc/releases/download/apps-v1.4.1/HSCC-Widgets-1.4.1.zip"
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
