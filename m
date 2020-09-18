From: Nathan Rutman <nrutman@gmail.com>
Date: Fri, 18 Sep 2020 10:33:46 -0700
Subject: [lustre-devel] Error checking for llapi_hsm_action_progress().
Message-ID: <CAA4iDz6wy1J+qv3WA4NtYSLWD0zMHTxTtD9Np3BpDNtfBz4MQA@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As I've presented before, I really think Lustre should get out of the
business of tracking HSM requests and progress completely for scalability
reasons. External tools should do their thing, and simply let Lustre know
when to atomically change the file's layout (released, restored, migrated,
mirrored, etc). (All this work is in the "externalized coordinator" and
"hsm as layout" patches up at WC.)

Anyhow, to that end, I vote in favor of resolving by removal this
apparently unused feature. Liblustre could silently drop the extent info
for a trivial "fix".


My understanding of the different use cases was:

- Copytool I/O could be done in parallel and acknowledge write range
in any order.

- Having a map of what have been copied and what haven't been was done
thinking of implementing partial restore in the future. I'm not sure
when this feature will be implemented it will really need this from
the coordinator.

You can verify some existing copytools in case some of them
acknowledge I/O with a specific pattern:

- posix copytool in lustre source

- S3 copytool Lemur (https://github.com/whamcloud/lemur)

- TSM copytools (https://github.com/tstibor/ltsm, and Simon linked
this one recently: https://github.com/guilbaults/ct_tsm/)

I would be in favor of not raising an error if acknowledging overlaps
an existing extent.

Aur?lien

?Le 01/09/2020 03:28, ? lustre-devel au nom de NeilBrown ?
<lustre-devel-bounces@lists.lustre.org
<http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org> au nom
de neilb at suse.de
<http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>> a
?crit :

    CAUTION: This email originated from outside of the organization.
Do not click links or open attachments unless you can confirm the
sender and know the content is safe.

    "code deleted in code debugged" is my preferred outcome.  I haven't

    heard anyone clamouring to keep the current behaviour, so I'm leaning

    more in that direction.

    Thanks,

    NeilBrown

    On Mon, Aug 31 2020, Joseph Benjamin Evans wrote:

    > I don't think anything is actually monitoring or using the
results of those extents, specifically.  "bytes copied" would be
equally useful to the end user, I'd think.  Others may have better
data on real-world usage, though.  So this might be a "code deleted is
code debugged" situation.

    >

    > -Ben

    >

    > On 8/31/20, 12:03 AM, "lustre-devel on behalf of NeilBrown"
<lustre-devel-bounces@lists.lustre.org
<http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org> on
behalf of neilb at suse.de
<http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>> wrote:

    >

    >

    >

    >     I have a question about llapi_hsm_action_progress().  The
documentation

    >     says that every interval sent "must" be unique, and must not overlap

    >     (which not exactly the same as 'unique').  The code (on server side)

    >     only partially enforces this.  It causes any request for an empty

    >     interval (start>end) to fail, but otherwise accepts any
interval.  If it

    >     gets two identical intervals (not just overlapping, but identical), it

    >     ignores the second.  This seems weird.

    >

    >     It would make some sense to just accept any interval - all it does is

    >     sum the lengths, and use this to report status, so no corruption would

    >     result.  It would also make sense to return an error if an interval

    >     overlaps any previous interval, as this violates the spec.  It might

    >     make sense to accept any interval, but only count the
overlapped length

    >     once.  But the current behaviour of only ignoring exact duplicates is

    >     weird.  I tried removing that check, but there is a test
(hsm_test 108)

    >     which checks for repeating identical intervals.

    >

    >     I want to clean up this code as I'm converting all users of the lustre

    >     interval-tree to use the upstream-linux interval tree code.
What should

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
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200918/36b186f4/attachment-0001.html>
