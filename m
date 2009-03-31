From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Tue, 31 Mar 2009 16:58:36 -0400
Subject: [Lustre-devel] Oleg/Mike Work on Apps Metrics - FW: Mike Booth
 week ending 2009.03.15
In-Reply-To: <20090331185111.GL3199@webber.adilger.int>
References: <D691F7E6-6030-4EB9-896C-77201445D865@Sun.COM>
	<C5E2A328.36EE0%Daniel.Ferber@Sun.Com>
	<015c01c9a5a7$cb2f83a0$618e8ae0$@com>
	<52E982EB-3ADE-46FA-A7BC-D1645961DF0B@Sun.COM>
	<018101c9a5b6$25dbc300$71934900$@com>
	<48A6CF99-F630-4581-9FFC-05E3AFF66FA0@Sun.COM>
	<023201c9a636$a987e4b0$fc97ae10$@com>
	<5CE22E46-771C-47EE-9CAC-26A37C87C466@sun.com>
	<20090331185111.GL3199@webber.adilger.int>
Message-ID: <179D81CC-3A2F-4D39-9A48-9BFA2F4D6BB0@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Mar 31, 2009, at 2:51 PM, Andreas Dilger wrote:
>>> This latter concept is the basis for the "flash cache" concept.
>>> Actually, I think it's worth exploring the economics of it in more
>>> detail.
>> This turns out to be a very true assertion. We (I) do see a huge  
>> delay
>> in e.g. MPI barriers done immediately after write.
> While this is true, I still believe that the amount of delay seen by
> the application cannot possibly be worse than waiting for all of the
> IO to complete.  Also, the question is whether you are measuring the

Absolutely.

> FIRST MPI barrier after the write, vs e.g. the SECOND MPI barrier
> after the write?  Since Lustre is currently aggressively flushing the
> write cache then the first MPI barrier is essentially waiting for all
> of the IO to complete, which is of course very slow.  The real item
> of interest is how long the SECOND MPI barrier takes, which is what
> the overhead of Lustre IO is on the network performance.

Second MPI takes 1.5 seconds for me.

> It is impossible that Lustre IO completely saturates the entire
> cross-sectional bandwidth of the system OR the client CPUs, so having
> some amount of computation for "free" during IO is still better than
> waiting for the IO to complete.

No arguments about that from me, I am advocating this same thing from
the very beginning

Bye,
     Oleg
