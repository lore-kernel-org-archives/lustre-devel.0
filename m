From: James Simmons <jsimmons@infradead.org>
Date: Sat, 20 Oct 2018 17:47:44 +0100 (BST)
Subject: [lustre-devel] [PATCH 14/24] lustre: lnet: reference counts on
 lnet_peer/lnet_peer_net
In-Reply-To: <87o9btduf0.fsf@notabene.neil.brown.name>
References: <153895417139.16383.3791701638653772865.stgit@noble>
 <153895437808.16383.1725584261522697360.stgit@noble>
 <alpine.LFD.2.21.1810142338510.9543@casper.infradead.org>
 <87o9btduf0.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1810201737280.16676@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Sun, Oct 14 2018, James Simmons wrote:
> 
> >> From: Olaf Weber <olaf@sgi.com>
> >> 
> >> Peer discovery will be keeping track of lnet_peer structures,
> >> so there will be references to an lnet_peer independent of
> >> the references implied by lnet_peer_ni structures. Manage
> >> this by adding explicit reference counts to lnet_peer_net and
> >> lnet_peer.
> >> 
> >> Each lnet_peer_net has a hold on the lnet_peer it links to
> >> with its lpn_peer pointer. This hold is only removed when that
> >> pointer is assigned a new value or the lnet_peer_net is freed.
> >> Just removing an lnet_peer_net from the lp_peer_nets list does
> >> not release this hold, it just prevents new lookups of the
> >> lnet_peer_net via the lnet_peer.
> >> 
> >> Each lnet_peer_ni has a hold on the lnet_peer_net it links to
> >> with its lpni_peer_net pointer. This hold is only removed when
> >> that pointer is assigned a new value or the lnet_peer_ni is
> >> freed. Just removing an lnet_peer_ni from the lpn_peer_nis
> >> list does not release this hold, it just prevents new lookups
> >> of the lnet_peer_ni via the lnet_peer_net.
> >> 
> >> This ensures that given a lnet_peer_ni *lpni, we can rely on
> >> lpni->lpni_peer_net->lpn_peer pointing to a valid lnet_peer.
> >> 
> >> Keep a count of the total number of lnet_peer_ni attached to
> >> an lnet_peer in lp_nnis.
> >> 
> >> Split the global ln_peers list into per-lnet_peer_table lists.
> >> The CPT of the peer table in which the lnet_peer is linked is
> >> stored in lp_cpt.
> >> 
> >> WC-bug-id: https://jira.whamcloud.com/browse/LU-9480
> >> Signed-off-by: Olaf Weber <olaf@sgi.com>
> >> Reviewed-on: https://review.whamcloud.com/25784
> >> Reviewed-by: Olaf Weber <olaf.weber@hpe.com>
> >> Reviewed-by: Amir Shehata <amir.shehata@intel.com>
> >> Tested-by: Amir Shehata <amir.shehata@intel.com>
> >> Signed-off-by: NeilBrown <neilb@suse.com>
> >> ---
> >>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |   49 +++--
> >>  .../staging/lustre/include/linux/lnet/lib-types.h  |   50 ++++-
> >>  drivers/staging/lustre/lnet/lnet/api-ni.c          |    1 
> >>  drivers/staging/lustre/lnet/lnet/lib-move.c        |    8 -
> >>  drivers/staging/lustre/lnet/lnet/peer.c            |  210 ++++++++++++++------
> >>  5 files changed, 227 insertions(+), 91 deletions(-)
> >> 
> >> diff --git a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> >> index 563417510722..aad25eb0011b 100644
> >> --- a/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> >> +++ b/drivers/staging/lustre/include/linux/lnet/lib-lnet.h
> >> @@ -310,6 +310,36 @@ lnet_handle2me(struct lnet_handle_me *handle)

.....

> >> +++ b/drivers/staging/lustre/lnet/lnet/peer.c
> >
> > INIT_LIST_HEAD(&ptable->pt_peer_list); seems to be missing from
> > lnet_peer_tables_create(). This is in the patch merged into 
> > lustre-testing. Other than that it looks okay.
> 
> No, it is there. It is just the the lnet_peer_tables_create() has moved,
> so it isn't in the same place in the patch.
> 
> ..snip..
> 
> >> @@ -319,6 +358,8 @@ lnet_peer_tables_create(void)
> >>  		spin_lock_init(&ptable->pt_zombie_lock);
> >>  		INIT_LIST_HEAD(&ptable->pt_zombie_list);
> >>  
> >> +		INIT_LIST_HEAD(&ptable->pt_peer_list);
> >> +
> >>  		for (j = 0; j < LNET_PEER_HASH_SIZE; j++)
> >>  			INIT_LIST_HEAD(&hash[j]);
> >>  		ptable->pt_hash = hash; /* sign of initialization */
> 
> here it is.

Missed it. Thanks.

Reviewed-by: James Simmons <jsimmons@infradead.org>
