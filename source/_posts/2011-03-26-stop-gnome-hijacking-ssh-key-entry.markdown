---
layout: post
title: 'Stop GNOME "Hijacking" SSH Key Entry'
date: 2011-03-26 19:17
comments: true
categories:
- Linux
- SSH
---

Here’s the scenario:

1. You’re sitting at your desktop, and you start a Screen session.
2. You do a bunch of work (say, lots of vim and a `git commit`); and then rush off.
3. You log in remotely, reconnect your Screen session with `screen -dR`, and try to do something that uses an SSH key (say, you `git push` to github).
4. Your SSH session mysteriously hangs.
5. A Ctrl-C later and a head-scratch later, you run `ssh -v git@github.com`, and you get as far as `debug1: Server accepts key: pkalg ssh-rsa ...`

Meanwhile, back on your desktop at home, GNOME has popped up this dialog:

{% img /images/posts/gnome-password-lock.png GNOME says, "Enter password to unlock private key" %}

Bollocks.


### The Fix

To stop this happening again, run the following:

    sudo gconftool-2 --set -t bool /apps/gnome-keyring/daemon-components/ssh false

