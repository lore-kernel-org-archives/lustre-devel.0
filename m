From: Cihangir Akturk <cakturk@gmail.com>
Date: Sat,  9 Apr 2016 21:47:44 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: split error handling code
	into multiple labels
Message-ID: <1460227664-28540-1-git-send-email-cakturk@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Instead of using a switch-case statement to find out what kind of error
has just happened, split error handling logic into multiple labels and
jump right into the appropriate label to do the error handling. This way
it is easier to follow different code paths. It also looks easy on the
eyes.

Additionally silences the following coccinelle warning:

drivers/staging/lustre/lustre/obdecho/echo_client.c:762:22-27: ERROR: ed
is NULL but dereferenced.

Signed-off-by: Cihangir Akturk <cakturk@gmail.com>
---
 .../staging/lustre/lustre/obdecho/echo_client.c    | 54 ++++++++--------------
 1 file changed, 20 insertions(+), 34 deletions(-)

diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
index a752bb4..f143f7a 100644
--- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
+++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
@@ -668,8 +668,7 @@ static struct lu_device *echo_device_alloc(const struct lu_env *env,
 	struct obd_device  *obd = NULL; /* to keep compiler happy */
 	struct obd_device  *tgt;
 	const char *tgt_type_name;
-	int rc;
-	int cleanup = 0;
+	int rc, err;
 
 	ed = kzalloc(sizeof(*ed), GFP_NOFS);
 	if (!ed) {
@@ -677,16 +676,14 @@ static struct lu_device *echo_device_alloc(const struct lu_env *env,
 		goto out;
 	}
 
-	cleanup = 1;
 	cd = &ed->ed_cl;
 	rc = cl_device_init(cd, t);
 	if (rc)
-		goto out;
+		goto out_free;
 
 	cd->cd_lu_dev.ld_ops = &echo_device_lu_ops;
 	cd->cd_ops = &echo_device_cl_ops;
 
-	cleanup = 2;
 	obd = class_name2obd(lustre_cfg_string(cfg, 0));
 	LASSERT(obd);
 	LASSERT(env);
@@ -696,28 +693,25 @@ static struct lu_device *echo_device_alloc(const struct lu_env *env,
 		CERROR("Can not find tgt device %s\n",
 		       lustre_cfg_string(cfg, 1));
 		rc = -ENODEV;
-		goto out;
+		goto out_device_fini;
 	}
 
 	next = tgt->obd_lu_dev;
 	if (!strcmp(tgt->obd_type->typ_name, LUSTRE_MDT_NAME)) {
 		CERROR("echo MDT client must be run on server\n");
 		rc = -EOPNOTSUPP;
-		goto out;
+		goto out_device_fini;
 	}
 
 	rc = echo_site_init(env, ed);
 	if (rc)
-		goto out;
-
-	cleanup = 3;
+		goto out_device_fini;
 
 	rc = echo_client_setup(env, obd, cfg);
 	if (rc)
-		goto out;
+		goto out_site_fini;
 
 	ed->ed_ec = &obd->u.echo_client;
-	cleanup = 4;
 
 	/* if echo client is to be stacked upon ost device, the next is
 	 * NULL since ost is not a clio device so far
@@ -729,7 +723,7 @@ static struct lu_device *echo_device_alloc(const struct lu_env *env,
 	if (next) {
 		if (next->ld_site) {
 			rc = -EBUSY;
-			goto out;
+			goto out_cleanup;
 		}
 
 		next->ld_site = &ed->ed_site->cs_lu;
@@ -737,7 +731,7 @@ static struct lu_device *echo_device_alloc(const struct lu_env *env,
 						next->ld_type->ldt_name,
 							      NULL);
 		if (rc)
-			goto out;
+			goto out_cleanup;
 
 	} else {
 		LASSERT(strcmp(tgt_type_name, LUSTRE_OST_NAME) == 0);
@@ -745,27 +739,19 @@ static struct lu_device *echo_device_alloc(const struct lu_env *env,
 
 	ed->ed_next = next;
 	return &cd->cd_lu_dev;
-out:
-	switch (cleanup) {
-	case 4: {
-		int rc2;
-
-		rc2 = echo_client_cleanup(obd);
-		if (rc2)
-			CERROR("Cleanup obd device %s error(%d)\n",
-			       obd->obd_name, rc2);
-	}
 
-	case 3:
-		echo_site_fini(env, ed);
-	case 2:
-		cl_device_fini(&ed->ed_cl);
-	case 1:
-		kfree(ed);
-	case 0:
-	default:
-		break;
-	}
+out_cleanup:
+	err = echo_client_cleanup(obd);
+	if (err)
+		CERROR("Cleanup obd device %s error(%d)\n",
+		       obd->obd_name, err);
+out_site_fini:
+	echo_site_fini(env, ed);
+out_device_fini:
+	cl_device_fini(&ed->ed_cl);
+out_free:
+	kfree(ed);
+out:
 	return ERR_PTR(rc);
 }
 
-- 
2.1.4
