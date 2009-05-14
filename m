From: Andreas Dilger <adilger@sun.com>
Date: Thu, 14 May 2009 14:54:49 -0600
Subject: [Lustre-devel] Thinking of Hacks around bug #12329
In-Reply-To: <9c21eeae0905140905u1aecbe95tfa2ed890668338ef@mail.gmail.com>
References: <9c21eeae0905131106w23032105tdcf9a2399fb550df@mail.gmail.com>
	<20090514062224.GD3209@webber.adilger.int>
	<9c21eeae0905140905u1aecbe95tfa2ed890668338ef@mail.gmail.com>
Message-ID: <20090514205449.GM3209@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On May 14, 2009  09:05 -0700, David Brown wrote:
> > Hmm, even projecting out to the future I'm not certain we will get
> > to systems with 18000 OSTs. ?The capacity of the disks is growing
> > contiuously, and with ZFS we can have very large individual OSTs
> > so even 2-3 years from now we're only looking at 1200 OSTs on 400 OSS
> > nodes (115 PB filesystem with 30x4TB disks/OST in RAID-6 8+2 = 96TB/OST).
> 
> So How fast is this theoretical 115PB system?

About 1.5TB/s fast, if the math holds true.

> With innovations like SSDs getting cheeper and larger, we may get
> faster and better performance. However, I'm still not sure we're going
> to be keeping up with the curve that processors are going to be doing.

Sure, we are already testing SSDs and what we can do to improve the
filesystem to take advantage of them.  They aren't quite at the price
point where people will be jumping on them, but I expect in a year or
two they will become much more affordable.

> However, I guess you guys really aren't too concerned about the
> processing power increasing particularly. Just make a file system that
> can save all the memory in a super computer in N minutes really.

Well, CPU power -> more RAM to feed CPU -> more disk to feed/purge RAM.
So even though CPU/RAM size is increasing exponentially, disk size and
more importantly perf is not growing so quickly.  Even worse, seeks are
almost static for spinning disks (8ms or so => 125 IOPS), so SSDs are
really the only hope to keep up with filesystem requirements.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
