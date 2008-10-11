From: Andreas Dilger <adilger@sun.com>
Date: Sat, 11 Oct 2008 10:00:10 -0600
Subject: [Lustre-devel] COS performance issues
In-Reply-To: <200810081544.08292.alexander.zarochentsev@sun.com>
References: <200810081544.08292.alexander.zarochentsev@sun.com>
Message-ID: <20081011160010.GR2009@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Oct 08, 2008  15:44 +0400, Alexander Zarochentsev wrote:
> I think the problem is that COS defers processing of replies to
> transaction commit time.  When commit happens, MDS has to process
> thousands of replies (about 14k replies per commit in the test 3.a)
> in short period of time. I guess the mdt service threads all woken
> up and spin trying to get the service svr_lock. Processing of new
> requests may also suffer of this.

Can you please explain what replies are being blocked?  It can't be the
create replies or the clients would be blocked waiting after starting a
single create each.

I think the thread and lock contention is only part of the issue - if all
of these replies are blocked until transaction commit this wastes all of
the bandwidth on the network while the replies are being held.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
