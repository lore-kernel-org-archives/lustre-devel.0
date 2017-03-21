From: Yan Li <yanli@ascar.io>
Date: Tue, 21 Mar 2017 12:43:33 -0700
Subject: [lustre-devel] [PATCH 6/6] Adjust max_rpcs_in_flight according to
	metrics
In-Reply-To: <cover.1490122510.git.yanli@ascar.io>
References: <cover.1490122510.git.yanli@ascar.io>
Message-ID: <65d90d71d2d0cd68642149cd2526d079594c2368.1490122510.git.yanli@ascar.io>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Signed-off-by: Yan Li <yanli@ascar.io>
---
 lustre/osc/osc_request.c | 165 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 165 insertions(+)

diff --git a/lustre/osc/osc_request.c b/lustre/osc/osc_request.c
index c59c281..8efaf5a 100644
--- a/lustre/osc/osc_request.c
+++ b/lustre/osc/osc_request.c
@@ -1613,6 +1613,156 @@ static void osc_release_ppga(struct brw_page **ppga, size_t count)
         OBD_FREE(ppga, sizeof(*ppga) * count);
 }
 
+
+#ifdef ENABLE_RLQOS
+/**
+ * te's lock should be acquired beforehand
+ */
+static void time_ewma_add_extlock(struct time_ewma *te, struct timeval *new_time) {
+	__u64 old_ea = te->ea;
+	long timediff;
+
+	if (te->last_time.tv_sec != 0) {
+		timediff = cfs_timeval_sub(new_time, &te->last_time, NULL);
+		if (timediff < 0) {
+			CDEBUG(D_INFO,
+					"(te: %p) negative timediff %ld detected, using abs value\n",
+					te, timediff);
+			timediff = -timediff;
+		}
+
+		/* Reset ea to 0 if a long gap (>10min) is detected */
+		if (timediff > 10 * 60 * ONE_MILLION) {
+			CWARN("(te: %p) Long gap detected\n", te);
+			te->ea = 0;
+		} else {
+			/* ewma = ewma * (1-alpha) + amount * alpha
+			 * ea = ewma * alpha, alpha_inv = 1/alpha
+			 *
+			 * ea = ea / alpha_inv * (alpha_inv - 1) + timediff
+			 */
+			do_div(te->ea, te->alpha_inv);
+			te->ea = te->ea * (te->alpha_inv - 1) + timediff;
+			if (te->ea > 1000000) {
+				CDEBUG(D_INFO,
+				       "(te: %p) old_ea = %llu, "
+				       "old_time = %ld.%ld, "
+				       "new_time = %ld.%ld, new ea = %llu\n",
+				       te, old_ea,
+				       te->last_time.tv_sec,
+				       te->last_time.tv_usec,
+				       new_time->tv_sec,
+				       new_time->tv_usec, te->ea);
+			}
+		}
+	} else {
+		CDEBUG(D_INFO, "(te: %p) first call\n", te);
+	}
+	te->last_time = *new_time;
+}
+
+/**
+ * Calculate ewma of time values. Long gaps will be ignored.
+ */
+static int qos_adjust(struct obd_device *obd, struct timeval *new_ack_time,
+		struct timeval *new_sent_time, int op, int bytes_transferred)
+{
+	struct client_obd *cli = &obd->u.cli;
+	struct qos_data_t *qos = &cli->qos;
+	struct time_ewma *ack_ewma_p = &qos->ack_ewma;
+	struct time_ewma *sent_ewma_p = &qos->sent_ewma;
+	__u64 ack_ewma;
+	__u64 sent_ewma;
+	struct qos_rule_t *r;
+	int new_mrif = -1;  /* -1 means no change needed */
+	int i;
+	struct timeval now;
+	long rtt;
+	int rtt_ratio100;
+	long usec_since_last_mrif_update;
+
+	spin_lock(&qos->lock);
+	time_ewma_add_extlock(ack_ewma_p, new_ack_time);
+	ack_ewma = qos_get_ewma_usec(ack_ewma_p);
+
+	time_ewma_add_extlock(sent_ewma_p, new_sent_time);
+	sent_ewma = qos_get_ewma_usec(sent_ewma_p);
+
+	/* calculate rtt */
+	do_gettimeofday(&now);
+	rtt = cfs_timeval_sub(&now, new_sent_time, NULL);
+	if (0 == qos->smallest_rtt || rtt < qos->smallest_rtt) {
+		qos->smallest_rtt = rtt;
+	}
+	rtt = rtt * 100;
+	rtt_ratio100 =  rtt / qos->smallest_rtt;
+	qos->rtt_ratio100 = rtt_ratio100;
+
+	/* Calculate throughput */
+	calc_throughput(qos, op, bytes_transferred);
+
+	/* Adjust max_rpc_in_flight according to ack_ewma and send_ewma */
+	if (NULL == qos->rules) goto out;
+	if (NULL == cli->cl_import) goto out; /* or else LPROCFS_CLIMP_CHECK may return this function, leaving qos->lock locked */
+	for(i = 0; i < qos->rule_no; ++i) {
+		r = &qos->rules[i];
+		if (ack_ewma     >= r->ack_ewma_lower &&
+		    ack_ewma     <  r->ack_ewma_upper &&
+		    sent_ewma    >= r->send_ewma_lower &&
+		    sent_ewma    <  r->send_ewma_upper &&
+		    rtt_ratio100 >= r->rtt_ratio100_lower &&
+		    rtt_ratio100 <  r->rtt_ratio100_upper)
+		{
+			r->used_times++;
+			r->ack_ewma_avg += ((__s64)ack_ewma - (__s64)r->ack_ewma_avg) / r->used_times;
+			r->send_ewma_avg += ((__s64)sent_ewma - (__s64)r->send_ewma_avg) / r->used_times;
+			r->rtt_ratio100_avg += (rtt_ratio100 - (int)r->rtt_ratio100_avg) / r->used_times;
+
+			usec_since_last_mrif_update = cfs_timeval_sub(&now, &qos->last_mrif_update_time, NULL);
+			if (usec_since_last_mrif_update > 0 &&
+					usec_since_last_mrif_update >= qos->min_gap_between_updating_mrif) {
+				qos->last_mrif_update_time = now;
+				/* m100 is disabled when assigned negative values */
+				if (r->m100 >= 0) {
+					/* Must multiply m100 first, then div by 100 to avoid
+					 * losing precision */
+					qos->max_rpc_in_flight100 *= r->m100;
+					qos->max_rpc_in_flight100 /= 100;
+				}
+				qos->max_rpc_in_flight100 += r->b100;
+				CDEBUG(D_INFO, "New max_rpc_in_flight100 = %d\n", qos->max_rpc_in_flight100);
+				if (qos->max_rpc_in_flight100 < 0) {
+					CDEBUG(D_INFO, "New max_rpc_in_flight100 is negative, reset it to 0\n");
+					qos->max_rpc_in_flight100 = 0;
+				}
+				if (qos->max_rpc_in_flight100 > OSC_MAX_RIF_MAX * 100) {
+					CDEBUG(D_INFO, "New max_rpc_in_flight100 is larger than %d, reset it to max allowed value\n", OSC_MAX_RIF_MAX * 100);
+					qos->max_rpc_in_flight100 = OSC_MAX_RIF_MAX * 100;
+				}
+				new_mrif = qos->max_rpc_in_flight100 / 100;
+				if (new_mrif < 1) {
+					CDEBUG(D_INFO, "New max_rpc_in_flight is smaller than 1, reset it to 1\n");
+					new_mrif = 1;
+				}
+			}
+			/* Update min_usec_between_rpcs to tau */
+			qos->min_usec_between_rpcs = r->tau;
+			/* set MRIF after unlocking qos->lock to prevent deadlocking */
+			break;
+		}
+	}
+out:
+	spin_unlock(&qos->lock);
+
+	if (-1 != new_mrif) {   /* -1 means no change needed */
+		LPROCFS_CLIMP_CHECK(obd);
+		set_max_rpcs_in_flight(new_mrif, cli);
+		LPROCFS_CLIMP_EXIT(obd);
+	}
+	return 0;
+}
+#endif /* ENABLE_RLQOS */
+
 static int brw_interpret(const struct lu_env *env,
                          struct ptlrpc_request *req, void *data, int rc)
 {
@@ -1622,6 +1772,14 @@ static int brw_interpret(const struct lu_env *env,
 	struct client_obd *cli = aa->aa_cli;
         ENTRY;
 
+#ifdef ENABLE_RLQOS
+	qos_adjust(req->rq_import->imp_obd,
+		   &req->rq_arrival_time,
+	           &aa->aa_oa->o_sent_time,
+	           lustre_msg_get_opc(req->rq_reqmsg) - OST_READ,
+	           req->rq_bulk->bd_nob_transferred);
+#endif
+
         rc = osc_brw_fini_request(req, rc);
         CDEBUG(D_INODE, "request %p aa %p rc %d\n", req, aa, rc);
         /* When server return -EINPROGRESS, client should always retry
@@ -1874,6 +2032,10 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 	list_splice_init(&rpc_list, &aa->aa_oaps);
 	INIT_LIST_HEAD(&aa->aa_exts);
 	list_splice_init(ext_list, &aa->aa_exts);
+#ifdef ENABLE_RLQOS
+	/* sent_time is used by RLQoS */
+	do_gettimeofday(&aa->aa_oa->o_sent_time);
+#endif
 
 	spin_lock(&cli->cl_loi_list_lock);
 	starting_offset >>= PAGE_SHIFT;
@@ -1897,6 +2059,9 @@ int osc_build_rpc(const struct lu_env *env, struct client_obd *cli,
 		  cli->cl_w_in_flight);
 	OBD_FAIL_TIMEOUT(OBD_FAIL_OSC_DELAY_IO, cfs_fail_val);
 
+#ifdef ENABLE_RLQOS
+	qos_throttle(&cli->qos);
+#endif
 	ptlrpcd_add_req(req);
 	rc = 0;
 	EXIT;
-- 
1.8.3.1
