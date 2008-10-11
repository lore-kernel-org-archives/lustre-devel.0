From: Eric Barton <eeb@sun.com>
Date: Sat, 11 Oct 2008 21:18:35 +0100
Subject: [Lustre-devel] COS performance issues
In-Reply-To: <20081011160010.GR2009@webber.adilger.int>
References: <200810081544.08292.alexander.zarochentsev@sun.com>
	<20081011160010.GR2009@webber.adilger.int>
Message-ID: <097E12B55A98421C880928B9F9A33DE7@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas,

Zam doesn't mean the reply messages being blocked - he means
the reply state that is holding lock references.  Previously
they got cleaned up one at a time as the repACKs came in.  Now
they get scheduled by the 1000s on the commit callback.  I'm
betting that we're getting thundering herds of MDS threads
at this time and that we should have dedicated 1-per-CPU threads
doing the cleanup to minimize interference with normal request
processing.  Bzzz thinks it's purely spinlock contention that's
the source of the inefficiency.  So Zam is going to run an
experiment with a single CPU MDS to see if the performance issue
goes away.  I'm betting it won't and Bzzz is betting it will.
We should see soon...

    Cheers,
              Eric

>  
> 
> -----Original Message-----
> From: Andreas.Dilger at Sun.COM [mailto:Andreas.Dilger at Sun.COM] On Behalf Of Andreas Dilger
> Sent: 11 October 2008 5:00 PM
> To: Alexander Zarochentsev
> Cc: lustre-devel at lists.lustre.org; lustre-recovery at Sun.COM
> Subject: Re: [Lustre-devel] COS performance issues
> 
> On Oct 08, 2008  15:44 +0400, Alexander Zarochentsev wrote:
> > I think the problem is that COS defers processing of replies to
> > transaction commit time.  When commit happens, MDS has to process
> > thousands of replies (about 14k replies per commit in the test 3.a)
> > in short period of time. I guess the mdt service threads all woken
> > up and spin trying to get the service svr_lock. Processing of new
> > requests may also suffer of this.
> 
> Can you please explain what replies are being blocked?  It can't be the
> create replies or the clients would be blocked waiting after starting a
> single create each.
> 
> I think the thread and lock contention is only part of the issue - if all
> of these replies are blocked until transaction commit this wastes all of
> the bandwidth on the network while the replies are being held.
> 
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
> 
> 
