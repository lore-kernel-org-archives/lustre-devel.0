From: NeilBrown <neilb@suse.com>
Date: Thu, 14 Mar 2019 11:11:48 +1100
Subject: [lustre-devel] [PATCH 01/32] lustre: remove outdated comments about
 ->ap_* functions.
In-Reply-To: <155252182126.26912.1842463462595601611.stgit@noble.brown>
References: <155252182126.26912.1842463462595601611.stgit@noble.brown>
Message-ID: <155252230846.26912.2394688817502959978.stgit@noble.brown>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

->ap_make_ready, ->ap_completion, ap_refresh count all no longer
exist.
So remove these comments.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 drivers/staging/lustre/lustre/include/obd.h      |    9 +--------
 drivers/staging/lustre/lustre/osc/osc_internal.h |    4 ++--
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index 93a47cf0ef68..faf2ea623a09 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -224,14 +224,7 @@ struct client_obd {
 	 */
 	/*
 	 * ->cl_loi_list_lock protects consistency of
-	 * ->cl_loi_{ready,read,write}_list. ->ap_make_ready() and
-	 * ->ap_completion() call-backs are executed under this lock. As we
-	 * cannot guarantee that these call-backs never block on all platforms
-	 * (as a matter of fact they do block on Mac OS X), type of
-	 * ->cl_loi_list_lock is platform dependent: it's a spin-lock on Linux
-	 * and blocking mutex on Mac OS X. (Alternative is to make this lock
-	 * blocking everywhere, but we don't want to slow down fast-path of
-	 * our main platform.)
+	 * ->cl_loi_{ready,read,write}_list.
 	 *
 	 * NB by Jinshan: though field names are still _loi_, but actually
 	 * osc_object{}s are in the list.
diff --git a/drivers/staging/lustre/lustre/osc/osc_internal.h b/drivers/staging/lustre/lustre/osc/osc_internal.h
index 40333655a01d..21955687ec5f 100644
--- a/drivers/staging/lustre/lustre/osc/osc_internal.h
+++ b/drivers/staging/lustre/lustre/osc/osc_internal.h
@@ -43,13 +43,13 @@ extern struct ptlrpc_request_pool *osc_rq_pool;
 struct lu_env;
 
 enum async_flags {
-	ASYNC_READY		= 0x1, /* ap_make_ready will not be
+	ASYNC_READY		= 0x1, /* osc_make_ready will not be
 					* called before this page is
 					* added to an rpc
 					*/
 	ASYNC_URGENT		= 0x2, /* page must be put into an RPC
 					* before return */
-	ASYNC_COUNT_STABLE	= 0x4, /* ap_refresh_count will not be
+	ASYNC_COUNT_STABLE	= 0x4, /* osc_refresh_count will not be
 					* called to give the caller a
 					* chance to update or cancel
 					* the size of the io
