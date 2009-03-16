From: Eric Barton <eeb@sun.com>
Date: Mon, 16 Mar 2009 12:56:45 +0000
Subject: [Lustre-devel] Oleg/Mike Work on Apps Metrics - FW: Mike Booth
 week ending 2009.03.15
In-Reply-To: <48A6CF99-F630-4581-9FFC-05E3AFF66FA0@Sun.COM>
References: <D691F7E6-6030-4EB9-896C-77201445D865@Sun.COM>
	<C5E2A328.36EE0%Daniel.Ferber@Sun.Com>
	<015c01c9a5a7$cb2f83a0$618e8ae0$@com>
	<52E982EB-3ADE-46FA-A7BC-D1645961DF0B@Sun.COM>
	<018101c9a5b6$25dbc300$71934900$@com>
	<48A6CF99-F630-4581-9FFC-05E3AFF66FA0@Sun.COM>
Message-ID: <023201c9a636$a987e4b0$fc97ae10$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Mike,

Yes, it would be fun to discuss - but I'm probably not going to be
available for a discussion like that for a week or 2.

BTW, I'm cc-ing lustre-devel since this is of general interest.

I _do_ agree that for some apps, if there was sufficient memory on the
app node to buffer the local component of a checkpoint and let it
"dribble" out to disk would achieve better utilization of the compute
resource.  However parallel apps can be very sensitive to "noise" on
the network they're using for inter- process communication - i.e. the
checkpoint data has either to be written all the way to disk, or at
least buffered somewhere so that moving it to disk will not interfere
with the app's own communications.

This latter concept is the basis for the "flash cache" concept.
Actually, I think it's worth exploring the economics of it in more
detail.

The variables are aggregate network bandwidth into the distributed
checkpoint cache, which determines the checkpoint time, and aggregate
path-minimum bandwidth (i.e. lesser of network and disk bandwidth)
from the cache to disk, which determines how soon the cache can be
ready for the next checkpoint.  The cache could be dedicated nodes and
storage (e.g. flash) or additional storage on the OSSes, or any
combination of either.  And the interesting relationship is how
compute cluster utilisation varies with the cost of the server and
cache subsystems.

-- 

        Cheers,
                   Eric

> -----Original Message-----
> From: Michael.Booth at Sun.COM [mailto:Michael.Booth at Sun.COM]
> Sent: 16 March 2009 3:06 AM
> To: Eric Barton
> Subject: Re: Oleg/Mike Work on Apps Metrics - FW: Mike Booth week ending 2009.03.15
> 
> Eric,
> 
> This is too bad.  I should run the test on my laptop and see if I get
> the same behavior.
> 
> The huge bandwidth requirements (30+ gbyes/sec) that I see for
> checkpoint-style I/O is driven in burst that last about 1/10 of the
> time of the following computation.  There is not a desire to assure
> that everything is on disk before resuming computations.  If while the
> computations proceeded the system cleared out the cache, the next
> write would go to cache at memory speed if the previous clean pages
> could be reused for the next write.  The bandwidth requirement to
> achieve what appears to be memory speed I/o could be achieved in this
> case with 3 gbytes/sec.
> 
>   There are middleware schemes being developed to do asynchronous I/O
> on "other" nodes to transfer the checkpoint data out to the other
> nodes so they write it all out.  To me this is the middleware working
> at odds with what the system software should naturally do for the
> application.
> 
> I think it is safe to say it is a minority of scientific applications
> that are writing out and quickly reading it back like a typical linux
> application, like web browsers.  This type of I/O is usually limited
> to codes that are larger than the sum  of the nodes memory,, which is
> rarer and rarer these days.
> 
> I believe that making this work for these codes is a win in three ways;,
> 
>    One: reduces the need for high burst rate I/O to disk for many
> programs while giving the perception of much faster I/O to the
> application.
> 
>    Two:  helps to reduce the impact of filesystem performance
> variability,
> 
>    Three: Overall in the system, not having the system being hit with
> huge burst of I/O by tens of thousands of cores at seemingly random
> times, could reduce the variability of the complete file system.
> 
> Should we discuss on the phone, with Oleg?
> 
> Thanks,, this is fun,
> 
> Mike
> 
> 
> Michael Booth
> michael.booth at sun.com
> mobile  512-289-3805
> 
