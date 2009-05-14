From: David Brown <dmlb2000@gmail.com>
Date: Thu, 14 May 2009 09:05:48 -0700
Subject: [Lustre-devel] Thinking of Hacks around bug #12329
In-Reply-To: <20090514062224.GD3209@webber.adilger.int>
References: <9c21eeae0905131106w23032105tdcf9a2399fb550df@mail.gmail.com>
	<20090514062224.GD3209@webber.adilger.int>
Message-ID: <9c21eeae0905140905u1aecbe95tfa2ed890668338ef@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

> Hmm, even projecting out to the future I'm not certain we will get
> to systems with 18000 OSTs. ?The capacity of the disks is growing
> contiuously, and with ZFS we can have very large individual OSTs
> so even 2-3 years from now we're only looking at 1200 OSTs on 400 OSS
> nodes (115 PB filesystem with 30x4TB disks/OST in RAID-6 8+2 = 96TB/OST).
>

So How fast is this theoretical 115PB system?

With innovations like SSDs getting cheeper and larger, we may get
faster and better performance. However, I'm still not sure we're going
to be keeping up with the curve that processors are going to be doing.

However, I guess you guys really aren't too concerned about the
processing power increasing particularly. Just make a file system that
can save all the memory in a super computer in N minutes really.

Also I'll be getting back with some interesting statistics on what
each system is doing memory used processors working and an infiniband
soft lockup detection that forces all ko2iblnd and prtlrpc kernel
procs to go full bore putting the load average to 16+ for a single OSS
(this does sound like a bug not sure if its already been noticed have
to do a bugzilla search).

Thanks,
- David Brown
