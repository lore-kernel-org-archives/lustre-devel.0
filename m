From: Jody McIntyre <scjody@sun.com>
Date: Tue, 03 Feb 2009 11:41:44 -0500
Subject: [Lustre-devel] Fwd: Disk rebuild
In-Reply-To: <6BAB26C7-8230-4D93-B41D-37B8AE31D7FF@sun.com>
References: <0da001c98608$ff6e5150$fe4af3f0$@com>
	<6BAB26C7-8230-4D93-B41D-37B8AE31D7FF@sun.com>
Message-ID: <20090203164144.GF14852@clouds>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Eric,

>> When we have some estimate of the overall HPCS filesystem size and
>> shape, can we do some calculations to show how frequently we expect
>> drives to fail and get our heads round the rebuild performance / 2nd
>> failure vulnerability tradeoff.  This obviously begs the question
>> whether RAID 6 changes this tradeoff significantly by allowing
>> rebuild to be so slow performance isn't impacted, and if so, whether
>> it's viable with a DMU backend.

Bryon asked me to clarify the RAID 6 vulnerability situation in resync
vs. recovery.  First some definitions, since I don't know how widely
accepted these terms are outside the Linux software RAID community:

recovery: This occurs when a disk fails and is replaced.  The entire
array must be read so that the new disk can be reconstructed from the
data and parity blocks on the existing disks.  Recovery is also done on
new arrays, because it's faster than resync.

resync: When a system crashes during a write, resync must be done to
repair the parity blocks.  All data blocks and parity blocks must be
read, and if the parity blocks are incorrect they must be rewritten.

With RAID 6, we are not vulnerable to a disk failure during recovery.
If a second disk fails while the first disk is being recovered, we can
replace it as well - recovery can reconstruct the data and parity blocks
on both new disks.

Unfortunately, we are vulnerable to _even one_ disk failing during
resync.  When a machine crashes during a write the parity could be
completely wrong and unsuitable for recovery.

It is possible to significantly reduce resync (but not recovery) times
using bitmaps, but these have been shown to hurt performance
significantly.  Another approach, journal-guided resynchronization, was
studied in a 2005 paper but has never been merged into the kernel.  The
paper shows improvements in resync times from 254 seconds to 0.21
seconds (for a 1 GB test array) with under 5% performance impact.  This
is an option if we're willing to develop and maintain the patches to do
it.

Cheers,
Jody
