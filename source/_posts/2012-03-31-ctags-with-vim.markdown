---
layout: post
title: "CTags with Vim, the Quick Version"
date: 2012-03-31 17:54
comments: true
categories:
- Vim
- Linux
---

1. `sudo apt-get install ctags` (Debian/Ubuntu Linux), or `brew install ctags` (OS X).
2. In `~/.vimrc`, add `set tags=tags`
3. Go to your project directory, and run `ctags -R`
4. When editing, put your cursor over a variable, method or class and hit `Ctrl-]` to jump to its definition.

(*Bonus step*: Go back to secretly coveting Intellisense.)
