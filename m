From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 01 Apr 2009 12:35:29 -0400
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <1238601506.5091.65.camel@wheel>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
	<1238596005.5091.31.camel@wheel>
	<D3750FED-36ED-4B07-9499-A8ABA7A2FCDA@Sun.COM>
	<1238601506.5091.65.camel@wheel>
Message-ID: <F939F52D-614F-4CA8-A80F-50CE31E3303A@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Apr 1, 2009, at 11:58 AM, Lee Ward wrote:
> I think my point was that there is already a priority scheme in the
> Seastar. Are there additional bits related to priority that you might
> use, also?

But if we cannot use it, there is none.
Like we want mpi rpcs go out first to some degree.

>>> I strongly suspect OS jitter, probably related to FS activity, is a
>>> much
>>> more likely explanation for the above. If just one node has the
>>> process/rank suspended then it can't service the barrier; All will
>>> wait
>>> until it can.
>> That's of course right and possible too.
>> Though given how nothing else is running on the nodes, I would think
>> it is somewhat irrelevant, since there is nothing else to give
>> resources to.
> How and where memory is used on two nodes is different. How, where,

That's irrelevant.

> when, scheduling occurs on two nodes is different. Any two nodes, even
> running the same app with barrier synchronization, perform things at
> different times outside of the barriers; They very quickly  
> desynchronize
> in the presence of jitter.

But since the only thing I have in my app inside barriers is write call,
there is no much way to desynchronize.

>> The Lustre processing of the outgoing queue is pretty fast in  
>> itself at
>> this phase.
>> Do you think it would be useful if I just run 1 thread per node,  
>> there
>> would be
>> 3 empty cores to adsorb all the jitter there might be then?
> You will still get jitter. I would hope less, though, so it wouldn't
> hurt to try to leave at least one idle core. We've toyed with the idea
> of leaving a core idle for IO and other background processing in the
> past. The idea was a non-starter with our apps folks though. Maybe the
> ORNL folks will feel differently?

No, I do not think they would like the idea to forfeit 1/4 of their
CPU just so io is better.
If the jitter is due to cpu occupied with io, and apps stalled due to  
this
(though I have hard time believing an app to be not given a cpu for  
4.5 seconds,
even though there are potentially 4 idle cpus, or even 3 (remember  
other cores are
also idle waiting on a barrier).

>>> Jitter gets a bad rap. Usually for good reason. However, in this  
>>> case,
>>> it doesn't seem something to worry overly much about as it will  
>>> cease.
>>> Your test says the 1st barrier after the write completes in 4.5 sec
>>> and
>>> the 2nd in 1.5 sec. That seems to imply the jitter is settling  
>>> pretty
>>> rapidly. Jitter is really only bad when it is chronic.
>> Well, 4.5*1200 = 1.5 hours of completely wasted cputime for my
>> specific job.
> That 1200 is the number of checkpoints? If so, I agree. If it's the
> number of nodes, I do not.

1200 is number of cores waiting on a barrier.
Every core spends 4.5 seconds == total wasted single-cpu core time is  
1.5 hours.
And the more often this happens the worse.

>> So I thought it would be a good idea to get to the root of it.
>> We hear many arguments here at the lab that "what good the buffered  
>> io
>> is for
>> me when my app performance is degraded if I don't do sync. I'll  
>> just do
>> the sync and be over with it". Of course I believe there is still
>> benefit to not
>> doing the sync, but that's just me.
> If the time to settle the jitter is on the order of 10 seconds but it
> takes 15 seconds to sync, it would be better to live with the jitter,
> no? I suggested an experiment to make this comparison. Why argue with
> them? just do the experiment and you can know which strategy is  
> better.

I know which one is better. I did the experiment. (though I have no  
realistic way
to measure when "jitter" settles out).

>>> To me, you are worrying way too much about the situation immediately
>>> after a write. Checkpoints are relatively rare, with long periods
>>> between. Why worry about something that's only going to affect a  
>>> very
>>> small portion of the overall job? As long as the jitter dissipates
>>> in a
>>> short time, things will work out fine.
>> I worry abut it specifically because users tend to do sync after the
>> write and that
>> wastes a lot of time. So as a result - I want as much of data to  
>> enter
>> into cache
>> and then trickle out all by itself and I want users not to see any  
>> bad
>> effects
>> (or otherwise to show to them that there are still benefits).
> Users tend to do sync for more reasons than making the IO  
> deterministic.
> They should be doing it so that they can have some faith that the last
> checkpoint is actually persistent when interrupted.

For that they only need to do fsync before their next checkpoint,
to make sure that the previous one completed.

> However, they should do the sync right before they enter the IO phase,
> in order to also get the benefits of write-back caching. Not after the
> IO phase. In the event of an interrupt, this forces them to throw away
> an in-progress checkpoint and the last one before that, to be safe,  
> but
> the one before the last should be good.

Right.
Yet they do some microbenchmark and decide it is bad idea.
Besides, reducing jitter, or whatever is the cause for the delays
would still be useful.

> In some cases, your app programmers will be unfortunately correct. An
> app that uses so much memory that the system cannot buffer the entire
> write will incur at least some issues while doing IO; Some of the IO
> must move synchronously and that amount will differ from node to node.
> This will have the effect of magnifying this post-IO jitter they are  
> so
> worried about. It is also why I wrote in the original requirements for

Why would it? There still is potentially a benefit for the available
cache size.

> Lustre that if write-back caching is employed there must be a way to
> turn it off.

There is around 3 ways to do that that I am aware of.

Bye,
     Oleg
