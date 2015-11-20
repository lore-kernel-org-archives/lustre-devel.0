From: James Simmons <jsimmons@infradead.org>
Date: Fri, 20 Nov 2015 18:36:08 -0500
Subject: [lustre-devel] [PATCH 32/40] staging: lustre: prevent assert on
	LNet module unload
In-Reply-To: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1448062576-23757-33-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Amir Shehata <amir.shehata@intel.com>

There is a use case where lnet can be unloaded while there are
no NIs configured.  Removing lnet in this case will cause
LNetFini() to be called without a prior call to LNetNIFini().
This will cause the LASSERT(the_lnet.ln_refcount == 0) to be
triggered.

To deal with this use case when LNet is configured a reference
count on the module is taken using try_module_get().  This way
LNet must be unconfigured before it could be removed; therefore
avoiding the above case.  When LNet is unconfigured module_put()
is called to return the reference count.

Signed-off-by: Amir Shehata <amir.shehata@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-6010
Reviewed-on: http://review.whamcloud.com/13110
Reviewed-by: James Simmons <uja.ornl@gmail.com>
Reviewed-by: Doug Oucharek <doug.s.oucharek@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
---
 drivers/staging/lustre/lnet/lnet/module.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/lustre/lnet/lnet/module.c b/drivers/staging/lustre/lnet/lnet/module.c
index 48eb085..b1f32a6 100644
--- a/drivers/staging/lustre/lnet/lnet/module.c
+++ b/drivers/staging/lustre/lnet/lnet/module.c
@@ -53,13 +53,21 @@ lnet_configure(void *arg)
 	mutex_lock(&lnet_config_mutex);
 
 	if (!the_lnet.ln_niinit_self) {
+		rc = try_module_get(THIS_MODULE);
+
+		if (rc != 1)
+			goto out;
+
 		rc = LNetNIInit(LNET_PID_LUSTRE);
 		if (rc >= 0) {
 			the_lnet.ln_niinit_self = 1;
 			rc = 0;
+		} else {
+			module_put(THIS_MODULE);
 		}
 	}
 
+out:
 	mutex_unlock(&lnet_config_mutex);
 	return rc;
 }
@@ -74,6 +82,7 @@ lnet_unconfigure(void)
 	if (the_lnet.ln_niinit_self) {
 		the_lnet.ln_niinit_self = 0;
 		LNetNIFini();
+		module_put(THIS_MODULE);
 	}
 
 	mutex_lock(&the_lnet.ln_api_mutex);
-- 
1.7.1
