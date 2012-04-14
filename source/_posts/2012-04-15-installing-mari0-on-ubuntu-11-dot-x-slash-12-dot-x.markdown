---
layout: post
title: "Installing Mari0 on Ubuntu 11.x / 12.x"
date: 2012-04-15 02:31
comments: true
categories:
- Games
- Ubuntu
- Linux
---

By Mari0, I mean [this slice-of-genius Mario / Portal mashup](http://stabyourself.net/mari0/).

```
sudo add-apt-repository ppa:bartbes/love-unstable
sudo apt-get update
sudo apt-get install love-unstable
mkdir mari0 && cd mari0
wget http://stabyourself.net/dl.php?file=mari0-1006/mari0-linux.zip && unzip mari0-linux.zip
love-unstable mari0_1.6.love
```

Piece of cake.
