From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 20 Jun 2016 16:55:52 -0400
Subject: [lustre-devel] [PATCH v2 29/29] staging: lustre: quiet lockdep
	recursive lock warning
In-Reply-To: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
References: <1466456152-2199975-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466456152-2199975-30-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Andreas Dilger <andreas.dilger@intel.com>

Lockdep complains about potential recursive locking during mount
because the client configuration log is holding a lock on the MGC
obd_device to prevent it from being torn down, while also getting
mutexes on the MDC and OSC devices as they are instantiated:

 Lustre: Mounted myth-client
=============================================
[ INFO: possible recursive locking detected ]
4.7.0-rc2-vm-nfs+ #127 Tainted: G         C
---------------------------------------------

 May be due to missing lock nesting notation
2 locks held by ll_cfg_requeue/5928:
 #0:  (&cli->cl_sem){.+.+.+}, at: mgc_requeue_thread+0x15d/0x730 [mgc]
 #1:  (&cld->cld_lock){+.+.+.}, at: mgc_process_log+0x5e/0xf80 [mgc]
CPU: 0 PID: 5928 Comm: ll_cfg_requeue
Call Trace:
 [<ffffffff814a0855>] dump_stack+0x86/0xc1
 [<ffffffff810e7766>] __lock_acquire+0x726/0x1210
 [<ffffffff810e86be>] lock_acquire+0xfe/0x1f0
 [<ffffffff81888171>] down_read+0x51/0xa0
 [<ffffffffa04a8477>] sptlrpc_conf_client_adapt+0x47/0x150 [ptlrpc]
 [<ffffffffa0186b16>] mdc_set_info_async+0x2b6/0x470 [mdc]
 [<ffffffffa0294090>] class_notify_sptlrpc_conf+0x190/0x360 [obdclass]
 [<ffffffffa01a9e85>] mgc_process_log+0x925/0xf80 [mgc]
 [<ffffffffa01abafa>] mgc_requeue_thread+0x1fa/0x730 [mgc]
 [<ffffffff810af331>] kthread+0x101/0x120
 [<ffffffff8188ad6f>] ret_from_fork+0x1f/0x40

Add a separate lock class for the MGC callpath, since it will always
be held first, and none of the other obd_device locks should ever
be held concurrently.

Signed-off-by: Andreas Dilger <andreas.dilger@intel.com>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/include/obd.h       | 6 ++++++
 drivers/staging/lustre/lustre/mgc/mgc_request.c   | 4 +++-
 drivers/staging/lustre/lustre/ptlrpc/sec_config.c | 2 +-
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/obd.h b/drivers/staging/lustre/lustre/include/obd.h
index ed1081a..593d107 100644
--- a/drivers/staging/lustre/lustre/include/obd.h
+++ b/drivers/staging/lustre/lustre/include/obd.h
@@ -228,6 +228,12 @@ enum {
 #define MDC_MAX_RIF_DEFAULT       8
 #define MDC_MAX_RIF_MAX	 512
 
+enum obd_cl_sem_lock_class {
+	OBD_CLI_SEM_NORMAL,
+	OBD_CLI_SEM_MGC,
+	OBD_CLI_SEM_MDCOSC,
+};
+
 struct mdc_rpc_lock;
 struct obd_import;
 struct client_obd {
diff --git a/drivers/staging/lustre/lustre/mgc/mgc_request.c b/drivers/staging/lustre/lustre/mgc/mgc_request.c
index fbbf276..9d0bd47 100644
--- a/drivers/staging/lustre/lustre/mgc/mgc_request.c
+++ b/drivers/staging/lustre/lustre/mgc/mgc_request.c
@@ -496,7 +496,9 @@ static void do_requeue(struct config_llog_data *cld)
 	 * export which is being disconnected. Take the client
 	 * semaphore to make the check non-racy.
 	 */
-	down_read(&cld->cld_mgcexp->exp_obd->u.cli.cl_sem);
+	down_read_nested(&cld->cld_mgcexp->exp_obd->u.cli.cl_sem,
+			 OBD_CLI_SEM_MGC);
+
 	if (cld->cld_mgcexp->exp_obd->u.cli.cl_conn_count != 0) {
 		int rc;
 
diff --git a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
index 1238c87..c140354 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/sec_config.c
@@ -815,7 +815,7 @@ void sptlrpc_conf_client_adapt(struct obd_device *obd)
 	CDEBUG(D_SEC, "obd %s\n", obd->u.cli.cl_target_uuid.uuid);
 
 	/* serialize with connect/disconnect import */
-	down_read(&obd->u.cli.cl_sem);
+	down_read_nested(&obd->u.cli.cl_sem, OBD_CLI_SEM_MDCOSC);
 
 	imp = obd->u.cli.cl_import;
 	if (imp) {
-- 
2.7.4
