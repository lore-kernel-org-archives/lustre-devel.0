From: James Simmons <jsimmons@infradead.org>
Date: Wed, 26 Jul 2017 11:22:24 -0400
Subject: [lustre-devel] [PATCH 08/20] staging: lustre: ptlrpc: correct use
	of list_add_tail()
In-Reply-To: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1501082556-17962-9-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: "John L. Hammond" <john.hammond@intel.com>

With people starting to test security enabled ptlrpc
a list_del corruption was reported. The reason for
this error was tracked down to wrong arguments to
list_add_tail(). In sptlrpc_gc_add_sec() swap the
arguments to list_add_tail() so that it does what
we meant it to do.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8270
Reviewed-on: http://review.whamcloud.com/20784
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Bob Glossman <bob.glossman@intel.com>
Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 drivers/staging/lustre/lustre/ptlrpc/sec_gc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
index 8ffd000..026bec7 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_gc.c
@@ -66,7 +66,7 @@ void sptlrpc_gc_add_sec(struct ptlrpc_sec *sec)
 	sec->ps_gc_next = ktime_get_real_seconds() + sec->ps_gc_interval;
 
 	spin_lock(&sec_gc_list_lock);
-	list_add_tail(&sec_gc_list, &sec->ps_gc_list);
+	list_add_tail(&sec->ps_gc_list, &sec_gc_list);
 	spin_unlock(&sec_gc_list_lock);
 
 	CDEBUG(D_SEC, "added sec %p(%s)\n", sec, sec->ps_policy->sp_name);
-- 
1.8.3.1
