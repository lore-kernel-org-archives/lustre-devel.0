From: James Simmons <jsimmons@infradead.org>
Date: Sun, 30 Sep 2018 03:17:45 +0100 (BST)
Subject: [lustre-devel] [PATCH 00/34] lustre: remainder of multi-rail
 series.
In-Reply-To: <153783752960.32103.8394391715843917125.stgit@noble>
References: <153783752960.32103.8394391715843917125.stgit@noble>
Message-ID: <alpine.LFD.2.21.1809300305290.25547@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> Hi,
>  following is the remainder of the Multi-Rail series, ported
>  to drivers/staging.
>  The previous series was only the first patch from upstream.
>  This series is mostly the individual patches from upstream,
>  though I did split some up a bit, and merged at least one bugfix back
>  to where the bug was introduced.
> 
>  Comments, review, and explanations of bits I didn't understand, are
>  most welcome.  I confess that I haven't looked at the code very
>  closely, just a superficially scan for things that look odd (there
>  weren't many).

Thanks for doing this. It makes my life easier. With the patches:

lustre: lnet: copy the correct amount of cpts to lnet_cpts
lustre: lnd: resolve IP query code in LND drivers

and the fixup in patch 11 it runs flawless in my testing. I do recommend
land the two above patches first so no git bisect will end up blowing up
someones nodes :-)

Just have a bunch of commit recommendations. I noticed some MR patches
landed to the main lustre branch. Perhaps those should be fixed as well.
The only reason I ask is that I worry about kernel developers might not
like that style of commit messages. In the past Greg pointed such things
out to me. Thanks for hearing me out about that concern.

I will poke Doug about looking at some of the commit messages you had
concern about. 

> Thanks,
> NeilBrown
> 
> ---
> 
> Amir Shehata (22):
>       LU-7734 lnet: Multi-Rail peer split
>       LU-7734 lnet: Multi-Rail local_ni/peer_ni selection
>       LU-7734 lnet: configure peers from DLC
>       LU-7734 lnet: configure local NI from DLC
>       LU-7734 lnet: NUMA support
>       LU-7734 lnet: Primary NID and traffic distribution
>       LU-7734 lnet: handle non-MR peers
>       LU-7734 lnet: handle N NIs to 1 LND peer
>       LU-7734 lnet: rename LND peer to peer_ni
>       LU-7734 lnet: peer/peer_ni handling adjustments
>       LU-7734 lnet: proper cpt locking
>       LU-7734 lnet: protect peer_ni credits
>       LU-7734 lnet: simplify and fix lnet_select_pathway()
>       LU-7734 lnet: configuration fixes
>       LU-7734 lnet: fix lnet_select_pathway()
>       LU-7734 lnet: Routing fixes part 1
>       LU-7734 lnet: Routing fixes part 2
>       LU-7734 lnet: fix routing selection
>       LU-7734 lnet: Fix crash in router_proc.c
>       LU-7734 lnet: fix NULL access in lnet_peer_aliveness_enabled
>       LU-7734 lnet: rename peer key_nid to prim_nid
>       LU-7734 lnet: cpt locking
> 
> Doug Oucharek (1):
>       LU-7734 lnet: Add peer_ni and NI stats for DLC
> 
> NeilBrown (8):
>       lnet: replace all lp_ fields with lpni_
>       lnet: change struct lnet_peer to struct lnet_peer_ni
>       lnet: Change lpni_refcount to atomic_t
>       lnet: change some function names - add 'ni'.
>       lnet: make lnet_nid_cpt_hash non-static.
>       lnet: introduce lnet_find_peer_ni_locked()
>       lnet: lnet_peer_tables_cleanup: use an exclusive lock.
>       lnet: use BIT() macro for LNET_MD_* flags
> 
> Olaf Weber (3):
>       LU-7734 lnet: fix lnet_peer_table_cleanup_locked()
>       LU-7734 lnet: double free in lnet_add_net_common()
>       LU-7734 lnet: set primary NID in ptlrpc_connection_get()
> 
> 
>  .../lustre/include/linux/libcfs/libcfs_string.h    |   12 
>  drivers/staging/lustre/include/linux/lnet/api.h    |    1 
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |  151 ++-
>  .../staging/lustre/include/linux/lnet/lib-types.h  |  157 ++-
>  .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |   11 
>  .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |  104 ++
>  .../lustre/include/uapi/linux/lnet/lnet-types.h    |   34 -
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  237 ++--
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  118 +-
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c |  516 ++++-----
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  678 ++++++------
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   66 +
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  207 ++--
>  .../lustre/lnet/klnds/socklnd/socklnd_lib.c        |    4 
>  .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   14 
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |  650 ++++++++++-
>  drivers/staging/lustre/lnet/lnet/config.c          |  107 +-
>  drivers/staging/lustre/lnet/lnet/lib-md.c          |   31 +
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |  957 +++++++++++++---
>  drivers/staging/lustre/lnet/lnet/lib-msg.c         |   18 
>  drivers/staging/lustre/lnet/lnet/lib-ptl.c         |    3 
>  drivers/staging/lustre/lnet/lnet/module.c          |   70 +
>  drivers/staging/lustre/lnet/lnet/peer.c            | 1169 +++++++++++++++++---
>  drivers/staging/lustre/lnet/lnet/router.c          |  341 +++---
>  drivers/staging/lustre/lnet/lnet/router_proc.c     |   66 +
>  drivers/staging/lustre/lustre/include/lustre_net.h |    2 
>  drivers/staging/lustre/lustre/ptlrpc/connection.c  |    1 
>  drivers/staging/lustre/lustre/ptlrpc/events.c      |    5 
>  drivers/staging/lustre/lustre/ptlrpc/niobuf.c      |   40 -
>  drivers/staging/lustre/lustre/ptlrpc/ptlrpcd.c     |    2 
>  drivers/staging/lustre/lustre/ptlrpc/service.c     |    4 
>  31 files changed, 4056 insertions(+), 1720 deletions(-)
> 
> --
> Signature
> 
> 
