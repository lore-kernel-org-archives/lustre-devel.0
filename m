From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 6 Feb 2015 23:33:29 +0000
Subject: [Lustre-devel] Removal of SOM code
Message-ID: <D0FA9D65.DA3FB%andreas.dilger@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The Size on MDT (SOM) feature has been in a prototype state for several
years, with no signs of moving beyond this prototype stage.

Several problems exist in the code today, primarily that recovery is not
really implemented, yet the existing code adds complexity on the clients
and servers. Without proper recovery, the current code risks file data
loss if the SOM data isn't updated on the MDS consistently with data
writes to the OST.


We're planning to remove the SOM code from the master branch as a result,
tracked under https://jira.hpdd.intel.com/browse/LU-6047:
- http://review.whamcloud.com/13126
- http://review.whamcloud.com/13169
- http://review.whamcloud.com/13442
- http://review.whamcloud.com/13443

Some of the performance improvements of SOM have been implemented by
statahead.

I think a case could be made for a very stripped down SOM to be
implemented in the future, that only deals with single-client writers and
synchronously invalidates the file size on open-for-write, which isn't so
bad with flash storage for the MDT as is typical today.  The size of files
that do not get set at initial write or are invalidated by an open can be
updated asynchronously by LFSCK doing a periodic scan in the background.
Since this stripped-down implementation would have very little to do with
the current implementation, there isn't much benefit to even trying to fix
the current code in place.

I definitely prefer presenting about new features going into Lustre, but I
also think it is important that people are aware when a semi-feature like
this is being removed.  I don't believe that anyone is actually using this
feature today, and the reduction in code maintenance and complexity will
help both ongoing maintenance and bug fixing, as well as make it a that
much easier for new developers to understand the code.

Cheers, Andreas
-- 
Andreas Dilger

Lustre Software Architect
Intel High Performance Data Division
