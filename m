From: Lee Ward <lee@sandia.gov>
Date: Wed, 1 Apr 2009 08:26:45 -0600
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
Message-ID: <1238596005.5091.31.camel@wheel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, 2009-03-31 at 22:43 -0600, Oleg Drokin wrote:
> Hello!
> 
>    It came to my attention that seastar network does not implement  
> message priorities for various reasons.

That is incorrect. The seastar network does implement at least one
priority scheme based on age. It's not something an application can play
with if I remember right.

>    I really think there is very valid case for the priorities of some  
> sort to allow MPI and other
>    latency-critical traffic to go in front of bulk IO traffic on the  
> wire.

That would be very difficult to implement without making starvation
scenarios trivial.

>    Consider this test I was running the other day on Jaguar. The  
> application writes 250M of data from every
>    core with plain write() system call, the write() syscall returns  
> very fast (less than 0.5 sec == 400+Mb/sec
>    app-perceived bandwidth) because the data just goes to the memory  
> cache to be flushed later.
>    Then I do 2 barriers one by one with nothing in between.
>    If I run it at sufficient scale (say 1200 cores), the first barrier  
> takes 4.5 seconds to complete and
>    the second one 1.5 seconds, all due to MPI RPCs being stuck behind  
> huge bulk data requests on the clients,
>    presumably (I do not have any other good explanations at least).
>    This makes for a lot of wasted time in applications that would like  
> to use the buffering capabilities provided
>    by the OS.

I strongly suspect OS jitter, probably related to FS activity, is a much
more likely explanation for the above. If just one node has the
process/rank suspended then it can't service the barrier; All will wait
until it can.

Jitter gets a bad rap. Usually for good reason. However, in this case,
it doesn't seem something to worry overly much about as it will cease.
Your test says the 1st barrier after the write completes in 4.5 sec and
the 2nd in 1.5 sec. That seems to imply the jitter is settling pretty
rapidly. Jitter is really only bad when it is chronic.

To me, you are worrying way too much about the situation immediately
after a write. Checkpoints are relatively rare, with long periods
between. Why worry about something that's only going to affect a very
small portion of the overall job? As long as the jitter dissipates in a
short time, things will work out fine.

Maybe you could convince yourself of the efficacy of write-back caching
in this scenario by altering the  app to do an fsync() after the write
phase on the node but before the barrier? If the app can get back to
computing, even with the jitter-disrupted barrier, faster than it could
by waiting for the outstanding dirty buffers to be flushed then it's a
net win to just live with the jitter, no?

		--Lee

> 
>    Do you think something like this could be organized if not for  
> current revision then at least for the next
>    version?
> 
> Bye,
>      Oleg
>   
>   
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
> 
