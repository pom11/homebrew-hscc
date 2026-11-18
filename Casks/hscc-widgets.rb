cask "hscc-widgets" do
  version "1.0.0"
  sha256 "b6e0356a216b66714474ba6c1053e262ddbc981808bfac380e91f9db0f6ef89c"

  url "https://github.com/pom11/hscc/releases/download/macos-widgets-v1.0.0/HSCC-Widgets-1.0.0.zip"
  name "HSCC Widgets"
  desc "Menu bar client and desktop widgets for an HSCC cluster"
  homepage "https://github.com/pom11/hscc"

  livecheck do
    url "https://github.com/pom11/hscc/releases"
    regex(/^macos-widgets-v?(\d+(?:\.\d+)+)$/i)
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
