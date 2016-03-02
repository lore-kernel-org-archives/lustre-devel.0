From: James Simmons <jsimmons@infradead.org>
Date: Wed,  2 Mar 2016 17:01:47 -0500
Subject: [lustre-devel] [PATCH 04/27] staging: lustre: return proper error
	code for LNet core
In-Reply-To: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
References: <1456956130-6110-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456956130-6110-5-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>, James Simmons <uja.ornl@yahoo.com>

It is consider bad style in the linux kernel to
return -1 or a positive number for an error.
Instead return the appropriate error codes.

Signed-off-by: James Simmons <uja.ornl@yahoo.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6142
Reviewed-on: http://review.whamcloud.com/17626
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c     |    4 ++--
 drivers/staging/lustre/lnet/lnet/config.c     |    6 +++---
 drivers/staging/lustre/lnet/lnet/lib-eq.c     |    2 +-
 drivers/staging/lustre/lnet/lnet/lib-move.c   |   22 +++++++++++-----------
 drivers/staging/lustre/lnet/lnet/nidstrings.c |    2 +-
 drivers/staging/lustre/lnet/lnet/router.c     |    6 +++---
 6 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index aa24489..6c42786 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1409,7 +1409,7 @@ int lnet_lib_init(void)
 		/* we are under risk of consuming all lh_cookie */
 		CERROR("Can't have %d CPTs for LNet (max allowed is %d), please change setting of CPT-table and retry\n",
 		       the_lnet.ln_cpt_number, LNET_CPT_MAX);
-		return -1;
+		return -E2BIG;
 	}
 
 	while ((1 << the_lnet.ln_cpt_bits) < the_lnet.ln_cpt_number)
@@ -1418,7 +1418,7 @@ int lnet_lib_init(void)
 	rc = lnet_create_locks();
 	if (rc) {
 		CERROR("Can't create LNet global locks: %d\n", rc);
-		return -1;
+		return rc;
 	}
 
 	the_lnet.ln_refcount = 0;
diff --git a/drivers/staging/lustre/lnet/lnet/config.c b/drivers/staging/lustre/lnet/lnet/config.c
index 4c40acb..e71eea7 100644
--- a/drivers/staging/lustre/lnet/lnet/config.c
+++ b/drivers/staging/lustre/lnet/lnet/config.c
@@ -467,7 +467,7 @@ lnet_str2tbs_sep(struct list_head *tbs, char *str)
 			ltb = lnet_new_text_buf(nob);
 			if (!ltb) {
 				lnet_free_text_bufs(&pending);
-				return -1;
+				return -ENOMEM;
 			}
 
 			for (i = 0; i < nob; i++)
@@ -598,7 +598,7 @@ lnet_str2tbs_expand(struct list_head *tbs, char *str)
 
  failed:
 	lnet_free_text_bufs(&pending);
-	return -1;
+	return -EINVAL;
 }
 
 static int
@@ -634,7 +634,7 @@ lnet_parse_priority(char *str, unsigned int *priority, char **token)
 		 * priority as the token to report in the error message.
 		 */
 		*token += sep - str + 1;
-		return -1;
+		return -EINVAL;
 	}
 
 	CDEBUG(D_NET, "gateway %s, priority %d, nob %d\n", str, *priority, nob);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index 042e974..adbcadb 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -320,7 +320,7 @@ __must_hold(&the_lnet.ln_eq_wait_lock)
 	unsigned long now;
 
 	if (!tms)
-		return -1; /* don't want to wait and no new event */
+		return -ENXIO; /* don't want to wait and no new event */
 
 	init_waitqueue_entry(&wl, current);
 	set_current_state(TASK_INTERRUPTIBLE);
diff --git a/drivers/staging/lustre/lnet/lnet/lib-move.c b/drivers/staging/lustre/lnet/lnet/lib-move.c
index 8a21198..2d187e4 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-move.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-move.c
@@ -1167,30 +1167,30 @@ lnet_compare_routes(lnet_route_t *r1, lnet_route_t *r2)
 		return 1;
 
 	if (r1->lr_priority > r2->lr_priority)
-		return -1;
+		return -ERANGE;
 
 	if (r1_hops < r2_hops)
 		return 1;
 
 	if (r1_hops > r2_hops)
-		return -1;
+		return -ERANGE;
 
 	if (p1->lp_txqnob < p2->lp_txqnob)
 		return 1;
 
 	if (p1->lp_txqnob > p2->lp_txqnob)
-		return -1;
+		return -ERANGE;
 
 	if (p1->lp_txcredits > p2->lp_txcredits)
 		return 1;
 
 	if (p1->lp_txcredits < p2->lp_txcredits)
-		return -1;
+		return -ERANGE;
 
 	if (r1->lr_seq - r2->lr_seq <= 0)
 		return 1;
 
-	return -1;
+	return -ERANGE;
 }
 
 static lnet_peer_t *
@@ -1517,7 +1517,7 @@ lnet_parse_put(lnet_ni_t *ni, lnet_msg_t *msg)
 			libcfs_id2str(info.mi_id), info.mi_portal,
 			info.mi_mbits, info.mi_roffset, info.mi_rlength, rc);
 
-		return ENOENT;	/* +ve: OK but no match */
+		return -ENOENT;	/* -ve: OK but no match */
 	}
 }
 
@@ -1548,7 +1548,7 @@ lnet_parse_get(lnet_ni_t *ni, lnet_msg_t *msg, int rdma_get)
 		CNETERR("Dropping GET from %s portal %d match %llu offset %d length %d\n",
 			libcfs_id2str(info.mi_id), info.mi_portal,
 			info.mi_mbits, info.mi_roffset, info.mi_rlength);
-		return ENOENT;	/* +ve: OK but no match */
+		return -ENOENT;	/* -ve: OK but no match */
 	}
 
 	LASSERT(rc == LNET_MATCHMD_OK);
@@ -1615,7 +1615,7 @@ lnet_parse_reply(lnet_ni_t *ni, lnet_msg_t *msg)
 			       md->md_me->me_portal);
 
 		lnet_res_unlock(cpt);
-		return ENOENT;		  /* +ve: OK but no match */
+		return -ENOENT;	/* -ve: OK but no match */
 	}
 
 	LASSERT(!md->md_offset);
@@ -1630,7 +1630,7 @@ lnet_parse_reply(lnet_ni_t *ni, lnet_msg_t *msg)
 			rlength, hdr->msg.reply.dst_wmd.wh_object_cookie,
 			mlength);
 		lnet_res_unlock(cpt);
-		return ENOENT;	  /* +ve: OK but no match */
+		return -ENOENT;	/* -ve: OK but no match */
 	}
 
 	CDEBUG(D_NET, "%s: Reply from %s of length %d/%d into md %#llx\n",
@@ -1683,7 +1683,7 @@ lnet_parse_ack(lnet_ni_t *ni, lnet_msg_t *msg)
 			       md->md_me->me_portal);
 
 		lnet_res_unlock(cpt);
-		return ENOENT;		  /* +ve! */
+		return -ENOENT;	/* -ve! */
 	}
 
 	CDEBUG(D_NET, "%s: ACK from %s into md %#llx\n",
@@ -2030,7 +2030,7 @@ lnet_parse(lnet_ni_t *ni, lnet_hdr_t *hdr, lnet_nid_t from_nid,
 	if (!rc)
 		return 0;
 
-	LASSERT(rc == ENOENT);
+	LASSERT(rc == -ENOENT);
 
  free_drop:
 	LASSERT(!msg->msg_md);
diff --git a/drivers/staging/lustre/lnet/lnet/nidstrings.c b/drivers/staging/lustre/lnet/lnet/nidstrings.c
index 00010f3..9d1c7fd 100644
--- a/drivers/staging/lustre/lnet/lnet/nidstrings.c
+++ b/drivers/staging/lustre/lnet/lnet/nidstrings.c
@@ -1085,7 +1085,7 @@ libcfs_str2lnd(const char *str)
 	if (nf)
 		return nf->nf_type;
 
-	return -1;
+	return -ENXIO;
 }
 EXPORT_SYMBOL(libcfs_str2lnd);
 
diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
index 51a831e..9543ba3 100644
--- a/drivers/staging/lustre/lnet/lnet/router.c
+++ b/drivers/staging/lustre/lnet/lnet/router.c
@@ -1503,7 +1503,7 @@ lnet_nrb_tiny_calculate(void)
 		LCONSOLE_ERROR_MSG(0x10c,
 				   "tiny_router_buffers=%d invalid when routing enabled\n",
 				   tiny_router_buffers);
-		return -1;
+		return -EINVAL;
 	}
 
 	if (tiny_router_buffers > 0)
@@ -1522,7 +1522,7 @@ lnet_nrb_small_calculate(void)
 		LCONSOLE_ERROR_MSG(0x10c,
 				   "small_router_buffers=%d invalid when routing enabled\n",
 				   small_router_buffers);
-		return -1;
+		return -EINVAL;
 	}
 
 	if (small_router_buffers > 0)
@@ -1541,7 +1541,7 @@ lnet_nrb_large_calculate(void)
 		LCONSOLE_ERROR_MSG(0x10c,
 				   "large_router_buffers=%d invalid when routing enabled\n",
 				   large_router_buffers);
-		return -1;
+		return -EINVAL;
 	}
 
 	if (large_router_buffers > 0)
-- 
1.7.1
