## loginwindowbgconverter

This is a simple Swift program to set the login screen background on macOS, both pre- and post-Mojave.

It has no dependencies other than the AppKit framework that comes with Xcode. Unfortunately it does _not_ work with open&#8209;source Swift, due to its reliance on NSImage.
<!-- &#8209; = non-breaking hyphen, U+2011 in decimal -->

### An Important Note

On Mojave, the login window background will be significantly dimmer than the original picture. It seems to be simply crushing whites down to 180 or so (out of 255).

---

### Compilation

You'll need to have [Xcode][xcode] or its command-line tools installed first.

Simply run `make`, then copy or link the generated `loginwindowbgconverter` to wherever is appropriate.

### Usage

Just run this command, replacing `<path to file>` with the path to your image. Or you can just drag your image into the terminal instead of typing the path.

```
./loginwindowbgconverter <path to file>
```

#### Making the change show up

_**If FileVault is off**, you don't have to worry about this section. (But you should go and turn it on at some point!)_

When your system boots up, it can't read anything on your boot partition (think a disk within a disk), because it's encrypted. So it has another partition specifically for the login window you see at boot.

When you run this program, it only changes the image on your main partition. You won't see the change when you boot up, but you will in login windows _after_ the boot (say, if you log out).

To make your picture show up on the boot login screen, you'll need to get your system to regenerate the login window mini-partition. The easiest way to do this is to **change some aspect of an account, like your account picture, then change it back**.

---

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
