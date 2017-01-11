From: Bart Van Assche <bart.vanassche@sandisk.com>
Date: Tue, 10 Jan 2017 16:56:48 -0800
Subject: [lustre-devel] [PATCH 9/9] treewide: Inline ib_dma_map_*() functions
In-Reply-To: <20170111005648.14988-1-bart.vanassche@sandisk.com>
References: <20170111005648.14988-1-bart.vanassche@sandisk.com>
Message-ID: <20170111005648.14988-10-bart.vanassche@sandisk.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Almost all changes in this patch except the removal of local variables
that became superfluous and the actual removal of the ib_dma_map_*()
functions have been generated as follows:

git grep -lE 'ib_(sg_|)dma_' |
  xargs -d\\n \
    sed -i -e 's/\([^[:alnum:]_]\)ib_dma_\([^(]*\)(\&\([^,]\+\),/\1dma_\2(\3.dma_device,/g' \
           -e 's/\([^[:alnum:]_]\)ib_dma_\([^(]*\)(\([^,]\+\),/\1dma_\2(\3->dma_device,/g' \
	   -e 's/ib_sg_dma_\(len\|address\)(\([^,]\+\), /sg_dma_\1(/g'

Signed-off-by: Bart Van Assche <bart.vanassche@sandisk.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Cc: Andreas Dilger <andreas.dilger@intel.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Eric Van Hensbergen <ericvh@gmail.com>
Cc: James Simmons <jsimmons@infradead.org>
Cc: Latchesar Ionkov <lucho@ionkov.net>
Cc: Oleg Drokin <oleg.drokin@intel.com>
Cc: Ron Minnich <rminnich@sandia.gov>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: devel at driverdev.osuosl.org
Cc: linux-nfs at vger.kernel.org
Cc: linux-nvme at lists.infradead.org
Cc: linux-rdma at vger.kernel.org
Cc: lustre-devel at lists.lustre.org
Cc: netdev at vger.kernel.org
Cc: rds-devel at oss.oracle.com
Cc: target-devel at vger.kernel.org
Cc: v9fs-developer at lists.sourceforge.net
---
 drivers/infiniband/core/mad.c                      |  28 +--
 drivers/infiniband/core/rw.c                       |  30 ++-
 drivers/infiniband/core/umem.c                     |   4 +-
 drivers/infiniband/core/umem_odp.c                 |   6 +-
 drivers/infiniband/hw/mlx4/cq.c                    |   2 +-
 drivers/infiniband/hw/mlx4/mad.c                   |  28 +--
 drivers/infiniband/hw/mlx4/mr.c                    |   4 +-
 drivers/infiniband/hw/mlx4/qp.c                    |  10 +-
 drivers/infiniband/hw/mlx5/mr.c                    |   4 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c            |  20 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c            |  22 +--
 drivers/infiniband/ulp/iser/iscsi_iser.c           |   6 +-
 drivers/infiniband/ulp/iser/iser_initiator.c       |  38 ++--
 drivers/infiniband/ulp/iser/iser_memory.c          |  12 +-
 drivers/infiniband/ulp/iser/iser_verbs.c           |   2 +-
 drivers/infiniband/ulp/isert/ib_isert.c            |  60 +++---
 drivers/infiniband/ulp/srp/ib_srp.c                |  50 +++--
 drivers/infiniband/ulp/srpt/ib_srpt.c              |  10 +-
 drivers/nvme/host/rdma.c                           |  22 +--
 drivers/nvme/target/rdma.c                         |  20 +-
 .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h    |  14 +-
 include/rdma/ib_verbs.h                            | 218 ---------------------
 net/9p/trans_rdma.c                                |  12 +-
 net/rds/ib.h                                       |  39 ----
 net/rds/ib_cm.c                                    |  18 +-
 net/rds/ib_fmr.c                                   |  10 +-
 net/rds/ib_frmr.c                                  |   8 +-
 net/rds/ib_rdma.c                                  |   6 +-
 net/rds/ib_recv.c                                  |  14 +-
 net/rds/ib_send.c                                  |  28 +--
 net/sunrpc/xprtrdma/fmr_ops.c                      |   6 +-
 net/sunrpc/xprtrdma/frwr_ops.c                     |   6 +-
 net/sunrpc/xprtrdma/rpc_rdma.c                     |  14 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c         |   4 +-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c            |   8 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c              |  14 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c           |   8 +-
 net/sunrpc/xprtrdma/verbs.c                        |   8 +-
 38 files changed, 275 insertions(+), 538 deletions(-)

diff --git a/drivers/infiniband/core/mad.c b/drivers/infiniband/core/mad.c
index a009f7132c73..2d51f0bdc13f 100644
--- a/drivers/infiniband/core/mad.c
+++ b/drivers/infiniband/core/mad.c
@@ -1152,21 +1152,21 @@ int ib_send_mad(struct ib_mad_send_wr_private *mad_send_wr)
 
 	mad_agent = mad_send_wr->send_buf.mad_agent;
 	sge = mad_send_wr->sg_list;
-	sge[0].addr = ib_dma_map_single(mad_agent->device,
+	sge[0].addr = dma_map_single(mad_agent->device->dma_device,
 					mad_send_wr->send_buf.mad,
 					sge[0].length,
 					DMA_TO_DEVICE);
-	if (unlikely(ib_dma_mapping_error(mad_agent->device, sge[0].addr)))
+	if (unlikely(dma_mapping_error(mad_agent->device->dma_device, sge[0].addr)))
 		return -ENOMEM;
 
 	mad_send_wr->header_mapping = sge[0].addr;
 
-	sge[1].addr = ib_dma_map_single(mad_agent->device,
+	sge[1].addr = dma_map_single(mad_agent->device->dma_device,
 					ib_get_payload(mad_send_wr),
 					sge[1].length,
 					DMA_TO_DEVICE);
-	if (unlikely(ib_dma_mapping_error(mad_agent->device, sge[1].addr))) {
-		ib_dma_unmap_single(mad_agent->device,
+	if (unlikely(dma_mapping_error(mad_agent->device->dma_device, sge[1].addr))) {
+		dma_unmap_single(mad_agent->device->dma_device,
 				    mad_send_wr->header_mapping,
 				    sge[0].length, DMA_TO_DEVICE);
 		return -ENOMEM;
@@ -1189,10 +1189,10 @@ int ib_send_mad(struct ib_mad_send_wr_private *mad_send_wr)
 	}
 	spin_unlock_irqrestore(&qp_info->send_queue.lock, flags);
 	if (ret) {
-		ib_dma_unmap_single(mad_agent->device,
+		dma_unmap_single(mad_agent->device->dma_device,
 				    mad_send_wr->header_mapping,
 				    sge[0].length, DMA_TO_DEVICE);
-		ib_dma_unmap_single(mad_agent->device,
+		dma_unmap_single(mad_agent->device->dma_device,
 				    mad_send_wr->payload_mapping,
 				    sge[1].length, DMA_TO_DEVICE);
 	}
@@ -2191,7 +2191,7 @@ static void ib_mad_recv_done(struct ib_cq *cq, struct ib_wc *wc)
 	mad_priv_hdr = container_of(mad_list, struct ib_mad_private_header,
 				    mad_list);
 	recv = container_of(mad_priv_hdr, struct ib_mad_private, header);
-	ib_dma_unmap_single(port_priv->device,
+	dma_unmap_single(port_priv->device->dma_device,
 			    recv->header.mapping,
 			    mad_priv_dma_size(recv),
 			    DMA_FROM_DEVICE);
@@ -2432,10 +2432,10 @@ static void ib_mad_send_done(struct ib_cq *cq, struct ib_wc *wc)
 	qp_info = send_queue->qp_info;
 
 retry:
-	ib_dma_unmap_single(mad_send_wr->send_buf.mad_agent->device,
+	dma_unmap_single(mad_send_wr->send_buf.mad_agent->device->dma_device,
 			    mad_send_wr->header_mapping,
 			    mad_send_wr->sg_list[0].length, DMA_TO_DEVICE);
-	ib_dma_unmap_single(mad_send_wr->send_buf.mad_agent->device,
+	dma_unmap_single(mad_send_wr->send_buf.mad_agent->device->dma_device,
 			    mad_send_wr->payload_mapping,
 			    mad_send_wr->sg_list[1].length, DMA_TO_DEVICE);
 	queued_send_wr = NULL;
@@ -2853,11 +2853,11 @@ static int ib_mad_post_receive_mads(struct ib_mad_qp_info *qp_info,
 			}
 		}
 		sg_list.length = mad_priv_dma_size(mad_priv);
-		sg_list.addr = ib_dma_map_single(qp_info->port_priv->device,
+		sg_list.addr = dma_map_single(qp_info->port_priv->device->dma_device,
 						 &mad_priv->grh,
 						 mad_priv_dma_size(mad_priv),
 						 DMA_FROM_DEVICE);
-		if (unlikely(ib_dma_mapping_error(qp_info->port_priv->device,
+		if (unlikely(dma_mapping_error(qp_info->port_priv->device->dma_device,
 						  sg_list.addr))) {
 			ret = -ENOMEM;
 			break;
@@ -2878,7 +2878,7 @@ static int ib_mad_post_receive_mads(struct ib_mad_qp_info *qp_info,
 			list_del(&mad_priv->header.mad_list.list);
 			recv_queue->count--;
 			spin_unlock_irqrestore(&recv_queue->lock, flags);
-			ib_dma_unmap_single(qp_info->port_priv->device,
+			dma_unmap_single(qp_info->port_priv->device->dma_device,
 					    mad_priv->header.mapping,
 					    mad_priv_dma_size(mad_priv),
 					    DMA_FROM_DEVICE);
@@ -2917,7 +2917,7 @@ static void cleanup_recv_queue(struct ib_mad_qp_info *qp_info)
 		/* Remove from posted receive MAD list */
 		list_del(&mad_list->list);
 
-		ib_dma_unmap_single(qp_info->port_priv->device,
+		dma_unmap_single(qp_info->port_priv->device->dma_device,
 				    recv->header.mapping,
 				    mad_priv_dma_size(recv),
 				    DMA_FROM_DEVICE);
diff --git a/drivers/infiniband/core/rw.c b/drivers/infiniband/core/rw.c
index dbfd854c32c9..f8aef874f636 100644
--- a/drivers/infiniband/core/rw.c
+++ b/drivers/infiniband/core/rw.c
@@ -178,7 +178,6 @@ static int rdma_rw_init_map_wrs(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
 		struct scatterlist *sg, u32 sg_cnt, u32 offset,
 		u64 remote_addr, u32 rkey, enum dma_data_direction dir)
 {
-	struct ib_device *dev = qp->pd->device;
 	u32 max_sge = dir == DMA_TO_DEVICE ? qp->max_write_sge :
 		      qp->max_read_sge;
 	struct ib_sge *sge;
@@ -208,8 +207,8 @@ static int rdma_rw_init_map_wrs(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
 		rdma_wr->wr.sg_list = sge;
 
 		for (j = 0; j < nr_sge; j++, sg = sg_next(sg)) {
-			sge->addr = ib_sg_dma_address(dev, sg) + offset;
-			sge->length = ib_sg_dma_len(dev, sg) - offset;
+			sge->addr = sg_dma_address(sg) + offset;
+			sge->length = sg_dma_len(sg) - offset;
 			sge->lkey = qp->pd->local_dma_lkey;
 
 			total_len += sge->length;
@@ -235,14 +234,13 @@ static int rdma_rw_init_single_wr(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
 		struct scatterlist *sg, u32 offset, u64 remote_addr, u32 rkey,
 		enum dma_data_direction dir)
 {
-	struct ib_device *dev = qp->pd->device;
 	struct ib_rdma_wr *rdma_wr = &ctx->single.wr;
 
 	ctx->nr_ops = 1;
 
 	ctx->single.sge.lkey = qp->pd->local_dma_lkey;
-	ctx->single.sge.addr = ib_sg_dma_address(dev, sg) + offset;
-	ctx->single.sge.length = ib_sg_dma_len(dev, sg) - offset;
+	ctx->single.sge.addr = sg_dma_address(sg) + offset;
+	ctx->single.sge.length = sg_dma_len(sg) - offset;
 
 	memset(rdma_wr, 0, sizeof(*rdma_wr));
 	if (dir == DMA_TO_DEVICE)
@@ -280,7 +278,7 @@ int rdma_rw_ctx_init(struct rdma_rw_ctx *ctx, struct ib_qp *qp, u8 port_num,
 	struct ib_device *dev = qp->pd->device;
 	int ret;
 
-	ret = ib_dma_map_sg(dev, sg, sg_cnt, dir);
+	ret = dma_map_sg(dev->dma_device, sg, sg_cnt, dir);
 	if (!ret)
 		return -ENOMEM;
 	sg_cnt = ret;
@@ -289,7 +287,7 @@ int rdma_rw_ctx_init(struct rdma_rw_ctx *ctx, struct ib_qp *qp, u8 port_num,
 	 * Skip to the S/G entry that sg_offset falls into:
 	 */
 	for (;;) {
-		u32 len = ib_sg_dma_len(dev, sg);
+		u32 len = sg_dma_len(sg);
 
 		if (sg_offset < len)
 			break;
@@ -319,7 +317,7 @@ int rdma_rw_ctx_init(struct rdma_rw_ctx *ctx, struct ib_qp *qp, u8 port_num,
 	return ret;
 
 out_unmap_sg:
-	ib_dma_unmap_sg(dev, sg, sg_cnt, dir);
+	dma_unmap_sg(dev->dma_device, sg, sg_cnt, dir);
 	return ret;
 }
 EXPORT_SYMBOL(rdma_rw_ctx_init);
@@ -358,12 +356,12 @@ int rdma_rw_ctx_signature_init(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
 		return -EINVAL;
 	}
 
-	ret = ib_dma_map_sg(dev, sg, sg_cnt, dir);
+	ret = dma_map_sg(dev->dma_device, sg, sg_cnt, dir);
 	if (!ret)
 		return -ENOMEM;
 	sg_cnt = ret;
 
-	ret = ib_dma_map_sg(dev, prot_sg, prot_sg_cnt, dir);
+	ret = dma_map_sg(dev->dma_device, prot_sg, prot_sg_cnt, dir);
 	if (!ret) {
 		ret = -ENOMEM;
 		goto out_unmap_sg;
@@ -457,9 +455,9 @@ int rdma_rw_ctx_signature_init(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
 out_free_ctx:
 	kfree(ctx->sig);
 out_unmap_prot_sg:
-	ib_dma_unmap_sg(dev, prot_sg, prot_sg_cnt, dir);
+	dma_unmap_sg(dev->dma_device, prot_sg, prot_sg_cnt, dir);
 out_unmap_sg:
-	ib_dma_unmap_sg(dev, sg, sg_cnt, dir);
+	dma_unmap_sg(dev->dma_device, sg, sg_cnt, dir);
 	return ret;
 }
 EXPORT_SYMBOL(rdma_rw_ctx_signature_init);
@@ -606,7 +604,7 @@ void rdma_rw_ctx_destroy(struct rdma_rw_ctx *ctx, struct ib_qp *qp, u8 port_num,
 		break;
 	}
 
-	ib_dma_unmap_sg(qp->pd->device, sg, sg_cnt, dir);
+	dma_unmap_sg(qp->pd->device->dma_device, sg, sg_cnt, dir);
 }
 EXPORT_SYMBOL(rdma_rw_ctx_destroy);
 
@@ -631,11 +629,11 @@ void rdma_rw_ctx_destroy_signature(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
 		return;
 
 	ib_mr_pool_put(qp, &qp->rdma_mrs, ctx->sig->data.mr);
-	ib_dma_unmap_sg(qp->pd->device, sg, sg_cnt, dir);
+	dma_unmap_sg(qp->pd->device->dma_device, sg, sg_cnt, dir);
 
 	if (ctx->sig->prot.mr) {
 		ib_mr_pool_put(qp, &qp->rdma_mrs, ctx->sig->prot.mr);
-		ib_dma_unmap_sg(qp->pd->device, prot_sg, prot_sg_cnt, dir);
+		dma_unmap_sg(qp->pd->device->dma_device, prot_sg, prot_sg_cnt, dir);
 	}
 
 	ib_mr_pool_put(qp, &qp->sig_mrs, ctx->sig->sig_mr);
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 1e62a5f0cb28..146ebdbd3f7c 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -50,7 +50,7 @@ static void __ib_umem_release(struct ib_device *dev, struct ib_umem *umem, int d
 	int i;
 
 	if (umem->nmap > 0)
-		ib_dma_unmap_sg(dev, umem->sg_head.sgl,
+		dma_unmap_sg(dev->dma_device, umem->sg_head.sgl,
 				umem->npages,
 				DMA_BIDIRECTIONAL);
 
@@ -214,7 +214,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 		sg_list_start = sg;
 	}
 
-	umem->nmap = ib_dma_map_sg_attrs(context->device,
+	umem->nmap = dma_map_sg_attrs(context->device->dma_device,
 				  umem->sg_head.sgl,
 				  umem->npages,
 				  DMA_BIDIRECTIONAL,
diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/core/umem_odp.c
index 6b079a31dced..066628ec6ed0 100644
--- a/drivers/infiniband/core/umem_odp.c
+++ b/drivers/infiniband/core/umem_odp.c
@@ -456,11 +456,11 @@ static int ib_umem_odp_map_dma_single_page(
 		goto out;
 	}
 	if (!(umem->odp_data->dma_list[page_index])) {
-		dma_addr = ib_dma_map_page(dev,
+		dma_addr = dma_map_page(dev->dma_device,
 					   page,
 					   0, PAGE_SIZE,
 					   DMA_BIDIRECTIONAL);
-		if (ib_dma_mapping_error(dev, dma_addr)) {
+		if (dma_mapping_error(dev->dma_device, dma_addr)) {
 			ret = -EFAULT;
 			goto out;
 		}
@@ -645,7 +645,7 @@ void ib_umem_odp_unmap_dma_pages(struct ib_umem *umem, u64 virt,
 
 			WARN_ON(!dma_addr);
 
-			ib_dma_unmap_page(dev, dma_addr, PAGE_SIZE,
+			dma_unmap_page(dev->dma_device, dma_addr, PAGE_SIZE,
 					  DMA_BIDIRECTIONAL);
 			if (dma & ODP_WRITE_ALLOWED_BIT) {
 				struct page *head_page = compound_head(page);
diff --git a/drivers/infiniband/hw/mlx4/cq.c b/drivers/infiniband/hw/mlx4/cq.c
index 6a0fec357dae..138ac59655ab 100644
--- a/drivers/infiniband/hw/mlx4/cq.c
+++ b/drivers/infiniband/hw/mlx4/cq.c
@@ -584,7 +584,7 @@ static void use_tunnel_data(struct mlx4_ib_qp *qp, struct mlx4_ib_cq *cq, struct
 {
 	struct mlx4_ib_proxy_sqp_hdr *hdr;
 
-	ib_dma_sync_single_for_cpu(qp->ibqp.device,
+	dma_sync_single_for_cpu(qp->ibqp.device->dma_device,
 				   qp->sqp_proxy_rcv[tail].map,
 				   sizeof (struct mlx4_ib_proxy_sqp_hdr),
 				   DMA_FROM_DEVICE);
diff --git a/drivers/infiniband/hw/mlx4/mad.c b/drivers/infiniband/hw/mlx4/mad.c
index db564ccc0f92..221fe481e6f7 100644
--- a/drivers/infiniband/hw/mlx4/mad.c
+++ b/drivers/infiniband/hw/mlx4/mad.c
@@ -582,7 +582,7 @@ int mlx4_ib_send_to_slave(struct mlx4_ib_dev *dev, int slave, u8 port,
 	if (tun_qp->tx_ring[tun_tx_ix].ah)
 		ib_destroy_ah(tun_qp->tx_ring[tun_tx_ix].ah);
 	tun_qp->tx_ring[tun_tx_ix].ah = ah;
-	ib_dma_sync_single_for_cpu(&dev->ib_dev,
+	dma_sync_single_for_cpu(dev->ib_dev.dma_device,
 				   tun_qp->tx_ring[tun_tx_ix].buf.map,
 				   sizeof (struct mlx4_rcv_tunnel_mad),
 				   DMA_TO_DEVICE);
@@ -624,7 +624,7 @@ int mlx4_ib_send_to_slave(struct mlx4_ib_dev *dev, int slave, u8 port,
 		tun_mad->hdr.slid_mac_47_32 = cpu_to_be16(wc->slid);
 	}
 
-	ib_dma_sync_single_for_device(&dev->ib_dev,
+	dma_sync_single_for_device(dev->ib_dev.dma_device,
 				      tun_qp->tx_ring[tun_tx_ix].buf.map,
 				      sizeof (struct mlx4_rcv_tunnel_mad),
 				      DMA_TO_DEVICE);
@@ -1321,7 +1321,7 @@ static int mlx4_ib_post_pv_qp_buf(struct mlx4_ib_demux_pv_ctx *ctx,
 	recv_wr.num_sge = 1;
 	recv_wr.wr_id = (u64) index | MLX4_TUN_WRID_RECV |
 		MLX4_TUN_SET_WRID_QPN(tun_qp->proxy_qpt);
-	ib_dma_sync_single_for_device(ctx->ib_dev, tun_qp->ring[index].map,
+	dma_sync_single_for_device(ctx->ib_dev->dma_device, tun_qp->ring[index].map,
 				      size, DMA_FROM_DEVICE);
 	return ib_post_recv(tun_qp->qp, &recv_wr, &bad_recv_wr);
 }
@@ -1412,14 +1412,14 @@ int mlx4_ib_send_to_wire(struct mlx4_ib_dev *dev, int slave, u8 port,
 	if (sqp->tx_ring[wire_tx_ix].ah)
 		ib_destroy_ah(sqp->tx_ring[wire_tx_ix].ah);
 	sqp->tx_ring[wire_tx_ix].ah = ah;
-	ib_dma_sync_single_for_cpu(&dev->ib_dev,
+	dma_sync_single_for_cpu(dev->ib_dev.dma_device,
 				   sqp->tx_ring[wire_tx_ix].buf.map,
 				   sizeof (struct mlx4_mad_snd_buf),
 				   DMA_TO_DEVICE);
 
 	memcpy(&sqp_mad->payload, mad, sizeof *mad);
 
-	ib_dma_sync_single_for_device(&dev->ib_dev,
+	dma_sync_single_for_device(dev->ib_dev.dma_device,
 				      sqp->tx_ring[wire_tx_ix].buf.map,
 				      sizeof (struct mlx4_mad_snd_buf),
 				      DMA_TO_DEVICE);
@@ -1504,7 +1504,7 @@ static void mlx4_ib_multiplex_mad(struct mlx4_ib_demux_pv_ctx *ctx, struct ib_wc
 	}
 
 	/* Map transaction ID */
-	ib_dma_sync_single_for_cpu(ctx->ib_dev, tun_qp->ring[wr_ix].map,
+	dma_sync_single_for_cpu(ctx->ib_dev->dma_device, tun_qp->ring[wr_ix].map,
 				   sizeof (struct mlx4_tunnel_mad),
 				   DMA_FROM_DEVICE);
 	switch (tunnel->mad.mad_hdr.method) {
@@ -1627,11 +1627,11 @@ static int mlx4_ib_alloc_pv_bufs(struct mlx4_ib_demux_pv_ctx *ctx,
 		tun_qp->ring[i].addr = kmalloc(rx_buf_size, GFP_KERNEL);
 		if (!tun_qp->ring[i].addr)
 			goto err;
-		tun_qp->ring[i].map = ib_dma_map_single(ctx->ib_dev,
+		tun_qp->ring[i].map = dma_map_single(ctx->ib_dev->dma_device,
 							tun_qp->ring[i].addr,
 							rx_buf_size,
 							DMA_FROM_DEVICE);
-		if (ib_dma_mapping_error(ctx->ib_dev, tun_qp->ring[i].map)) {
+		if (dma_mapping_error(ctx->ib_dev->dma_device, tun_qp->ring[i].map)) {
 			kfree(tun_qp->ring[i].addr);
 			goto err;
 		}
@@ -1643,11 +1643,11 @@ static int mlx4_ib_alloc_pv_bufs(struct mlx4_ib_demux_pv_ctx *ctx,
 		if (!tun_qp->tx_ring[i].buf.addr)
 			goto tx_err;
 		tun_qp->tx_ring[i].buf.map =
-			ib_dma_map_single(ctx->ib_dev,
+			dma_map_single(ctx->ib_dev->dma_device,
 					  tun_qp->tx_ring[i].buf.addr,
 					  tx_buf_size,
 					  DMA_TO_DEVICE);
-		if (ib_dma_mapping_error(ctx->ib_dev,
+		if (dma_mapping_error(ctx->ib_dev->dma_device,
 					 tun_qp->tx_ring[i].buf.map)) {
 			kfree(tun_qp->tx_ring[i].buf.addr);
 			goto tx_err;
@@ -1664,7 +1664,7 @@ static int mlx4_ib_alloc_pv_bufs(struct mlx4_ib_demux_pv_ctx *ctx,
 tx_err:
 	while (i > 0) {
 		--i;
-		ib_dma_unmap_single(ctx->ib_dev, tun_qp->tx_ring[i].buf.map,
+		dma_unmap_single(ctx->ib_dev->dma_device, tun_qp->tx_ring[i].buf.map,
 				    tx_buf_size, DMA_TO_DEVICE);
 		kfree(tun_qp->tx_ring[i].buf.addr);
 	}
@@ -1674,7 +1674,7 @@ static int mlx4_ib_alloc_pv_bufs(struct mlx4_ib_demux_pv_ctx *ctx,
 err:
 	while (i > 0) {
 		--i;
-		ib_dma_unmap_single(ctx->ib_dev, tun_qp->ring[i].map,
+		dma_unmap_single(ctx->ib_dev->dma_device, tun_qp->ring[i].map,
 				    rx_buf_size, DMA_FROM_DEVICE);
 		kfree(tun_qp->ring[i].addr);
 	}
@@ -1704,13 +1704,13 @@ static void mlx4_ib_free_pv_qp_bufs(struct mlx4_ib_demux_pv_ctx *ctx,
 
 
 	for (i = 0; i < MLX4_NUM_TUNNEL_BUFS; i++) {
-		ib_dma_unmap_single(ctx->ib_dev, tun_qp->ring[i].map,
+		dma_unmap_single(ctx->ib_dev->dma_device, tun_qp->ring[i].map,
 				    rx_buf_size, DMA_FROM_DEVICE);
 		kfree(tun_qp->ring[i].addr);
 	}
 
 	for (i = 0; i < MLX4_NUM_TUNNEL_BUFS; i++) {
-		ib_dma_unmap_single(ctx->ib_dev, tun_qp->tx_ring[i].buf.map,
+		dma_unmap_single(ctx->ib_dev->dma_device, tun_qp->tx_ring[i].buf.map,
 				    tx_buf_size, DMA_TO_DEVICE);
 		kfree(tun_qp->tx_ring[i].buf.addr);
 		if (tun_qp->tx_ring[i].ah)
diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index 5d73989d9771..89297b832a9f 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -538,12 +538,12 @@ int mlx4_ib_map_mr_sg(struct ib_mr *ibmr, struct scatterlist *sg, int sg_nents,
 
 	mr->npages = 0;
 
-	ib_dma_sync_single_for_cpu(ibmr->device, mr->page_map,
+	dma_sync_single_for_cpu(ibmr->device->dma_device, mr->page_map,
 				   mr->page_map_size, DMA_TO_DEVICE);
 
 	rc = ib_sg_to_pages(ibmr, sg, sg_nents, sg_offset, mlx4_set_page);
 
-	ib_dma_sync_single_for_device(ibmr->device, mr->page_map,
+	dma_sync_single_for_device(ibmr->device->dma_device, mr->page_map,
 				      mr->page_map_size, DMA_TO_DEVICE);
 
 	return rc;
diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index c068add8838b..a8c4ef02aef1 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -570,10 +570,10 @@ static int alloc_proxy_bufs(struct ib_device *dev, struct mlx4_ib_qp *qp)
 		if (!qp->sqp_proxy_rcv[i].addr)
 			goto err;
 		qp->sqp_proxy_rcv[i].map =
-			ib_dma_map_single(dev, qp->sqp_proxy_rcv[i].addr,
+			dma_map_single(dev->dma_device, qp->sqp_proxy_rcv[i].addr,
 					  sizeof (struct mlx4_ib_proxy_sqp_hdr),
 					  DMA_FROM_DEVICE);
-		if (ib_dma_mapping_error(dev, qp->sqp_proxy_rcv[i].map)) {
+		if (dma_mapping_error(dev->dma_device, qp->sqp_proxy_rcv[i].map)) {
 			kfree(qp->sqp_proxy_rcv[i].addr);
 			goto err;
 		}
@@ -583,7 +583,7 @@ static int alloc_proxy_bufs(struct ib_device *dev, struct mlx4_ib_qp *qp)
 err:
 	while (i > 0) {
 		--i;
-		ib_dma_unmap_single(dev, qp->sqp_proxy_rcv[i].map,
+		dma_unmap_single(dev->dma_device, qp->sqp_proxy_rcv[i].map,
 				    sizeof (struct mlx4_ib_proxy_sqp_hdr),
 				    DMA_FROM_DEVICE);
 		kfree(qp->sqp_proxy_rcv[i].addr);
@@ -598,7 +598,7 @@ static void free_proxy_bufs(struct ib_device *dev, struct mlx4_ib_qp *qp)
 	int i;
 
 	for (i = 0; i < qp->rq.wqe_cnt; i++) {
-		ib_dma_unmap_single(dev, qp->sqp_proxy_rcv[i].map,
+		dma_unmap_single(dev->dma_device, qp->sqp_proxy_rcv[i].map,
 				    sizeof (struct mlx4_ib_proxy_sqp_hdr),
 				    DMA_FROM_DEVICE);
 		kfree(qp->sqp_proxy_rcv[i].addr);
@@ -3306,7 +3306,7 @@ int mlx4_ib_post_recv(struct ib_qp *ibqp, struct ib_recv_wr *wr,
 
 		if (qp->mlx4_ib_qp_type & (MLX4_IB_QPT_PROXY_SMI_OWNER |
 		    MLX4_IB_QPT_PROXY_SMI | MLX4_IB_QPT_PROXY_GSI)) {
-			ib_dma_sync_single_for_device(ibqp->device,
+			dma_sync_single_for_device(ibqp->device->dma_device,
 						      qp->sqp_proxy_rcv[ind].map,
 						      sizeof (struct mlx4_ib_proxy_sqp_hdr),
 						      DMA_FROM_DEVICE);
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 00175191fdc6..68655e994bfe 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -1865,7 +1865,7 @@ int mlx5_ib_map_mr_sg(struct ib_mr *ibmr, struct scatterlist *sg, int sg_nents,
 
 	mr->ndescs = 0;
 
-	ib_dma_sync_single_for_cpu(ibmr->device, mr->desc_map,
+	dma_sync_single_for_cpu(ibmr->device->dma_device, mr->desc_map,
 				   mr->desc_size * mr->max_descs,
 				   DMA_TO_DEVICE);
 
@@ -1875,7 +1875,7 @@ int mlx5_ib_map_mr_sg(struct ib_mr *ibmr, struct scatterlist *sg, int sg_nents,
 		n = ib_sg_to_pages(ibmr, sg, sg_nents, sg_offset,
 				mlx5_set_page);
 
-	ib_dma_sync_single_for_device(ibmr->device, mr->desc_map,
+	dma_sync_single_for_device(ibmr->device->dma_device, mr->desc_map,
 				      mr->desc_size * mr->max_descs,
 				      DMA_TO_DEVICE);
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_cm.c b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
index 096c4f6fbd65..0c6b0a0c607b 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_cm.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_cm.c
@@ -83,10 +83,10 @@ static void ipoib_cm_dma_unmap_rx(struct ipoib_dev_priv *priv, int frags,
 {
 	int i;
 
-	ib_dma_unmap_single(priv->ca, mapping[0], IPOIB_CM_HEAD_SIZE, DMA_FROM_DEVICE);
+	dma_unmap_single(priv->ca->dma_device, mapping[0], IPOIB_CM_HEAD_SIZE, DMA_FROM_DEVICE);
 
 	for (i = 0; i < frags; ++i)
-		ib_dma_unmap_page(priv->ca, mapping[i + 1], PAGE_SIZE, DMA_FROM_DEVICE);
+		dma_unmap_page(priv->ca->dma_device, mapping[i + 1], PAGE_SIZE, DMA_FROM_DEVICE);
 }
 
 static int ipoib_cm_post_receive_srq(struct net_device *dev, int id)
@@ -158,9 +158,9 @@ static struct sk_buff *ipoib_cm_alloc_rx_skb(struct net_device *dev,
 	 */
 	skb_reserve(skb, IPOIB_CM_RX_RESERVE);
 
-	mapping[0] = ib_dma_map_single(priv->ca, skb->data, IPOIB_CM_HEAD_SIZE,
+	mapping[0] = dma_map_single(priv->ca->dma_device, skb->data, IPOIB_CM_HEAD_SIZE,
 				       DMA_FROM_DEVICE);
-	if (unlikely(ib_dma_mapping_error(priv->ca, mapping[0]))) {
+	if (unlikely(dma_mapping_error(priv->ca->dma_device, mapping[0]))) {
 		dev_kfree_skb_any(skb);
 		return NULL;
 	}
@@ -172,9 +172,9 @@ static struct sk_buff *ipoib_cm_alloc_rx_skb(struct net_device *dev,
 			goto partial_error;
 		skb_fill_page_desc(skb, i, page, 0, PAGE_SIZE);
 
-		mapping[i + 1] = ib_dma_map_page(priv->ca, page,
+		mapping[i + 1] = dma_map_page(priv->ca->dma_device, page,
 						 0, PAGE_SIZE, DMA_FROM_DEVICE);
-		if (unlikely(ib_dma_mapping_error(priv->ca, mapping[i + 1])))
+		if (unlikely(dma_mapping_error(priv->ca->dma_device, mapping[i + 1])))
 			goto partial_error;
 	}
 
@@ -183,10 +183,10 @@ static struct sk_buff *ipoib_cm_alloc_rx_skb(struct net_device *dev,
 
 partial_error:
 
-	ib_dma_unmap_single(priv->ca, mapping[0], IPOIB_CM_HEAD_SIZE, DMA_FROM_DEVICE);
+	dma_unmap_single(priv->ca->dma_device, mapping[0], IPOIB_CM_HEAD_SIZE, DMA_FROM_DEVICE);
 
 	for (; i > 0; --i)
-		ib_dma_unmap_page(priv->ca, mapping[i], PAGE_SIZE, DMA_FROM_DEVICE);
+		dma_unmap_page(priv->ca->dma_device, mapping[i], PAGE_SIZE, DMA_FROM_DEVICE);
 
 	dev_kfree_skb_any(skb);
 	return NULL;
@@ -626,10 +626,10 @@ void ipoib_cm_handle_rx_wc(struct net_device *dev, struct ib_wc *wc)
 		small_skb = dev_alloc_skb(dlen + IPOIB_CM_RX_RESERVE);
 		if (small_skb) {
 			skb_reserve(small_skb, IPOIB_CM_RX_RESERVE);
-			ib_dma_sync_single_for_cpu(priv->ca, rx_ring[wr_id].mapping[0],
+			dma_sync_single_for_cpu(priv->ca->dma_device, rx_ring[wr_id].mapping[0],
 						   dlen, DMA_FROM_DEVICE);
 			skb_copy_from_linear_data(skb, small_skb->data, dlen);
-			ib_dma_sync_single_for_device(priv->ca, rx_ring[wr_id].mapping[0],
+			dma_sync_single_for_device(priv->ca->dma_device, rx_ring[wr_id].mapping[0],
 						      dlen, DMA_FROM_DEVICE);
 			skb_put(small_skb, dlen);
 			skb = small_skb;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 5038f9d2d753..ccf540abedac 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -92,7 +92,7 @@ void ipoib_free_ah(struct kref *kref)
 static void ipoib_ud_dma_unmap_rx(struct ipoib_dev_priv *priv,
 				  u64 mapping[IPOIB_UD_RX_SG])
 {
-	ib_dma_unmap_single(priv->ca, mapping[0],
+	dma_unmap_single(priv->ca->dma_device, mapping[0],
 			    IPOIB_UD_BUF_SIZE(priv->max_ib_mtu),
 			    DMA_FROM_DEVICE);
 }
@@ -139,9 +139,9 @@ static struct sk_buff *ipoib_alloc_rx_skb(struct net_device *dev, int id)
 	skb_reserve(skb, sizeof(struct ipoib_pseudo_header));
 
 	mapping = priv->rx_ring[id].mapping;
-	mapping[0] = ib_dma_map_single(priv->ca, skb->data, buf_size,
+	mapping[0] = dma_map_single(priv->ca->dma_device, skb->data, buf_size,
 				       DMA_FROM_DEVICE);
-	if (unlikely(ib_dma_mapping_error(priv->ca, mapping[0])))
+	if (unlikely(dma_mapping_error(priv->ca->dma_device, mapping[0])))
 		goto error;
 
 	priv->rx_ring[id].skb = skb;
@@ -278,9 +278,9 @@ int ipoib_dma_map_tx(struct ib_device *ca, struct ipoib_tx_buf *tx_req)
 	int off;
 
 	if (skb_headlen(skb)) {
-		mapping[0] = ib_dma_map_single(ca, skb->data, skb_headlen(skb),
+		mapping[0] = dma_map_single(ca->dma_device, skb->data, skb_headlen(skb),
 					       DMA_TO_DEVICE);
-		if (unlikely(ib_dma_mapping_error(ca, mapping[0])))
+		if (unlikely(dma_mapping_error(ca->dma_device, mapping[0])))
 			return -EIO;
 
 		off = 1;
@@ -289,11 +289,11 @@ int ipoib_dma_map_tx(struct ib_device *ca, struct ipoib_tx_buf *tx_req)
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; ++i) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		mapping[i + off] = ib_dma_map_page(ca,
+		mapping[i + off] = dma_map_page(ca->dma_device,
 						 skb_frag_page(frag),
 						 frag->page_offset, skb_frag_size(frag),
 						 DMA_TO_DEVICE);
-		if (unlikely(ib_dma_mapping_error(ca, mapping[i + off])))
+		if (unlikely(dma_mapping_error(ca->dma_device, mapping[i + off])))
 			goto partial_error;
 	}
 	return 0;
@@ -302,11 +302,11 @@ int ipoib_dma_map_tx(struct ib_device *ca, struct ipoib_tx_buf *tx_req)
 	for (; i > 0; --i) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i - 1];
 
-		ib_dma_unmap_page(ca, mapping[i - !off], skb_frag_size(frag), DMA_TO_DEVICE);
+		dma_unmap_page(ca->dma_device, mapping[i - !off], skb_frag_size(frag), DMA_TO_DEVICE);
 	}
 
 	if (off)
-		ib_dma_unmap_single(ca, mapping[0], skb_headlen(skb), DMA_TO_DEVICE);
+		dma_unmap_single(ca->dma_device, mapping[0], skb_headlen(skb), DMA_TO_DEVICE);
 
 	return -EIO;
 }
@@ -320,7 +320,7 @@ void ipoib_dma_unmap_tx(struct ipoib_dev_priv *priv,
 	int off;
 
 	if (skb_headlen(skb)) {
-		ib_dma_unmap_single(priv->ca, mapping[0], skb_headlen(skb),
+		dma_unmap_single(priv->ca->dma_device, mapping[0], skb_headlen(skb),
 				    DMA_TO_DEVICE);
 		off = 1;
 	} else
@@ -329,7 +329,7 @@ void ipoib_dma_unmap_tx(struct ipoib_dev_priv *priv,
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; ++i) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
-		ib_dma_unmap_page(priv->ca, mapping[i + off],
+		dma_unmap_page(priv->ca->dma_device, mapping[i + off],
 				  skb_frag_size(frag), DMA_TO_DEVICE);
 	}
 }
diff --git a/drivers/infiniband/ulp/iser/iscsi_iser.c b/drivers/infiniband/ulp/iser/iscsi_iser.c
index 9104e6b8cac9..f2b2baccfe69 100644
--- a/drivers/infiniband/ulp/iser/iscsi_iser.c
+++ b/drivers/infiniband/ulp/iser/iscsi_iser.c
@@ -198,9 +198,9 @@ iser_initialize_task_headers(struct iscsi_task *task,
 		goto out;
 	}
 
-	dma_addr = ib_dma_map_single(device->ib_device, (void *)tx_desc,
+	dma_addr = dma_map_single(device->ib_device->dma_device, (void *)tx_desc,
 				ISER_HEADERS_LEN, DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(device->ib_device, dma_addr)) {
+	if (dma_mapping_error(device->ib_device->dma_device, dma_addr)) {
 		ret = -ENOMEM;
 		goto out;
 	}
@@ -375,7 +375,7 @@ static void iscsi_iser_cleanup_task(struct iscsi_task *task)
 		return;
 
 	if (likely(tx_desc->mapped)) {
-		ib_dma_unmap_single(device->ib_device, tx_desc->dma_addr,
+		dma_unmap_single(device->ib_device->dma_device, tx_desc->dma_addr,
 				    ISER_HEADERS_LEN, DMA_TO_DEVICE);
 		tx_desc->mapped = false;
 	}
diff --git a/drivers/infiniband/ulp/iser/iser_initiator.c b/drivers/infiniband/ulp/iser/iser_initiator.c
index 81ae2e30dd12..2e65513833bd 100644
--- a/drivers/infiniband/ulp/iser/iser_initiator.c
+++ b/drivers/infiniband/ulp/iser/iser_initiator.c
@@ -164,7 +164,7 @@ static void iser_create_send_desc(struct iser_conn	*iser_conn,
 {
 	struct iser_device *device = iser_conn->ib_conn.device;
 
-	ib_dma_sync_single_for_cpu(device->ib_device,
+	dma_sync_single_for_cpu(device->ib_device->dma_device,
 		tx_desc->dma_addr, ISER_HEADERS_LEN, DMA_TO_DEVICE);
 
 	memset(&tx_desc->iser_header, 0, sizeof(struct iser_ctrl));
@@ -180,10 +180,10 @@ static void iser_free_login_buf(struct iser_conn *iser_conn)
 	if (!desc->req)
 		return;
 
-	ib_dma_unmap_single(device->ib_device, desc->req_dma,
+	dma_unmap_single(device->ib_device->dma_device, desc->req_dma,
 			    ISCSI_DEF_MAX_RECV_SEG_LEN, DMA_TO_DEVICE);
 
-	ib_dma_unmap_single(device->ib_device, desc->rsp_dma,
+	dma_unmap_single(device->ib_device->dma_device, desc->rsp_dma,
 			    ISER_RX_LOGIN_SIZE, DMA_FROM_DEVICE);
 
 	kfree(desc->req);
@@ -203,10 +203,10 @@ static int iser_alloc_login_buf(struct iser_conn *iser_conn)
 	if (!desc->req)
 		return -ENOMEM;
 
-	desc->req_dma = ib_dma_map_single(device->ib_device, desc->req,
+	desc->req_dma = dma_map_single(device->ib_device->dma_device, desc->req,
 					  ISCSI_DEF_MAX_RECV_SEG_LEN,
 					  DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(device->ib_device,
+	if (dma_mapping_error(device->ib_device->dma_device,
 				desc->req_dma))
 		goto free_req;
 
@@ -214,10 +214,10 @@ static int iser_alloc_login_buf(struct iser_conn *iser_conn)
 	if (!desc->rsp)
 		goto unmap_req;
 
-	desc->rsp_dma = ib_dma_map_single(device->ib_device, desc->rsp,
+	desc->rsp_dma = dma_map_single(device->ib_device->dma_device, desc->rsp,
 					   ISER_RX_LOGIN_SIZE,
 					   DMA_FROM_DEVICE);
-	if (ib_dma_mapping_error(device->ib_device,
+	if (dma_mapping_error(device->ib_device->dma_device,
 				desc->rsp_dma))
 		goto free_rsp;
 
@@ -226,7 +226,7 @@ static int iser_alloc_login_buf(struct iser_conn *iser_conn)
 free_rsp:
 	kfree(desc->rsp);
 unmap_req:
-	ib_dma_unmap_single(device->ib_device, desc->req_dma,
+	dma_unmap_single(device->ib_device->dma_device, desc->req_dma,
 			    ISCSI_DEF_MAX_RECV_SEG_LEN,
 			    DMA_TO_DEVICE);
 free_req:
@@ -265,9 +265,9 @@ int iser_alloc_rx_descriptors(struct iser_conn *iser_conn,
 	rx_desc = iser_conn->rx_descs;
 
 	for (i = 0; i < iser_conn->qp_max_recv_dtos; i++, rx_desc++)  {
-		dma_addr = ib_dma_map_single(device->ib_device, (void *)rx_desc,
+		dma_addr = dma_map_single(device->ib_device->dma_device, (void *)rx_desc,
 					ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
-		if (ib_dma_mapping_error(device->ib_device, dma_addr))
+		if (dma_mapping_error(device->ib_device->dma_device, dma_addr))
 			goto rx_desc_dma_map_failed;
 
 		rx_desc->dma_addr = dma_addr;
@@ -284,7 +284,7 @@ int iser_alloc_rx_descriptors(struct iser_conn *iser_conn,
 rx_desc_dma_map_failed:
 	rx_desc = iser_conn->rx_descs;
 	for (j = 0; j < i; j++, rx_desc++)
-		ib_dma_unmap_single(device->ib_device, rx_desc->dma_addr,
+		dma_unmap_single(device->ib_device->dma_device, rx_desc->dma_addr,
 				    ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
 	kfree(iser_conn->rx_descs);
 	iser_conn->rx_descs = NULL;
@@ -309,7 +309,7 @@ void iser_free_rx_descriptors(struct iser_conn *iser_conn)
 
 	rx_desc = iser_conn->rx_descs;
 	for (i = 0; i < iser_conn->qp_max_recv_dtos; i++, rx_desc++)
-		ib_dma_unmap_single(device->ib_device, rx_desc->dma_addr,
+		dma_unmap_single(device->ib_device->dma_device, rx_desc->dma_addr,
 				    ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
 	kfree(iser_conn->rx_descs);
 	/* make sure we never redo any unmapping */
@@ -522,12 +522,12 @@ int iser_send_control(struct iscsi_conn *conn,
 			goto send_control_error;
 		}
 
-		ib_dma_sync_single_for_cpu(device->ib_device, desc->req_dma,
+		dma_sync_single_for_cpu(device->ib_device->dma_device, desc->req_dma,
 					   task->data_count, DMA_TO_DEVICE);
 
 		memcpy(desc->req, task->data, task->data_count);
 
-		ib_dma_sync_single_for_device(device->ib_device, desc->req_dma,
+		dma_sync_single_for_device(device->ib_device->dma_device, desc->req_dma,
 					      task->data_count, DMA_TO_DEVICE);
 
 		tx_dsg->addr = desc->req_dma;
@@ -570,7 +570,7 @@ void iser_login_rsp(struct ib_cq *cq, struct ib_wc *wc)
 		return;
 	}
 
-	ib_dma_sync_single_for_cpu(ib_conn->device->ib_device,
+	dma_sync_single_for_cpu(ib_conn->device->ib_device->dma_device,
 				   desc->rsp_dma, ISER_RX_LOGIN_SIZE,
 				   DMA_FROM_DEVICE);
 
@@ -583,7 +583,7 @@ void iser_login_rsp(struct ib_cq *cq, struct ib_wc *wc)
 
 	iscsi_iser_recv(iser_conn->iscsi_conn, hdr, data, length);
 
-	ib_dma_sync_single_for_device(ib_conn->device->ib_device,
+	dma_sync_single_for_device(ib_conn->device->ib_device->dma_device,
 				      desc->rsp_dma, ISER_RX_LOGIN_SIZE,
 				      DMA_FROM_DEVICE);
 
@@ -655,7 +655,7 @@ void iser_task_rsp(struct ib_cq *cq, struct ib_wc *wc)
 		return;
 	}
 
-	ib_dma_sync_single_for_cpu(ib_conn->device->ib_device,
+	dma_sync_single_for_cpu(ib_conn->device->ib_device->dma_device,
 				   desc->dma_addr, ISER_RX_PAYLOAD_SIZE,
 				   DMA_FROM_DEVICE);
 
@@ -673,7 +673,7 @@ void iser_task_rsp(struct ib_cq *cq, struct ib_wc *wc)
 
 	iscsi_iser_recv(iser_conn->iscsi_conn, hdr, desc->data, length);
 
-	ib_dma_sync_single_for_device(ib_conn->device->ib_device,
+	dma_sync_single_for_device(ib_conn->device->ib_device->dma_device,
 				      desc->dma_addr, ISER_RX_PAYLOAD_SIZE,
 				      DMA_FROM_DEVICE);
 
@@ -724,7 +724,7 @@ void iser_dataout_comp(struct ib_cq *cq, struct ib_wc *wc)
 	if (unlikely(wc->status != IB_WC_SUCCESS))
 		iser_err_comp(wc, "dataout");
 
-	ib_dma_unmap_single(device->ib_device, desc->dma_addr,
+	dma_unmap_single(device->ib_device->dma_device, desc->dma_addr,
 			    ISER_HEADERS_LEN, DMA_TO_DEVICE);
 	kmem_cache_free(ig.desc_cache, desc);
 }
diff --git a/drivers/infiniband/ulp/iser/iser_memory.c b/drivers/infiniband/ulp/iser/iser_memory.c
index 9c3e9ab53a41..ae89be7d69a9 100644
--- a/drivers/infiniband/ulp/iser/iser_memory.c
+++ b/drivers/infiniband/ulp/iser/iser_memory.c
@@ -145,9 +145,9 @@ static void iser_data_buf_dump(struct iser_data_buf *data,
 	for_each_sg(data->sg, sg, data->dma_nents, i)
 		iser_dbg("sg[%d] dma_addr:0x%lX page:0x%p "
 			 "off:0x%x sz:0x%x dma_len:0x%x\n",
-			 i, (unsigned long)ib_sg_dma_address(ibdev, sg),
+			 i, (unsigned long)sg_dma_address(sg),
 			 sg_page(sg), sg->offset,
-			 sg->length, ib_sg_dma_len(ibdev, sg));
+			 sg->length, sg_dma_len(sg));
 }
 
 static void iser_dump_page_vec(struct iser_page_vec *page_vec)
@@ -170,7 +170,7 @@ int iser_dma_map_task_data(struct iscsi_iser_task *iser_task,
 	iser_task->dir[iser_dir] = 1;
 	dev = iser_task->iser_conn->ib_conn.device->ib_device;
 
-	data->dma_nents = ib_dma_map_sg(dev, data->sg, data->size, dma_dir);
+	data->dma_nents = dma_map_sg(dev->dma_device, data->sg, data->size, dma_dir);
 	if (data->dma_nents == 0) {
 		iser_err("dma_map_sg failed!!!\n");
 		return -EINVAL;
@@ -185,7 +185,7 @@ void iser_dma_unmap_task_data(struct iscsi_iser_task *iser_task,
 	struct ib_device *dev;
 
 	dev = iser_task->iser_conn->ib_conn.device->ib_device;
-	ib_dma_unmap_sg(dev, data->sg, data->size, dir);
+	dma_unmap_sg(dev->dma_device, data->sg, data->size, dir);
 }
 
 static int
@@ -204,8 +204,8 @@ iser_reg_dma(struct iser_device *device, struct iser_data_buf *mem,
 		reg->rkey = device->pd->unsafe_global_rkey;
 	else
 		reg->rkey = 0;
-	reg->sge.addr = ib_sg_dma_address(device->ib_device, &sg[0]);
-	reg->sge.length = ib_sg_dma_len(device->ib_device, &sg[0]);
+	reg->sge.addr = sg_dma_address(&sg[0]);
+	reg->sge.length = sg_dma_len(&sg[0]);
 
 	iser_dbg("Single DMA entry: lkey=0x%x, rkey=0x%x, addr=0x%llx,"
 		 " length=0x%x\n", reg->sge.lkey, reg->rkey,
diff --git a/drivers/infiniband/ulp/iser/iser_verbs.c b/drivers/infiniband/ulp/iser/iser_verbs.c
index 8ae7a3beddb7..632e57f9bd58 100644
--- a/drivers/infiniband/ulp/iser/iser_verbs.c
+++ b/drivers/infiniband/ulp/iser/iser_verbs.c
@@ -1077,7 +1077,7 @@ int iser_post_send(struct ib_conn *ib_conn, struct iser_tx_desc *tx_desc,
 	struct ib_send_wr *bad_wr, *wr = iser_tx_next_wr(tx_desc);
 	int ib_ret;
 
-	ib_dma_sync_single_for_device(ib_conn->device->ib_device,
+	dma_sync_single_for_device(ib_conn->device->ib_device->dma_device,
 				      tx_desc->dma_addr, ISER_HEADERS_LEN,
 				      DMA_TO_DEVICE);
 
diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
index 314e95516068..e81c49d10d29 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.c
+++ b/drivers/infiniband/ulp/isert/ib_isert.c
@@ -189,9 +189,9 @@ isert_alloc_rx_descriptors(struct isert_conn *isert_conn)
 	rx_desc = isert_conn->rx_descs;
 
 	for (i = 0; i < ISERT_QP_MAX_RECV_DTOS; i++, rx_desc++)  {
-		dma_addr = ib_dma_map_single(ib_dev, (void *)rx_desc,
+		dma_addr = dma_map_single(ib_dev->dma_device, (void *)rx_desc,
 					ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
-		if (ib_dma_mapping_error(ib_dev, dma_addr))
+		if (dma_mapping_error(ib_dev->dma_device, dma_addr))
 			goto dma_map_fail;
 
 		rx_desc->dma_addr = dma_addr;
@@ -208,7 +208,7 @@ isert_alloc_rx_descriptors(struct isert_conn *isert_conn)
 dma_map_fail:
 	rx_desc = isert_conn->rx_descs;
 	for (j = 0; j < i; j++, rx_desc++) {
-		ib_dma_unmap_single(ib_dev, rx_desc->dma_addr,
+		dma_unmap_single(ib_dev->dma_device, rx_desc->dma_addr,
 				    ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
 	}
 	kfree(isert_conn->rx_descs);
@@ -229,7 +229,7 @@ isert_free_rx_descriptors(struct isert_conn *isert_conn)
 
 	rx_desc = isert_conn->rx_descs;
 	for (i = 0; i < ISERT_QP_MAX_RECV_DTOS; i++, rx_desc++)  {
-		ib_dma_unmap_single(ib_dev, rx_desc->dma_addr,
+		dma_unmap_single(ib_dev->dma_device, rx_desc->dma_addr,
 				    ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
 	}
 
@@ -410,11 +410,11 @@ isert_free_login_buf(struct isert_conn *isert_conn)
 {
 	struct ib_device *ib_dev = isert_conn->device->ib_device;
 
-	ib_dma_unmap_single(ib_dev, isert_conn->login_rsp_dma,
+	dma_unmap_single(ib_dev->dma_device, isert_conn->login_rsp_dma,
 			    ISER_RX_PAYLOAD_SIZE, DMA_TO_DEVICE);
 	kfree(isert_conn->login_rsp_buf);
 
-	ib_dma_unmap_single(ib_dev, isert_conn->login_req_dma,
+	dma_unmap_single(ib_dev->dma_device, isert_conn->login_req_dma,
 			    ISER_RX_PAYLOAD_SIZE,
 			    DMA_FROM_DEVICE);
 	kfree(isert_conn->login_req_buf);
@@ -431,10 +431,10 @@ isert_alloc_login_buf(struct isert_conn *isert_conn,
 	if (!isert_conn->login_req_buf)
 		return -ENOMEM;
 
-	isert_conn->login_req_dma = ib_dma_map_single(ib_dev,
+	isert_conn->login_req_dma = dma_map_single(ib_dev->dma_device,
 				isert_conn->login_req_buf,
 				ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
-	ret = ib_dma_mapping_error(ib_dev, isert_conn->login_req_dma);
+	ret = dma_mapping_error(ib_dev->dma_device, isert_conn->login_req_dma);
 	if (ret) {
 		isert_err("login_req_dma mapping error: %d\n", ret);
 		isert_conn->login_req_dma = 0;
@@ -447,10 +447,10 @@ isert_alloc_login_buf(struct isert_conn *isert_conn,
 		goto out_unmap_login_req_buf;
 	}
 
-	isert_conn->login_rsp_dma = ib_dma_map_single(ib_dev,
+	isert_conn->login_rsp_dma = dma_map_single(ib_dev->dma_device,
 					isert_conn->login_rsp_buf,
 					ISER_RX_PAYLOAD_SIZE, DMA_TO_DEVICE);
-	ret = ib_dma_mapping_error(ib_dev, isert_conn->login_rsp_dma);
+	ret = dma_mapping_error(ib_dev->dma_device, isert_conn->login_rsp_dma);
 	if (ret) {
 		isert_err("login_rsp_dma mapping error: %d\n", ret);
 		isert_conn->login_rsp_dma = 0;
@@ -462,7 +462,7 @@ isert_alloc_login_buf(struct isert_conn *isert_conn,
 out_free_login_rsp_buf:
 	kfree(isert_conn->login_rsp_buf);
 out_unmap_login_req_buf:
-	ib_dma_unmap_single(ib_dev, isert_conn->login_req_dma,
+	dma_unmap_single(ib_dev->dma_device, isert_conn->login_req_dma,
 			    ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
 out_free_login_req_buf:
 	kfree(isert_conn->login_req_buf);
@@ -854,7 +854,7 @@ isert_login_post_send(struct isert_conn *isert_conn, struct iser_tx_desc *tx_des
 	struct ib_send_wr send_wr, *send_wr_failed;
 	int ret;
 
-	ib_dma_sync_single_for_device(ib_dev, tx_desc->dma_addr,
+	dma_sync_single_for_device(ib_dev->dma_device, tx_desc->dma_addr,
 				      ISER_HEADERS_LEN, DMA_TO_DEVICE);
 
 	tx_desc->tx_cqe.done = isert_login_send_done;
@@ -881,7 +881,7 @@ isert_create_send_desc(struct isert_conn *isert_conn,
 	struct isert_device *device = isert_conn->device;
 	struct ib_device *ib_dev = device->ib_device;
 
-	ib_dma_sync_single_for_cpu(ib_dev, tx_desc->dma_addr,
+	dma_sync_single_for_cpu(ib_dev->dma_device, tx_desc->dma_addr,
 				   ISER_HEADERS_LEN, DMA_TO_DEVICE);
 
 	memset(&tx_desc->iser_header, 0, sizeof(struct iser_ctrl));
@@ -903,10 +903,10 @@ isert_init_tx_hdrs(struct isert_conn *isert_conn,
 	struct ib_device *ib_dev = device->ib_device;
 	u64 dma_addr;
 
-	dma_addr = ib_dma_map_single(ib_dev, (void *)tx_desc,
+	dma_addr = dma_map_single(ib_dev->dma_device, (void *)tx_desc,
 			ISER_HEADERS_LEN, DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(ib_dev, dma_addr)) {
-		isert_err("ib_dma_mapping_error() failed\n");
+	if (dma_mapping_error(ib_dev->dma_device, dma_addr)) {
+		isert_err("dma_mapping_error() failed\n");
 		return -ENOMEM;
 	}
 
@@ -992,12 +992,12 @@ isert_put_login_tx(struct iscsi_conn *conn, struct iscsi_login *login,
 	if (length > 0) {
 		struct ib_sge *tx_dsg = &tx_desc->tx_sg[1];
 
-		ib_dma_sync_single_for_cpu(ib_dev, isert_conn->login_rsp_dma,
+		dma_sync_single_for_cpu(ib_dev->dma_device, isert_conn->login_rsp_dma,
 					   length, DMA_TO_DEVICE);
 
 		memcpy(isert_conn->login_rsp_buf, login->rsp_buf, length);
 
-		ib_dma_sync_single_for_device(ib_dev, isert_conn->login_rsp_dma,
+		dma_sync_single_for_device(ib_dev->dma_device, isert_conn->login_rsp_dma,
 					      length, DMA_TO_DEVICE);
 
 		tx_dsg->addr	= isert_conn->login_rsp_dma;
@@ -1397,7 +1397,7 @@ isert_recv_done(struct ib_cq *cq, struct ib_wc *wc)
 		return;
 	}
 
-	ib_dma_sync_single_for_cpu(ib_dev, rx_desc->dma_addr,
+	dma_sync_single_for_cpu(ib_dev->dma_device, rx_desc->dma_addr,
 			ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
 
 	isert_dbg("DMA: 0x%llx, iSCSI opcode: 0x%02x, ITT: 0x%08x, flags: 0x%02x dlen: %d\n",
@@ -1432,7 +1432,7 @@ isert_recv_done(struct ib_cq *cq, struct ib_wc *wc)
 	isert_rx_opcode(isert_conn, rx_desc,
 			read_stag, read_va, write_stag, write_va);
 
-	ib_dma_sync_single_for_device(ib_dev, rx_desc->dma_addr,
+	dma_sync_single_for_device(ib_dev->dma_device, rx_desc->dma_addr,
 			ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
 }
 
@@ -1447,7 +1447,7 @@ isert_login_recv_done(struct ib_cq *cq, struct ib_wc *wc)
 		return;
 	}
 
-	ib_dma_sync_single_for_cpu(ib_dev, isert_conn->login_req_dma,
+	dma_sync_single_for_cpu(ib_dev->dma_device, isert_conn->login_req_dma,
 			ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
 
 	isert_conn->login_req_len = wc->byte_len - ISER_HEADERS_LEN;
@@ -1463,7 +1463,7 @@ isert_login_recv_done(struct ib_cq *cq, struct ib_wc *wc)
 	complete(&isert_conn->login_req_comp);
 	mutex_unlock(&isert_conn->mutex);
 
-	ib_dma_sync_single_for_device(ib_dev, isert_conn->login_req_dma,
+	dma_sync_single_for_device(ib_dev->dma_device, isert_conn->login_req_dma,
 				ISER_RX_PAYLOAD_SIZE, DMA_FROM_DEVICE);
 }
 
@@ -1571,7 +1571,7 @@ isert_unmap_tx_desc(struct iser_tx_desc *tx_desc, struct ib_device *ib_dev)
 {
 	if (tx_desc->dma_addr != 0) {
 		isert_dbg("unmap single for tx_desc->dma_addr\n");
-		ib_dma_unmap_single(ib_dev, tx_desc->dma_addr,
+		dma_unmap_single(ib_dev->dma_device, tx_desc->dma_addr,
 				    ISER_HEADERS_LEN, DMA_TO_DEVICE);
 		tx_desc->dma_addr = 0;
 	}
@@ -1583,7 +1583,7 @@ isert_completion_put(struct iser_tx_desc *tx_desc, struct isert_cmd *isert_cmd,
 {
 	if (isert_cmd->pdu_buf_dma != 0) {
 		isert_dbg("unmap single for isert_cmd->pdu_buf_dma\n");
-		ib_dma_unmap_single(ib_dev, isert_cmd->pdu_buf_dma,
+		dma_unmap_single(ib_dev->dma_device, isert_cmd->pdu_buf_dma,
 				    isert_cmd->pdu_buf_len, DMA_TO_DEVICE);
 		isert_cmd->pdu_buf_dma = 0;
 	}
@@ -1841,10 +1841,10 @@ isert_put_response(struct iscsi_conn *conn, struct iscsi_cmd *cmd)
 		hton24(hdr->dlength, (u32)cmd->se_cmd.scsi_sense_length);
 		pdu_len = cmd->se_cmd.scsi_sense_length + padding;
 
-		isert_cmd->pdu_buf_dma = ib_dma_map_single(ib_dev,
+		isert_cmd->pdu_buf_dma = dma_map_single(ib_dev->dma_device,
 				(void *)cmd->sense_buffer, pdu_len,
 				DMA_TO_DEVICE);
-		if (ib_dma_mapping_error(ib_dev, isert_cmd->pdu_buf_dma))
+		if (dma_mapping_error(ib_dev->dma_device, isert_cmd->pdu_buf_dma))
 			return -ENOMEM;
 
 		isert_cmd->pdu_buf_len = pdu_len;
@@ -1970,10 +1970,10 @@ isert_put_reject(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 	isert_init_tx_hdrs(isert_conn, &isert_cmd->tx_desc);
 
 	hton24(hdr->dlength, ISCSI_HDR_LEN);
-	isert_cmd->pdu_buf_dma = ib_dma_map_single(ib_dev,
+	isert_cmd->pdu_buf_dma = dma_map_single(ib_dev->dma_device,
 			(void *)cmd->buf_ptr, ISCSI_HDR_LEN,
 			DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(ib_dev, isert_cmd->pdu_buf_dma))
+	if (dma_mapping_error(ib_dev->dma_device, isert_cmd->pdu_buf_dma))
 		return -ENOMEM;
 	isert_cmd->pdu_buf_len = ISCSI_HDR_LEN;
 	tx_dsg->addr	= isert_cmd->pdu_buf_dma;
@@ -2013,9 +2013,9 @@ isert_put_text_rsp(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 		struct ib_sge *tx_dsg = &isert_cmd->tx_desc.tx_sg[1];
 		void *txt_rsp_buf = cmd->buf_ptr;
 
-		isert_cmd->pdu_buf_dma = ib_dma_map_single(ib_dev,
+		isert_cmd->pdu_buf_dma = dma_map_single(ib_dev->dma_device,
 				txt_rsp_buf, txt_rsp_len, DMA_TO_DEVICE);
-		if (ib_dma_mapping_error(ib_dev, isert_cmd->pdu_buf_dma))
+		if (dma_mapping_error(ib_dev->dma_device, isert_cmd->pdu_buf_dma))
 			return -ENOMEM;
 
 		isert_cmd->pdu_buf_len = txt_rsp_len;
diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index cd150c19d0d2..751865f0429d 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -233,9 +233,9 @@ static struct srp_iu *srp_alloc_iu(struct srp_host *host, size_t size,
 	if (!iu->buf)
 		goto out_free_iu;
 
-	iu->dma = ib_dma_map_single(host->srp_dev->dev, iu->buf, size,
+	iu->dma = dma_map_single(host->srp_dev->dev->dma_device, iu->buf, size,
 				    direction);
-	if (ib_dma_mapping_error(host->srp_dev->dev, iu->dma))
+	if (dma_mapping_error(host->srp_dev->dev->dma_device, iu->dma))
 		goto out_free_buf;
 
 	iu->size      = size;
@@ -256,7 +256,7 @@ static void srp_free_iu(struct srp_host *host, struct srp_iu *iu)
 	if (!iu)
 		return;
 
-	ib_dma_unmap_single(host->srp_dev->dev, iu->dma, iu->size,
+	dma_unmap_single(host->srp_dev->dev->dma_device, iu->dma, iu->size,
 			    iu->direction);
 	kfree(iu->buf);
 	kfree(iu);
@@ -843,7 +843,7 @@ static void srp_free_req_data(struct srp_target_port *target,
 			kfree(req->map_page);
 		}
 		if (req->indirect_dma_addr) {
-			ib_dma_unmap_single(ibdev, req->indirect_dma_addr,
+			dma_unmap_single(ibdev->dma_device, req->indirect_dma_addr,
 					    target->indirect_size,
 					    DMA_TO_DEVICE);
 		}
@@ -888,10 +888,10 @@ static int srp_alloc_req_data(struct srp_rdma_ch *ch)
 		if (!req->indirect_desc)
 			goto out;
 
-		dma_addr = ib_dma_map_single(ibdev, req->indirect_desc,
+		dma_addr = dma_map_single(ibdev->dma_device, req->indirect_desc,
 					     target->indirect_size,
 					     DMA_TO_DEVICE);
-		if (ib_dma_mapping_error(ibdev, dma_addr))
+		if (dma_mapping_error(ibdev->dma_device, dma_addr))
 			goto out;
 
 		req->indirect_dma_addr = dma_addr;
@@ -1096,7 +1096,7 @@ static void srp_unmap_data(struct scsi_cmnd *scmnd,
 			ib_fmr_pool_unmap(*pfmr);
 	}
 
-	ib_dma_unmap_sg(ibdev, scsi_sglist(scmnd), scsi_sg_count(scmnd),
+	dma_unmap_sg(ibdev->dma_device, scsi_sglist(scmnd), scsi_sg_count(scmnd),
 			scmnd->sc_data_direction);
 }
 
@@ -1429,9 +1429,8 @@ static int srp_map_sg_entry(struct srp_map_state *state,
 {
 	struct srp_target_port *target = ch->target;
 	struct srp_device *dev = target->srp_host->srp_dev;
-	struct ib_device *ibdev = dev->dev;
-	dma_addr_t dma_addr = ib_sg_dma_address(ibdev, sg);
-	unsigned int dma_len = ib_sg_dma_len(ibdev, sg);
+	dma_addr_t dma_addr = sg_dma_address(sg);
+	unsigned int dma_len = sg_dma_len(sg);
 	unsigned int len = 0;
 	int ret;
 
@@ -1525,13 +1524,12 @@ static int srp_map_sg_dma(struct srp_map_state *state, struct srp_rdma_ch *ch,
 			  int count)
 {
 	struct srp_target_port *target = ch->target;
-	struct srp_device *dev = target->srp_host->srp_dev;
 	struct scatterlist *sg;
 	int i;
 
 	for_each_sg(scat, sg, count, i) {
-		srp_map_desc(state, ib_sg_dma_address(dev->dev, sg),
-			     ib_sg_dma_len(dev->dev, sg),
+		srp_map_desc(state, sg_dma_address(sg),
+			     sg_dma_len(sg),
 			     target->pd->unsafe_global_rkey);
 	}
 
@@ -1659,7 +1657,7 @@ static int srp_map_data(struct scsi_cmnd *scmnd, struct srp_rdma_ch *ch,
 	dev = target->srp_host->srp_dev;
 	ibdev = dev->dev;
 
-	count = ib_dma_map_sg(ibdev, scat, nents, scmnd->sc_data_direction);
+	count = dma_map_sg(ibdev->dma_device, scat, nents, scmnd->sc_data_direction);
 	if (unlikely(count == 0))
 		return -EIO;
 
@@ -1691,9 +1689,9 @@ static int srp_map_data(struct scsi_cmnd *scmnd, struct srp_rdma_ch *ch,
 		 */
 		struct srp_direct_buf *buf = (void *) cmd->add_data;
 
-		buf->va  = cpu_to_be64(ib_sg_dma_address(ibdev, scat));
+		buf->va  = cpu_to_be64(sg_dma_address(scat));
 		buf->key = cpu_to_be32(pd->unsafe_global_rkey);
-		buf->len = cpu_to_be32(ib_sg_dma_len(ibdev, scat));
+		buf->len = cpu_to_be32(sg_dma_len(scat));
 
 		req->nmdesc = 0;
 		/* Debugging help. */
@@ -1707,7 +1705,7 @@ static int srp_map_data(struct scsi_cmnd *scmnd, struct srp_rdma_ch *ch,
 	 */
 	indirect_hdr = (void *) cmd->add_data;
 
-	ib_dma_sync_single_for_cpu(ibdev, req->indirect_dma_addr,
+	dma_sync_single_for_cpu(ibdev->dma_device, req->indirect_dma_addr,
 				   target->indirect_size, DMA_TO_DEVICE);
 
 	memset(&state, 0, sizeof(state));
@@ -1789,7 +1787,7 @@ static int srp_map_data(struct scsi_cmnd *scmnd, struct srp_rdma_ch *ch,
 	else
 		cmd->data_in_desc_cnt = count;
 
-	ib_dma_sync_single_for_device(ibdev, req->indirect_dma_addr, table_len,
+	dma_sync_single_for_device(ibdev->dma_device, req->indirect_dma_addr, table_len,
 				      DMA_TO_DEVICE);
 
 map_complete:
@@ -2084,9 +2082,9 @@ static int srp_response_common(struct srp_rdma_ch *ch, s32 req_delta,
 		return 1;
 	}
 
-	ib_dma_sync_single_for_cpu(dev, iu->dma, len, DMA_TO_DEVICE);
+	dma_sync_single_for_cpu(dev->dma_device, iu->dma, len, DMA_TO_DEVICE);
 	memcpy(iu->buf, rsp, len);
-	ib_dma_sync_single_for_device(dev, iu->dma, len, DMA_TO_DEVICE);
+	dma_sync_single_for_device(dev->dma_device, iu->dma, len, DMA_TO_DEVICE);
 
 	err = srp_post_send(ch, iu, len);
 	if (err) {
@@ -2144,7 +2142,7 @@ static void srp_recv_done(struct ib_cq *cq, struct ib_wc *wc)
 		return;
 	}
 
-	ib_dma_sync_single_for_cpu(dev, iu->dma, ch->max_ti_iu_len,
+	dma_sync_single_for_cpu(dev->dma_device, iu->dma, ch->max_ti_iu_len,
 				   DMA_FROM_DEVICE);
 
 	opcode = *(u8 *) iu->buf;
@@ -2181,7 +2179,7 @@ static void srp_recv_done(struct ib_cq *cq, struct ib_wc *wc)
 		break;
 	}
 
-	ib_dma_sync_single_for_device(dev, iu->dma, ch->max_ti_iu_len,
+	dma_sync_single_for_device(dev->dma_device, iu->dma, ch->max_ti_iu_len,
 				      DMA_FROM_DEVICE);
 
 	res = srp_post_recv(ch, iu);
@@ -2267,7 +2265,7 @@ static int srp_queuecommand(struct Scsi_Host *shost, struct scsi_cmnd *scmnd)
 
 	req = &ch->req_ring[idx];
 	dev = target->srp_host->srp_dev->dev;
-	ib_dma_sync_single_for_cpu(dev, iu->dma, target->max_iu_len,
+	dma_sync_single_for_cpu(dev->dma_device, iu->dma, target->max_iu_len,
 				   DMA_TO_DEVICE);
 
 	scmnd->host_scribble = (void *) req;
@@ -2302,7 +2300,7 @@ static int srp_queuecommand(struct Scsi_Host *shost, struct scsi_cmnd *scmnd)
 		goto err_iu;
 	}
 
-	ib_dma_sync_single_for_device(dev, iu->dma, target->max_iu_len,
+	dma_sync_single_for_device(dev->dma_device, iu->dma, target->max_iu_len,
 				      DMA_TO_DEVICE);
 
 	if (srp_post_send(ch, iu, len)) {
@@ -2689,7 +2687,7 @@ static int srp_send_tsk_mgmt(struct srp_rdma_ch *ch, u64 req_tag, u64 lun,
 		return -1;
 	}
 
-	ib_dma_sync_single_for_cpu(dev, iu->dma, sizeof *tsk_mgmt,
+	dma_sync_single_for_cpu(dev->dma_device, iu->dma, sizeof *tsk_mgmt,
 				   DMA_TO_DEVICE);
 	tsk_mgmt = iu->buf;
 	memset(tsk_mgmt, 0, sizeof *tsk_mgmt);
@@ -2700,7 +2698,7 @@ static int srp_send_tsk_mgmt(struct srp_rdma_ch *ch, u64 req_tag, u64 lun,
 	tsk_mgmt->tsk_mgmt_func = func;
 	tsk_mgmt->task_tag	= req_tag;
 
-	ib_dma_sync_single_for_device(dev, iu->dma, sizeof *tsk_mgmt,
+	dma_sync_single_for_device(dev->dma_device, iu->dma, sizeof *tsk_mgmt,
 				      DMA_TO_DEVICE);
 	if (srp_post_send(ch, iu, sizeof(*tsk_mgmt))) {
 		srp_put_tx_iu(ch, iu, SRP_IU_TSK_MGMT);
diff --git a/drivers/infiniband/ulp/srpt/ib_srpt.c b/drivers/infiniband/ulp/srpt/ib_srpt.c
index 20444a7d867d..a1c2d602a4fa 100644
--- a/drivers/infiniband/ulp/srpt/ib_srpt.c
+++ b/drivers/infiniband/ulp/srpt/ib_srpt.c
@@ -626,8 +626,8 @@ static struct srpt_ioctx *srpt_alloc_ioctx(struct srpt_device *sdev,
 	if (!ioctx->buf)
 		goto err_free_ioctx;
 
-	ioctx->dma = ib_dma_map_single(sdev->device, ioctx->buf, dma_size, dir);
-	if (ib_dma_mapping_error(sdev->device, ioctx->dma))
+	ioctx->dma = dma_map_single(sdev->device->dma_device, ioctx->buf, dma_size, dir);
+	if (dma_mapping_error(sdev->device->dma_device, ioctx->dma))
 		goto err_free_buf;
 
 	return ioctx;
@@ -649,7 +649,7 @@ static void srpt_free_ioctx(struct srpt_device *sdev, struct srpt_ioctx *ioctx,
 	if (!ioctx)
 		return;
 
-	ib_dma_unmap_single(sdev->device, ioctx->dma, dma_size, dir);
+	dma_unmap_single(sdev->device->dma_device, ioctx->dma, dma_size, dir);
 	kfree(ioctx->buf);
 	kfree(ioctx);
 }
@@ -1492,7 +1492,7 @@ static void srpt_handle_new_iu(struct srpt_rdma_ch *ch,
 	BUG_ON(!ch);
 	BUG_ON(!recv_ioctx);
 
-	ib_dma_sync_single_for_cpu(ch->sport->sdev->device,
+	dma_sync_single_for_cpu(ch->sport->sdev->device->dma_device,
 				   recv_ioctx->ioctx.dma, srp_max_req_size,
 				   DMA_FROM_DEVICE);
 
@@ -2385,7 +2385,7 @@ static void srpt_queue_response(struct se_cmd *cmd)
 		goto out;
 	}
 
-	ib_dma_sync_single_for_device(sdev->device, ioctx->ioctx.dma, resp_len,
+	dma_sync_single_for_device(sdev->device->dma_device, ioctx->ioctx.dma, resp_len,
 				      DMA_TO_DEVICE);
 
 	sge.addr = ioctx->ioctx.dma;
diff --git a/drivers/nvme/host/rdma.c b/drivers/nvme/host/rdma.c
index 208b6a08781c..de8156847327 100644
--- a/drivers/nvme/host/rdma.c
+++ b/drivers/nvme/host/rdma.c
@@ -207,7 +207,7 @@ static inline size_t nvme_rdma_inline_data_size(struct nvme_rdma_queue *queue)
 static void nvme_rdma_free_qe(struct ib_device *ibdev, struct nvme_rdma_qe *qe,
 		size_t capsule_size, enum dma_data_direction dir)
 {
-	ib_dma_unmap_single(ibdev, qe->dma, capsule_size, dir);
+	dma_unmap_single(ibdev->dma_device, qe->dma, capsule_size, dir);
 	kfree(qe->data);
 }
 
@@ -218,8 +218,8 @@ static int nvme_rdma_alloc_qe(struct ib_device *ibdev, struct nvme_rdma_qe *qe,
 	if (!qe->data)
 		return -ENOMEM;
 
-	qe->dma = ib_dma_map_single(ibdev, qe->data, capsule_size, dir);
-	if (ib_dma_mapping_error(ibdev, qe->dma)) {
+	qe->dma = dma_map_single(ibdev->dma_device, qe->data, capsule_size, dir);
+	if (dma_mapping_error(ibdev->dma_device, qe->dma)) {
 		kfree(qe->data);
 		return -ENOMEM;
 	}
@@ -895,7 +895,7 @@ static void nvme_rdma_unmap_data(struct nvme_rdma_queue *queue,
 		}
 	}
 
-	ib_dma_unmap_sg(ibdev, req->sg_table.sgl,
+	dma_unmap_sg(ibdev->dma_device, req->sg_table.sgl,
 			req->nents, rq_data_dir(rq) ==
 				    WRITE ? DMA_TO_DEVICE : DMA_FROM_DEVICE);
 
@@ -1008,7 +1008,7 @@ static int nvme_rdma_map_data(struct nvme_rdma_queue *queue,
 
 	req->nents = blk_rq_map_sg(rq->q, rq, req->sg_table.sgl);
 
-	count = ib_dma_map_sg(ibdev, req->sg_table.sgl, req->nents,
+	count = dma_map_sg(ibdev->dma_device, req->sg_table.sgl, req->nents,
 		    rq_data_dir(rq) == WRITE ? DMA_TO_DEVICE : DMA_FROM_DEVICE);
 	if (unlikely(count <= 0)) {
 		sg_free_table_chained(&req->sg_table, true);
@@ -1135,7 +1135,7 @@ static void nvme_rdma_submit_async_event(struct nvme_ctrl *arg, int aer_idx)
 	if (WARN_ON_ONCE(aer_idx != 0))
 		return;
 
-	ib_dma_sync_single_for_cpu(dev, sqe->dma, sizeof(*cmd), DMA_TO_DEVICE);
+	dma_sync_single_for_cpu(dev->dma_device, sqe->dma, sizeof(*cmd), DMA_TO_DEVICE);
 
 	memset(cmd, 0, sizeof(*cmd));
 	cmd->common.opcode = nvme_admin_async_event;
@@ -1143,7 +1143,7 @@ static void nvme_rdma_submit_async_event(struct nvme_ctrl *arg, int aer_idx)
 	cmd->common.flags |= NVME_CMD_SGL_METABUF;
 	nvme_rdma_set_sg_null(cmd);
 
-	ib_dma_sync_single_for_device(dev, sqe->dma, sizeof(*cmd),
+	dma_sync_single_for_device(dev->dma_device, sqe->dma, sizeof(*cmd),
 			DMA_TO_DEVICE);
 
 	ret = nvme_rdma_post_send(queue, sqe, &sge, 1, NULL, false);
@@ -1194,7 +1194,7 @@ static int __nvme_rdma_recv_done(struct ib_cq *cq, struct ib_wc *wc, int tag)
 		return 0;
 	}
 
-	ib_dma_sync_single_for_cpu(ibdev, qe->dma, len, DMA_FROM_DEVICE);
+	dma_sync_single_for_cpu(ibdev->dma_device, qe->dma, len, DMA_FROM_DEVICE);
 	/*
 	 * AEN requests are special as they don't time out and can
 	 * survive any kind of queue freeze and often don't respond to
@@ -1207,7 +1207,7 @@ static int __nvme_rdma_recv_done(struct ib_cq *cq, struct ib_wc *wc, int tag)
 				&cqe->result);
 	else
 		ret = nvme_rdma_process_nvme_rsp(queue, cqe, wc, tag);
-	ib_dma_sync_single_for_device(ibdev, qe->dma, len, DMA_FROM_DEVICE);
+	dma_sync_single_for_device(ibdev->dma_device, qe->dma, len, DMA_FROM_DEVICE);
 
 	nvme_rdma_post_recv(queue, qe);
 	return ret;
@@ -1455,7 +1455,7 @@ static int nvme_rdma_queue_rq(struct blk_mq_hw_ctx *hctx,
 		return BLK_MQ_RQ_QUEUE_BUSY;
 
 	dev = queue->device->dev;
-	ib_dma_sync_single_for_cpu(dev, sqe->dma,
+	dma_sync_single_for_cpu(dev->dma_device, sqe->dma,
 			sizeof(struct nvme_command), DMA_TO_DEVICE);
 
 	ret = nvme_setup_cmd(ns, rq, c);
@@ -1473,7 +1473,7 @@ static int nvme_rdma_queue_rq(struct blk_mq_hw_ctx *hctx,
 		goto err;
 	}
 
-	ib_dma_sync_single_for_device(dev, sqe->dma,
+	dma_sync_single_for_device(dev->dma_device, sqe->dma,
 			sizeof(struct nvme_command), DMA_TO_DEVICE);
 
 	if (rq->cmd_type == REQ_TYPE_FS && req_op(rq) == REQ_OP_FLUSH)
diff --git a/drivers/nvme/target/rdma.c b/drivers/nvme/target/rdma.c
index 8c3760a78ac0..447ba53a9c0b 100644
--- a/drivers/nvme/target/rdma.c
+++ b/drivers/nvme/target/rdma.c
@@ -246,9 +246,9 @@ static int nvmet_rdma_alloc_cmd(struct nvmet_rdma_device *ndev,
 	if (!c->nvme_cmd)
 		goto out;
 
-	c->sge[0].addr = ib_dma_map_single(ndev->device, c->nvme_cmd,
+	c->sge[0].addr = dma_map_single(ndev->device->dma_device, c->nvme_cmd,
 			sizeof(*c->nvme_cmd), DMA_FROM_DEVICE);
-	if (ib_dma_mapping_error(ndev->device, c->sge[0].addr))
+	if (dma_mapping_error(ndev->device->dma_device, c->sge[0].addr))
 		goto out_free_cmd;
 
 	c->sge[0].length = sizeof(*c->nvme_cmd);
@@ -259,10 +259,10 @@ static int nvmet_rdma_alloc_cmd(struct nvmet_rdma_device *ndev,
 				get_order(NVMET_RDMA_INLINE_DATA_SIZE));
 		if (!c->inline_page)
 			goto out_unmap_cmd;
-		c->sge[1].addr = ib_dma_map_page(ndev->device,
+		c->sge[1].addr = dma_map_page(ndev->device->dma_device,
 				c->inline_page, 0, NVMET_RDMA_INLINE_DATA_SIZE,
 				DMA_FROM_DEVICE);
-		if (ib_dma_mapping_error(ndev->device, c->sge[1].addr))
+		if (dma_mapping_error(ndev->device->dma_device, c->sge[1].addr))
 			goto out_free_inline_page;
 		c->sge[1].length = NVMET_RDMA_INLINE_DATA_SIZE;
 		c->sge[1].lkey = ndev->pd->local_dma_lkey;
@@ -282,7 +282,7 @@ static int nvmet_rdma_alloc_cmd(struct nvmet_rdma_device *ndev,
 				get_order(NVMET_RDMA_INLINE_DATA_SIZE));
 	}
 out_unmap_cmd:
-	ib_dma_unmap_single(ndev->device, c->sge[0].addr,
+	dma_unmap_single(ndev->device->dma_device, c->sge[0].addr,
 			sizeof(*c->nvme_cmd), DMA_FROM_DEVICE);
 out_free_cmd:
 	kfree(c->nvme_cmd);
@@ -295,12 +295,12 @@ static void nvmet_rdma_free_cmd(struct nvmet_rdma_device *ndev,
 		struct nvmet_rdma_cmd *c, bool admin)
 {
 	if (!admin) {
-		ib_dma_unmap_page(ndev->device, c->sge[1].addr,
+		dma_unmap_page(ndev->device->dma_device, c->sge[1].addr,
 				NVMET_RDMA_INLINE_DATA_SIZE, DMA_FROM_DEVICE);
 		__free_pages(c->inline_page,
 				get_order(NVMET_RDMA_INLINE_DATA_SIZE));
 	}
-	ib_dma_unmap_single(ndev->device, c->sge[0].addr,
+	dma_unmap_single(ndev->device->dma_device, c->sge[0].addr,
 				sizeof(*c->nvme_cmd), DMA_FROM_DEVICE);
 	kfree(c->nvme_cmd);
 }
@@ -350,9 +350,9 @@ static int nvmet_rdma_alloc_rsp(struct nvmet_rdma_device *ndev,
 	if (!r->req.rsp)
 		goto out;
 
-	r->send_sge.addr = ib_dma_map_single(ndev->device, r->req.rsp,
+	r->send_sge.addr = dma_map_single(ndev->device->dma_device, r->req.rsp,
 			sizeof(*r->req.rsp), DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(ndev->device, r->send_sge.addr))
+	if (dma_mapping_error(ndev->device->dma_device, r->send_sge.addr))
 		goto out_free_rsp;
 
 	r->send_sge.length = sizeof(*r->req.rsp);
@@ -378,7 +378,7 @@ static int nvmet_rdma_alloc_rsp(struct nvmet_rdma_device *ndev,
 static void nvmet_rdma_free_rsp(struct nvmet_rdma_device *ndev,
 		struct nvmet_rdma_rsp *r)
 {
-	ib_dma_unmap_single(ndev->device, r->send_sge.addr,
+	dma_unmap_single(ndev->device->dma_device, r->send_sge.addr,
 				sizeof(*r->req.rsp), DMA_TO_DEVICE);
 	kfree(r->req.rsp);
 }
diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
index 14576977200f..f2c0c60eee1d 100644
--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.h
@@ -925,21 +925,21 @@ kiblnd_rd_msg_size(struct kib_rdma_desc *rd, int msgtype, int n)
 static inline __u64
 kiblnd_dma_mapping_error(struct ib_device *dev, u64 dma_addr)
 {
-	return ib_dma_mapping_error(dev, dma_addr);
+	return dma_mapping_error(dev->dma_device, dma_addr);
 }
 
 static inline __u64 kiblnd_dma_map_single(struct ib_device *dev,
 					  void *msg, size_t size,
 					  enum dma_data_direction direction)
 {
-	return ib_dma_map_single(dev, msg, size, direction);
+	return dma_map_single(dev->dma_device, msg, size, direction);
 }
 
 static inline void kiblnd_dma_unmap_single(struct ib_device *dev,
 					   __u64 addr, size_t size,
 					  enum dma_data_direction direction)
 {
-	ib_dma_unmap_single(dev, addr, size, direction);
+	dma_unmap_single(dev->dma_device, addr, size, direction);
 }
 
 #define KIBLND_UNMAP_ADDR_SET(p, m, a)  do {} while (0)
@@ -949,26 +949,26 @@ static inline int kiblnd_dma_map_sg(struct ib_device *dev,
 				    struct scatterlist *sg, int nents,
 				    enum dma_data_direction direction)
 {
-	return ib_dma_map_sg(dev, sg, nents, direction);
+	return dma_map_sg(dev->dma_device, sg, nents, direction);
 }
 
 static inline void kiblnd_dma_unmap_sg(struct ib_device *dev,
 				       struct scatterlist *sg, int nents,
 				       enum dma_data_direction direction)
 {
-	ib_dma_unmap_sg(dev, sg, nents, direction);
+	dma_unmap_sg(dev->dma_device, sg, nents, direction);
 }
 
 static inline __u64 kiblnd_sg_dma_address(struct ib_device *dev,
 					  struct scatterlist *sg)
 {
-	return ib_sg_dma_address(dev, sg);
+	return sg_dma_address(sg);
 }
 
 static inline unsigned int kiblnd_sg_dma_len(struct ib_device *dev,
 					     struct scatterlist *sg)
 {
-	return ib_sg_dma_len(dev, sg);
+	return sg_dma_len(sg);
 }
 
 /* XXX We use KIBLND_CONN_PARAM(e) as writable buffer, it's not strictly */
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index de8dfb61d2b6..b4b83603b5df 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -2912,224 +2912,6 @@ static inline int ib_req_ncomp_notif(struct ib_cq *cq, int wc_cnt)
 }
 
 /**
- * ib_dma_mapping_error - check a DMA addr for error
- * @dev: The device for which the dma_addr was created
- * @dma_addr: The DMA address to check
- */
-static inline int ib_dma_mapping_error(struct ib_device *dev, u64 dma_addr)
-{
-	return dma_mapping_error(dev->dma_device, dma_addr);
-}
-
-/**
- * ib_dma_map_single - Map a kernel virtual address to DMA address
- * @dev: The device for which the dma_addr is to be created
- * @cpu_addr: The kernel virtual address
- * @size: The size of the region in bytes
- * @direction: The direction of the DMA
- */
-static inline u64 ib_dma_map_single(struct ib_device *dev,
-				    void *cpu_addr, size_t size,
-				    enum dma_data_direction direction)
-{
-	return dma_map_single(dev->dma_device, cpu_addr, size, direction);
-}
-
-/**
- * ib_dma_unmap_single - Destroy a mapping created by ib_dma_map_single()
- * @dev: The device for which the DMA address was created
- * @addr: The DMA address
- * @size: The size of the region in bytes
- * @direction: The direction of the DMA
- */
-static inline void ib_dma_unmap_single(struct ib_device *dev,
-				       u64 addr, size_t size,
-				       enum dma_data_direction direction)
-{
-	dma_unmap_single(dev->dma_device, addr, size, direction);
-}
-
-static inline u64 ib_dma_map_single_attrs(struct ib_device *dev,
-					  void *cpu_addr, size_t size,
-					  enum dma_data_direction direction,
-					  unsigned long dma_attrs)
-{
-	return dma_map_single_attrs(dev->dma_device, cpu_addr, size,
-				    direction, dma_attrs);
-}
-
-static inline void ib_dma_unmap_single_attrs(struct ib_device *dev,
-					     u64 addr, size_t size,
-					     enum dma_data_direction direction,
-					     unsigned long dma_attrs)
-{
-	return dma_unmap_single_attrs(dev->dma_device, addr, size,
-				      direction, dma_attrs);
-}
-
-/**
- * ib_dma_map_page - Map a physical page to DMA address
- * @dev: The device for which the dma_addr is to be created
- * @page: The page to be mapped
- * @offset: The offset within the page
- * @size: The size of the region in bytes
- * @direction: The direction of the DMA
- */
-static inline u64 ib_dma_map_page(struct ib_device *dev,
-				  struct page *page,
-				  unsigned long offset,
-				  size_t size,
-					 enum dma_data_direction direction)
-{
-	return dma_map_page(dev->dma_device, page, offset, size, direction);
-}
-
-/**
- * ib_dma_unmap_page - Destroy a mapping created by ib_dma_map_page()
- * @dev: The device for which the DMA address was created
- * @addr: The DMA address
- * @size: The size of the region in bytes
- * @direction: The direction of the DMA
- */
-static inline void ib_dma_unmap_page(struct ib_device *dev,
-				     u64 addr, size_t size,
-				     enum dma_data_direction direction)
-{
-	dma_unmap_page(dev->dma_device, addr, size, direction);
-}
-
-/**
- * ib_dma_map_sg - Map a scatter/gather list to DMA addresses
- * @dev: The device for which the DMA addresses are to be created
- * @sg: The array of scatter/gather entries
- * @nents: The number of scatter/gather entries
- * @direction: The direction of the DMA
- */
-static inline int ib_dma_map_sg(struct ib_device *dev,
-				struct scatterlist *sg, int nents,
-				enum dma_data_direction direction)
-{
-	return dma_map_sg(dev->dma_device, sg, nents, direction);
-}
-
-/**
- * ib_dma_unmap_sg - Unmap a scatter/gather list of DMA addresses
- * @dev: The device for which the DMA addresses were created
- * @sg: The array of scatter/gather entries
- * @nents: The number of scatter/gather entries
- * @direction: The direction of the DMA
- */
-static inline void ib_dma_unmap_sg(struct ib_device *dev,
-				   struct scatterlist *sg, int nents,
-				   enum dma_data_direction direction)
-{
-	dma_unmap_sg(dev->dma_device, sg, nents, direction);
-}
-
-static inline int ib_dma_map_sg_attrs(struct ib_device *dev,
-				      struct scatterlist *sg, int nents,
-				      enum dma_data_direction direction,
-				      unsigned long dma_attrs)
-{
-	return dma_map_sg_attrs(dev->dma_device, sg, nents, direction,
-				dma_attrs);
-}
-
-static inline void ib_dma_unmap_sg_attrs(struct ib_device *dev,
-					 struct scatterlist *sg, int nents,
-					 enum dma_data_direction direction,
-					 unsigned long dma_attrs)
-{
-	dma_unmap_sg_attrs(dev->dma_device, sg, nents, direction, dma_attrs);
-}
-/**
- * ib_sg_dma_address - Return the DMA address from a scatter/gather entry
- * @dev: The device for which the DMA addresses were created
- * @sg: The scatter/gather entry
- *
- * Note: this function is obsolete. To do: change all occurrences of
- * ib_sg_dma_address() into sg_dma_address().
- */
-static inline u64 ib_sg_dma_address(struct ib_device *dev,
-				    struct scatterlist *sg)
-{
-	return sg_dma_address(sg);
-}
-
-/**
- * ib_sg_dma_len - Return the DMA length from a scatter/gather entry
- * @dev: The device for which the DMA addresses were created
- * @sg: The scatter/gather entry
- *
- * Note: this function is obsolete. To do: change all occurrences of
- * ib_sg_dma_len() into sg_dma_len().
- */
-static inline unsigned int ib_sg_dma_len(struct ib_device *dev,
-					 struct scatterlist *sg)
-{
-	return sg_dma_len(sg);
-}
-
-/**
- * ib_dma_sync_single_for_cpu - Prepare DMA region to be accessed by CPU
- * @dev: The device for which the DMA address was created
- * @addr: The DMA address
- * @size: The size of the region in bytes
- * @dir: The direction of the DMA
- */
-static inline void ib_dma_sync_single_for_cpu(struct ib_device *dev,
-					      u64 addr,
-					      size_t size,
-					      enum dma_data_direction dir)
-{
-	dma_sync_single_for_cpu(dev->dma_device, addr, size, dir);
-}
-
-/**
- * ib_dma_sync_single_for_device - Prepare DMA region to be accessed by device
- * @dev: The device for which the DMA address was created
- * @addr: The DMA address
- * @size: The size of the region in bytes
- * @dir: The direction of the DMA
- */
-static inline void ib_dma_sync_single_for_device(struct ib_device *dev,
-						 u64 addr,
-						 size_t size,
-						 enum dma_data_direction dir)
-{
-	dma_sync_single_for_device(dev->dma_device, addr, size, dir);
-}
-
-/**
- * ib_dma_alloc_coherent - Allocate memory and map it for DMA
- * @dev: The device for which the DMA address is requested
- * @size: The size of the region to allocate in bytes
- * @dma_handle: A pointer for returning the DMA address of the region
- * @flag: memory allocator flags
- */
-static inline void *ib_dma_alloc_coherent(struct ib_device *dev,
-					   size_t size,
-					   dma_addr_t *dma_handle,
-					   gfp_t flag)
-{
-	return dma_alloc_coherent(dev->dma_device, size, dma_handle, flag);
-}
-
-/**
- * ib_dma_free_coherent - Free memory allocated by ib_dma_alloc_coherent()
- * @dev: The device for which the DMA addresses were allocated
- * @size: The size of the region
- * @cpu_addr: the address returned by ib_dma_alloc_coherent()
- * @dma_handle: the DMA address returned by ib_dma_alloc_coherent()
- */
-static inline void ib_dma_free_coherent(struct ib_device *dev,
-					size_t size, void *cpu_addr,
-					dma_addr_t dma_handle)
-{
-	dma_free_coherent(dev->dma_device, size, cpu_addr, dma_handle);
-}
-
-/**
  * ib_dereg_mr - Deregisters a memory region and removes it from the
  *   HCA translation table.
  * @mr: The memory region to deregister.
diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 553ed4ecb6a0..38b45a37ed18 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -294,7 +294,7 @@ recv_done(struct ib_cq *cq, struct ib_wc *wc)
 	int16_t tag;
 
 	req = NULL;
-	ib_dma_unmap_single(rdma->cm_id->device, c->busa, client->msize,
+	dma_unmap_single(rdma->cm_id->device->dma_device, c->busa, client->msize,
 							 DMA_FROM_DEVICE);
 
 	if (wc->status != IB_WC_SUCCESS)
@@ -339,7 +339,7 @@ send_done(struct ib_cq *cq, struct ib_wc *wc)
 	struct p9_rdma_context *c =
 		container_of(wc->wr_cqe, struct p9_rdma_context, cqe);
 
-	ib_dma_unmap_single(rdma->cm_id->device,
+	dma_unmap_single(rdma->cm_id->device->dma_device,
 			    c->busa, c->req->tc->size,
 			    DMA_TO_DEVICE);
 	up(&rdma->sq_sem);
@@ -379,10 +379,10 @@ post_recv(struct p9_client *client, struct p9_rdma_context *c)
 	struct ib_recv_wr wr, *bad_wr;
 	struct ib_sge sge;
 
-	c->busa = ib_dma_map_single(rdma->cm_id->device,
+	c->busa = dma_map_single(rdma->cm_id->device->dma_device,
 				    c->rc->sdata, client->msize,
 				    DMA_FROM_DEVICE);
-	if (ib_dma_mapping_error(rdma->cm_id->device, c->busa))
+	if (dma_mapping_error(rdma->cm_id->device->dma_device, c->busa))
 		goto error;
 
 	c->cqe.done = recv_done;
@@ -469,10 +469,10 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 	}
 	c->req = req;
 
-	c->busa = ib_dma_map_single(rdma->cm_id->device,
+	c->busa = dma_map_single(rdma->cm_id->device->dma_device,
 				    c->req->tc->sdata, c->req->tc->size,
 				    DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(rdma->cm_id->device, c->busa)) {
+	if (dma_mapping_error(rdma->cm_id->device->dma_device, c->busa)) {
 		err = -EIO;
 		goto send_error;
 	}
diff --git a/net/rds/ib.h b/net/rds/ib.h
index d21ca88ab628..02e5fe8d6af8 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -275,45 +275,6 @@ struct rds_ib_statistics {
 
 extern struct workqueue_struct *rds_ib_wq;
 
-/*
- * Fake ib_dma_sync_sg_for_{cpu,device} as long as ib_verbs.h
- * doesn't define it.
- */
-static inline void rds_ib_dma_sync_sg_for_cpu(struct ib_device *dev,
-					      struct scatterlist *sglist,
-					      unsigned int sg_dma_len,
-					      int direction)
-{
-	struct scatterlist *sg;
-	unsigned int i;
-
-	for_each_sg(sglist, sg, sg_dma_len, i) {
-		ib_dma_sync_single_for_cpu(dev,
-				ib_sg_dma_address(dev, sg),
-				ib_sg_dma_len(dev, sg),
-				direction);
-	}
-}
-#define ib_dma_sync_sg_for_cpu	rds_ib_dma_sync_sg_for_cpu
-
-static inline void rds_ib_dma_sync_sg_for_device(struct ib_device *dev,
-						 struct scatterlist *sglist,
-						 unsigned int sg_dma_len,
-						 int direction)
-{
-	struct scatterlist *sg;
-	unsigned int i;
-
-	for_each_sg(sglist, sg, sg_dma_len, i) {
-		ib_dma_sync_single_for_device(dev,
-				ib_sg_dma_address(dev, sg),
-				ib_sg_dma_len(dev, sg),
-				direction);
-	}
-}
-#define ib_dma_sync_sg_for_device	rds_ib_dma_sync_sg_for_device
-
-
 /* ib.c */
 extern struct rds_transport rds_ib_transport;
 struct rds_ib_device *rds_ib_get_client_data(struct ib_device *device);
diff --git a/net/rds/ib_cm.c b/net/rds/ib_cm.c
index 5b2ab95afa07..7bd69104e8ba 100644
--- a/net/rds/ib_cm.c
+++ b/net/rds/ib_cm.c
@@ -456,31 +456,31 @@ static int rds_ib_setup_qp(struct rds_connection *conn)
 		goto out;
 	}
 
-	ic->i_send_hdrs = ib_dma_alloc_coherent(dev,
+	ic->i_send_hdrs = dma_alloc_coherent(dev->dma_device,
 					   ic->i_send_ring.w_nr *
 						sizeof(struct rds_header),
 					   &ic->i_send_hdrs_dma, GFP_KERNEL);
 	if (!ic->i_send_hdrs) {
 		ret = -ENOMEM;
-		rdsdebug("ib_dma_alloc_coherent send failed\n");
+		rdsdebug("dma_alloc_coherent send failed\n");
 		goto out;
 	}
 
-	ic->i_recv_hdrs = ib_dma_alloc_coherent(dev,
+	ic->i_recv_hdrs = dma_alloc_coherent(dev->dma_device,
 					   ic->i_recv_ring.w_nr *
 						sizeof(struct rds_header),
 					   &ic->i_recv_hdrs_dma, GFP_KERNEL);
 	if (!ic->i_recv_hdrs) {
 		ret = -ENOMEM;
-		rdsdebug("ib_dma_alloc_coherent recv failed\n");
+		rdsdebug("dma_alloc_coherent recv failed\n");
 		goto out;
 	}
 
-	ic->i_ack = ib_dma_alloc_coherent(dev, sizeof(struct rds_header),
+	ic->i_ack = dma_alloc_coherent(dev->dma_device, sizeof(struct rds_header),
 				       &ic->i_ack_dma, GFP_KERNEL);
 	if (!ic->i_ack) {
 		ret = -ENOMEM;
-		rdsdebug("ib_dma_alloc_coherent ack failed\n");
+		rdsdebug("dma_alloc_coherent ack failed\n");
 		goto out;
 	}
 
@@ -781,21 +781,21 @@ void rds_ib_conn_path_shutdown(struct rds_conn_path *cp)
 
 		/* then free the resources that ib callbacks use */
 		if (ic->i_send_hdrs)
-			ib_dma_free_coherent(dev,
+			dma_free_coherent(dev->dma_device,
 					   ic->i_send_ring.w_nr *
 						sizeof(struct rds_header),
 					   ic->i_send_hdrs,
 					   ic->i_send_hdrs_dma);
 
 		if (ic->i_recv_hdrs)
-			ib_dma_free_coherent(dev,
+			dma_free_coherent(dev->dma_device,
 					   ic->i_recv_ring.w_nr *
 						sizeof(struct rds_header),
 					   ic->i_recv_hdrs,
 					   ic->i_recv_hdrs_dma);
 
 		if (ic->i_ack)
-			ib_dma_free_coherent(dev, sizeof(struct rds_header),
+			dma_free_coherent(dev->dma_device, sizeof(struct rds_header),
 					     ic->i_ack, ic->i_ack_dma);
 
 		if (ic->i_sends)
diff --git a/net/rds/ib_fmr.c b/net/rds/ib_fmr.c
index 4fe8f4fec4ee..150e8f756bd9 100644
--- a/net/rds/ib_fmr.c
+++ b/net/rds/ib_fmr.c
@@ -100,7 +100,7 @@ int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev, struct rds_ib_mr *ibmr,
 	int i, j;
 	int ret;
 
-	sg_dma_len = ib_dma_map_sg(dev, sg, nents, DMA_BIDIRECTIONAL);
+	sg_dma_len = dma_map_sg(dev->dma_device, sg, nents, DMA_BIDIRECTIONAL);
 	if (unlikely(!sg_dma_len)) {
 		pr_warn("RDS/IB: %s failed!\n", __func__);
 		return -EBUSY;
@@ -110,8 +110,8 @@ int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev, struct rds_ib_mr *ibmr,
 	page_cnt = 0;
 
 	for (i = 0; i < sg_dma_len; ++i) {
-		unsigned int dma_len = ib_sg_dma_len(dev, &scat[i]);
-		u64 dma_addr = ib_sg_dma_address(dev, &scat[i]);
+		unsigned int dma_len = sg_dma_len(&scat[i]);
+		u64 dma_addr = sg_dma_address(&scat[i]);
 
 		if (dma_addr & ~PAGE_MASK) {
 			if (i > 0)
@@ -140,8 +140,8 @@ int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev, struct rds_ib_mr *ibmr,
 
 	page_cnt = 0;
 	for (i = 0; i < sg_dma_len; ++i) {
-		unsigned int dma_len = ib_sg_dma_len(dev, &scat[i]);
-		u64 dma_addr = ib_sg_dma_address(dev, &scat[i]);
+		unsigned int dma_len = sg_dma_len(&scat[i]);
+		u64 dma_addr = sg_dma_address(&scat[i]);
 
 		for (j = 0; j < dma_len; j += PAGE_SIZE)
 			dma_pages[page_cnt++] =
diff --git a/net/rds/ib_frmr.c b/net/rds/ib_frmr.c
index d921adc62765..e30a8c6f003f 100644
--- a/net/rds/ib_frmr.c
+++ b/net/rds/ib_frmr.c
@@ -169,7 +169,7 @@ static int rds_ib_map_frmr(struct rds_ib_device *rds_ibdev,
 	ibmr->sg_dma_len = 0;
 	frmr->sg_byte_len = 0;
 	WARN_ON(ibmr->sg_dma_len);
-	ibmr->sg_dma_len = ib_dma_map_sg(dev, ibmr->sg, ibmr->sg_len,
+	ibmr->sg_dma_len = dma_map_sg(dev->dma_device, ibmr->sg, ibmr->sg_len,
 					 DMA_BIDIRECTIONAL);
 	if (unlikely(!ibmr->sg_dma_len)) {
 		pr_warn("RDS/IB: %s failed!\n", __func__);
@@ -182,8 +182,8 @@ static int rds_ib_map_frmr(struct rds_ib_device *rds_ibdev,
 
 	ret = -EINVAL;
 	for (i = 0; i < ibmr->sg_dma_len; ++i) {
-		unsigned int dma_len = ib_sg_dma_len(dev, &ibmr->sg[i]);
-		u64 dma_addr = ib_sg_dma_address(dev, &ibmr->sg[i]);
+		unsigned int dma_len = sg_dma_len(&ibmr->sg[i]);
+		u64 dma_addr = sg_dma_address(&ibmr->sg[i]);
 
 		frmr->sg_byte_len += dma_len;
 		if (dma_addr & ~PAGE_MASK) {
@@ -221,7 +221,7 @@ static int rds_ib_map_frmr(struct rds_ib_device *rds_ibdev,
 	return ret;
 
 out_unmap:
-	ib_dma_unmap_sg(rds_ibdev->dev, ibmr->sg, ibmr->sg_len,
+	dma_unmap_sg(rds_ibdev->dev->dma_device, ibmr->sg, ibmr->sg_len,
 			DMA_BIDIRECTIONAL);
 	ibmr->sg_dma_len = 0;
 	return ret;
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 977f69886c00..b8276915ab3d 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -221,11 +221,11 @@ void rds_ib_sync_mr(void *trans_private, int direction)
 
 	switch (direction) {
 	case DMA_FROM_DEVICE:
-		ib_dma_sync_sg_for_cpu(rds_ibdev->dev, ibmr->sg,
+		dma_sync_sg_for_cpu(rds_ibdev->dev->dma_device, ibmr->sg,
 			ibmr->sg_dma_len, DMA_BIDIRECTIONAL);
 		break;
 	case DMA_TO_DEVICE:
-		ib_dma_sync_sg_for_device(rds_ibdev->dev, ibmr->sg,
+		dma_sync_sg_for_device(rds_ibdev->dev->dma_device, ibmr->sg,
 			ibmr->sg_dma_len, DMA_BIDIRECTIONAL);
 		break;
 	}
@@ -236,7 +236,7 @@ void __rds_ib_teardown_mr(struct rds_ib_mr *ibmr)
 	struct rds_ib_device *rds_ibdev = ibmr->device;
 
 	if (ibmr->sg_dma_len) {
-		ib_dma_unmap_sg(rds_ibdev->dev,
+		dma_unmap_sg(rds_ibdev->dev->dma_device,
 				ibmr->sg, ibmr->sg_len,
 				DMA_BIDIRECTIONAL);
 		ibmr->sg_dma_len = 0;
diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index 606a11f681d2..374a4e038b24 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -225,7 +225,7 @@ static void rds_ib_recv_clear_one(struct rds_ib_connection *ic,
 		recv->r_ibinc = NULL;
 	}
 	if (recv->r_frag) {
-		ib_dma_unmap_sg(ic->i_cm_id->device, &recv->r_frag->f_sg, 1, DMA_FROM_DEVICE);
+		dma_unmap_sg(ic->i_cm_id->device->dma_device, &recv->r_frag->f_sg, 1, DMA_FROM_DEVICE);
 		rds_ib_frag_free(ic, recv->r_frag);
 		recv->r_frag = NULL;
 	}
@@ -331,7 +331,7 @@ static int rds_ib_recv_refill_one(struct rds_connection *conn,
 	if (!recv->r_frag)
 		goto out;
 
-	ret = ib_dma_map_sg(ic->i_cm_id->device, &recv->r_frag->f_sg,
+	ret = dma_map_sg(ic->i_cm_id->device->dma_device, &recv->r_frag->f_sg,
 			    1, DMA_FROM_DEVICE);
 	WARN_ON(ret != 1);
 
@@ -340,8 +340,8 @@ static int rds_ib_recv_refill_one(struct rds_connection *conn,
 	sge->length = sizeof(struct rds_header);
 
 	sge = &recv->r_sge[1];
-	sge->addr = ib_sg_dma_address(ic->i_cm_id->device, &recv->r_frag->f_sg);
-	sge->length = ib_sg_dma_len(ic->i_cm_id->device, &recv->r_frag->f_sg);
+	sge->addr = sg_dma_address(&recv->r_frag->f_sg);
+	sge->length = sg_dma_len(&recv->r_frag->f_sg);
 
 	ret = 0;
 out:
@@ -408,9 +408,7 @@ void rds_ib_recv_refill(struct rds_connection *conn, int prefill, gfp_t gfp)
 		ret = ib_post_recv(ic->i_cm_id->qp, &recv->r_wr, &failed_wr);
 		rdsdebug("recv %p ibinc %p page %p addr %lu ret %d\n", recv,
 			 recv->r_ibinc, sg_page(&recv->r_frag->f_sg),
-			 (long) ib_sg_dma_address(
-				ic->i_cm_id->device,
-				&recv->r_frag->f_sg),
+			 (long) sg_dma_address(&recv->r_frag->f_sg),
 			ret);
 		if (ret) {
 			rds_ib_conn_error(conn, "recv post on "
@@ -968,7 +966,7 @@ void rds_ib_recv_cqe_handler(struct rds_ib_connection *ic,
 
 	rds_ib_stats_inc(s_ib_rx_cq_event);
 	recv = &ic->i_recvs[rds_ib_ring_oldest(&ic->i_recv_ring)];
-	ib_dma_unmap_sg(ic->i_cm_id->device, &recv->r_frag->f_sg, 1,
+	dma_unmap_sg(ic->i_cm_id->device->dma_device, &recv->r_frag->f_sg, 1,
 			DMA_FROM_DEVICE);
 
 	/* Also process recvs in connecting state because it is possible
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 84d90c97332f..bd23633e5c7a 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -74,7 +74,7 @@ static void rds_ib_send_unmap_data(struct rds_ib_connection *ic,
 				   int wc_status)
 {
 	if (op->op_nents)
-		ib_dma_unmap_sg(ic->i_cm_id->device,
+		dma_unmap_sg(ic->i_cm_id->device->dma_device,
 				op->op_sg, op->op_nents,
 				DMA_TO_DEVICE);
 }
@@ -84,7 +84,7 @@ static void rds_ib_send_unmap_rdma(struct rds_ib_connection *ic,
 				   int wc_status)
 {
 	if (op->op_mapped) {
-		ib_dma_unmap_sg(ic->i_cm_id->device,
+		dma_unmap_sg(ic->i_cm_id->device->dma_device,
 				op->op_sg, op->op_nents,
 				op->op_write ? DMA_TO_DEVICE : DMA_FROM_DEVICE);
 		op->op_mapped = 0;
@@ -106,7 +106,7 @@ static void rds_ib_send_unmap_rdma(struct rds_ib_connection *ic,
 	 * handling in the ACK processing code.
 	 *
 	 * Note: There's no need to explicitly sync any RDMA buffers using
-	 * ib_dma_sync_sg_for_cpu - the completion for the RDMA
+	 * dma_sync_sg_for_cpu - the completion for the RDMA
 	 * operation itself unmapped the RDMA buffers, which takes care
 	 * of synching.
 	 */
@@ -125,7 +125,7 @@ static void rds_ib_send_unmap_atomic(struct rds_ib_connection *ic,
 {
 	/* unmap atomic recvbuf */
 	if (op->op_mapped) {
-		ib_dma_unmap_sg(ic->i_cm_id->device, op->op_sg, 1,
+		dma_unmap_sg(ic->i_cm_id->device->dma_device, op->op_sg, 1,
 				DMA_FROM_DEVICE);
 		op->op_mapped = 0;
 	}
@@ -546,7 +546,7 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 	/* map the message the first time we see it */
 	if (!ic->i_data_op) {
 		if (rm->data.op_nents) {
-			rm->data.op_count = ib_dma_map_sg(dev,
+			rm->data.op_count = dma_map_sg(dev->dma_device,
 							  rm->data.op_sg,
 							  rm->data.op_nents,
 							  DMA_TO_DEVICE);
@@ -640,16 +640,16 @@ int rds_ib_xmit(struct rds_connection *conn, struct rds_message *rm,
 		if (i < work_alloc
 		    && scat != &rm->data.op_sg[rm->data.op_count]) {
 			len = min(RDS_FRAG_SIZE,
-				ib_sg_dma_len(dev, scat) - rm->data.op_dmaoff);
+				sg_dma_len(scat) - rm->data.op_dmaoff);
 			send->s_wr.num_sge = 2;
 
-			send->s_sge[1].addr = ib_sg_dma_address(dev, scat);
+			send->s_sge[1].addr = sg_dma_address(scat);
 			send->s_sge[1].addr += rm->data.op_dmaoff;
 			send->s_sge[1].length = len;
 
 			bytes_sent += len;
 			rm->data.op_dmaoff += len;
-			if (rm->data.op_dmaoff == ib_sg_dma_len(dev, scat)) {
+			if (rm->data.op_dmaoff == sg_dma_len(scat)) {
 				scat++;
 				rm->data.op_dmasg++;
 				rm->data.op_dmaoff = 0;
@@ -797,7 +797,7 @@ int rds_ib_xmit_atomic(struct rds_connection *conn, struct rm_atomic_op *op)
 	rds_message_addref(container_of(send->s_op, struct rds_message, atomic));
 
 	/* map 8 byte retval buffer to the device */
-	ret = ib_dma_map_sg(ic->i_cm_id->device, op->op_sg, 1, DMA_FROM_DEVICE);
+	ret = dma_map_sg(ic->i_cm_id->device->dma_device, op->op_sg, 1, DMA_FROM_DEVICE);
 	rdsdebug("ic %p mapping atomic op %p. mapped %d pg\n", ic, op, ret);
 	if (ret != 1) {
 		rds_ib_ring_unalloc(&ic->i_send_ring, work_alloc);
@@ -807,8 +807,8 @@ int rds_ib_xmit_atomic(struct rds_connection *conn, struct rm_atomic_op *op)
 	}
 
 	/* Convert our struct scatterlist to struct ib_sge */
-	send->s_sge[0].addr = ib_sg_dma_address(ic->i_cm_id->device, op->op_sg);
-	send->s_sge[0].length = ib_sg_dma_len(ic->i_cm_id->device, op->op_sg);
+	send->s_sge[0].addr = sg_dma_address(op->op_sg);
+	send->s_sge[0].length = sg_dma_len(op->op_sg);
 	send->s_sge[0].lkey = ic->i_pd->local_dma_lkey;
 
 	rdsdebug("rva %Lx rpa %Lx len %u\n", op->op_remote_addr,
@@ -861,7 +861,7 @@ int rds_ib_xmit_rdma(struct rds_connection *conn, struct rm_rdma_op *op)
 
 	/* map the op the first time we see it */
 	if (!op->op_mapped) {
-		op->op_count = ib_dma_map_sg(ic->i_cm_id->device,
+		op->op_count = dma_map_sg(ic->i_cm_id->device->dma_device,
 					     op->op_sg, op->op_nents, (op->op_write) ?
 					     DMA_TO_DEVICE : DMA_FROM_DEVICE);
 		rdsdebug("ic %p mapping op %p: %d\n", ic, op, op->op_count);
@@ -920,9 +920,9 @@ int rds_ib_xmit_rdma(struct rds_connection *conn, struct rm_rdma_op *op)
 
 		for (j = 0; j < send->s_rdma_wr.wr.num_sge &&
 		     scat != &op->op_sg[op->op_count]; j++) {
-			len = ib_sg_dma_len(ic->i_cm_id->device, scat);
+			len = sg_dma_len(scat);
 			send->s_sge[j].addr =
-				 ib_sg_dma_address(ic->i_cm_id->device, scat);
+				 sg_dma_address(scat);
 			send->s_sge[j].length = len;
 			send->s_sge[j].lkey = ic->i_pd->local_dma_lkey;
 
diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 1ebb09e1ac4f..e47bf78ec478 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -136,7 +136,7 @@ fmr_op_recover_mr(struct rpcrdma_mw *mw)
 	rc = __fmr_unmap(mw);
 
 	/* ORDER: then DMA unmap */
-	ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
+	dma_unmap_sg(r_xprt->rx_ia.ri_device->dma_device,
 			mw->mw_sg, mw->mw_nents, mw->mw_dir);
 	if (rc)
 		goto out_release;
@@ -218,7 +218,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (i == 0)
 		goto out_dmamap_err;
 
-	if (!ib_dma_map_sg(r_xprt->rx_ia.ri_device,
+	if (!dma_map_sg(r_xprt->rx_ia.ri_device->dma_device,
 			   mw->mw_sg, mw->mw_nents, mw->mw_dir))
 		goto out_dmamap_err;
 
@@ -284,7 +284,7 @@ fmr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
 		list_del_init(&mw->mw_list);
 		list_del_init(&mw->fmr.fm_mr->list);
-		ib_dma_unmap_sg(r_xprt->rx_ia.ri_device,
+		dma_unmap_sg(r_xprt->rx_ia.ri_device->dma_device,
 				mw->mw_sg, mw->mw_nents, mw->mw_dir);
 		rpcrdma_put_mw(r_xprt, mw);
 	}
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 47bed5333c7f..65863a52a070 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -182,7 +182,7 @@ frwr_op_recover_mr(struct rpcrdma_mw *mw)
 
 	rc = __frwr_reset_mr(ia, mw);
 	if (state != FRMR_FLUSHED_LI)
-		ib_dma_unmap_sg(ia->ri_device,
+		dma_unmap_sg(ia->ri_device->dma_device,
 				mw->mw_sg, mw->mw_nents, mw->mw_dir);
 	if (rc)
 		goto out_release;
@@ -396,7 +396,7 @@ frwr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
 	if (i == 0)
 		goto out_dmamap_err;
 
-	dma_nents = ib_dma_map_sg(ia->ri_device,
+	dma_nents = dma_map_sg(ia->ri_device->dma_device,
 				  mw->mw_sg, mw->mw_nents, mw->mw_dir);
 	if (!dma_nents)
 		goto out_dmamap_err;
@@ -538,7 +538,7 @@ frwr_op_unmap_sync(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 		dprintk("RPC:       %s: DMA unmapping frmr %p\n",
 			__func__, &mw->frmr);
 		list_del_init(&mw->mw_list);
-		ib_dma_unmap_sg(ia->ri_device,
+		dma_unmap_sg(ia->ri_device->dma_device,
 				mw->mw_sg, mw->mw_nents, mw->mw_dir);
 		rpcrdma_put_mw(r_xprt, mw);
 	}
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index c52e0f2ffe52..8dbc42bd0080 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -476,7 +476,7 @@ rpcrdma_prepare_hdr_sge(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 	}
 	sge->length = len;
 
-	ib_dma_sync_single_for_device(ia->ri_device, sge->addr,
+	dma_sync_single_for_device(ia->ri_device->dma_device, sge->addr,
 				      sge->length, DMA_TO_DEVICE);
 	req->rl_send_wr.num_sge++;
 	return true;
@@ -505,7 +505,7 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 	sge[sge_no].addr = rdmab_addr(rb);
 	sge[sge_no].length = xdr->head[0].iov_len;
 	sge[sge_no].lkey = rdmab_lkey(rb);
-	ib_dma_sync_single_for_device(device, sge[sge_no].addr,
+	dma_sync_single_for_device(device->dma_device, sge[sge_no].addr,
 				      sge[sge_no].length, DMA_TO_DEVICE);
 
 	/* If there is a Read chunk, the page list is being handled
@@ -547,10 +547,10 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 				goto out_mapping_overflow;
 
 			len = min_t(u32, PAGE_SIZE - page_base, remaining);
-			sge[sge_no].addr = ib_dma_map_page(device, *ppages,
+			sge[sge_no].addr = dma_map_page(device->dma_device, *ppages,
 							   page_base, len,
 							   DMA_TO_DEVICE);
-			if (ib_dma_mapping_error(device, sge[sge_no].addr))
+			if (dma_mapping_error(device->dma_device, sge[sge_no].addr))
 				goto out_mapping_err;
 			sge[sge_no].length = len;
 			sge[sge_no].lkey = lkey;
@@ -574,10 +574,10 @@ rpcrdma_prepare_msg_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req,
 
 map_tail:
 		sge_no++;
-		sge[sge_no].addr = ib_dma_map_page(device, page,
+		sge[sge_no].addr = dma_map_page(device->dma_device, page,
 						   page_base, len,
 						   DMA_TO_DEVICE);
-		if (ib_dma_mapping_error(device, sge[sge_no].addr))
+		if (dma_mapping_error(device->dma_device, sge[sge_no].addr))
 			goto out_mapping_err;
 		sge[sge_no].length = len;
 		sge[sge_no].lkey = lkey;
@@ -628,7 +628,7 @@ rpcrdma_unmap_sges(struct rpcrdma_ia *ia, struct rpcrdma_req *req)
 
 	sge = &req->rl_send_sge[2];
 	for (count = req->rl_mapped_sges; count--; sge++)
-		ib_dma_unmap_page(device, sge->addr, sge->length,
+		dma_unmap_page(device->dma_device, sge->addr, sge->length,
 				  DMA_TO_DEVICE);
 	req->rl_mapped_sges = 0;
 }
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 288e35c2d8f4..73f33fe09bbf 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -123,9 +123,9 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 	ctxt->sge[0].lkey = rdma->sc_pd->local_dma_lkey;
 	ctxt->sge[0].length = sndbuf->len;
 	ctxt->sge[0].addr =
-	    ib_dma_map_page(rdma->sc_cm_id->device, ctxt->pages[0], 0,
+	    dma_map_page(rdma->sc_cm_id->device->dma_device, ctxt->pages[0], 0,
 			    sndbuf->len, DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(rdma->sc_cm_id->device, ctxt->sge[0].addr)) {
+	if (dma_mapping_error(rdma->sc_cm_id->device->dma_device, ctxt->sge[0].addr)) {
 		ret = -EIO;
 		goto out_unmap;
 	}
diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 57d35fbb1c28..28768d900258 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -151,11 +151,11 @@ int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
 		rqstp->rq_respages = &rqstp->rq_arg.pages[pg_no+1];
 		rqstp->rq_next_page = rqstp->rq_respages + 1;
 		ctxt->sge[pno].addr =
-			ib_dma_map_page(xprt->sc_cm_id->device,
+			dma_map_page(xprt->sc_cm_id->device->dma_device,
 					head->arg.pages[pg_no], pg_off,
 					PAGE_SIZE - pg_off,
 					DMA_FROM_DEVICE);
-		ret = ib_dma_mapping_error(xprt->sc_cm_id->device,
+		ret = dma_mapping_error(xprt->sc_cm_id->device->dma_device,
 					   ctxt->sge[pno].addr);
 		if (ret)
 			goto err;
@@ -271,7 +271,7 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	else
 		clear_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags);
 
-	dma_nents = ib_dma_map_sg(xprt->sc_cm_id->device,
+	dma_nents = dma_map_sg(xprt->sc_cm_id->device->dma_device,
 				  frmr->sg, frmr->sg_nents,
 				  frmr->direction);
 	if (!dma_nents) {
@@ -347,7 +347,7 @@ int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
 	atomic_inc(&rdma_stat_read);
 	return ret;
  err:
-	ib_dma_unmap_sg(xprt->sc_cm_id->device,
+	dma_unmap_sg(xprt->sc_cm_id->device->dma_device,
 			frmr->sg, frmr->sg_nents, frmr->direction);
 	svc_rdma_put_context(ctxt, 0);
 	svc_rdma_put_frmr(xprt, frmr);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index ad4d286a83c5..356c31e9468e 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -148,7 +148,7 @@ static dma_addr_t dma_map_xdr(struct svcxprt_rdma *xprt,
 			page = virt_to_page(xdr->tail[0].iov_base);
 		}
 	}
-	dma_addr = ib_dma_map_page(xprt->sc_cm_id->device, page, xdr_off,
+	dma_addr = dma_map_page(xprt->sc_cm_id->device->dma_device, page, xdr_off,
 				   min_t(size_t, PAGE_SIZE, len), dir);
 	return dma_addr;
 }
@@ -269,7 +269,7 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
 			dma_map_xdr(xprt, &rqstp->rq_res, xdr_off,
 				    sge_bytes, DMA_TO_DEVICE);
 		xdr_off += sge_bytes;
-		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
+		if (dma_mapping_error(xprt->sc_cm_id->device->dma_device,
 					 sge[sge_no].addr))
 			goto err;
 		svc_rdma_count_mappings(xprt, ctxt);
@@ -478,9 +478,9 @@ static int send_reply(struct svcxprt_rdma *rdma,
 	ctxt->sge[0].lkey = rdma->sc_pd->local_dma_lkey;
 	ctxt->sge[0].length = svc_rdma_xdr_get_reply_hdr_len(rdma_resp);
 	ctxt->sge[0].addr =
-	    ib_dma_map_page(rdma->sc_cm_id->device, page, 0,
+	    dma_map_page(rdma->sc_cm_id->device->dma_device, page, 0,
 			    ctxt->sge[0].length, DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(rdma->sc_cm_id->device, ctxt->sge[0].addr))
+	if (dma_mapping_error(rdma->sc_cm_id->device->dma_device, ctxt->sge[0].addr))
 		goto err;
 	svc_rdma_count_mappings(rdma, ctxt);
 
@@ -495,7 +495,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
 			dma_map_xdr(rdma, &rqstp->rq_res, xdr_off,
 				    sge_bytes, DMA_TO_DEVICE);
 		xdr_off += sge_bytes;
-		if (ib_dma_mapping_error(rdma->sc_cm_id->device,
+		if (dma_mapping_error(rdma->sc_cm_id->device->dma_device,
 					 ctxt->sge[sge_no].addr))
 			goto err;
 		svc_rdma_count_mappings(rdma, ctxt);
@@ -677,9 +677,9 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
 	/* Prepare SGE for local address */
 	ctxt->sge[0].lkey = xprt->sc_pd->local_dma_lkey;
 	ctxt->sge[0].length = length;
-	ctxt->sge[0].addr = ib_dma_map_page(xprt->sc_cm_id->device,
+	ctxt->sge[0].addr = dma_map_page(xprt->sc_cm_id->device->dma_device,
 					    p, 0, length, DMA_TO_DEVICE);
-	if (ib_dma_mapping_error(xprt->sc_cm_id->device, ctxt->sge[0].addr)) {
+	if (dma_mapping_error(xprt->sc_cm_id->device->dma_device, ctxt->sge[0].addr)) {
 		dprintk("svcrdma: Error mapping buffer for protocol error\n");
 		svc_rdma_put_context(ctxt, 1);
 		return;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index ca2799af05a6..b9e86e3f0fad 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -237,7 +237,7 @@ void svc_rdma_unmap_dma(struct svc_rdma_op_ctxt *ctxt)
 		 * last WR that uses it completes.
 		 */
 		if (ctxt->sge[i].lkey == lkey)
-			ib_dma_unmap_page(device,
+			dma_unmap_page(device->dma_device,
 					    ctxt->sge[i].addr,
 					    ctxt->sge[i].length,
 					    ctxt->direction);
@@ -600,10 +600,10 @@ int svc_rdma_post_recv(struct svcxprt_rdma *xprt, gfp_t flags)
 		if (!page)
 			goto err_put_ctxt;
 		ctxt->pages[sge_no] = page;
-		pa = ib_dma_map_page(xprt->sc_cm_id->device,
+		pa = dma_map_page(xprt->sc_cm_id->device->dma_device,
 				     page, 0, PAGE_SIZE,
 				     DMA_FROM_DEVICE);
-		if (ib_dma_mapping_error(xprt->sc_cm_id->device, pa))
+		if (dma_mapping_error(xprt->sc_cm_id->device->dma_device, pa))
 			goto err_put_ctxt;
 		svc_rdma_count_mappings(xprt, ctxt);
 		ctxt->sge[sge_no].addr = pa;
@@ -941,7 +941,7 @@ void svc_rdma_put_frmr(struct svcxprt_rdma *rdma,
 		       struct svc_rdma_fastreg_mr *frmr)
 {
 	if (frmr) {
-		ib_dma_unmap_sg(rdma->sc_cm_id->device,
+		dma_unmap_sg(rdma->sc_cm_id->device->dma_device,
 				frmr->sg, frmr->sg_nents, frmr->direction);
 		spin_lock_bh(&rdma->sc_frmr_q_lock);
 		WARN_ON_ONCE(!list_empty(&frmr->frmr_list));
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 11d07748f699..613040464ccc 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -179,7 +179,7 @@ rpcrdma_wc_receive(struct ib_cq *cq, struct ib_wc *wc)
 	rep->rr_wc_flags = wc->wc_flags;
 	rep->rr_inv_rkey = wc->ex.invalidate_rkey;
 
-	ib_dma_sync_single_for_cpu(rep->rr_device,
+	dma_sync_single_for_cpu(rep->rr_device->dma_device,
 				   rdmab_addr(rep->rr_rdmabuf),
 				   rep->rr_len, DMA_FROM_DEVICE);
 
@@ -1259,11 +1259,11 @@ __rpcrdma_dma_map_regbuf(struct rpcrdma_ia *ia, struct rpcrdma_regbuf *rb)
 	if (rb->rg_direction == DMA_NONE)
 		return false;
 
-	rb->rg_iov.addr = ib_dma_map_single(ia->ri_device,
+	rb->rg_iov.addr = dma_map_single(ia->ri_device->dma_device,
 					    (void *)rb->rg_base,
 					    rdmab_length(rb),
 					    rb->rg_direction);
-	if (ib_dma_mapping_error(ia->ri_device, rdmab_addr(rb)))
+	if (dma_mapping_error(ia->ri_device->dma_device, rdmab_addr(rb)))
 		return false;
 
 	rb->rg_device = ia->ri_device;
@@ -1277,7 +1277,7 @@ rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb)
 	if (!rpcrdma_regbuf_is_mapped(rb))
 		return;
 
-	ib_dma_unmap_single(rb->rg_device, rdmab_addr(rb),
+	dma_unmap_single(rb->rg_device->dma_device, rdmab_addr(rb),
 			    rdmab_length(rb), rb->rg_direction);
 	rb->rg_device = NULL;
 }
-- 
2.11.0
