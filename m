From: Eric Barton <eeb@sun.com>
Date: Tue, 03 Feb 2009 14:09:15 +0000
Subject: [Lustre-devel] Disk rebuild
Message-ID: <0da001c98608$ff6e5150$fe4af3f0$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas,

When we have some estimate of the overall HPCS filesystem size and shape,
can we do some calculations to show how frequently we expect drives to
fail and get our heads round the rebuild performance / 2nd failure
vulnerability tradeoff.  This obviously begs the question whether RAID 6
changes this tradeoff significantly by allowing rebuild to be so slow
performance isn't impacted, and if so, whether it's viable with a DMU
backend.

    Cheers,
              Eric
