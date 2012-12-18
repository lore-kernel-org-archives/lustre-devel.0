From: Prakash Surya <surya1@llnl.gov>
Date: Tue, 18 Dec 2012 12:29:09 -0800
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
 primitives usage.
In-Reply-To: <201212180412.qBI4CTe9028934@hedwig.cmf.nrl.navy.mil>
References: <395EB593-8E66-4567-B072-D8642F22E435@intel.com>
	<201212180412.qBI4CTe9028934@hedwig.cmf.nrl.navy.mil>
Message-ID: <20121218202909.GE23755@llnl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Dec 17, 2012 at 11:12:29PM -0500, Ken Hornstein wrote:
> >Yes, we'd discussed this in the past, but the patches for lock cleanup
> >never got added into the core Lustre code. We will still be the
> >maintainers of the Lustre code in the kernel, so if there are innocuous
> >no-op calls that can be put into the code (e.g. spin_lock_free()) or
> >something similar I think that is fine.
> 
> Well as long as that's not a problem, I don't think that will be an issue
> then.
> 
> >The root of the problem, for which there was no easy solution (wrappers
> >or not) is that there is no easy way to test for this under Linux, so
> >without either static code analysis tools (preferably run with the
> >prepare-commit-msg git hook), or rigorous testing on MacOS, it would
> >always be a game of catch up for these cleanups.
> 
> I understand that, and I'm personally fine with that.  From my memory,
> the issue is not that a lot of lock structures were being created all
> of the time and then deallocated (or I was able to find all of those
> cases); it was more that a bunch of locks were leaked when Lustre shut
> down.  I understand it's going to be a constant catch-up.
> 
> >I'd like to understand your reasons for thinking it is a bad idea. There
> >are definite plusses and minuses to being in the kernel, but if there is
> >some overwhelming badness for being in the kernel is like to know about
> >it.
> 
> Well, fundamentally it just seems to me that you're tying your product
> to the whims of a group of people who, quite frankly, don't care about
> your product (except in a very abstract sense).  Giving away a huge amount
> of control of your product looks like a bad idea to me.
> 
> But that's sort of vague; let me talk about specifics.  There's a HUGE
> difference in practice between "feature X appears in Linux kernel
> version Y" and "My RedHat release Z has a particular feature".  That's
> where life gets complicated.  Many times we're stuck on a particular
> kernel for various complicated reasons, yet we need to upgrade Lustre
> ... or vice versa.  It's kind of like Infiniband in the Linux kernel ...

Perhaps I'm being naive, but at some point it would be nice to have a
rock solid "stable" version of a lustre client and protocol. Giving up
some control over the ability to upgrade the client could be perceived
as a good thing.

-- 
Cheers, Prakash

> at best, it doesn't hurt us, but it's always the "wrong" version (or so
> my Infiniband guys tell me).  We never end up using the Infiniband in
> the kernel, and sometimes (depending on the vagarities of the distro)
> that screws us up hard; part of that is because for a long time one
> particular distro never would distribute the development symbols for
> the Infiniband in the kernel that matched what the kernel was running.
> That won't be an issue with Lustre, but you get the idea.
> 
> --Ken
