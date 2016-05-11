From: James Simmons <jsimmons@infradead.org>
Date: Wed, 11 May 2016 17:22:09 +0100 (BST)
Subject: [lustre-devel] [PATCH 1/4] staging: lustre: o2iblnd: limit
 cap.max_send_wr for MLX5 (fwd)
Message-ID: <alpine.LFD.2.20.1605111715490.27778@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> James,
>   I?m pretty sure this port to upstream is flawed.  See below

Yep. I missed that line. Thanks for review. Greg you can drop this one. I 
will submit a updated version soon. This patch series is not 
order dependent so the other patches are safe to land.
 
> On 5/9/16, 7:53 AM, "lustre-devel on behalf of James Simmons" <lustre-devel-bounces at lists.lustre.org on behalf of jsimmons@infradead.org> wrote:
> 
>>From: Dmitry Eremin <dmitry.eremin@intel.com>
>>
>>Decrease cap.max_send_wr until it is accepted by rdma_create_qp()
>>
>>Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
>>Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-7124
>>Reviewed-on: http://review.whamcloud.com/18347
>>Reviewed-by: Olaf Weber <olaf@sgi.com>
>>Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
>>Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
>>Signed-off-by: James Simmons <jsimmons@infradead.org>
>>---
>> .../staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c    |   11 ++++++++++-
>> 1 files changed, 10 insertions(+), 1 deletions(-)
>>
>>diff --git a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
>>index d99b4fa..bc179a2 100644
>>--- a/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
>>+++ b/drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c
>>@@ -768,7 +768,12 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
>> 
>>      conn->ibc_sched = sched;
>> 
>> -	rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, init_qp_attr);
>> +	do {
>> +		rc = rdma_create_qp(cmid, conn->ibc_hdev->ibh_pd, init_qp_attr);
>> +		if (!rc || init_qp_attr->cap.max_send_wr < 16)
>> +			break;
> 
> I think the loop here is missing code to decrease the max_send_wr value.  In current master it?s
> 
> 		init_qp_attr->cap.max_send_wr -= init_qp_attr->cap.max_send_wr / 4;
> 
>>+	} while (rc);
>>+
>> 	if (rc) {
>> 		CERROR("Can't create QP: %d, send_wr: %d, recv_wr: %d\n",
>> 		       rc, init_qp_attr->cap.max_send_wr,
>>@@ -776,6 +781,10 @@ kib_conn_t *kiblnd_create_conn(kib_peer_t *peer, struct rdma_cm_id *cmid,
>> 		goto failed_2;
>> 	}
>> 
>>+	if (init_qp_attr->cap.max_send_wr != IBLND_SEND_WRS(conn))
>>+		CDEBUG(D_NET, "original send wr %d, created with %d\n",
>>+		       IBLND_SEND_WRS(conn), init_qp_attr->cap.max_send_wr);
>>+
>> 	LIBCFS_FREE(init_qp_attr, sizeof(*init_qp_attr));
>> 
>> 	/* 1 ref for caller and each rxmsg */
>> -- 
>> 1.7.1
>> 
