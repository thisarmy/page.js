This repository contains the files that get compiled, concatenated and then
minified to become the page.js file that's included by all pages built by
[Thing](https://thing.io/).

Included
========

**fittext.coffee** is used when sizing headlines to fit the width of their
containers.

**fullscreenoverlay.coffee** is used when showing video, audio or map embeds
fullscreen.

**cookie.coffee** is a library for easily working with cookies.

**view_page.coffee** contains the code that runs when the page loads.

* It loads the Google fonts that are used by the page using the Google/Typekit
  webfont loader.

* It detects when the page is resized so that fitted headlines can be
  re-fitted, fullscreen embeds can be resized and so that content that should
  be vertically centered on a page will continue to be centered.

* It also shows the initial preview warning banner which you would almost
  certainly not want if you're hosting the page yourself.

* It stores the initial referer header and query string so that analytics code
  can pick that up later.

Therefore if you're not vertically centering everything on the page, you're not
fitting any headlines and you're not choosing to show any embeds fullscreen,
then you probably don't even need this file.

Not included here
=================

page.js depends on the latest version of [jQuery](http://jquery.com/). It is
assumed that jQuery has already been included in the page.


page.js as used in Thing also contains
[webfont.js](https://github.com/typekit/webfontloader).
