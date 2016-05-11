From: Alexey Lyashkov <alexey.lyashkov@seagate.com>
Date: Wed, 11 May 2016 19:44:55 +0300
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: o2iblnd: limit
 cap.max_send_wr for MLX5
In-Reply-To: <1462805628-23403-2-git-send-email-jsimmons@infradead.org>
References: <1462805628-23403-1-git-send-email-jsimmons@infradead.org>
	<1462805628-23403-2-git-send-email-jsimmons@infradead.org>
Message-ID: <CAJ2e-W3KxFfp=Tm+3NXf78So3BPGftK54Kummg5eoDN7Ya9=JQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Sergey Cheremensev
<https://jira.xyratex.com/secure/ViewProfile.jspa?name=scheremencev>  comment
-

[49672.067906] mlx5_ib:mlx5_0:calc_sq_size:485:(pid 8297): wqe_size 192

[49672.067908] mlx5_ib:mlx5_0:calc_sq_size:507:(pid 8297): wqe
count(65536) exceeds limits(16384)
[49672.067910] mlx5_ib:mlx5_0:create_kernel_qp:1051:(pid 8297): err -12

According to above data mlx5 has internal limit for wqe count 16384:

        wq_size = roundup_pow_of_two(attr->cap.max_send_wr * wqe_size);
        qp->sq.wqe_cnt = wq_size / MLX5_SEND_WQE_BB;
        if (qp->sq.wqe_cnt > (1 << MLX5_CAP_GEN(dev->mdev, log_max_qp_sz))) {
                mlx5_ib_dbg(dev, "wqe count(%d) exceeds limits(%d)\n",
                            qp->sq.wqe_cnt,
                            1 << MLX5_CAP_GEN(dev->mdev, log_max_qp_sz));
                return -ENOMEM;
        }

So -12(ENOMEM) in message "Can't create QP" doesn't point to any problems
with free memory in the system.
Imo better error code here is -EINVAL.
It seems peer_credits==16 is the maximum value that is supported by mlx5.

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
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20160511/823a9059/attachment-0001.htm>
