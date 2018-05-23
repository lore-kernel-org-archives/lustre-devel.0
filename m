From: James Simmons <jsimmons@infradead.org>
Date: Wed, 23 May 2018 23:36:58 +0100 (BST)
Subject: [lustre-devel] Regression with delayed_work in sec_gc
In-Reply-To: <874lizz6lq.fsf@notabene.neil.brown.name>
References: <alpine.LFD.2.21.1805151609430.28403@casper.infradead.org>
 <87sh6s5zjy.fsf@notabene.neil.brown.name>
 <E4BBDF07-0165-4306-9846-382D2D0A9C3D@ddn.com>
 <87r2m5ztsr.fsf@notabene.neil.brown.name>
 <79108C6E-9FC1-44E8-9B3A-AB7FE3A4C5DE@intel.com>
 <874lizz6lq.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1805232218570.21947@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> >> When (e.g.) ctx_release_kr() is called as part of shutting down a security
> >> context, it calls sptlrpc_gc_add_ctx() which signals the gc-thread to
> >> re-run.
> >> None of this code is in mainline (why isn't the GSS code in
> >> mainline????)
> >
> > We are in the un-enviable position that we can't really land new Lustre
> > features into the staging tree, but we can't get out of the staging tree
> > without a lot of code changes.
> 
> I don't see this as a problem.  "code changes" and "new fetures" are
> largely independent.  There certainly are grey areas, but then the rules
> aren't inflexible.  If something feature-like is needed to achieve clean
> code, I doubt anyone would object.

To explain why this is brought up let me clear something up. While Lustre 
is thought of as a strictly Intel product, and yes the OpenSFS out of 
tree is managed by them, that is not the case. The best way to think 
of the Lustre Intel developers is as the "features team". Andreas as an 
Intel developer bringing this up makes sense. If you look at things like 
performance improvements it generally falls to companies like Cray and 
DDN. They have developers that work on those sort of things. Not saying
they don't do features but when they do it generally has the motive to 
improve performance. Look at slide 12 of the following slides:

http://cdn.opensfs.org/wp-content/uploads/2018/04/Jones-Community_Release_Update_LUG_2018.pdf

You will noticed that after Intel the next largest contributor is ORNL
which is my employer. The 25083 lines of code change is me updating the
code for the linux upstream work :-) So in the Intel source tree following
the features developed by Intel the next largest work is making Lustre 
more linux compliant. Well I do lots of other work to make Lustre 
deployable at my employer and to keep my admins happy :-) Also I'm the
Lustre ARM, PowerPC guy. But that is off topic. Okay I guess I do lots of
things.

So the slides show Lustre has grown into more of a community effort. The
aim is to make Intel slice shrink into a reasonable size. That is not 
sustainable in the long run especially once Lustre enters the cloud 
market which is many orders of magnitude larger then the HPC market.

> I also don't see how your observation explains the lack of gss code in
> the staging tree.
> I've found
> Commit: b78560200d41 ("staging: lustre: ptlrpc: gss: delete unused code")
> and am wondering why all the sec*.c code didn't disappear at the same
> time.
> I guess I'll put 'gss' on my list of things to "fix".

I can explain why this is the case. For the lustre version that first 
merged into the staging tree the GSS code just plain didn't work. At that
time anything that didn't seem to work wasn't fix but just deleted :-(
This is how for example we lost the libcfs watchdog timer used for ptlrpc
threads to get back traces for threads that got hung. Sadly once removed
its not easy to bring it back.
 
BTW the GSS code for lustre still is a bit wonky. So I would say its not
yet ready for prime time. I felt it was something best to wait until after
leaving staging since that is a big code drop. Also as I pointed out at
developers day their is a lot of code duplication with the sunrpc gss 
code. We need to get together with the sunrpc gss maintainer and work out 
a common api so lustre and sunrpc could register with this infrastructre.
I just haven't had the cycles to get to this yet. Currently I would say
this is down the list of TODOs.

> > It isn't clear to me why Lustre has such a high bar to cross to get out
> > of staging, compared to other filesystems that were added in the past.
> 
> I don't see the bar as being all that high, but then I haven't seen any
> battles that you might have already fought that seem to show a high bar.
> 
> In my mind there are two issues: code quality and maintainership
> quality.
> Lustre was (is) out-of-tree for a long time with little or no apparent
> interesting in going mainline, so that results in a fairly low score for
> maintainership.  Maintainership means working in and with the community.
> While lustre was out-of-tree it developed lot of useful functionality
> which was also independently (and differently) developed in mainline
> linux.  This makes the code look worse than it is - because it seems to
> be unnecessarily different.
> Lustre also previously supported multiple kernels, so it had (has)
> abstraction layers which are now just technical debt.
> So it is coming from a fairly low starting point.  I think it is
> reasonable for the Linux community to want to be able to see lustre clearly
> rising above all that past, clearing the debt with interest (you might
> say).

That is from the long history of supporting a user land version which also
was used for the Cray catamount OS and a potential Windows and Mac client.
Also when Sun acquired Lustre it wanted it on it Solaris system. Often
the solutions Lustre did happened long before linux had a solution. In
any case Lustre is now a linux product. Its better than what it was. I
have been doing a lot of work to clean up the duplicate efforts and such. 

> This is all quite achievable - it just takes time and effort (and skill
> - I think we have that among us).
> I've been given time by SUSE to work on this and I can clear a lot of
> the technical debt.  The more we work together, the easier it will be.
> James has been a great help and I think momentum is building.
> The community side needs key people to stop thinking of "us vs them" and
> start thinking of lustre as part of the Linux community.  Don't talk
> about "upstream has accepted this" or "upstream have rejected that", but
> get on board with "we've landed this upstream" or "we are working to
> find the best solution for that".
>
> It might help to start using the mailing list more, rather than
> depending on whamcloud.  The work-flow is different, but is quite
> workable, and shows a willingness to be part of the broader community.
> 
> > It's not like Lustre is going away any time soon, unlike some no-name
> > ethernet card driver, and we could still continue to improve the Lustre
> > code if we could move out of staging, but it could be done in a more
> > sustainable manner where we also land feature patches and try to bring
> > the kernel and master code closer together over time.
> 
> I think we should do one thing at a time.
> Firstly, focus on getting out of staging.  Freeze the current feature
> set and get all existing features into an acceptable form.
> Secondly, add all the fixes and features from master-code into Linux.
> If you also want to move fixes from Linux into master, that's up to you.

I have a plan which I will go over in a latter email.
