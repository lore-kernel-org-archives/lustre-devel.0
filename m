From: Doug Oucharek <dougso@me.com>
Date: Fri, 09 Mar 2018 16:34:14 -0800
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: fix race at
 kiblnd_connect_peer
In-Reply-To: <8D09A62F-69B3-48CF-BE9B-D3C1ABB70910@me.com>
References: <8D09A62F-69B3-48CF-BE9B-D3C1ABB70910@me.com>
Message-ID: <072214EC-91AE-4376-87B5-7CE6A19B23F2@me.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, "Drokin, Oleg" <oleg.drokin@intel.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, alexander.boyko@seagate.com
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Please ignore this patch.  Turns out it depends on a series which has not been submitted yet.  I?ll resend this one once all of those are done.

Doug

> On Mar 9, 2018, at 3:29 PM, Doug Oucharek <dougso@me.com> wrote:
> 
> cmid will be destroyed at OFED if kiblnd_cm_callback return error.
> if error happen before the end of kiblnd_connect_peer, it will touch
> destroyed cmid and fail as
> (o2iblnd_cb.c:1315:kiblnd_connect_peer())
>           ASSERTION( cmid->device != ((void *)0) ) failed:
> 
> Signed-off-by: Alexander Boyko <alexander.boyko@seagate.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10015
> Reviewed-by: Alexey Lyashkov <c17817@cray.com>
> Reviewed-by: Doug Oucharek <dougso@me.com>
> Reviewed-by: John L. Hammond <john.hammond@intel.com>
> Signed-off-by: Doug Oucharek <dougso@me.com>
> ---
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c | 18 ++++++++++++------
> 1 file changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> index 6690a6c..080c2a1 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd_cb.c
> @@ -1290,11 +1290,6 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> 		goto failed2;
> 	}
> 
> -	LASSERT(cmid->device);
> -	CDEBUG(D_NET, "%s: connection bound to %s:%pI4h:%s\n",
> -	       libcfs_nid2str(peer->ibp_nid), dev->ibd_ifname,
> -	       &dev->ibd_ifip, cmid->device->name);
> -
> 	return;
> 
> failed2:
> @@ -2996,8 +2991,19 @@ static int kiblnd_resolve_addr(struct rdma_cm_id *cmid,
> 		} else {
> 			rc = rdma_resolve_route(
> 				cmid, *kiblnd_tunables.kib_timeout * 1000);
> -			if (!rc)
> +			if (!rc) {
> +				kib_net_t *net = peer_ni->ibp_ni->ni_data;
> +				kib_dev_t *dev = net->ibn_dev;
> +
> +				CDEBUG(D_NET, "%s: connection bound to "\
> +				       "%s:%pI4h:%s\n",
> +				       libcfs_nid2str(peer_ni->ibp_nid),
> +				       dev->ibd_ifname,
> +				       &dev->ibd_ifip, cmid->device->name);
> +
> 				return 0;
> +			}
> +
> 			/* Can't initiate route resolution */
> 			CERROR("Can't resolve route for %s: %d\n",
> 			       libcfs_nid2str(peer->ibp_nid), rc);
> -- 
> 1.8.3.1
> 
