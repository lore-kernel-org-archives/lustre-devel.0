From: NeilBrown <neilb@suse.com>
Date: Thu, 27 Sep 2018 11:19:08 +1000
Subject: [lustre-devel] [PATCH 00/25] lustre: lnet: remaining fixes for
 multi-rail
In-Reply-To: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
References: <1537930097-11624-1-git-send-email-jsimmons@infradead.org>
Message-ID: <87o9cjhh4j.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Sep 25 2018, James Simmons wrote:

> This is the remaining patches to land to 2.10 to resolve issues
> found in MR testing. These patches are based on lustre-testing
> commit 18c9cf20ec376d5b3d432aa3923645a12636d14b. A few fixes for
> o2iblnd is also pushed.

Thanks.
I've applied this, making a couple of little changes I suggested
in response to individual patches.

NeilBrown


>
> Amir Shehata (10):
>   lustre: lnet: Normalize ioctl interface
>   lustre: lnet: selftest MR fix
>   lustre: lnet: prevent assert on ln_state
>   lustre: lnet: increment per NI stats
>   lustre: lnet: correct locking in legacy add net
>   lustre: lnet: fix lnet_cpt_of_md()
>   lustre: lnet: safe access to msg
>   lustre: lnet: handle empty CPTs
>   lustre: lnet: set LND tunables properly
>   lustre: lnd: pending transmits dropped silently
>
> Dmitry Eremin (1):
>   lustre: lnet: Fix lost lock
>
> Doug Oucharek (4):
>   lustre: lnet: Allow min stats to be reset in peers and nis
>   lustre: lnd: Turn on 2 sges by default
>   lustre: lnd: Don't Assert On Reconnect with MultiQP
>   lustre: lnd: Don't Page Align remote_addr with FastReg
>
> John L. Hammond (1):
>   lustre: ko2iblnd: allow for discontiguous fragments
>
> Liang Zhen (1):
>   lustre: o2iblnd: multiple sges for work request
>
> Olaf Weber (5):
>   lustre: lnet: remove debug ioctl
>   lustre: lnet: fix race in lnet shutdown path
>   lustre: lnet: loopback NID in lnet_select_pathway()
>   lustre: lnet: rename LNET_MAX_INTERFACES
>   lustre: socklnd: propagate errors on send failure
>
> Sergey Cheremencev (3):
>   lustre: lnet: remove ni from lnet_finalize
>   lustre: o2iblnd: reconnect peer for REJ_INVALID_SERVICE_ID
>   lustre: o2iblnd: kill timedout txs from ibp_tx_queue
>
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |  12 +-
>  .../staging/lustre/include/linux/lnet/lib-types.h  |  11 +-
>  .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |   3 +-
>  .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |  67 ++++---
>  .../lustre/include/uapi/linux/lnet/lnet-types.h    |   2 +-
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |  79 ++++++--
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  11 +-
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 212 +++++++++++----------
>  .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |  11 +-
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |  61 ++++--
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |   8 +-
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |  21 +-
>  .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |   4 +-
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |  69 +++----
>  drivers/staging/lustre/lnet/lnet/config.c          |  10 +-
>  drivers/staging/lustre/lnet/lnet/lib-md.c          |  96 ++++++++--
>  drivers/staging/lustre/lnet/lnet/lib-move.c        | 100 ++++++----
>  drivers/staging/lustre/lnet/lnet/lib-msg.c         |  10 +-
>  drivers/staging/lustre/lnet/lnet/lib-ptl.c         |   4 +-
>  drivers/staging/lustre/lnet/lnet/lo.c              |   4 +-
>  drivers/staging/lustre/lnet/lnet/net_fault.c       |   2 +-
>  drivers/staging/lustre/lnet/lnet/peer.c            |  60 +++---
>  drivers/staging/lustre/lnet/lnet/router.c          |   6 +-
>  drivers/staging/lustre/lnet/lnet/router_proc.c     |  69 ++++++-
>  drivers/staging/lustre/lnet/selftest/rpc.c         |   2 +-
>  25 files changed, 593 insertions(+), 341 deletions(-)
>
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180927/f658dfe7/attachment-0001.sig>
