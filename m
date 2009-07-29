From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Wed, 29 Jul 2009 14:22:30 -0500
Subject: [Lustre-devel] SMP Scalability, MDS, reducing cpu pingpong
In-Reply-To: <002001ca1062$7b526fc0$71f74f40$@com>
References: <7580C3C1-7634-47C8-827B-C93157C1301A@Sun.COM>
	<002001ca1062$7b526fc0$71f74f40$@com>
Message-ID: <20090729192230.GU1020@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Jul 29, 2009 at 04:37:29PM +0100, Eric Barton wrote:
> > Also on lustre front - something I plan to tackle, though not yet
> > completely sure how: Lustre has a concept of reserving one thread for
> > difficult replies handling + one thread for high priority messages
> > handling (if enabled). In SMP scalability branch that becomes 2x
> > num_cpus reserved threads potentially per service since naturally
> > rep_ack reply or high prio message might arrive on any cpu separately
> > now (and message queues are per cpu) - seems like huge overkill to
> > me. I see that there is a handle reply separate threads in HEAD now,
> > so perhaps this could be greatly simplified by proper usage of those.
> > the high prio seems to be harder to improve, though.
> 
> These threads are required in case all normal service threads are
> blocking.  I don't suppose this can be a performance critical case, so
> voilating CPU affinity for the sake of deadlock avoidance seems OK.
> However is 1 extra thread per CPU such a big deal?  We'll have
> 10s-100s of them in any case.

Probably not.  You could have a single thread per-CPU if everything was
written in async I/O, continuation passing style (CPS), blocking only in
an event loop per-CPU.  That'd reduce context switches, but it'd
increase the amount of context being saved and read as that one thread
services each event/event completion.  In other words, you'd still have
context switches!

Also, the code would get insanely complicated -- CPS is for compilers,
not humans (nor do we have Scheme-like continuations in C nor in the
Linux kernel, and if we did that'd add quite a bit of run-time overhead
too).  And kernels are not usually written this way either, so it may
not even be feasible.  The thread model is just easier to code to.

> > Do anybody else have any extra thoughts for lustre side  
> > improvements we can get off this?
> 
> I think we need measurements to prove/disprove whether object affinity
> trumps client affinity.

If we have secure PTLRPC in the picture then client affinity is more
likely to trump object affinity: between keys, key schedules, and
sequence number windows may add up to enough.  (Of course, we could have
multiple streams per-client, so that a client could be serviced by
multiple server CPUs.)

Nico
-- 
