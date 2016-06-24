From: Nathan Rutman <nathan.rutman@seagate.com>
Date: Thu, 23 Jun 2016 17:10:48 -0700
Subject: [lustre-devel] HSM issues
Message-ID: <CAB_j=McQ3AUyOtSbs2291Fg2RsHc59OGYqhCYo5_uX1dgGasVw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi all -
I have a number of nagging concerns about current HSM implementation; maybe
I'm just out of date, but I figure this is the place to ask:
1. Changelog size limits. Can changelogs still grow unbounded, resulting in
ENOSPC (or worse) on the MDS? Should there be a size limit? What should be
done at that limit -- stop recording changelogs? Turn FS read-only?
2. Coordinator queue limit. Can coordinator queue grow unbounded? Can we
add some throttling from the coordinator to the PE, maybe an -EAGAIN if the
coordinator queue is large?
3. Error-condition passthrough from hsmtool back to PE. Backend may have
e.g. ENOSPC, reported back to coordinator, but then what? Can future PE
requests be denied by the coordinator with an ENOSPC, presumably prompting
Robinhood to issue hsm_remove commands? ENOSPC should continue to be
returned, until some other rv is returned by copytool.
4. Coordinator should sort incoming requests so that "restores" and
"removes" are placed before "archives". Restores are the highest priority
from user point of view, and removes are next from a space available point
of view.

*--*

*Nathan Rutman ? Principal Systems ArchitectSeagate Technology** ? *+1 503
877-9507* ? *GMT-8
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160623/b4b32168/attachment.htm>
