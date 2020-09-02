From: NeilBrown <neilb@suse.de>
Date: Wed, 02 Sep 2020 10:36:24 +1000
Subject: [lustre-devel] Error checking for llapi_hsm_action_progress().
In-Reply-To: <3df93cf2-1a94-f7bf-e073-29bf0c8c985a@cea.fr>
References: <87pn77qx60.fsf@notabene.neil.brown.name>
 <2659fe05-9cd7-afd3-e1ce-c1726129e354@cea.fr>
 <87mu2aqpnp.fsf@notabene.neil.brown.name>
 <3df93cf2-1a94-f7bf-e073-29bf0c8c985a@cea.fr>
Message-ID: <87imcxxbef.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Sep 01 2020, quentin.bouget at cea.fr wrote:
>
> Ideally, there would be a standard data structure that automatically 
> merges overlapping/contiguous extents.
> But I don't know any, and I don't think it is worth coding one from scratch.
>

An interval tree is close enough that it would take .. uhmm....

 while ((overlap = interval_iter_first(
                        &crp->crp_root,
 			node->start == 0 ? 0 : node->start - 1,
                        node->end == LUSTRE_EOF ? LUSTRE_EOF : node->end + 1))
        != NULL) {
	node->start = min(node->start, overlap->start);
        node->end = max(node->end, overlap->end);
        interval_remove(node, &crp->crp_root);
 }
 interval_insert(node, &crp->crp_root);

... 10 lines of code to merge overlapping regions.

Maybe I'll do that.

I get the general impression that while people don't see it as very
important to keep track of the reported ranges, they would probably feel
a little happier if we kept track than if we didn't.
Reporting errors on overlaps is definitely out, but merging overlaps
is widely seen as sensible.

Thanks everyone for the feedback.

NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 853 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20200902/5a48ce37/attachment.sig>
