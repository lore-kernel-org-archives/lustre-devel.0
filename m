Return-Path: <SRS0=o51I=JC=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D538EC433ED
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:47 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 9037D6138E
	for <lustre-devel@archiver.kernel.org>; Mon,  5 Apr 2021 00:52:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9037D6138E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id A6064328C93;
	Mon,  5 Apr 2021 00:52:19 +0000 (UTC)
Received: from smtp3.ccs.ornl.gov (smtp3.ccs.ornl.gov [160.91.203.39])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DA01D21FB74
 for <lustre-devel@lists.lustre.org>; Mon,  5 Apr 2021 00:51:25 +0000 (UTC)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp3.ccs.ornl.gov (Postfix) with ESMTP id 05F74E33;
 Sun,  4 Apr 2021 20:51:17 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id F3B6D90AA8; Sun,  4 Apr 2021 20:51:16 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  4 Apr 2021 20:50:57 -0400
Message-Id: <1617583870-32029-29-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
References: <1617583870-32029-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 28/41] lsutre: ldlm: return error from
 ldlm_namespace_new()
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Andreas Dilger <adilger@whamcloud.com>

Return the underlying error in ldlm_namespace_new() from
ldlm_namespace_sysfs_register() to the caller instead of NULL.
Otherwise, the callers convert the NULL to -ENOMEM and this
is incorrectly reported as an allocation error to the user.

  sysfs: cannot create duplicate filename
     '/fs/lustre/ldlm/namespaces/lustre-OST0002-osc-ffff89f33be70000'
  mount.lustre: mount mgs:/lfs at /lfs failed: Cannot allocate memory

Change ldlm_namespace_new() to return errors via PTR_ERR() and
change the callers to use IS_ERR().

Fix associated CERROR() messages to follow proper code style.

WC-bug-id: https://jira.whamcloud.com/browse/LU-14178
Lutsre-commit: e9c3b89bdacdb90 ("LU-14178 ldlm: return error from ldlm_namespace_new()")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/40851
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Neil Brown <neilb@suse.de>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/ldlm/ldlm_lib.c      | 10 ++++++----
 fs/lustre/ldlm/ldlm_resource.c | 32 +++++++++++++++++++++-----------
 2 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/fs/lustre/ldlm/ldlm_lib.c b/fs/lustre/ldlm/ldlm_lib.c
index 2965395..9499995 100644
--- a/fs/lustre/ldlm/ldlm_lib.c
+++ b/fs/lustre/ldlm/ldlm_lib.c
@@ -524,10 +524,11 @@ int client_obd_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 						LDLM_NAMESPACE_CLIENT,
 						LDLM_NAMESPACE_GREEDY,
 						ns_type);
-	if (!obd->obd_namespace) {
-		CERROR("Unable to create client namespace - %s\n",
-		       obd->obd_name);
-		rc = -ENOMEM;
+	if (IS_ERR(obd->obd_namespace)) {
+		rc = PTR_ERR(obd->obd_namespace);
+		CERROR("%s: unable to create client namespace: rc = %d\n",
+		       obd->obd_name, rc);
+		obd->obd_namespace = NULL;
 		goto err_import;
 	}
 
@@ -540,6 +541,7 @@ int client_obd_setup(struct obd_device *obd, struct lustre_cfg *lcfg)
 err:
 	kfree(cli->cl_mod_tag_bitmap);
 	cli->cl_mod_tag_bitmap = NULL;
+
 	return rc;
 }
 EXPORT_SYMBOL(client_obd_setup);
diff --git a/fs/lustre/ldlm/ldlm_resource.c b/fs/lustre/ldlm/ldlm_resource.c
index dab837d..481f14e 100644
--- a/fs/lustre/ldlm/ldlm_resource.c
+++ b/fs/lustre/ldlm/ldlm_resource.c
@@ -630,19 +630,23 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 
 	rc = ldlm_get_ref();
 	if (rc) {
-		CERROR("ldlm_get_ref failed: %d\n", rc);
-		return NULL;
+		CERROR("%s: ldlm_get_ref failed: rc = %d\n", name, rc);
+		return ERR_PTR(rc);
 	}
 
 	if (ns_type >= ARRAY_SIZE(ldlm_ns_hash_defs) ||
 	    ldlm_ns_hash_defs[ns_type].nsd_bkt_bits == 0) {
-		CERROR("Unknown type %d for ns %s\n", ns_type, name);
+		rc = -EINVAL;
+		CERROR("%s: unknown namespace type %d: rc = %d\n",
+		       name, ns_type, rc);
 		goto out_ref;
 	}
 
 	ns = kzalloc(sizeof(*ns), GFP_NOFS);
-	if (!ns)
+	if (!ns) {
+		rc = -ENOMEM;
 		goto out_ref;
+	}
 
 	ns->ns_rs_hash = cfs_hash_create(name,
 					 ldlm_ns_hash_defs[ns_type].nsd_all_bits,
@@ -656,8 +660,10 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 					 CFS_HASH_BIGNAME |
 					 CFS_HASH_SPIN_BKTLOCK |
 					 CFS_HASH_NO_ITEMREF);
-	if (!ns->ns_rs_hash)
+	if (!ns->ns_rs_hash) {
+		rc = -ENOMEM;
 		goto out_ns;
+	}
 
 	ns->ns_bucket_bits = ldlm_ns_hash_defs[ns_type].nsd_all_bits -
 			     ldlm_ns_hash_defs[ns_type].nsd_bkt_bits;
@@ -665,8 +671,10 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ns->ns_rs_buckets = kvzalloc((1 << ns->ns_bucket_bits) *
 				     sizeof(*ns->ns_rs_buckets),
 				     GFP_KERNEL);
-	if (!ns->ns_rs_buckets)
+	if (!ns->ns_rs_buckets) {
+		rc = -ENOMEM;
 		goto out_hash;
+	}
 
 	for (idx = 0; idx < (1 << ns->ns_bucket_bits); idx++) {
 		struct ldlm_ns_bucket *nsb = &ns->ns_rs_buckets[idx];
@@ -680,8 +688,10 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	ns->ns_appetite = apt;
 	ns->ns_client = client;
 	ns->ns_name = kstrdup(name, GFP_KERNEL);
-	if (!ns->ns_name)
+	if (!ns->ns_name) {
+		rc = -ENOMEM;
 		goto out_hash;
+	}
 
 	INIT_LIST_HEAD(&ns->ns_list_chain);
 	INIT_LIST_HEAD(&ns->ns_unused_list);
@@ -704,20 +714,20 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 
 	rc = ldlm_namespace_sysfs_register(ns);
 	if (rc != 0) {
-		CERROR("Can't initialize ns sysfs, rc %d\n", rc);
+		CERROR("%s: cannot initialize ns sysfs: rc = %d\n", name, rc);
 		goto out_hash;
 	}
 
 	rc = ldlm_namespace_debugfs_register(ns);
 	if (rc != 0) {
-		CERROR("Can't initialize ns proc, rc %d\n", rc);
+		CERROR("%s: cannot initialize ns proc: rc = %d\n", name, rc);
 		goto out_sysfs;
 	}
 
 	idx = ldlm_namespace_nr_read(client);
 	rc = ldlm_pool_init(&ns->ns_pool, ns, idx, client);
 	if (rc) {
-		CERROR("Can't initialize lock pool, rc %d\n", rc);
+		CERROR("%s: cannot initialize lock pool, rc = %d\n", name, rc);
 		goto out_proc;
 	}
 
@@ -736,7 +746,7 @@ struct ldlm_namespace *ldlm_namespace_new(struct obd_device *obd, char *name,
 	kfree(ns);
 out_ref:
 	ldlm_put_ref();
-	return NULL;
+	return ERR_PTR(rc);
 }
 EXPORT_SYMBOL(ldlm_namespace_new);
 
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
