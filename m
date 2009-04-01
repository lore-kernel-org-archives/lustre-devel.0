From: Nicholas Henke <nic@cray.com>
Date: Wed, 01 Apr 2009 14:15:53 -0500
Subject: [Lustre-devel] SeaStar message priority
In-Reply-To: <F939F52D-614F-4CA8-A80F-50CE31E3303A@Sun.COM>
References: <74EA92D6-25E8-42DA-A4FD-BDDCED233244@Sun.COM>	<1238596005.5091.31.camel@wheel>	<D3750FED-36ED-4B07-9499-A8ABA7A2FCDA@Sun.COM>	<1238601506.5091.65.camel@wheel>
	<F939F52D-614F-4CA8-A80F-50CE31E3303A@Sun.COM>
Message-ID: <49D3BD69.1070900@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Oleg Drokin wrote:
> Hello!
> 
> On Apr 1, 2009, at 11:58 AM, Lee Ward wrote:
>> I think my point was that there is already a priority scheme in the
>> Seastar. Are there additional bits related to priority that you might
>> use, also?
> 
> But if we cannot use it, there is none.
> Like we want mpi rpcs go out first to some degree.

If we have to deal with ordering - we are already sunk. The Lustre RPCs will go 
out and affect MPI latency to some degree, introducing jitter into the calls and 
affecting application performance.


> 
> But since the only thing I have in my app inside barriers is write call,
> there is no much way to desynchronize.

Incorrect - you are running your app on all 4 CPUs on the node at the same time 
Lustre is sending RPCs. The kernel threads will get scheduled and run, pushing 
your app to the side and desynchronizing the barrier for the app as a whole.


> No, I do not think they would like the idea to forfeit 1/4 of their
> CPU just so io is better.
> If the jitter is due to cpu occupied with io, and apps stalled due to  
> this
> (though I have hard time believing an app to be not given a cpu for  
> 4.5 seconds,
> even though there are potentially 4 idle cpus, or even 3 (remember  
> other cores are
> also idle waiting on a barrier).

This gets easier to swallow in the future with 12core and larger nodes - 1/12 is 
much easier to sacrifice.

What we really need to "prove" is where the delay is occurring. The MPI_Barrier 
messages are 0-byte sends, effectively turning them into Portals headers and 
these are sent and processed very fast. In fact, the total amount of data being 
sent is _much_ less than the NIC is capable of. A rough estimate for 2 nodes 
talking to each other is 1700 MB/s and 50K lnet pings/s.

One thing to try is changing your aprun to use fewer CPUs per node:
aprun -n 1200 -N [1,2,3] -cc 1-3.

The -cc 1-3 will keep it off cpu 0 - a known location for some IRQs and other 
servicing.

You should also try to capture compute-node stats like cpu usage, # of threads 
active during barrier, etc to help narrow down where the time is going.

Nic
