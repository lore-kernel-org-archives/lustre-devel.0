From: James Simmons <jsimmons@infradead.org>
Date: Fri, 11 Mar 2016 20:29:43 -0500
Subject: [lustre-devel] [PATCH 02/10] staging: lustre: remove returns in
	void function for lnet selftest
In-Reply-To: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
References: <1457746191-27981-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1457746191-27981-3-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

No reason to have returns at end of void function.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lnet/selftest/brw_test.c  |    9 +++------
 drivers/staging/lustre/lnet/selftest/conrpc.c    |    6 ------
 drivers/staging/lustre/lnet/selftest/framework.c |   14 --------------
 drivers/staging/lustre/lnet/selftest/ping_test.c |    1 -
 drivers/staging/lustre/lnet/selftest/rpc.c       |    8 --------
 drivers/staging/lustre/lnet/selftest/selftest.h  |    3 ---
 6 files changed, 3 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
index b71f4b4..7bfc0db 100644
--- a/drivers/staging/lustre/lnet/selftest/brw_test.c
+++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
@@ -331,7 +331,7 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 		       libcfs_id2str(rpc->crpc_dest), rpc->crpc_status);
 		if (!tsi->tsi_stopping) /* rpc could have been aborted */
 			atomic_inc(&sn->sn_brw_errors);
-		goto out;
+		return;
 	}
 
 	if (msg->msg_magic != SRPC_MSG_MAGIC) {
@@ -346,11 +346,11 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 	if (reply->brw_status) {
 		atomic_inc(&sn->sn_brw_errors);
 		rpc->crpc_status = -(int)reply->brw_status;
-		goto out;
+		return;
 	}
 
 	if (reqst->brw_rw == LST_BRW_WRITE)
-		goto out;
+		return;
 
 	if (brw_check_bulk(&rpc->crpc_bulk, reqst->brw_flags, magic)) {
 		CERROR("Bulk data from %s is corrupted!\n",
@@ -358,9 +358,6 @@ brw_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 		atomic_inc(&sn->sn_brw_errors);
 		rpc->crpc_status = -EBADMSG;
 	}
-
-out:
-	return;
 }
 
 static void
diff --git a/drivers/staging/lustre/lnet/selftest/conrpc.c b/drivers/staging/lustre/lnet/selftest/conrpc.c
index 5604fce..f2afa13 100644
--- a/drivers/staging/lustre/lnet/selftest/conrpc.c
+++ b/drivers/staging/lustre/lnet/selftest/conrpc.c
@@ -463,8 +463,6 @@ lstcon_rpc_trans_stat(lstcon_rpc_trans_t *trans, lstcon_trans_stat_t *stat)
 	       lstcon_rpc_stat_failure(stat, 0),
 	       lstcon_rpc_stat_total(stat, 0),
 	       stat->trs_rpc_errno, stat->trs_fwk_errno);
-
-	return;
 }
 
 int
@@ -593,8 +591,6 @@ lstcon_rpc_trans_destroy(lstcon_rpc_trans_t *trans)
 	       lstcon_rpc_trans_name(trans->tas_opc), count);
 
 	LIBCFS_FREE(trans, sizeof(*trans));
-
-	return;
 }
 
 int
@@ -1084,8 +1080,6 @@ lstcon_rpc_stat_reply(lstcon_rpc_trans_t *trans, srpc_msg_t *msg,
 
 	if (!stat->trs_fwk_errno)
 		stat->trs_fwk_errno = rc;
-
-	return;
 }
 
 int
diff --git a/drivers/staging/lustre/lnet/selftest/framework.c b/drivers/staging/lustre/lnet/selftest/framework.c
index b86db8d..04bab32 100644
--- a/drivers/staging/lustre/lnet/selftest/framework.c
+++ b/drivers/staging/lustre/lnet/selftest/framework.c
@@ -172,7 +172,6 @@ sfw_add_session_timer(void)
 	sn->sn_timer_active = 1;
 	timer->stt_expires = ktime_get_real_seconds() + sn->sn_timeout;
 	stt_add_timer(timer);
-	return;
 }
 
 static int
@@ -296,7 +295,6 @@ sfw_server_rpc_done(struct srpc_server_rpc *rpc)
 
 	if (rpc->srpc_bulk)
 		sfw_free_pages(rpc);
-	return;
 }
 
 static void
@@ -613,7 +611,6 @@ sfw_unload_test(struct sfw_test_instance *tsi)
 	 */
 	srpc_service_remove_buffers(tsc->tsc_srv_service,
 				    sfw_test_buffers(tsi));
-	return;
 }
 
 static void
@@ -648,7 +645,6 @@ sfw_destroy_test_instance(sfw_test_instance_t *tsi)
 clean:
 	sfw_unload_test(tsi);
 	LIBCFS_FREE(tsi, sizeof(*tsi));
-	return;
 }
 
 static void
@@ -667,7 +663,6 @@ sfw_destroy_batch(sfw_batch_t *tsb)
 	}
 
 	LIBCFS_FREE(tsb, sizeof(sfw_batch_t));
-	return;
 }
 
 void
@@ -687,7 +682,6 @@ sfw_destroy_session(sfw_session_t *sn)
 
 	LIBCFS_FREE(sn, sizeof(*sn));
 	atomic_dec(&sfw_data.fw_nzombies);
-	return;
 }
 
 static void
@@ -732,7 +726,6 @@ sfw_unpack_addtest_req(srpc_msg_t *msg)
 	}
 
 	LBUG();
-	return;
 }
 
 static int
@@ -870,7 +863,6 @@ sfw_test_unit_done(sfw_test_unit_t *tsu)
 	spin_unlock(&sfw_data.fw_lock);
 
 	sfw_destroy_session(sn);
-	return;
 }
 
 static void
@@ -905,7 +897,6 @@ sfw_test_rpc_done(srpc_client_rpc_t *rpc)
 	}
 
 	sfw_test_unit_done(tsu);
-	return;
 }
 
 int
@@ -1565,7 +1556,6 @@ sfw_unpack_message(srpc_msg_t *msg)
 	}
 
 	LBUG();
-	return;
 }
 
 void
@@ -1577,7 +1567,6 @@ sfw_abort_rpc(srpc_client_rpc_t *rpc)
 	spin_lock(&rpc->crpc_lock);
 	srpc_abort_rpc(rpc, -EINTR);
 	spin_unlock(&rpc->crpc_lock);
-	return;
 }
 
 void
@@ -1594,7 +1583,6 @@ sfw_post_rpc(srpc_client_rpc_t *rpc)
 	srpc_post_rpc(rpc);
 
 	spin_unlock(&rpc->crpc_lock);
-	return;
 }
 
 static srpc_service_t sfw_services[] = {
@@ -1798,6 +1786,4 @@ sfw_shutdown(void)
 		list_del(&tsc->tsc_list);
 		LIBCFS_FREE(tsc, sizeof(*tsc));
 	}
-
-	return;
 }
diff --git a/drivers/staging/lustre/lnet/selftest/ping_test.c b/drivers/staging/lustre/lnet/selftest/ping_test.c
index 6d44126..33c758a 100644
--- a/drivers/staging/lustre/lnet/selftest/ping_test.c
+++ b/drivers/staging/lustre/lnet/selftest/ping_test.c
@@ -165,7 +165,6 @@ ping_client_done_rpc(sfw_test_unit_t *tsu, srpc_client_rpc_t *rpc)
 	CDEBUG(D_NET, "%d reply in %u usec\n", reply->pnr_seq,
 	       (unsigned)((ts.tv_sec - reqst->pnr_time_sec) * 1000000 +
 			  (ts.tv_nsec / NSEC_PER_USEC - reqst->pnr_time_usec)));
-	return;
 }
 
 static int
diff --git a/drivers/staging/lustre/lnet/selftest/rpc.c b/drivers/staging/lustre/lnet/selftest/rpc.c
index 60d38df..08a0ad5 100644
--- a/drivers/staging/lustre/lnet/selftest/rpc.c
+++ b/drivers/staging/lustre/lnet/selftest/rpc.c
@@ -118,7 +118,6 @@ srpc_free_bulk(srpc_bulk_t *bk)
 	}
 
 	LIBCFS_FREE(bk, offsetof(srpc_bulk_t, bk_iovs[bk->bk_niov]));
-	return;
 }
 
 srpc_bulk_t *
@@ -960,7 +959,6 @@ srpc_server_rpc_done(struct srpc_server_rpc *rpc, int status)
 	}
 
 	spin_unlock(&scd->scd_lock);
-	return;
 }
 
 /* handles an incoming RPC */
@@ -1110,7 +1108,6 @@ srpc_add_client_rpc_timer(srpc_client_rpc_t *rpc)
 	timer->stt_func    = srpc_client_rpc_expired;
 	timer->stt_expires = ktime_get_real_seconds() + rpc->crpc_timeout;
 	stt_add_timer(timer);
-	return;
 }
 
 /*
@@ -1174,7 +1171,6 @@ srpc_client_rpc_done(srpc_client_rpc_t *rpc, int status)
 	spin_unlock(&rpc->crpc_lock);
 
 	(*rpc->crpc_done)(rpc);
-	return;
 }
 
 /* sends an outgoing RPC */
@@ -1347,7 +1343,6 @@ srpc_abort_rpc(srpc_client_rpc_t *rpc, int why)
 	rpc->crpc_aborted = 1;
 	rpc->crpc_status  = why;
 	swi_schedule_workitem(&rpc->crpc_wi);
-	return;
 }
 
 /* called with rpc->crpc_lock held */
@@ -1363,7 +1358,6 @@ srpc_post_rpc(srpc_client_rpc_t *rpc)
 
 	srpc_add_client_rpc_timer(rpc);
 	swi_schedule_workitem(&rpc->crpc_wi);
-	return;
 }
 
 int
@@ -1689,6 +1683,4 @@ srpc_shutdown(void)
 	case SRPC_STATE_NI_INIT:
 		LNetNIFini();
 	}
-
-	return;
 }
diff --git a/drivers/staging/lustre/lnet/selftest/selftest.h b/drivers/staging/lustre/lnet/selftest/selftest.h
index 4ca274f..9669088 100644
--- a/drivers/staging/lustre/lnet/selftest/selftest.h
+++ b/drivers/staging/lustre/lnet/selftest/selftest.h
@@ -512,8 +512,6 @@ srpc_destroy_client_rpc(srpc_client_rpc_t *rpc)
 		LIBCFS_FREE(rpc, srpc_client_rpc_size(rpc));
 	else
 		(*rpc->crpc_fini) (rpc);
-
-	return;
 }
 
 static inline void
@@ -552,7 +550,6 @@ srpc_init_client_rpc(srpc_client_rpc_t *rpc, lnet_process_id_t peer,
 	rpc->crpc_reqstmsg.msg_magic   = SRPC_MSG_MAGIC;
 	rpc->crpc_reqstmsg.msg_version = SRPC_MSG_VERSION;
 	rpc->crpc_reqstmsg.msg_type    = srpc_service2request(service);
-	return;
 }
 
 static inline const char *
-- 
1.7.1
