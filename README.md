## loginwindowbgconverter

This is a simple Swift program to set the login screen background on macOS, both pre- and post-Mojave.

### An Important Note

On Mojave, the login window background will be significantly dimmer than the original picture. It seems to be simply crushing whites down to 180 or so (out of 255).

### Compilation

Simply run `make`, then copy or link the generated `loginwindowbgconverter` to wherever is appropriate.

### Privileges

This program **must be run as root**; the most convenient way to do that is with sudo.

#### Enabling sudo

If you're an administrator, sudo should already be on.

If you aren't, and didn't enable sudo for your account, you can run this command to edit the configuration:

```
sudo EDITOR=nano visudo
```
<sub>(leave out EDITOR=nano if you already have an editor configured or like the default)</sub>

Then add this line to the `# User privilege specification` block, replacing <user\> with your username:

```
<user>	ALL=(ALL) ALL
```
