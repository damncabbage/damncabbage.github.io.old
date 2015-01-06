---
layout: post
title: 'Ansible Pit-Traps: The Hash-in-a-String DSL'
date: 2015-01-06 23:22
comments: true
categories:
- Ansible
- Ops
---

Or, as you may see them in the docs, ["key=value" options for module actions](http://docs.ansible.com/playbooks_intro.html#tasks-list). They look a bit like this:

{% codeblock lang:yaml %}
tasks:
- name: make sure apache is running
  service: name=httpd state=running
{% endcodeblock %}

Every playbook file is a YAML file; what we have above is a list of one task hash that has two keys (`name` and `service`), with a string value for each.

Formatted properly, the above looks like:

{% codeblock lang:yaml %}
tasks:
- name: "make sure apache is running"
  service: "name=httpd state=running"
{% endcodeblock %}<!--more-->

### The Problem

What's going on is that Ansible has [its own key=value parser that it runs over the strings](https://github.com/ansible/ansible/blob/fe53d86a83b8fdd9019c1237fd37e3295e8df2b5/lib/ansible/module_utils/splitter.py#L51), which then [runs the Jinja2 templating engine over](https://github.com/ansible/ansible/blob/d3c9eda15b0028b4a0621f313c6ee53eef439d43/lib/ansible/runner/__init__.py#L993).

This is fine and dandy if you have plain arguments, but as is common in Ansible, you often want to interpolate in variables. Here's a simple example:

{% codeblock lang:yaml %}
tasks:
- name: "Install basic packages"
  apt: pkg={{ "{{ item "}}}} state=installed
  with_items:
  - screen
  - vim
  - cowsay

# Interpreted as:
# apt: pkg=screen state=installed
# apt: pkg=vim state=installed
# etc.
{% endcodeblock %}

Here's a [not-so-simple example](https://github.com/ansible/ansible/issues/9067):

{% codeblock lang:yaml %}
tasks:
- copy: "dest=/tmp/1.txt content={{ "{{ contains_quote "}}}}"
# ^-- Broken; interpreted as:
#       copy: dest=/tmp/1.txt content=Hello"World
#     (Throws "try quoting the entire line" error.)

- copy: dest=/tmp/2.txt content="{{ "{{ contains_quote "}}}}"
# ^-- Also broken, interpreted as:
        copy: dest=/tmp/2.txt content="Hello"World"

- copy: dest=/tmp/3.txt content='{{ "{{ contains_quote "}}}}'
# ^-- "Fixed" by swapping " for ' quotes, but...

- copy: dest=/tmp/4.txt content='{{ "{{ contains_alt_quote "}}}}'
# ^-- Also broken, interpreted as:
#       copy: dest=/tmp/4.txt content='Hello'World'

vars:
  contains_quote: 'Hello"World'
  contains_alt_quote: "Hello'World"
{% endcodeblock %}

Same goes for things like:

* `campfire: room=example subscription=example token=example msg="{{ "{{ contains_a_quote_or_newline "}}}}"`
* `command:  cap deploy -s branch=master` (Whinges about the `=`)

... or anything else that could include "special" characters. It's a fruitless game of whack-a-mole.


### The Fix

Stick to using YAMLs own features for structured data; use a hash:

{% codeblock lang:yaml %}
tasks:
- name: "Long-form Hash"
  service:
    dest: "/tmp/whatever.txt"
    content: "{{ "{{ contains_quotes_or_other_things "}}}}"

- name: "Inline Hash"
  service: { name: "httpd", state: "running" }
{% endcodeblock %}

And if you're using something like [shell](http://docs.ansible.com/shell_module.html) or [command](http://docs.ansible.com/command_module.html) that expect a string *and* `key=value` arguments (eg. `shell: "something --file /home/foo/bar.txt creates=/home/foo/bar.txt"`), you can instead provide an `args` key:

{% codeblock lang:yaml %}
tasks:
- name: "A complicated command meant to only run once, which leaves a file around when it's finished."
  shell: "something --file /home/foo/bar.txt -o -m -g"
  args:
    creates: "/home/foo/bar.txt"
{% endcodeblock %}

Why not use `service: name=httpd state=running` sometimes, and `service: { name: "{{ "{{some_variable "}}}}", state: "running" }` other times when needed for variable interpolation or special-case `=` usage? Consistency, in attempt to increase safety. Remembering the special rules for `key=value` can be done, yes, but it's another edge case in a tool that's arguably already [full of](https://github.com/ansible/ansible/issues/9899) [edge](https://github.com/ansible/ansible/issues/9856) [cases](https://github.com/ansible/ansible/issues/8219); sticking to the "Always use YAML hashes" rule means one less thing to forget about or train the new ops people up on.

And hey, think of it like what people used to do with SQL; nobody does `$sql = "SELECT * FROM users WHERE name = '$username'";` anymore, right?

<small>... Right? D:</small>
