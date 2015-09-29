From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:46 -0400
Subject: [lustre-devel] [PATCH 03/29] staging/lustre/ptlrpc: Remove
	server-specific health checks
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-4-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

ptlrpc_service_health_check is only used on a service, so
it makes no point to retain it in the client code.
Also removing it's helpers: ptlrpc_svcpt_health_check and
ptlrpc_nrs_req_peek_nolock

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/lustre_net.h |  1 -
 .../staging/lustre/lustre/ptlrpc/ptlrpc_internal.h |  6 ---
 drivers/staging/lustre/lustre/ptlrpc/service.c     | 58 ----------------------
 3 files changed, 65 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_net.h b/drivers/staging/lustre/lustre/include/lustre_net.h
index e929c93..a928631 100644
--- a/drivers/staging/lustre/lustre/include/lustre_net.h
+++ b/drivers/staging/lustre/lustre/include/lustre_net.h
@@ -2541,7 +2541,6 @@ int ptlrpc_start_threads(struct ptlrpc_service *svc);
 int ptlrpc_unregister_service(struct ptlrpc_service *service);
 int liblustre_check_services(void *arg);
 void ptlrpc_daemonize(char *name);
-int ptlrpc_service_health_check(struct ptlrpc_service *);
 void ptlrpc_server_drop_request(struct ptlrpc_request *req);
 void ptlrpc_request_change_export(struct ptlrpc_request *req,
 				  struct obd_export *export);
diff --git a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
index 059ad96b..a3608a9 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
+++ b/drivers/staging/lustre/lustre/ptlrpc/ptlrpc_internal.h
@@ -137,12 +137,6 @@ ptlrpc_nrs_req_get_nolock(struct ptlrpc_service_part *svcpt, bool hp,
 	return ptlrpc_nrs_req_get_nolock0(svcpt, hp, false, force);
 }
 
-static inline struct ptlrpc_request *
-ptlrpc_nrs_req_peek_nolock(struct ptlrpc_service_part *svcpt, bool hp)
-{
-	return ptlrpc_nrs_req_get_nolock0(svcpt, hp, true, false);
-}
-
 void ptlrpc_nrs_req_del_nolock(struct ptlrpc_request *req);
 bool ptlrpc_nrs_req_pending_nolock(struct ptlrpc_service_part *svcpt, bool hp);
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/service.c b/drivers/staging/lustre/lustre/ptlrpc/service.c
index 326f89e..cdc7e62 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/service.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/service.c
@@ -2977,61 +2977,3 @@ int ptlrpc_unregister_service(struct ptlrpc_service *service)
 	return 0;
 }
 EXPORT_SYMBOL(ptlrpc_unregister_service);
-
-/**
- * Returns 0 if the service is healthy.
- *
- * Right now, it just checks to make sure that requests aren't languishing
- * in the queue.  We'll use this health check to govern whether a node needs
- * to be shot, so it's intentionally non-aggressive. */
-static int ptlrpc_svcpt_health_check(struct ptlrpc_service_part *svcpt)
-{
-	struct ptlrpc_request *request = NULL;
-	struct timespec64 right_now;
-	struct timespec64 timediff;
-
-	ktime_get_real_ts64(&right_now);
-
-	spin_lock(&svcpt->scp_req_lock);
-	/* How long has the next entry been waiting? */
-	if (ptlrpc_server_high_pending(svcpt, true))
-		request = ptlrpc_nrs_req_peek_nolock(svcpt, true);
-	else if (ptlrpc_server_normal_pending(svcpt, true))
-		request = ptlrpc_nrs_req_peek_nolock(svcpt, false);
-
-	if (request == NULL) {
-		spin_unlock(&svcpt->scp_req_lock);
-		return 0;
-	}
-
-	timediff = timespec64_sub(right_now, request->rq_arrival_time);
-	spin_unlock(&svcpt->scp_req_lock);
-
-	if ((timediff.tv_sec) >
-	    (AT_OFF ? obd_timeout * 3 / 2 : at_max)) {
-		CERROR("%s: unhealthy - request has been waiting %llds\n",
-		       svcpt->scp_service->srv_name, (s64)timediff.tv_sec);
-		return -1;
-	}
-
-	return 0;
-}
-
-int
-ptlrpc_service_health_check(struct ptlrpc_service *svc)
-{
-	struct ptlrpc_service_part *svcpt;
-	int i;
-
-	if (svc == NULL)
-		return 0;
-
-	ptlrpc_service_for_each_part(svcpt, i, svc) {
-		int rc = ptlrpc_svcpt_health_check(svcpt);
-
-		if (rc != 0)
-			return rc;
-	}
-	return 0;
-}
-EXPORT_SYMBOL(ptlrpc_service_health_check);
-- 
2.1.0
