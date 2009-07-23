From: Eric Barton <eeb@sun.com>
Date: Thu, 23 Jul 2009 13:32:41 +0100
Subject: [Lustre-devel] [FWD: Re: Fast MAC algorithms?]
In-Reply-To: <20090723054328.GX1020@Sun.COM>
References: <20090722191511.GG1020@Sun.COM>
	<20090722230032.GW4231@webber.adilger.int>
	<20090723000401.GT1020@Sun.COM> <20090723054328.GX1020@Sun.COM>
Message-ID: <00be01ca0b91$abe0a470$03a1ed50$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nico,

> On Wed, Jul 22, 2009 at 05:00:32PM -0600, Andreas Dilger wrote:
> > In any case, the more important numbers are for IB where the
> > overhead is low and the throughput is high.  We have DARPA
> > requesting 40GB/s from a single client, and definitely MAC
> > overhead will be noticable at that rate.
> 
> Also, 40GB/s is I/O, right?  There MACs come in via Secure PTLRPC.
> Chances are that encryption will be turned off.

I believe we should offer clear and simple but powerful and easy to
administer choices so that customers can make their own performance
v. security tradeoffs.  Obviously we want overhead to be as low as
possible, but it's never going away - especially for high bandwidth
bulk which is always going to on the edge of what the hardware can
provide.  I'm not at all surprised that the mail you quoted says that
MAC overhead becomes noticable as packets reach 1000 bytes.  Quite
recently, you needed to be using the full 1500 byte ether frames to
saturate 10GigE even with no additional processing just because of
the data copying - not the TCP protocol overhead.

> But MACs could still be used for replay sigs, capabilities, ...

Indeed.

> In the case of replay sigs we'd not want to sign _data_ anyways, so
> if we're doing 1MB I/Os then MAC overhead should be minimal.  

If the data was originally transferred encrypted or signed, then it
surely needs to do the same during recovery.  Plus I'm not so
concerned about performance during recovery given all the other
waiting around at this time we've yet to eliminate.  Even if
communications performance recovery was (a) the bottleneck and (b) 1/2
that of normal operation, it's not going to be sustained for longer
than a small multiple of the backend F/S sync interval - i.e. 10s of
seconds.

> Speaking of which, do RDMA transfers happen purely in the context of
> LNET?  Does LNET have a decent CRC?

Although bulk data can be checksummed in current Lustre, LNET and the
LNDs don't do an additional integrity checking, but rely on the
underlying transport(s).

> For bulk-data transfers I think it might suffice to MAC the RPCs and
> the CRCs of RDMA transfers where encryption is not required and very
> weak integrity protection of data is OK.

The end-to-end integrity work (i.e. integrating lustre with DMU
checksums) should take care of this.

> What about MAC overhead in meta-data ops?
<snip>
> I've been told that MDSes are CPU-bound, so it seems likely that
> crypto overhead should add noticeable latency to meta-data ops.

Yes probably.  We currently waste most of this CPU on spinlock
contention and through not paying sufficient attention to CPU
affinity.  Fixing these problems will buy us back a bunch of
performance (anywhere between 5x and 20x?) but we'll still be CPU
bound AFAICS.

Lets just measure and then we'll have some fact to reason about.  We
should be able to mock-up signing and/or encryption in LNET Self-Test
and get some numbers right away.  BTW I propose LNET ST rather than
obdecho since the SMP scaling work has been completed there, so we
should be able to get a worst-case impact measurement.

-- 

        Cheers,
                   Eric
