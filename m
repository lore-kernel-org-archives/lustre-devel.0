From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 1 Jun 2018 21:08:39 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: delete the filesystem
 from the tree.
In-Reply-To: <6A5E4E02-AE72-4068-BF93-38791BF38B4F@dilger.ca>
References: <20180601091133.GA27521@kroah.com>
 <6A5E4E02-AE72-4068-BF93-38791BF38B4F@dilger.ca>
Message-ID: <20180601190839.GA20734@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Dilger <adilger@dilger.ca>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linuxfoundation.org>, lustre-devel <lustre-devel@lists.lustre.org>, fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org, selinux@tycho.nsa.gov

On Fri, Jun 01, 2018 at 02:30:49PM -0400, Andreas Dilger wrote:
> On Jun 1, 2018, at 5:11 AM, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> > 
> > The Lustre filesystem has been in the kernel tree for over 5 years now.
> > While it has been an endless source of enjoyment for new kernel
> > developers learning how to do basic codingstyle cleanups, as well as an
> > semi-entertaining source of bewilderment from the vfs developers any
> > time they have looked into the codebase to try to figure out how to port
> > their latest api changes to this filesystem, it has not really moved
> > forward into the "this is in shape to get out of staging" despite many
> > half-completed attempts.
> 
> I am happy to submit a patch that moves Lustre out of staging and into
> the mainline.  I'm just about to board a flight, but it could be done
> later today.  Then we can avoid the constant churn of kernel newbies
> submitting patches that break the code.

It's not the kernel newbies that are your biggest problem.  It's your
development model, and lack of support from anyone to actually do real
cleanups.

Every few months, when I get really bored, I do a drive-by pass and have
never yet failed to find numerous problems that you all have been
totally ignoring.  Look at the debugfs patch series I sent out this
week.  Look at all of the wonderful work that NeilBrown has been doing
on core cleanups for your mess.  Neither he nor I should be the ones
that have to do this stuff, you all should be doing it yourself.

You all have had over 5 years to work on cleaning up your crazy shim
layers.  It's still not done.  And based on the recent patch series that
was sent to me, I don't even see anyone planning on working on that type
of thing.

I'm sorry, but I am tired of it.  If you want to submit this for the
filesystem maintainers to accept, wonderful, please do so.  But that
will not consist of a patch that just moves the directories.  You have
to create a real set of patches and send them to linux-fsdevel, just
like any other new filesystem does.

And I would like to point out the fact that while this whole thing sat
in staging, other filesystems and major driver subsystems entered
staging, got cleaned up, and moved on out.  It can be done.  But for
some reason you all don't want to do the real work to do it, which is
fine, I understand that you need management buy-in to make that happen,
and you all need to focus on your users and new features for them.

So if you really do want this out of staging, go off and do the real
work to do so and then merge it the "real" way.  I'm tired of dealing
with it in staging as-is and having to every few months start rejecting
new feature patches and tell people that "this is the last time I'm
going to tell you..."

You all were warned many times, this is not my fault, but rather, yours,
or your management for not allowing you to prioritize this work.

> Lustre has been in use at large sites around the world for 18 years now.
> Over 70% of the largest 100 systems in the world use Lustre.  It runs at
> universities, oil companies, weather bureaus around the world, etc.

And yet, I bet none of them run the in-kernel codebase, right?

I bet you could get all of this cleaned up and merge properly in 6
months if you really wanted to do so.  But it seems that no one really
wants to do that work, which is sad.  I should not have to be the one to
force you all, but it seems like I now have to be.

> I know Andrew has long been a supporter of getting code into the kernel
> that users are using.  This is code that thousands of large computers
> are using with exabytes of storage, a lot more than orangefs, exofs, and
> random other filesystems that seem to get into the kernel easily.

Because those developers took the time and did it right.

Please, compare yourself to orangefs.  That is the perfect example of
how to do everything right.  They got their code into staging, cleaned
it up, talked to us about what was needed to do to get the remaining
bits in proper shape, they assigned dedicated developers to do that
work, talked with all of us at different conferences around the world to
check up and constantly ensure that they were doing the right thing, and
most importantly, they asked for feedback and acted on it.  In the end,
their codebase is much smaller, works better, is in the "real" part of
the kernel, and available to every Linux user out there.

So yes, you are no orangefs, but you really should aspire to be just
like them, as they know how to do all of this correctly.

> It's true the code is not as pretty as it could be, but the same is true
> of code that has been in the kernel for ages.

If you know of major subsystems that look at bad as lustre does with the
numerous wrapper layers and other crazy things that you all do, please
let me know and I will be glad to go point people at that code to help
get it fixed up.

Also note that the attempt to defend your behavior with "but he's doing
the same thing over there!" is not a valid defense at all.  I'll gladly
go over and deal with your misbehaving sibling after dealing with you :)

> We've spent years cleaning it up in staging, and it has gotten a lot
> better.

Better yes.  Correct and mergable out of staging, no.  You all have had
plenty of time to get your act together.  Maybe this is what you all
really need to kick it into gear to do it correctly.  I certainly hope
so, because I think we all can agree that what we have been doing for
the past 5 years is NOT working at all.

sorry,

greg k-h
