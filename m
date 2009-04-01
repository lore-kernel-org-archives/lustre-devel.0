From: Lee Ward <lee@sandia.gov>
Date: Wed, 1 Apr 2009 13:13:20 -0600
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <F939F52D-614F-4CA8-A80F-50CE31E3303A@Sun.COM>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
	<1238596005.5091.31.camel@wheel>
	<D3750FED-36ED-4B07-9499-A8ABA7A2FCDA@Sun.COM>
	<1238601506.5091.65.camel@wheel>
	<F939F52D-614F-4CA8-A80F-50CE31E3303A@Sun.COM>
Message-ID: <1238613200.5091.184.camel@wheel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 2009-04-01 at 10:35 -0600, Oleg Drokin wrote:
> Hello!
> 
> On Apr 1, 2009, at 11:58 AM, Lee Ward wrote:
> > I think my point was that there is already a priority scheme in the
> > Seastar. Are there additional bits related to priority that you might
> > use, also?
> 
> But if we cannot use it, there is none.
> Like we want mpi rpcs go out first to some degree.

If you don't want to follow up, I'm ok with that. It's up to you.

I understood what you want. There are at least two things I can imagine
that would better the situation without trying to leverage something in
the network, itself.

1) Partition the adapter CAM so that there is always room to accommodate
a user-space receive.
2) Prioritize injection to favor sends originating from user-space.

One or both of these might already be implemented. I don't know.

> 
> >>> I strongly suspect OS jitter, probably related to FS activity, is a
> >>> much
> >>> more likely explanation for the above. If just one node has the
> >>> process/rank suspended then it can't service the barrier; All will
> >>> wait
> >>> until it can.
> >> That's of course right and possible too.
> >> Though given how nothing else is running on the nodes, I would think
> >> it is somewhat irrelevant, since there is nothing else to give
> >> resources to.
> > How and where memory is used on two nodes is different. How, where,
> 
> That's irrelevant.
> 
> > when, scheduling occurs on two nodes is different. Any two nodes, even
> > running the same app with barrier synchronization, perform things at
> > different times outside of the barriers; They very quickly  
> > desynchronize
> > in the presence of jitter.
> 
> But since the only thing I have in my app inside barriers is write call,
> there is no much way to desynchronize.

Modify your test to report the length of time each node spent in the
barrier (not just rank 0, as it is written now) immediately after the
write call, then? If you are correct, they will all be roughly the same.
If they have desynchronized, most will have very long wait times but at
least one will be relatively short.

> 
> >> The Lustre processing of the outgoing queue is pretty fast in  
> >> itself at
> >> this phase.
> >> Do you think it would be useful if I just run 1 thread per node,  
> >> there
> >> would be
> >> 3 empty cores to adsorb all the jitter there might be then?
> > You will still get jitter. I would hope less, though, so it wouldn't
> > hurt to try to leave at least one idle core. We've toyed with the idea
> > of leaving a core idle for IO and other background processing in the
> > past. The idea was a non-starter with our apps folks though. Maybe the
> > ORNL folks will feel differently?
> 
> No, I do not think they would like the idea to forfeit 1/4 of their
> CPU just so io is better.
> If the jitter is due to cpu occupied with io, and apps stalled due to  
> this
> (though I have hard time believing an app to be not given a cpu for  
> 4.5 seconds,
> even though there are potentially 4 idle cpus, or even 3 (remember  
> other cores are
> also idle waiting on a barrier).

Oh, I'm sure they're getting the CPU. They just won't come out of the
barrier until all have processed the operation. The rates at which the
nodes reach the barrier will be different. The rates at which they
proceed through will be different. The only invariant after a barrier is
that all the involved ranks *have* reached that point. Nothing about
when that happened is stated or implied.

> 
> >>> Jitter gets a bad rap. Usually for good reason. However, in this  
> >>> case,
> >>> it doesn't seem something to worry overly much about as it will  
> >>> cease.
> >>> Your test says the 1st barrier after the write completes in 4.5 sec
> >>> and
> >>> the 2nd in 1.5 sec. That seems to imply the jitter is settling  
> >>> pretty
> >>> rapidly. Jitter is really only bad when it is chronic.
> >> Well, 4.5*1200 = 1.5 hours of completely wasted cputime for my
> >> specific job.
> > That 1200 is the number of checkpoints? If so, I agree. If it's the
> > number of nodes, I do not.
> 
> 1200 is number of cores waiting on a barrier.
> Every core spends 4.5 seconds == total wasted single-cpu core time is  
> 1.5 hours.

It doesn't work that way. The barrier operation is implemented as a
collective on the Cray. What you are missing in the math above is that
every core waited during the *same* 4.5 second period. Total wasted time
is only 4.5 seconds then.

> And the more often this happens the worse.
> 
> >> So I thought it would be a good idea to get to the root of it.
> >> We hear many arguments here at the lab that "what good the buffered  
> >> io
> >> is for
> >> me when my app performance is degraded if I don't do sync. I'll  
> >> just do
> >> the sync and be over with it". Of course I believe there is still
> >> benefit to not
> >> doing the sync, but that's just me.
> > If the time to settle the jitter is on the order of 10 seconds but it
> > takes 15 seconds to sync, it would be better to live with the jitter,
> > no? I suggested an experiment to make this comparison. Why argue with
> > them? just do the experiment and you can know which strategy is  
> > better.
> 
> I know which one is better. I did the experiment. (though I have no  
> realistic way
> to measure when "jitter" settles out).

Which was better then? By how much? Were you just measuring a barrier or
do those numbers still work out when the app uses the network heavily
after doing it's writes?

> 
> >>> To me, you are worrying way too much about the situation immediately
> >>> after a write. Checkpoints are relatively rare, with long periods
> >>> between. Why worry about something that's only going to affect a  
> >>> very
> >>> small portion of the overall job? As long as the jitter dissipates
> >>> in a
> >>> short time, things will work out fine.
> >> I worry abut it specifically because users tend to do sync after the
> >> write and that
> >> wastes a lot of time. So as a result - I want as much of data to  
> >> enter
> >> into cache
> >> and then trickle out all by itself and I want users not to see any  
> >> bad
> >> effects
> >> (or otherwise to show to them that there are still benefits).
> > Users tend to do sync for more reasons than making the IO  
> > deterministic.
> > They should be doing it so that they can have some faith that the last
> > checkpoint is actually persistent when interrupted.
> 
> For that they only need to do fsync before their next checkpoint,
> to make sure that the previous one completed.
> 
> > However, they should do the sync right before they enter the IO phase,
> > in order to also get the benefits of write-back caching. Not after the
> > IO phase. In the event of an interrupt, this forces them to throw away
> > an in-progress checkpoint and the last one before that, to be safe,  
> > but
> > the one before the last should be good.
> 
> Right.
> Yet they do some microbenchmark and decide it is bad idea.
> Besides, reducing jitter, or whatever is the cause for the delays
> would still be useful.

You're making a wonderful argument for Catamount :)

> 
> > In some cases, your app programmers will be unfortunately correct. An
> > app that uses so much memory that the system cannot buffer the entire
> > write will incur at least some issues while doing IO; Some of the IO
> > must move synchronously and that amount will differ from node to node.
> > This will have the effect of magnifying this post-IO jitter they are  
> > so
> > worried about. It is also why I wrote in the original requirements for
> 
> Why would it? There still is potentially a benefit for the available
> cache size.

In a fitted application, there is no useful amount of memory left over
for the cache. Using it, then, is just unnecessary overhead.

As I said, there's a very real possibility your app programmers are
correct. It goes beyond memory. Any resource under intense pressure due
to contention offers the possibility that it can take longer to perform
it's requests independently than to serialize them. For instance, if an
app does not use all of memory then there is plenty of room for Lustre
to cache. Since these apps presumably are going to communicate after the
IO phase (why else the barrier after the IO?) then they will contend
heavily with the Lustre client for the network interface and that
interface does not deal well with such a situation on the Cray. I  can
easily believe it would take longer for the app to get back to computing
because of the asynchronous network traffic from the write-back than it
would to just force the IO phase to complete, via fsync, and, after, do
what it needs to do to get back to work. If, instead, an app does use
all of the memory then it's blocked for a long time in the IO calls
waiting for a free buffer, before the sync. If, when, that happens then
the fsync is nearly a no-op as most of the dirty data have already been
written.

Were I an app programmer, I could easily come to the conclusion that the
fsync is either useful or does not hurt.

The only cooperative app I can think of that seems to be able to win
universally is the one structured to:

	for (;;) {
		barrier
		fsync
		checkpoint
		for (n = 0; n < TIME_STEPS_TWEEN_CHECKPOINT; n++) {
			compute
			communicate
		}
	}

I don't know any that work that way though :(

> 
> > Lustre that if write-back caching is employed there must be a way to
> > turn it off.
> 
> There is around 3 ways to do that that I am aware of.

That's nice. It was a requirement, after all. ;)

		--Lee

> 
> Bye,
>      Oleg
> 
