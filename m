From: Patrick Farrell <paf@cray.com>
Date: Fri, 10 Jul 2015 11:14:45 -0500
Subject: [lustre-devel] Lock ahead - Possible change
Message-ID: <559FEF75.4080103@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Good morning,

I am reluctant to make further changes to lock ahead at this point when 
it is ready and pending review, but I wanted to float an idea to see if 
it would likely meet acceptance.  (I am primarily asking Jinshan and 
Andreas, who have been involved from the beginning.)

Currently, lock ahead requests are asynchronous, and, because of that, 
non-blocking.  What about the possibility of also allowing blocking, 
*synchronous* requests via the same API?

This is intended as a way for a client to make a blocking lock request 
on a specific region of a file, rather than the whole file by taking a 
group lock as is currently the only option.

This would not be used for my immediate goal of enhancing strided 
writing performance with lock ahead itself, but might be handy in other 
situations and is a pretty minor change to the API.  (Just allow 
blocking requests and make them synchronous, rather than not allowing 
them as is the case now.)

I still think I will push this out to a future enhancement of the 
feature rather than integrate it into the current patch.

Thoughts?  Objections?

I admit that this expansion of the API is making me question 'lock 
ahead' as the name for the API itself, rather than a particular usage of 
it.  Perhaps that's not a direction we want to go, or perhaps we should 
rename the API.  (Suggestions encouraged)

- Patrick Farrell
