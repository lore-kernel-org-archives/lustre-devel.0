From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Wed, 01 Apr 2009 16:17:13 -0400
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <1238613200.5091.184.camel@wheel>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
	<1238596005.5091.31.camel@wheel>
	<D3750FED-36ED-4B07-9499-A8ABA7A2FCDA@Sun.COM>
	<1238601506.5091.65.camel@wheel>
	<F939F52D-614F-4CA8-A80F-50CE31E3303A@Sun.COM>
	<1238613200.5091.184.camel@wheel>
Message-ID: <1849D28F-423C-42F7-BE4A-EB0D79571557@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Apr 1, 2009, at 3:13 PM, Lee Ward wrote:
>> But if we cannot use it, there is none.
>> Like we want mpi rpcs go out first to some degree.
> If you don't want to follow up, I'm ok with that. It's up to you.
> I understood what you want. There are at least two things I can  
> imagine
> that would better the situation without trying to leverage something  
> in
> the network, itself.
> 1) Partition the adapter CAM so that there is always room to  
> accommodate
> a user-space receive.

I cannot really comment on this option.

> 2) Prioritize injection to favor sends originating from user-space.

This is what I am speaking about, actually, perhaps not being able to  
explain
myself clearly. Except perhaps just userspace is too generic and a bit  
more
fine-grained controls would be more beneficial.

> One or both of these might already be implemented. I don't know.

The second option does not look like it is implemented.

>>> when, scheduling occurs on two nodes is different. Any two nodes,  
>>> even
>>> running the same app with barrier synchronization, perform things at
>>> different times outside of the barriers; They very quickly
>>> desynchronize
>>> in the presence of jitter.
>> But since the only thing I have in my app inside barriers is write  
>> call,
>> there is no much way to desynchronize.
> Modify your test to report the length of time each node spent in the
> barrier (not just rank 0, as it is written now) immediately after the
> write call, then? If you are correct, they will all be roughly the  
> same.
> If they have desynchronized, most will have very long wait times but  
> at
> least one will be relatively short.

That's a fair point. I just scheduled the run.

> Oh, I'm sure they're getting the CPU. They just won't come out of the
> barrier until all have processed the operation. The rates at which the
> nodes reach the barrier will be different. The rates at which they

I believe the rates at which they come to the barrier are the aprox  
the same.
I do time the write system call. And the barrier is next to it. And  
write
system call has relatively small variability in time, so we can assume
that all barriers start within 0.1 seconds from each other.

> proceed through will be different. The only invariant after a  
> barrier is
> that all the involved ranks *have* reached that point. Nothing about
> when that happened is stated or implied.

Ok, I did not realize that, though that makes sense.
I believe in my test the problem is on the sending side - i.e. the  
bottleneck
does not let all nodes to report that the point was reached by every  
thread.
But as soon as all nodes gathered, whatever control node sends the  
messages
(that are of course could be delayed in the queue if it is also doing  
the io,
hm, I wonder what node coordinates this (set of nodes?). Rank 0?) and  
once injected, they should
be processed instantly since we do not have any significant incoming  
traffic on the
nodes.
Don't take my word for it of course, the test is already scheduled and  
I'll share the results.

>>>>> Jitter gets a bad rap. Usually for good reason. However, in this
>>>>> case,
>>>>> it doesn't seem something to worry overly much about as it will
>>>>> cease.
>>>>> Your test says the 1st barrier after the write completes in 4.5  
>>>>> sec
>>>>> and
>>>>> the 2nd in 1.5 sec. That seems to imply the jitter is settling
>>>>> pretty
>>>>> rapidly. Jitter is really only bad when it is chronic.
>>>> Well, 4.5*1200 = 1.5 hours of completely wasted cputime for my
>>>> specific job.
>>> That 1200 is the number of checkpoints? If so, I agree. If it's the
>>> number of nodes, I do not.
>> 1200 is number of cores waiting on a barrier.
>> Every core spends 4.5 seconds == total wasted single-cpu core time is
>> 1.5 hours.
> It doesn't work that way. The barrier operation is implemented as a
> collective on the Cray. What you are missing in the math above is that
> every core waited during the *same* 4.5 second period. Total wasted  
> time
> is only 4.5 seconds then.

I have a feeling we are speaking about different subjects here.
You are speaking about wall-clock time. I am speaking about total cpu- 
cycles
wasted across all nodes.

>>> If the time to settle the jitter is on the order of 10 seconds but  
>>> it
>>> takes 15 seconds to sync, it would be better to live with the  
>>> jitter,
>>> no? I suggested an experiment to make this comparison. Why argue  
>>> with
>>> them? just do the experiment and you can know which strategy is
>>> better.
>> I know which one is better. I did the experiment. (though I have no
>> realistic way
>> to measure when "jitter" settles out).
> Which was better then? By how much? Were you just measuring a  
> barrier or
> do those numbers still work out when the app uses the network heavily
> after doing it's writes?

Unfortunately I do not have any real applications instrumented, so my  
barrier
is a substitute for "network-heavy app activity". I started with it  
because
app programmers I spoke with complained about how their network  
latency is
affected if they do buffered writes.
The fsync takes upward from 10 seconds, depending on other load in the  
system,
I guess. I have no easy way to measure the jitter.
I do not think writeout with or without fsync would take significantly  
different
time because the underlying io paths don't change, but that's non- 
scientific.
Unfortunately just doing a write, time the fsync then doing the write  
again and
wait the same amount of time as fsync took, then do another fsync and  
see if it is
instantly returned, since lustre only eagerly writes 1M chunks, and vm  
pressure only
ensures data older than 30 seconds would be pushed out. And that  
before taking into
account possible variability of the loads on OSTs over time (since I  
cannot have
entire Jaguar all for myself).

>>> However, they should do the sync right before they enter the IO  
>>> phase,
>>> in order to also get the benefits of write-back caching. Not after  
>>> the
>>> IO phase. In the event of an interrupt, this forces them to throw  
>>> away
>>> an in-progress checkpoint and the last one before that, to be safe,
>>> but
>>> the one before the last should be good.
>>
>> Right.
>> Yet they do some microbenchmark and decide it is bad idea.
>> Besides, reducing jitter, or whatever is the cause for the delays
>> would still be useful.
> You're making a wonderful argument for Catamount :)

Actually, catamount definitely has its strong points, but there are
drawbacks as well. With Linux it's just another set of benefits and
drawbacks.

>>> In some cases, your app programmers will be unfortunately correct.  
>>> An
>>> app that uses so much memory that the system cannot buffer the  
>>> entire
>>> write will incur at least some issues while doing IO; Some of the IO
>>> must move synchronously and that amount will differ from node to  
>>> node.
>>> This will have the effect of magnifying this post-IO jitter they are
>>> so
>>> worried about. It is also why I wrote in the original requirements  
>>> for
>> Why would it? There still is potentially a benefit for the available
>> cache size.
> In a fitted application, there is no useful amount of memory left over
> for the cache. Using it, then, is just unnecessary overhead.

Right. In this case it is even better to do non-caching io (directio  
style)
to reduce the memory copy overhead as well.

> As I said, there's a very real possibility your app programmers are
> correct. It goes beyond memory. Any resource under intense pressure  
> due
> to contention offers the possibility that it can take longer to  
> perform
> it's requests independently than to serialize them. For instance, if  
> an
> app does not use all of memory then there is plenty of room for Lustre
> to cache. Since these apps presumably are going to communicate after  
> the
> IO phase (why else the barrier after the IO?) then they will contend
> heavily with the Lustre client for the network interface and that
> interface does not deal well with such a situation on the Cray. I  can
> easily believe it would take longer for the app to get back to  
> computing
> because of the asynchronous network traffic from the write-back than  
> it
> would to just force the IO phase to complete, via fsync, and, after,  
> do
> what it needs to do to get back to work. If, instead, an app does use
> all of the memory then it's blocked for a long time in the IO calls
> waiting for a free buffer, before the sync. If, when, that happens  
> then
> the fsync is nearly a no-op as most of the dirty data have already  
> been
> written.

This is all very true.
Currently I am only focusing on applications that do leave enough space
for the fs cache, since that's where the possible benefit is and there  
is
no drawback for applications that don't do cached io. (And this is the
case for the app programmers I spoke with).

> The only cooperative app I can think of that seems to be able to win
> universally is the one structured to:
>
> 	for (;;) {
> 		barrier
> 		fsync
> 		checkpoint
> 		for (n = 0; n < TIME_STEPS_TWEEN_CHECKPOINT; n++) {
> 			compute
> 			communicate
> 		}
> 	}

> I don't know any that work that way though :(

We here at ORNL are trying hard to convice app programmers that this is
indeed beneficial.
Unfortunately it is not all that clean-cut, the machine itself behaves
differently every time due to all different workloads going on is part
of the problem too.
Of course we stand in our way too, with the default 32Mb limit of  
dirty cache
per osc, in order to get meaningful caching size we need to stripe the  
files
over waay to many OSTs, and as a result the overall IO performance is
degraded compared to just the case of outputting to a single OST from  
every
job, due to reduced randomness in IO pattern.

Bye,
     Oleg
