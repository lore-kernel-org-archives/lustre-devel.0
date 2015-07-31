From: Drokin, Oleg <oleg.drokin@intel.com>
Date: Fri, 31 Jul 2015 03:54:02 +0000
Subject: [lustre-devel] Lock ahead - Possible change
In-Reply-To: <559FEF75.4080103@cray.com>
References: <559FEF75.4080103@cray.com>
Message-ID: <7A7A49C2-E8AB-4661-8991-0A23D4188D6B@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Jul 10, 2015, at 12:14 PM, Patrick Farrell wrote:

> Good morning,
> 
> I am reluctant to make further changes to lock ahead at this point when it is ready and pending review, but I wanted to float an idea to see if it would likely meet acceptance.  (I am primarily asking Jinshan and Andreas, who have been involved from the beginning.)
> 
> Currently, lock ahead requests are asynchronous, and, because of that, non-blocking.  What about the possibility of also allowing blocking, *synchronous* requests via the same API?

This is potentially deadlockprone, so definitely think it through first.

There are plenty of design assumptions about how there could be just one blocking lock request from a thread.
Otherwise stuff like
process1: request lock1, request lock2
process2: request lock3, that conflicts with lock1 and lock2.

Now if lock1 is granted then lock3 is processed next and process1 is blocked with lock1 actually held until lock2 is granted - this will not end well.

> This is intended as a way for a client to make a blocking lock request on a specific region of a file, rather than the whole file by taking a group lock as is currently the only option.
> 
> This would not be used for my immediate goal of enhancing strided writing performance with lock ahead itself, but might be handy in other situations and is a pretty minor change to the API.  (Just allow blocking requests and make them synchronous, rather than not allowing them as is the case now.)
> 
> I still think I will push this out to a future enhancement of the feature rather than integrate it into the current patch.

In my view this definitely should be a separate patch.

Bye,
    Oleg
