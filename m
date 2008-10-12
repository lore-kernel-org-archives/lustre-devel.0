From: Alexander Zarochentsev <Alexander.Zarochentsev@Sun.COM>
Date: Sun, 12 Oct 2008 19:51:56 +0400
Subject: [Lustre-devel] COS performance issues
In-Reply-To: <20081011160010.GR2009@webber.adilger.int>
References: <200810081544.08292.alexander.zarochentsev@sun.com>
	<20081011160010.GR2009@webber.adilger.int>
Message-ID: <200810121951.56922.alexander.zarochentsev@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 11 October 2008 20:00:10 Andreas Dilger wrote:
> On Oct 08, 2008  15:44 +0400, Alexander Zarochentsev wrote:
> > I think the problem is that COS defers processing of replies to
> > transaction commit time.  When commit happens, MDS has to process
> > thousands of replies (about 14k replies per commit in the test 3.a)
> > in short period of time. I guess the mdt service threads all woken
> > up and spin trying to get the service svr_lock. Processing of new
> > requests may also suffer of this.
>
> Can you please explain what replies are being blocked?  It can't be
> the create replies or the clients would be blocked waiting after
> starting a single create each.
>
> I think the thread and lock contention is only part of the issue - if
> all of these replies are blocked until transaction commit this wastes
> all of the bandwidth on the network while the replies are being held.

as Eric explained already, replies are sent already but the reply state 
objects remain in memory.  The cleanup process is almost serialized by 
per-service spinlock. It might be only a part of the problem but the 
first task to solve.

> Cheers, Andreas

WBR,
-- 
Alexander "Zam" Zarochentsev
Staff Engineer
Lustre Group, Sun Microsystems
