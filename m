From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:37:18 -0400
Subject: [lustre-devel] [PATCH 019/124] staging: lustre: ptlrpc: fix magic
	return value of ptlrpc_init_portals
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-20-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Wang Shilong <wshilong@ddn.com>, James Simmons <jsimmons@infradead.org>

From: Wang Shilong <wshilong@ddn.com>

Previously, when running 'modprobe lustre', it hit the following
error message which is becaue of network initialisation failure:
modprobe: ERROR: could not insert 'lustre': Input/output error

However, error code is there, just let it return to caller,
after this patch, error message will be something like:
modprobe: ERROR: could not insert 'lustre': Network is down

Signed-off-by: Wang Shilong <wshilong@ddn.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5455
Reviewed-on: http://review.whamcloud.com/11337
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: John L. Hammond <john.hammond@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/events.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/events.c b/drivers/staging/lustre/lustre/ptlrpc/events.c
index b1ce725..283dfb2 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/events.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/events.c
@@ -543,7 +543,7 @@ static int ptlrpc_ni_init(void)
 	rc = LNetNIInit(pid);
 	if (rc < 0) {
 		CDEBUG(D_NET, "Can't init network interface: %d\n", rc);
-		return -ENOENT;
+		return rc;
 	}
 
 	/* CAVEAT EMPTOR: how we process portals events is _radically_
@@ -561,7 +561,7 @@ static int ptlrpc_ni_init(void)
 	CERROR("Failed to allocate event queue: %d\n", rc);
 	LNetNIFini();
 
-	return -ENOMEM;
+	return rc;
 }
 
 int ptlrpc_init_portals(void)
@@ -570,7 +570,7 @@ int ptlrpc_init_portals(void)
 
 	if (rc != 0) {
 		CERROR("network initialisation failed\n");
-		return -EIO;
+		return rc;
 	}
 	rc = ptlrpcd_addref();
 	if (rc == 0)
-- 
1.7.1
