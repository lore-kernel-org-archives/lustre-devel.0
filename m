From: Lee Ward <lee@sandia.gov>
Date: Wed, 1 Apr 2009 22:28:12 -0600
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <89655A8C-F417-461E-8D5E-8A6395200795@sun.com>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>
	<1238596005.5091.31.camel@wheel>
	<D3750FED-36ED-4B07-9499-A8ABA7A2FCDA@Sun.COM>
	<1238601506.5091.65.camel@wheel>
	<F939F52D-614F-4CA8-A80F-50CE31E3303A@Sun.COM>
	<1238613200.5091.184.camel@wheel>
	<1849D28F-423C-42F7-BE4A-EB0D79571557@Sun.COM>
	<89655A8C-F417-461E-8D5E-8A6395200795@sun.com>
Message-ID: <1238646492.5091.275.camel@wheel>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, 2009-04-01 at 20:46 -0600, Oleg Drokin wrote:
> Hello!
> 
> On Apr 1, 2009, at 4:17 PM, Oleg Drokin wrote:
> 
> >>>> when, scheduling occurs on two nodes is different. Any two nodes,  
> >>>> even
> >>>> running the same app with barrier synchronization, perform things  
> >>>> at
> >>>> different times outside of the barriers; They very quickly
> >>>> desynchronize
> >>>> in the presence of jitter.
> >>> But since the only thing I have in my app inside barriers is write  
> >>> call,
> >>> there is no much way to desynchronize.
> >> Modify your test to report the length of time each node spent in the
> >> barrier (not just rank 0, as it is written now) immediately after the
> >> write call, then? If you are correct, they will all be roughly the  
> >> same.
> >> If they have desynchronized, most will have very long wait times  
> >> but at
> >> least one will be relatively short.
> > That's a fair point. I just scheduled the run.
> 
> Ok.
> The results are in. I scheduled 2 runs. One at 4 threads/node and one
> at 1 thread/node.
> 
> For the 4 threads/node case the 1st barrier took anywhere from 1.497  
> sec to
> 3.025 sec with rank 0 reporting 1.627 sec.
> The second barrier took 0.916 to 2.758 seconds with rank 0 reporting  
> 1.992 sec.
> For the barrier 2 I can actually clearly observe that thread terminate  
> in
> groups of 4 with very close times, and ranks suggest those nids are on  
> the same
> nodes. On 1st barrier this trend is much less visible, though.
> 
> On the 1 thread/node case the fastest 1st barrier was 7.515 seconds and
> slowest was 10.176
> For the 2nd barrier, fastest was 0.085 and slowest 2.756 which is  
> pretty close
> to the difference between fastest and slowest 1st barrier, since  
> amount of data
> written per node in this case 4 smaller, I guess we just flushed all  
> the data
> to the disk before the 1st barrier finished and the difference in  
> waiting was due
> to the differences in start times.
> 
> As you can see, numbers tend to jump around, but there are still  
> relatively big delays
> due to something else than just threads getting out of sync.

Agreed. It's something more than simple jitter.

From everything you have described, the nodes are otherwise idle. The
only other thing I can think, then, of would be one or more Lustre
client threads, injecting traffic into the network, which is where you
started.

A useful test might be to grab the MPI ping-pong from the test suite,
modify it to slow it down a bit. Say 4 times a second? Augment it to
report the ping-pong time and a time stamp. Augment your existing test
to report time stamps for the beginning of the write call. Launch one,
each, of these on your set of nodes; I.e., each node has both your write
test and the ping-pong running at the same time. This presumes you can
launch two mpi jobs onto your set of nodes. If not, come up with an
equivalent that is supported?

If the ping-pong latency goes way up at the write calls you can claim a
correlation. Not definitive as correlation does not equal cause but it
is pretty strong.

If there is correlation, it means Cray has kind of messed up the portals
implementation. The portals implementation would be attempting to send
*everything* in order. All portals needs is for traffic to go in order
per nid and pid pair. An implementation is free to mix in unrelated
traffic, and should, to prevent one process from starving others.

An idea... Does the Lustre service side restrict the number of
simultaneous get operations it issues? I don't just mean to a particular
client, but to all from a single server, be it OST or MDS. If not,
consider it. If there are too many outstanding receives an arriving
message may miss the corresponding CAM entry due to a flush. What
happens after that can't be pretty. At one time, it caused the client to
resend. Does it still? If so, and resends are occurring the affected
clients have their bandwidth reduced by more than 50% for the affected
operations. Since there is a barrier operation stuck behind it, well...

Mr. Booth has suggested that the portals client might offer to send less
data per transfer. This would allow latency sensitive sends to reach the
front of the queue more quickly. It would also, I think, lower overall
throughput. It's an idea worth considering but is a case of two evils.
Can this be mitigated by peeking at the portals send queue in some way?
If Lustre can identify outbound traffic in the queue that it didn't
present then it could respond as Mr. Booth has suggested or back off on
the rate at which it presents traffic, or both even? Initial latencies
would be unchanged but would get better as the app did more
communication, especially if it used the one-sided calls and overlapped
them.

I'm sorry, if it's contention for the adapter I don't see a work around
without changing Lustre or Cray changing the driver to more fairly
service the independent streams.

In any case, right now, your apps guys suspicions probably have merit if
it is indeed contention on the network adapter. They may really be
better off forcing the IO to complete before moving to the next phase if
that phase involves the network. How sad.

You do need to do the test, though, before you try to "fix" anything.
Right now, it's only supposition that contention for the network adapter
is the evil here.

		--Lee

> 
> Bye,
>     Oleg
> 
