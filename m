From: NeilBrown <neilb@suse.de>
Date: Tue, 01 Sep 2020 11:27:57 +1000
Subject: [lustre-devel] Error checking for llapi_hsm_action_progress().
In-Reply-To: <DA0C2761-A024-4D7D-8E78-37649812D037@ddn.com>
References: <87pn77qx60.fsf@notabene.neil.brown.name>
 <DA0C2761-A024-4D7D-8E78-37649812D037@ddn.com>
Message-ID: <87k0xeqo9u.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


"code deleted in code debugged" is my preferred outcome.  I haven't
heard anyone clamouring to keep the current behaviour, so I'm leaning
more in that direction.

Thanks,
NeilBrown

On Mon, Aug 31 2020, Joseph Benjamin Evans wrote:

> I don't think anything is actually monitoring or using the results of those extents, specifically.  "bytes copied" would be equally useful to the end user, I'd think.  Others may have better data on real-world usage, though.  So this might be a "code deleted is code debugged" situation.
>
> -Ben
>
> ?On 8/31/20, 12:03 AM, "lustre-devel on behalf of NeilBrown" <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.de> wrote:
>
>
>
>     I have a question about llapi_hsm_action_progress().  The documentation
>     says that every interval sent "must" be unique, and must not overlap
>     (which not exactly the same as 'unique').  The code (on server side)
>     only partially enforces this.  It causes any request for an empty
>     interval (start>end) to fail, but otherwise accepts any interval.  If it
>     gets two identical intervals (not just overlapping, but identical), it
>     ignores the second.  This seems weird.
>
>     It would make some sense to just accept any interval - all it does is
>     sum the lengths, and use this to report status, so no corruption would
>     result.  It would also make sense to return an error if an interval
>     overlaps any previous interval, as this violates the spec.  It might
>     make sense to accept any interval, but only count the overlapped length
>     once.  But the current behaviour of only ignoring exact duplicates is
>     weird.  I tried removing that check, but there is a test (hsm_test 108)
>     which checks for repeating identical intervals.
>
>     I want to clean up this code as I'm converting all users of the lustre
>     interval-tree to use the upstream-linux interval tree code.  What should
>     I do?
>
>     Should I remove test 108 because it is only testing one particular
>     corner case, or should I improve the code to handle all overlaps
>     consistently?  Would it be OK to fail an overlap (I'd need to change
>     test 108), it must they be quietly accepted?
>
>     Thanks,
>     NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200901/a2331e59/attachment.sig>
