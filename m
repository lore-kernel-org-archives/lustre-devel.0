From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 01 Apr 2009 11:14:19 -0400
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <1238596005.5091.31.camel@wheel>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
	<1238596005.5091.31.camel@wheel>
Message-ID: <D3750FED-36ED-4B07-9499-A8ABA7A2FCDA@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Apr 1, 2009, at 10:26 AM, Lee Ward wrote:
>>   It came to my attention that seastar network does not implement
>> message priorities for various reasons.
> That is incorrect. The seastar network does implement at least one
> priority scheme based on age. It's not something an application can  
> play
> with if I remember right.

Well, then it's as good as none for our purposes, I think?

> I strongly suspect OS jitter, probably related to FS activity, is a  
> much
> more likely explanation for the above. If just one node has the
> process/rank suspended then it can't service the barrier; All will  
> wait
> until it can.

That's of course right and possible too.
Though given how nothing else is running on the nodes, I would think
it is somewhat irrelevant, since there is nothing else to give  
resources to.
The Lustre processing of the outgoing queue is pretty fast in itself at
this phase.
Do you think it would be useful if I just run 1 thread per node, there  
would be
3 empty cores to adsorb all the jitter there might be then?

> Jitter gets a bad rap. Usually for good reason. However, in this case,
> it doesn't seem something to worry overly much about as it will cease.
> Your test says the 1st barrier after the write completes in 4.5 sec  
> and
> the 2nd in 1.5 sec. That seems to imply the jitter is settling pretty
> rapidly. Jitter is really only bad when it is chronic.

Well, 4.5*1200 = 1.5 hours of completely wasted cputime for my  
specific job.
So I thought it would be a good idea to get to the root of it.
We hear many arguments here at the lab that "what good the buffered io  
is for
me when my app performance is degraded if I don't do sync. I'll just do
the sync and be over with it". Of course I believe there is still  
benefit to not
doing the sync, but that's just me.

> To me, you are worrying way too much about the situation immediately
> after a write. Checkpoints are relatively rare, with long periods
> between. Why worry about something that's only going to affect a very
> small portion of the overall job? As long as the jitter dissipates  
> in a
> short time, things will work out fine.

I worry abut it specifically because users tend to do sync after the  
write and that
wastes a lot of time. So as a result - I want as much of data to enter  
into cache
and then trickle out all by itself and I want users not to see any bad  
effects
(or otherwise to show to them that there are still benefits).

> Maybe you could convince yourself of the efficacy of write-back  
> caching
> in this scenario by altering the  app to do an fsync() after the write
> phase on the node but before the barrier? If the app can get back to
> computing, even with the jitter-disrupted barrier, faster than it  
> could
> by waiting for the outstanding dirty buffers to be flushed then it's a
> net win to just live with the jitter, no?

I do not need to convince myself. IT's the app programmers that are  
fixated
on "oh, look, my program is slower after the write if I do not do  
sync, I must
do sync!"

Bye,
     Oleg
