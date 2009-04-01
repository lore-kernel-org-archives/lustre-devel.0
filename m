From: Lee Ward <lee@sandia.gov>
Date: Wed, 1 Apr 2009 09:58:26 -0600
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <D3750FED-36ED-4B07-9499-A8ABA7A2FCDA@Sun.COM>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
	<1238596005.5091.31.camel@wheel>
	<D3750FED-36ED-4B07-9499-A8ABA7A2FCDA@Sun.COM>
Message-ID: <1238601506.5091.65.camel@wheel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 2009-04-01 at 09:14 -0600, Oleg Drokin wrote:
> Hello!
> 
> On Apr 1, 2009, at 10:26 AM, Lee Ward wrote:
> >>   It came to my attention that seastar network does not implement
> >> message priorities for various reasons.
> > That is incorrect. The seastar network does implement at least one
> > priority scheme based on age. It's not something an application can  
> > play
> > with if I remember right.
> 
> Well, then it's as good as none for our purposes, I think?

Other than that traffic moves (only very roughly) in a fair manner and
that packets from different nodes can arrive out of order, I guess.

I think my point was that there is already a priority scheme in the
Seastar. Are there additional bits related to priority that you might
use, also?

> 
> > I strongly suspect OS jitter, probably related to FS activity, is a  
> > much
> > more likely explanation for the above. If just one node has the
> > process/rank suspended then it can't service the barrier; All will  
> > wait
> > until it can.
> 
> That's of course right and possible too.
> Though given how nothing else is running on the nodes, I would think
> it is somewhat irrelevant, since there is nothing else to give  
> resources to.

How and where memory is used on two nodes is different. How, where,
when, scheduling occurs on two nodes is different. Any two nodes, even
running the same app with barrier synchronization, perform things at
different times outside of the barriers; They very quickly desynchronize
in the presence of jitter.

> The Lustre processing of the outgoing queue is pretty fast in itself at
> this phase.
> Do you think it would be useful if I just run 1 thread per node, there  
> would be
> 3 empty cores to adsorb all the jitter there might be then?

You will still get jitter. I would hope less, though, so it wouldn't
hurt to try to leave at least one idle core. We've toyed with the idea
of leaving a core idle for IO and other background processing in the
past. The idea was a non-starter with our apps folks though. Maybe the
ORNL folks will feel differently?

> 
> > Jitter gets a bad rap. Usually for good reason. However, in this case,
> > it doesn't seem something to worry overly much about as it will cease.
> > Your test says the 1st barrier after the write completes in 4.5 sec  
> > and
> > the 2nd in 1.5 sec. That seems to imply the jitter is settling pretty
> > rapidly. Jitter is really only bad when it is chronic.
> 
> Well, 4.5*1200 = 1.5 hours of completely wasted cputime for my  
> specific job.

That 1200 is the number of checkpoints? If so, I agree. If it's the
number of nodes, I do not.

> So I thought it would be a good idea to get to the root of it.
> We hear many arguments here at the lab that "what good the buffered io  
> is for
> me when my app performance is degraded if I don't do sync. I'll just do
> the sync and be over with it". Of course I believe there is still  
> benefit to not
> doing the sync, but that's just me.

If the time to settle the jitter is on the order of 10 seconds but it
takes 15 seconds to sync, it would be better to live with the jitter,
no? I suggested an experiment to make this comparison. Why argue with
them? just do the experiment and you can know which strategy is better.

> 
> > To me, you are worrying way too much about the situation immediately
> > after a write. Checkpoints are relatively rare, with long periods
> > between. Why worry about something that's only going to affect a very
> > small portion of the overall job? As long as the jitter dissipates  
> > in a
> > short time, things will work out fine.
> 
> I worry abut it specifically because users tend to do sync after the  
> write and that
> wastes a lot of time. So as a result - I want as much of data to enter  
> into cache
> and then trickle out all by itself and I want users not to see any bad  
> effects
> (or otherwise to show to them that there are still benefits).

Users tend to do sync for more reasons than making the IO deterministic.
They should be doing it so that they can have some faith that the last
checkpoint is actually persistent when interrupted.

However, they should do the sync right before they enter the IO phase,
in order to also get the benefits of write-back caching. Not after the
IO phase. In the event of an interrupt, this forces them to throw away
an in-progress checkpoint and the last one before that, to be safe, but
the one before the last should be good.

The apps could also be more reasonable about their checkpoints, I've
noticed. Often, for us anyway, the machine just behaves. If the app
began by assuming the machine was unreliable but as it ran for longer
and longer periods, it could (I argue should) allow the period between
checkpoints to grow. If the idea is to make progress, as I'm told, then
on a well behaved machine far fewer checkpoints are required. Most apps,
though, just use a fixed period and waste a lot of time doing their
checkpoints when the machine is being nice to them.

> 
> > Maybe you could convince yourself of the efficacy of write-back  
> > caching
> > in this scenario by altering the  app to do an fsync() after the write
> > phase on the node but before the barrier? If the app can get back to
> > computing, even with the jitter-disrupted barrier, faster than it  
> > could
> > by waiting for the outstanding dirty buffers to be flushed then it's a
> > net win to just live with the jitter, no?
> 
> I do not need to convince myself. IT's the app programmers that are  
> fixated
> on "oh, look, my program is slower after the write if I do not do  
> sync, I must
> do sync!"

Try the experiment. Show them the data. They are, in theory, reasoning
people, right?

In some cases, your app programmers will be unfortunately correct. An
app that uses so much memory that the system cannot buffer the entire
write will incur at least some issues while doing IO; Some of the IO
must move synchronously and that amount will differ from node to node.
This will have the effect of magnifying this post-IO jitter they are so
worried about. It is also why I wrote in the original requirements for
Lustre that if write-back caching is employed there must be a way to
turn it off.

If they aren't sizing their app for the node's physical memory, though,
I would think that the experiment should show that write-back caching is
a win.

		--Lee

> 
> Bye,
>      Oleg
> 
