From: quentin.bouget at cea.fr <quentin.bouget@cea.fr>
Date: Mon, 31 Aug 2020 14:53:31 +0200
Subject: [lustre-devel] Error checking for llapi_hsm_action_progress().
In-Reply-To: <87pn77qx60.fsf@notabene.neil.brown.name>
References: <87pn77qx60.fsf@notabene.neil.brown.name>
Message-ID: <2659fe05-9cd7-afd3-e1ce-c1726129e354@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Neil,


On 31/08/2020 06:03, NeilBrown wrote:
> I have a question about llapi_hsm_action_progress().  The documentation
> says that every interval sent "must" be unique, and must not overlap
> (which not exactly the same as 'unique').  The code (on server side)
> only partially enforces this.  It causes any request for an empty
> interval (start>end) to fail, but otherwise accepts any interval.  If it
> gets two identical intervals (not just overlapping, but identical), it
> ignores the second.  This seems weird.
>
> It would make some sense to just accept any interval - all it does is
> sum the lengths, and use this to report status, so no corruption would
> result.  It would also make sense to return an error if an interval
> overlaps any previous interval, as this violates the spec.  It might
> make sense to accept any interval, but only count the overlapped length
> once.  But the current behaviour of only ignoring exact duplicates is
> weird.  I tried removing that check, but there is a test (hsm_test 108)
> which checks for repeating identical intervals.

test108 handles a "growing" extent (offset=0, length=1, 2, 3, ...).
test112 handles acknowledging non-overlapping extents twice each.

I wrote a test to check what happens if you acknowledge overlapping extents:

  * (offset=0, length=256)
  * (offset=128, length=256)

And surely enough mdt_cdt_get_work_done() returns "512" rather than the 
expected "384" (ie. 128 + 256).

Even worse, when acknowledging a "shrinking" extent (offset=0, length=N, 
N - 1, N - 2, ...), only the last value is kept in store.

 From this, I think that exact duplicates are not really ignored, 
rather, intervals that share the same starting point overwrite one 
another, until only the last one remains.
Bug or feature? I don't really know.


> I want to clean up this code as I'm converting all users of the lustre
> interval-tree to use the upstream-linux interval tree code.  What should
> I do?
>
> Should I remove test 108 because it is only testing one particular
> corner case, or should I improve the code to handle all overlaps
> consistently?  Would it be OK to fail an overlap (I'd need to change
> test 108), it must they be quietly accepted?

How does the upstream-linux interval tree compares to Lustre's?

If their behaviours match, there should not be any issue (so far as the 
current behaviour can be considered issue-free).

Otherwise, I think it would be OK to just assume sending overlapping 
extents is a programming error and the server does not need to protect 
itself against it.
In terms of security, this isn't very good, but the problem already 
exists, and copytools are supposedly trusted binaries run as root.
You could then remove test108 as it is itself a programming error, 
test112 as well, and maybe others.

Just to be sure, you could open a new issue on Jira, and let others rule 
how much of a bug/feature the whole thing is.

Cheers,
Quentin

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200831/dc117d63/attachment.html>
