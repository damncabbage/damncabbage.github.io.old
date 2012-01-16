---
layout: post
title: "Bridging the PHP/Ruby Divide: Testing With Timecop"
date: 2011-10-25 11:32
published: false
comments: true
categories:
- Ruby
- PHP
- Testing
---

*This is the first in a short series of posts showing you how to use some of the niftier features from the Ruby world in your PHP work.*

[Timecop](https://github.com/jtrupiano/timecop) is a library that makes testing time-dependant code a cinch.

The results from a graphing calculator isn't going to change if you run it now or next week. Something like a prize-draw competition, though, will produce wildly different results depending when a punter puts in an entry, and testing this is where you wedge Timecop.

Take the example of that prize-draw competition. It's initially closed, no entries allowed; it opens for a while, during which you can enter, and then finally, it closes again and a winner is drawn.

Let's run through how we tackle testing this with Timecop.<!--more-->

## Timecop (Ruby)

Let's assume we have two classes, `Competition` and `Entry`. You set up a competition by giving it the open and close dates; calling `enter` on the competition with your details will give you back an `Entry` object to interrogate:

{% codeblock lang=ruby %}
competition = Competition.new(:open => "2012-01-01 09:00", :close => "2015-12-30 23:59")
entry       = competition.enter(:name => "Sam")
entry.valid? # => true
{% endcodeblock %}

Pretty simple. Let's set up some basic tests; we'll fill the missing ones in later:

{% codeblock lang=ruby %}
require 'spec_helper'

describe Competition do
  let :competition do
  	# Opens a day from now, closes a day after that.
  	Competition.new(:open => Time.now + 86400, :close => Time.now + 86400*2)
  end

  it "should reject early entries" do
	entry = competition.enter(:name => "Bert")
	entry.valid?.should == false
	entry.errors.should include("Too early!")
  end

  it "should accept timely entries" do
	# TODO
  end

  it "should reject late entries" do
  	# TODO
  end
end
{% end %}

The open date is always a day from now, so the early condition is easy. The other two are a bit tougher.

Timecop provides a couple of ways of altering time: `jump` (jump to a particular time), or `freeze` (jump to a particular time *and* freeze the clock). In both cases, a `return` will revert back to reality.

In addition to this, you can pass `freeze` a block (a closure, eg. `do ... end`), and have it automatically return for you after the block has been called.

Let's fill out those test cases:

{% codeblock lang=ruby %}
require 'spec_helper'

describe Competition do
  let :competition do
  	# Opens a day from now, closes a day after that.
  	Competition.new(:open => Time.now + 86400, :close => Time.now + 86400*2)
  end

  it "should reject early entries" do
	entry = competition.enter(:name => "Bert")
	entry.valid?.should == false
	entry.errors.should include("Too early!")
  end

  it "should accept timely entries" do
    # A bit more than a day from now.
  	Timecop.jump(Time.now + 89000) do
      entry = competition.enter(:name => "Sam")
      entry.valid?.should == true
    end
  end

  it "should reject late entries" do
    # Three days from now, after competition closure.
    Timecop.jump(Time.now + 86400*3) do
      entry = competition.enter(:name => "Frank")
      entry.valid?.should == false
      entry.errors.should include("Too late!")
    end
  end
end
{% end %}

You can get the sample classes, full test suite and running instructions from [this GitHub project](https://github.com/damncabbage/bridging-the-divide/blob/master/timecop/ruby).


## Timecop-PHP

Timecop was [ported to PHP by Erik Ferčák](https://github.com/erikfercak/Timecop-PHP). It depends on PHP5.3+ and the [https://github.com/zenovich/runkit.git](Runkit Extension) (in order to mess around with core functions).

Follow these instructions to get it set up; these instructions are aimed at those with a Debian/Ubuntu development box, but should work on Fedora/Centos and the like too:

{% codeblock %}
$ git clone https://github.com/zenovich/runkit.git
$ cd runkit
$ sudo pecl install package.xml
$ sudo su -c 'echo -e "extension=runkit.so\nrunkit.internal_override=1" > /etc/php5/conf.d/runkit.ini'
$ sudo service apache2 restart # Or 'sudo service php5-fpm restart' if you use that and nginx.
{% endcodeblock %}

Set up a tests directory and grab Timecop-PHP with the following:

{% codeblock %}
$ mkdir -p tests/support && cd tests
$ git clone git://github.com/erikfercak/Timecop-PHP.git support/Timecop
{% endcodeblock %}

To start with, set up a basic test case, and just require() it into your test file:

{% codeblock lang=php %}
<?php
require_once dirname(__FILE__).'/support/Timecop/lib/Timecop.php';

class CompetitionTest extends PHPUnit_Framework_TestCase
{
	protected $competition;

	public function setUp() {
		// Opens a day from now, closes a day after that.
		$this->competition = new Competition($opens = strtotime('+1 day'), $closes = strtotime('+2 day'));
	}

	public function testEarlyEntry() {
		$entry = $this->competition->enter(array('Name' => 'Bert'));
		$this->assertFalse($entry->isValid());
		$this->assertContains("Too early!", $entry->getErrors());
	}

	public function testTimelyEntry() {
		// TODO
	}

	public function testLateEntry() {
		// TODO
	}
}
{% endcodeblock %}

(If you wish, you can set this up to autoload later by putting Timecop.php into `/usr/share/php`, or wherever else your PEAR directory is.)

