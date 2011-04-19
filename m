From: Eric Barton <eeb@whamcloud.com>
Date: Tue, 19 Apr 2011 14:39:57 +0100
Subject: [Lustre-devel] Quota enforcement
Message-ID: <011901cbfe97$46ef3630$d4cda290$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I'd like to take a fresh look at quota enforcement.  I think the
current approach of trying to implement quota purely through POSIX
APIs is flawed, and I'd like to open up a debate on alternatives.

If we go back to first premises, quota enforcement is about resource
management - tracking and enforcing limits on consumption to ensure
some measure of insulation between different users.  In general, when
we have 'n' resources which are all consumed independently we should
also track and enforce limits on each of these independently.

In conventional filesystems the relevant resources are inodes and
blocks - which POSIX quota matches nicely.  Although it may seem to
simplify quota management to equate the POSIX quota inode count with
the MDS's inode count, and the POSIX quota block count with the sum of
all blocks on the OSTs, it ignores the following issues...

1. Block storage on the MDS must be sized to ensure it is not
   exhausted before inodes on the MDS run out.  This requires
   assumptions about the average size of Lustre directories and
   utilisation of extended attributes.

2. Sufficient inodes must be reserved on the OSTs to ensure they are
   not exhausted before block storage.  This requires assumptions
   about the average Lustre file size and number of stripes.

3. Imbalanced OST utilization causes allocation failures while
   resources are still available on other OSTs.

(3) is the most glaringly obvious issue.  It gives you ENOSPACE when
you extend a file if one of the OSTs it's striped over is full.  Very
irritating if 'df' reports that plenty of space is still available and
it's not something the quota system itself can help you avoid.  

In fact quota enforcement currently takes pains to allow quota
utilisation to become imbalanced across OSTs by dynamically
distributing the user's quota to where it's being used.  This comes at
a performance cost as quota nears exhaustion.  Provided the user
operates well within her quota, quota is distributed in large units
with low overhead.  However as she nears her limit, protocol overhead
increases as quota is distributed in successively smaller units to
ensure it is not all consumed prematurely on one OST.

An alternative approach to (3) is to move the usage to where the
resources are - i.e. implement complex/dynamic file layouts that
effectively allow files to grow dynamically into available free space.
This works not just for quota enforcement but for all free space.
However it also comes at the cost of increasing overhead as
space/quota is exhausted.  It's also much harder to implement -
especially for overwriting "holes" rather than simply extending files.

I'd dearly like some surveys of real-world systems to discover exactly
how imbalanced utilisation can really become, both for individual
users and also in aggregate to provide guidance on how to proceed.

I'm leaning towards static quota distribution since that matches the
physical constraints, but it requires much better tools (e.g.  for
rebalancing files and reporting not just utilization totals but also
median/min etc).

Thoughts?

-- 

                Cheers,
                        Eric

Eric Barton
CTO Whamcloud, Inc.
Tel: +44 117 330 1575
Mob: +44 7920 797 273  
