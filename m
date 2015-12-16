From: Shraddha <shraddha.6596@gmail.com>
Date: Wed, 16 Dec 2015 23:10:17 +0530
Subject: [lustre-devel] [PATCH 3/3] Staging: lustre: lnet: Remove functions
	LNetEQWait and LNetEQGet
In-Reply-To: <1450287617-7682-1-git-send-email-shraddha.6596@gmail.com>
References: <1450287617-7682-1-git-send-email-shraddha.6596@gmail.com>
Message-ID: <1450287617-7682-4-git-send-email-shraddha.6596@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Shraddha Barke <shraddha.6596@gmail.com>

Functions LNetEQWait and LNetEQGet are defined but not used. Thus
remove it. Also remove corresponding declarations from header file.

Signed-off-by: Shraddha Barke <shraddha.6596@gmail.com>
---
 drivers/staging/lustre/include/linux/lnet/api.h |  6 ------
 drivers/staging/lustre/lnet/lnet/lib-eq.c       | 18 ------------------
 2 files changed, 24 deletions(-)

diff --git a/drivers/staging/lustre/include/linux/lnet/api.h b/drivers/staging/lustre/include/linux/lnet/api.h
index 9493d5e..75285fd 100644
--- a/drivers/staging/lustre/include/linux/lnet/api.h
+++ b/drivers/staging/lustre/include/linux/lnet/api.h
@@ -161,12 +161,6 @@ int LNetEQAlloc(unsigned int       count_in,
 
 int LNetEQFree(lnet_handle_eq_t eventq_in);
 
-int LNetEQGet(lnet_handle_eq_t  eventq_in,
-	      lnet_event_t     *event_out);
-
-int LNetEQWait(lnet_handle_eq_t  eventq_in,
-	       lnet_event_t     *event_out);
-
 int LNetEQPoll(lnet_handle_eq_t *eventqs_in,
 	       int		 neq_in,
 	       int		 timeout_ms,
diff --git a/drivers/staging/lustre/lnet/lnet/lib-eq.c b/drivers/staging/lustre/lnet/lnet/lib-eq.c
index 60889eb..64f94a6 100644
--- a/drivers/staging/lustre/lnet/lnet/lib-eq.c
+++ b/drivers/staging/lustre/lnet/lnet/lib-eq.c
@@ -282,15 +282,6 @@ lnet_eq_dequeue_event(lnet_eq_t *eq, lnet_event_t *ev)
  * at least one event between this event and the last event obtained from the
  * EQ has been dropped due to limited space in the EQ.
  */
-int
-LNetEQGet(lnet_handle_eq_t eventq, lnet_event_t *event)
-{
-	int which;
-
-	return LNetEQPoll(&eventq, 1, 0,
-			 event, &which);
-}
-EXPORT_SYMBOL(LNetEQGet);
 
 /**
  * Block the calling process until there is an event in the EQ.
@@ -308,15 +299,6 @@ EXPORT_SYMBOL(LNetEQGet);
  * at least one event between this event and the last event obtained from the
  * EQ has been dropped due to limited space in the EQ.
  */
-int
-LNetEQWait(lnet_handle_eq_t eventq, lnet_event_t *event)
-{
-	int which;
-
-	return LNetEQPoll(&eventq, 1, LNET_TIME_FOREVER,
-			 event, &which);
-}
-EXPORT_SYMBOL(LNetEQWait);
 
 static int
 lnet_eq_wait_locked(int *timeout_ms)
-- 
2.1.4
