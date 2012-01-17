---
layout: post
title: "Pilfering Gems: Testing With Timecop"
date: 2012-01-05 11:32
comments: true
categories:
- Ruby
- PHP
- Testing
- Pilfering Gems
---

*This is the first in a short series of posts showing you how to cherry-pick some of the niftier things (libraries, techniques, whatever) from the Ruby world for use in your PHP work. All code examples are [available here in this GitHub repo](https://github.com/damncabbage/pilfering-gems-examples).*

[Timecop](https://github.com/jtrupiano/timecop) is a library that makes testing time-dependant code a cinch.

The results from a graphing calculator isn't going to change if you run it now or next week. Something like a prize-draw competition, though, will produce wildly different results depending when a punter puts in an entry, and testing this is where you wedge Timecop.

Take the example of that prize-draw competition. It's initially closed, no entries allowed; it opens for a while, during which you can enter, and then finally, it closes again and a winner is drawn.

Let's run through how we tackle testing this with Timecop.<!--more-->

## Timecop (Ruby)

Let's assume we have two classes: `Competition` and `Entry`. You set up a competition by giving it the open and close dates; calling `enter` on the competition with your details will give you back an `Entry` object to interrogate:

{% codeblock lang:ruby %}
competition = Competition.new(:open => "2012-01-01 09:00", :close => "2015-12-30 23:59")
entry       = competition.enter(:name => "Sam")
entry.valid? # => true
{% endcodeblock %}

Pretty simple. To start with, let's just get a taste of how to test something like this with Timecop; we'll go through the nitty-gritty of setting it up a little further on.

Here's a bare-bones [RSpec](http://rspec.info) test, with the easiest test case filled out:

{% codeblock lang:ruby %}
require 'spec_helper'
require 'timecop'

describe Competition do
  let!(:competition) do
    # Opens a day from now, closes a day after that.
	day = 86400
    Competition.new(:open => Time.now + day, :close => Time.now + day*2)
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
{% endcodeblock %}

The open date is always a day from now, so the "early entry" condition is easy. The other two are a bit tougher.

Timecop provides a couple of ways of altering time: `Timecop.travel` (jump to a particular time), or `Timecop.freeze` (jump to a particular time *and* freeze the clock). In both cases, a `Timecop.return` will revert back to reality.

In addition to this, you can pass `freeze` a block (a closure, eg. `do ... end`), and have it automatically return for you after the block has been called.

Let's fill out those test cases:

{% codeblock lang:ruby %}
require 'spec_helper'
require 'timecop'

describe Competition do
  let (:day) { 86400 }
  let!(:competition) do
    # Opens a day from now, closes a day after that.
    Competition.new(:open => Time.now + day, :close => Time.now + day*2)
  end

  it "should reject early entries" do
    entry = competition.enter(:name => "Bert")
    entry.valid?.should == false
    entry.errors.should include("Too early!")
  end

  it "should accept timely entries" do
    # A day and a half from now.
    Timecop.freeze(Time.now + day*1.5) do
      entry = competition.enter(:name => "Sam")
      entry.valid?.should == true
    end
  end

  it "should reject late entries" do
    # Three days from now, after competition closure.
    Timecop.freeze(Time.now + day*3) do
      entry = competition.enter(:name => "Frank")
      entry.valid?.should == false
      entry.errors.should include("Too late!")
    end
  end
end
{% endcodeblock %}

You can get the sample classes, full test suite and running instructions from [the ruby directory in this GitHub project](https://github.com/damncabbage/pilfering-gems-examples/blob/master/timecop/ruby).


## Timecop-PHP

Timecop was [ported to PHP by Erik Ferčák](https://github.com/erikfercak/Timecop-PHP). It depends on PHP5.3+ and the [https://github.com/zenovich/runkit.git](Runkit Extension) (in order to mess around with core functions, such as `time()`).

Again, let's just run through an example before diving into setting it up.

Starting with a basic PHPUnit test case, again with the easiest test case filled out:

{% codeblock lang:php %}
<?php
require_once dirname(__FILE__).'/../lib/Competition.php';
require_once dirname(__FILE__).'/../lib/Entry.php';
require_once dirname(__FILE__).'/support/Timecop.php';

class CompetitionTest extends PHPUnit_Framework_TestCase
{
	protected $competition;

	public function setUp() {
		// Opens a day from now, closes a day after that.
		$this->competition = new Competition($opens = strtotime('+1 day'), $closes = strtotime('+2 day'));
	}

	public function testEarlyEntry() {
		$entry = $this->competition->enter(array('name' => 'Bert'));
		$this->assertFalse($entry->isValid());
		$this->assertContains("Too early!", $entry->errors);
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

Timecop-PHP provides a similar way to hop around to its Ruby progenitor. Before jumping through time, though, you need to tell Timecop to prepare first with `Timecop::warpTime()`.
After that, you can use `Timecop::travel()` to move forward and back through time. `Timecop::freeze()` is also supported, but you must first call `travel()` to set the destination time.

Here are the rest of the entry test cases, using Timecop to leap forward through the three competition states:

{% codeblock lang:php %}
<?php
require_once dirname(__FILE__).'/support/Timecop/lib/Timecop.php';

class CompetitionTest extends PHPUnit_Framework_TestCase
{
	const DAY_IN_SECONDS = 86400;

	protected $competition;

	// Runs before each test
	public function setUp() {
		// Opens a day from now, closes a day after that.
		$this->competition = new Competition($opens = strtotime('+1 day'), $closes = strtotime('+2 day'));
		Timecop::warpTime(); // Setup
	}

	public function testEarlyEntry() {
		$entry = $this->competition->enter(array('name' => 'Bert'));
		$this->assertFalse($entry->isValid());
		$this->assertContains("Too early!", $entry->errors);
	}

	public function testTimelyEntry() {
		// Jump a day and a half from now.
		Timecop::travel(time() + self::DAY_IN_SECONDS * 1.5);
		$entry = $this->competition->enter(array('name' => 'Sam'));
		$this->assertTrue($entry->isValid());
	}

	public function testLateEntry() {
		// Jump three days from now.
		Timecop::travel(time() + self::DAY_IN_SECONDS * 3);
		$entry = $this->competition->enter(array('name' => 'Frank'));
		$this->assertFalse($entry->isValid());
		$this->assertContains("Too late!", $entry->errors);
	}

	// Runs after each test
	public function tearDown() {
		// Always make sure we're back in the present.
		Timecop::unwarpTime();
	}
}
{% endcodeblock %}

You can get the sample classes, full test suite and running instructions from [the php directory in this GitHub project](https://github.com/damncabbage/pilfering-gems-examples/blob/master/timecop/php).

