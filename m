From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:35:56 -0500
Subject: [lustre-devel] [PATCH 20/40] staging: lustre: fix kernel crash when
	network failed to start
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-21-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

When loading Lustre modules without proper network configuration,
it always hit the following kernel panic:
LNetError: 105-4: Error -100 starting up LNI tcp
LNetError: 2145:0:(api-ni.c:823:lnet_unprepare())
ASSERTION( list_empty(&the_lnet.ln_nis) ) failed:
NetError: 2145:0:(api-ni.c:823:lnet_unprepare()) LBUG
Pid: 2145, comm: modprobe
x0aCall Trace:
[<ffffffffa044f853>] libcfs_debug_dumpstack+0x53/0x80 [libcfs]
[<ffffffffa044fdf5>] lbug_with_loc+0x45/0xc0 [libcfs]
[<ffffffffa04f3267>] lnet_unprepare+0x297/0x340 [lnet]
[<ffffffffa04f3b5c>] LNetNIInit+0x25c/0x3e0 [lnet]
[<ffffffff81061bc6>] ? put_online_cpus+0x56/0x80
[<ffffffffa0983000>] ? init_module+0x0/0x1000 [ptlrpc]
[<ffffffffa081310c>] ptlrpc_ni_init+0x2c/0x1a0 [ptlrpc]
[<ffffffffa0983000>] ? init_module+0x0/0x1000 [ptlrpc]
[<ffffffffa0813291>] ptlrpc_init_portals+0x11/0xf0 [ptlrpc]
[<ffffffffa0983000>] ? init_module+0x0/0x1000 [ptlrpc]
[<ffffffffa09831c4>] init_module+0x1c4/0x1000 [ptlrpc]
[<ffffffff810020e2>] do_one_initcall+0xe2/0x190
[<ffffffff810ca7fb>] load_module+0x129b/0x1a90
[<ffffffff812da590>] ? ddebug_dyndbg_module_param_cb+0x0/0x60
[<ffffffff810c7133>] ? copy_module_from_fd.isra.43+0x53/0x150
[<ffffffff810cb1a6>] SyS_finit_module+0xa6/0xd0
[<ffffffff815f2119>] system_call_fastpath+0x16/0x1b
...
This is because in lnet_startup_lndnis(), we may add list items to
@the_lnet.ln_nis and @the_lnet.ln_nis_cpt before it failed. But in
lnet_startup_lndis() failure path,it did not cleanup list thus
causing assertion in lnet_unprepare().

Fix the assertion by cleaning up using lnet_shutdown_lndnis()
if the startup fails.

In a future enahancement the ni startup API will be modified to
cleanup after itself in case of failure.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5568
Reviewed-on: http://review.whamcloud.com/12512
Reviewed-by: Liang Zhen <liang.zhen@intel.com>
Reviewed-by: Isaac Huang <he.huang@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/api-ni.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/api-ni.c b/drivers/staging/lustre/lnet/lnet/api-ni.c
index 4c4e6d3..bfc1f13 100644
--- a/drivers/staging/lustre/lnet/lnet/api-ni.c
+++ b/drivers/staging/lustre/lnet/lnet/api-ni.c
@@ -1246,6 +1246,10 @@ lnet_shutdown_lndni(__u32 net)
 	return 0;
 }
 
+/*
+ * Callers of lnet_startup_lndnis need to clean up using
+ * lnet_shutdown_lndnis if startup fails
+ */
 static int
 lnet_startup_lndnis(struct list_head *nilist, __s32 peer_timeout,
 		    __s32 peer_cr, __s32 peer_buf_cr, __s32 credits,
@@ -1554,7 +1558,7 @@ LNetNIInit(lnet_pid_t requested_pid)
 
 	rc = lnet_startup_lndnis(&net_head, -1, -1, -1, -1, &ni_count);
 	if (rc != 0)
-		goto failed1;
+		goto failed2;
 
 	if (the_lnet.ln_eq_waitni && ni_count > 1) {
 		lnd_type = the_lnet.ln_eq_waitni->ni_lnd->lnd_type;
-- 
1.7.1
