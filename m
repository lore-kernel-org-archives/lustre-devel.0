From: Alexey Lyashkov <alexey.lyashkov@seagate.com>
Date: Wed, 11 May 2016 19:32:26 +0300
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: o2iblnd: limit
 cap.max_send_wr for MLX5
In-Reply-To: <1462805628-23403-2-git-send-email-jsimmons@infradead.org>
References: <1462805628-23403-1-git-send-email-jsimmons@infradead.org>
	<1462805628-23403-2-git-send-email-jsimmons@infradead.org>
Message-ID: <CAJ2e-W16tXpkj2bu05T13E_3w-MST01pa=0Rsux-BSUHe3_VKw@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

As Sergey say in original ticket, It patch change system tunable without
any visible effects.
So user will continue to think it uses a max sends XX when system have
change it to some other value.
Let's change CDEBUG(D_NET to warning, or rework a patch.
It patch needs because someone may set max sends over HW card limitation,
so good fix will take config from card and adjust max sends without a loop.


On Mon, May 9, 2016 at 5:53 PM, James Simmons <jsimmons@infradead.org>
wrote:

> From: Dmitry Eremin <dmitry.eremin@intel.com>
>
> Decrease cap.max_send_wr until it is accepted by rdma_create_qp()
>
> Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7124
> Reviewed-on: http://review.whamcloud.com/18347
> Reviewed-by: Olaf Weber <olaf@sgi.com>
> Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   11 ++++++++++-
>  1 files changed, 10 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> index d99b4fa..bc179a2 100644
> --- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> +++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
> @@ -768,7 +768,12 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer,
> struct rdma_cm_id *cmid,
>
>         conn->ibc_sched = sched;
>
> -       rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, init_qp_attr);
> +       do {
> +               rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd,
> init_qp_attr);
> +               if (!rc || init_qp_attr->cap.max_send_wr < 16)
> +                       break;
> +       } while (rc);
> +
>         if (rc) {
>                 CERROR("Can't create QP: %d, send_wr: %d, recv_wr: %d\n",
>                        rc, init_qp_attr->cap.max_send_wr,
> @@ -776,6 +781,10 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer,
> struct rdma_cm_id *cmid,
>                 goto failed_2;
>         }
>
> +       if (init_qp_attr->cap.max_send_wr != IBLND_SEND_WRS(conn))
> +               CDEBUG(D_NET, "original send wr %d, created with %d\n",
> +                      IBLND_SEND_WRS(conn),
> init_qp_attr->cap.max_send_wr);
> +
>         LIBCFS_FREE(init_qp_attr, sizeof(*init_qp_attr));
>
>         /* 1 ref for caller and each rxmsg */
> --
> 1.7.1
>
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
>



-- 
Alexey Lyashkov *?* Technical lead for a Morpheus team
Seagate Technology, LLC
www.seagate.com
www.lustre.org
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160511/042f00c5/attachment.htm>
