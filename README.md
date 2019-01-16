## loginwindowbgconverter

This is a simple Swift program to set the login screen background on macOS, both pre- and post-Mojave.

It has no dependencies other than the AppKit framework that comes with Xcode. Unfortunately it does _not_ work with open&#8209;source Swift, due to its reliance on NSImage.
<!-- &#8209; = non-breaking hyphen, U+2011 in decimal -->

### An Important Note

On Mojave, the login window background will be significantly dimmer than the original picture. It seems to be simply crushing whites down to 180 or so (out of 255).

### Compilation

You'll need to have [Xcode][xcode] or its command-line tools installed first.

Simply run `make`, then copy or link the generated `loginwindowbgconverter` to wherever is appropriate.

### Privileges

This program **must be run as root**; the most convenient way to do that is with sudo.

#### Enabling sudo

If you're an administrator, sudo should already be on.

If you aren't, and haven't already enabled sudo for your account, you can run this command to edit the configuration:

```
sudo EDITOR=nano visudo
```
<sub>(leave out EDITOR=nano if you already have an editor configured or like the default)</sub>

Then add this line to the `# User privilege specification` block, replacing <user\> with your username:

```
<user>	ALL=(ALL) ALL
```

[xcode]: https://developer.apple.com/xcode/
