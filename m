From: James Simmons <jsimmons@infradead.org>
Date: Mon, 15 Oct 2018 00:54:55 +0100 (BST)
Subject: [lustre-devel] [PATCH 00/24] Port Dynamic Discovery to
 drivers/staging
In-Reply-To: <153895417139.16383.3791701638653772865.stgit@noble>
References: <153895417139.16383.3791701638653772865.stgit@noble>
Message-ID: <alpine.LFD.2.21.1810150054240.9543@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> This is a port of the "Dynamic Discovery" series
> (756abb9cf00b936b3..1c45d9051764e0637ba90b3)
> to my mainline-linux-with-lustre tree.
> It is all fairly straight forward, but I don't think I have the
> hardware to testing properly.  And review never hurts.
> 
> This is all in my lustre-testing branch.

Only one patch was incorrect but the verison in lustre-testing is fine.
Testing has shown no problems.
 
> Thanks,
> NeilBrown
> 
> ---
> 
> Amir Shehata (2):
>       lustre: lnet: add enhanced statistics
>       lustre: lnet: show peer state
> 
> John L. Hammond (1):
>       lustre: lnet: balance references in lnet_discover_peer_locked()
> 
> Olaf Weber (20):
>       lustre: lnet: add lnet_interfaces_max tunable
>       lustre: lnet: configure lnet_interfaces_max tunable from dlc
>       lustre: lnet: add struct lnet_ping_buffer
>       lustre: lnet: automatic sizing of router pinger buffers
>       lustre: lnet: add Multi-Rail and Discovery ping feature bits
>       lustre: lnet: add sanity checks on ping-related constants
>       lustre: lnet: cleanup of lnet_peer_ni_addref/decref_locked()
>       lustre: lnet: rename lnet_add/del_peer_ni_to/from_peer()
>       lustre: lnet: refactor lnet_del_peer_ni()
>       lustre: lnet: refactor lnet_add_peer_ni()
>       lustre: lnet: introduce LNET_PEER_MULTI_RAIL flag bit
>       lustre: lnet: preferred NIs for non-Multi-Rail peers
>       lustre: lnet: add LNET_PEER_CONFIGURED flag
>       lustre: lnet: reference counts on lnet_peer/lnet_peer_net
>       lustre: lnet: add msg_type to lnet_event
>       lustre: lnet: add discovery thread
>       lustre: lnet: add the Push target
>       lustre: lnet: implement Peer Discovery
>       lustre: lnet: add "lnetctl peer list"
>       lustre: lnet: add "lnetctl ping" command
> 
> Sonia Sharma (1):
>       lustre: lnet: add "lnetctl discover"
> 
> 
>  .../staging/lustre/include/linux/lnet/lib-lnet.h   |  156 +
>  .../staging/lustre/include/linux/lnet/lib-types.h  |  258 ++
>  .../lustre/include/uapi/linux/lnet/libcfs_ioctl.h  |    8 
>  .../lustre/include/uapi/linux/lnet/lnet-dlc.h      |   10 
>  .../lustre/include/uapi/linux/lnet/lnet-types.h    |   42 
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |    2 
>  .../lustre/lnet/klnds/o2iblnd/o2iblnd_modparams.c  |    2 
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.c    |   22 
>  .../staging/lustre/lnet/klnds/socklnd/socklnd.h    |    4 
>  .../staging/lustre/lnet/klnds/socklnd/socklnd_cb.c |    2 
>  .../lustre/lnet/klnds/socklnd/socklnd_modparams.c  |    2 
>  .../lustre/lnet/klnds/socklnd/socklnd_proto.c      |    4 
>  drivers/staging/lustre/lnet/lnet/api-ni.c          |  907 +++++-
>  drivers/staging/lustre/lnet/lnet/config.c          |   10 
>  drivers/staging/lustre/lnet/lnet/lib-move.c        |  242 +-
>  drivers/staging/lustre/lnet/lnet/lib-msg.c         |   17 
>  drivers/staging/lustre/lnet/lnet/net_fault.c       |    3 
>  drivers/staging/lustre/lnet/lnet/peer.c            | 3002 +++++++++++++++++---
>  drivers/staging/lustre/lnet/lnet/router.c          |  174 +
>  19 files changed, 4056 insertions(+), 811 deletions(-)
> 
> --
> Signature
> 
> 
