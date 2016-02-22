From: James Simmons <jsimmons@infradead.org>
Date: Mon, 22 Feb 2016 17:29:12 -0500
Subject: [lustre-devel] [PATCH 11/24] staging: lustre: startup lnet acceptor
	thread dynamically
In-Reply-To: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
References: <1456180165-1105-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1456180165-1105-12-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Amir Shehata <amir.shehata@intel.com>

From: Amir Shehata <amir.shehata@intel.com>

With DLC it's possible to start up a system with no NIs that require
the acceptor thread, and thus it won't start.  Later on the user
can add an NI that requires the acceptor thread to start, it is
then necessary to start it up.

If the user removes a NI and as a result there are no more
NIs that require the acceptor thread then it should be stopped.
This patch adds logic in the dynamically adding and removing NIs
code to ensure the above logic is implemented.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6002
Reviewed-on: http://review.whamcloud.com/13010
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/acceptor.c |   10 ++++++++--
 drivers/staging/lustre/lnet/lnet/api-ni.c   |   14 ++++++++++++++
 2 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 07df727..9fe3ff7 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -46,7 +46,9 @@ static struct {
 	int			pta_shutdown;
 	struct socket		*pta_sock;
 	struct completion	pta_signal;
-} lnet_acceptor_state;
+} lnet_acceptor_state = {
+	.pta_shutdown = 1
+};
 
 int
 lnet_acceptor_port(void)
@@ -444,6 +446,10 @@ lnet_acceptor_start(void)
 	long rc2;
 	long secure;
 
+	/* if acceptor is already running return immediately */
+	if (!lnet_acceptor_state.pta_shutdown)
+		return 0;
+
 	LASSERT(!lnet_acceptor_state.pta_sock);
 
 	rc = lnet_acceptor_get_tunables();
@@ -484,7 +490,7 @@ lnet_acceptor_start(void)
 void
 lnet_acceptor_stop(void)
 {
-	if (!lnet_acceptor_state.pta_sock) /* not running */
+	if (lnet_acceptor_state.pta_shutdown) /* not running */
 		return;
 
 	lnet_acceptor_state.pta_shutdown = 1;
diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index f223d5d..9497ce1 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1785,6 +1785,16 @@ lnet_dyn_add_ni(lnet_pid_t requested_pid, char *nets,
 	if (rc)
 		goto failed1;
 
+	if (ni->ni_lnd->lnd_accept) {
+		rc = lnet_acceptor_start();
+		if (rc < 0) {
+			/* shutdown the ni that we just started */
+			CERROR("Failed to start up acceptor thread\n");
+			lnet_shutdown_lndni(ni);
+			goto failed1;
+		}
+	}
+
 	lnet_ping_target_update(pinfo, md_handle);
 	mutex_unlock(&the_lnet.ln_api_mutex);
 
@@ -1832,6 +1842,10 @@ lnet_dyn_del_ni(__u32 net)
 	lnet_ni_decref_locked(ni, 0);
 
 	lnet_shutdown_lndni(ni);
+
+	if (!lnet_count_acceptor_nis())
+		lnet_acceptor_stop();
+
 	lnet_ping_target_update(pinfo, md_handle);
 	goto out;
 failed:
-- 
1.7.1
