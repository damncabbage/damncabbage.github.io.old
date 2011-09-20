---
layout: post
title: "Less wood behind more arrows: nested_form"
date: 2011-09-20 20:15
comments: true
categories: 
- Ruby
- Rails
- Forms
---

*(Or, "Crazy forks everywhere".)*

All the way back in [RailsCast 197](http://railscasts.com/episodes/197-nested-model-form-part-2) Ryan Bates introduced us to his javascript-powered dynamic nested form gem, [nested_form](http://github.com/ryanb/nested_form). It's pretty useful, and in concert with Rails' existing `accepts_nested_attributes_for :relation`, got pretty close to solving a problem I haven't ever seen cleanly solved without unwieldy controller code and custom javascript.

Ryan has previously kept it up to date (bless his socks), but now after a three months and a gradual accumulation of about twenty outstanding pull requests (some that fix niggles like hardcoded markup, the undocumented testing environment, and weird jumbled-attribute record creation bugs), I need to move on so I can [get back to work](https://github.com/smashcon/lincoln).

Fortunately, [elmatou](https://github.com/elmatou) forked `nested_form`, merged a bunch of changes and made plenty of his own, and put it all in [a branch called 'defacto'](https://github.com/elmatou/nested_form/tree/defacto). These changes include:

* Configurable wrapper markup,
* Actual removal of 'removed' forms,
* Positionable insertion of newly-added nested forms,
* Storage of the field template in a javascript variable, not inside a hidden `<div>` (meaning your markup doesn't break when using Formtastic).

Also fortunately, [fxposter](https://github.com/fxposter) (a long-time `nested_form` committer) has [also forked](https://github.com/fxposter/nested_form), and improved the testing situation by swapping out Appraisal with an integrated dummy app.

As is tradition for any moderately popular project, there are a ton more forks and the situation is as messy as hell, but if you need one of the above fixes sooner than later, then pull in one of these versions of `nested_form` by putting the following in your Gemfile:

{% codeblock lang:ruby %}
# The Ryan Bates original:
#gem 'nested_form' # The Ryan Bates original

# Fxposter's fork:
gem 'nested_form', :git => 'git://github.com/fxposter/nested_form.git' 

# Elmatou's fork:
gem 'nested_form', :git => 'git://github.com/elmatou/nested_form.git', :branch => 'defacto'
{% endcodeblock %}

I've elected to go with Elmatou's fork (for the moment) for the configurable markup. Formtastic's ordered `<li>` field setup is not friendly at all with Ryan's hardcoded `<div>` method.


(tl;dr [nested_form](https://github.com/ryanb/nested_form) has some odd bugs, [elmatou's fork](https://github.com/elmatou/nested_form/tree/defacto) has less, but [fxposter's fork](https://github.com/fxposter/nested_form) has a better testing setup. I'm using elmatou's to [get on with building stuff](https://github.com/smashcon/lincoln). It's all kind of sad right now.)
