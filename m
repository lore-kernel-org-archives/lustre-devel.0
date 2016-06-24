From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 24 Jun 2016 00:36:33 +0000
Subject: [lustre-devel] HSM issues
In-Reply-To: <CAB_j=McQ3AUyOtSbs2291Fg2RsHc59OGYqhCYo5_uX1dgGasVw@mail.gmail.com>
References: <CAB_j=McQ3AUyOtSbs2291Fg2RsHc59OGYqhCYo5_uX1dgGasVw@mail.gmail.com>
Message-ID: <330D2386-1ACD-40A1-B39C-A5F50556668D@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The ChangeLogs do have limits on the number of records, but hitting that limit will _also_ result in ENOSPC, as would also happen if the MDT actually runs out of space.  Alex has a patch in flight that reduces the maximum llog size if the MDT is running out of space, so that the old logs can be closed and cleaned up rather than continuing to grow even though they are mostly empty.  There was also a patch landed from Artem to add a /proc file that reports the current ChangeLog size to userspace so that this can be tracked.

We did discuss what should happen if the ChangeLog is running out of space for new records (e.g. because some consumer is not consuming).  It should be tunable by the admin, either to drop the consumer and delete all of the records for that consumer, or to prevent new operations being performed in the filesystem (e.g. if it was critical to not lose any records for some reason).  I'd suspect the first option would be the better default.

No idea about the other items.  Hopefully someone else can reply.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel High Performance Data Division

On 2016/06/23, 18:10, "Nathan Rutman" <nathan.rutman at seagate.com<mailto:nathan.rutman@seagate.com>> wrote:

Hi all -
I have a number of nagging concerns about current HSM implementation; maybe I'm just out of date, but I figure this is the place to ask:
1. Changelog size limits. Can changelogs still grow unbounded, resulting in ENOSPC (or worse) on the MDS? Should there be a size limit? What should be done at that limit -- stop recording changelogs? Turn FS read-only?
2. Coordinator queue limit. Can coordinator queue grow unbounded? Can we add some throttling from the coordinator to the PE, maybe an -EAGAIN if the coordinator queue is large?
3. Error-condition passthrough from hsmtool back to PE. Backend may have e.g. ENOSPC, reported back to coordinator, but then what? Can future PE requests be denied by the coordinator with an ENOSPC, presumably prompting Robinhood to issue hsm_remove commands? ENOSPC should continue to be returned, until some other rv is returned by copytool.
4. Coordinator should sort incoming requests so that "restores" and "removes" are placed before "archives". Restores are the highest priority from user point of view, and removes are next from a space available point of view.

--
Nathan Rutman ? Principal Systems Architect
Seagate Technology ? +1 503 877-9507 ? GMT-8
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160624/f582d4ba/attachment-0001.htm>
