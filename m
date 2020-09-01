From: Joseph Benjamin Evans <beevans@whamcloud.com>
Date: Tue, 1 Sep 2020 13:10:04 +0000
Subject: [lustre-devel] Error checking for llapi_hsm_action_progress().
In-Reply-To: <377DBC36-B8E2-478E-BAA8-B59577EC29D2@amazon.com>
References: <87pn77qx60.fsf@notabene.neil.brown.name>
 <DA0C2761-A024-4D7D-8E78-37649812D037@ddn.com>
 <87k0xeqo9u.fsf@notabene.neil.brown.name>
 <377DBC36-B8E2-478E-BAA8-B59577EC29D2@amazon.com>
Message-ID: <8103393F-7BCF-4D50-92AC-A914DE12A63A@ddn.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

If we implement partial restore, there should definitely be code in the coordinator to handle it.  But right now, I don't see anyone working on it.

As to parallel I/O, I know of a few copytools that do that already, and they coordinate among themselves (using MPI or other frameworks) to specify what data gets copied by which clients rather than use Lustre to do it.  To Lustre that should be opaque.

?On 9/1/20, 3:41 AM, "Degremont, Aurelien" <degremoa@amazon.com> wrote:

    My understanding of the different use cases was:
    - Copytool I/O could be done in parallel and acknowledge write range in any order.
    - Having a map of what have been copied and what haven't been was done thinking of implementing partial restore in the future. I'm not sure when this feature will be implemented it will really need this from the coordinator.

    You can verify some existing copytools in case some of them acknowledge I/O with a specific pattern:
    - posix copytool in lustre source
    - S3 copytool Lemur (https://github.com/whamcloud/lemur)
    - TSM copytools (https://github.com/tstibor/ltsm, and Simon linked this one recently: https://github.com/guilbaults/ct_tsm/)

    I would be in favor of not raising an error if acknowledging overlaps an existing extent. 

    Aur?lien

    Le 01/09/2020 03:28, ? lustre-devel au nom de NeilBrown ? <lustre-devel-bounces at lists.lustre.org au nom de neilb@suse.de> a ?crit :

        CAUTION: This email originated from outside of the organization. Do not click links or open attachments unless you can confirm the sender and know the content is safe.



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
        > On 8/31/20, 12:03 AM, "lustre-devel on behalf of NeilBrown" <lustre-devel-bounces at lists.lustre.org on behalf of neilb@suse.de> wrote:
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
