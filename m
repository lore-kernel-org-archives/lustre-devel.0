From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:06 -0500
Subject: [lustre-devel] [PATCH 05/24] staging: lustre: make local functions
	static for LNet ni
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-6-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Frank Zago <fzago@cray.com>

From: Frank Zago <fzago@cray.com>

The function lnet_unprepare can be made static.

Signed-off-by: Frank Zago <fzago@cray.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5396
Reviewed-on: http://review.whamcloud.com/11306
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Patrick Farrell <paf@cray.com>
Reviewed-by: Amir Shehata <amir.shehata@intel.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index fa65797..7583ae4 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -525,7 +525,7 @@ lnet_res_lh_initialize(struct lnet_res_container *rec, lnet_libhandle_t *lh)
 	list_add(&lh->lh_hash_chain, &rec->rec_lh_hash[hash]);
 }
 
-int lnet_unprepare(void);
+static int lnet_unprepare(void);
 
 static int
 lnet_prepare(lnet_pid_t requested_pid)
@@ -611,7 +611,7 @@ lnet_prepare(lnet_pid_t requested_pid)
 	return rc;
 }
 
-int
+static int
 lnet_unprepare(void)
 {
 	/*
-- 
1.7.1
