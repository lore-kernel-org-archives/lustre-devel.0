Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id C82FCECAAA1
	for <lustre-devel@archiver.kernel.org>; Thu, 27 Oct 2022 14:27:17 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mynjm5nGrz219y;
	Thu, 27 Oct 2022 07:14:20 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mynjh0q6xz1yCy
 for <lustre-devel@lists.lustre.org>; Thu, 27 Oct 2022 07:14:15 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 913051009109;
 Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 8E9D6E8CAE; Thu, 27 Oct 2022 10:05:44 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Thu, 27 Oct 2022 10:05:40 -0400
Message-Id: <1666879542-10737-14-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
References: <1666879542-10737-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 13/15] lustre: obdclass: fix race in
 class_del_profile
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Li Dongyang <dongyangli@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Li Dongyang <dongyangli@ddn.com>

Move profile lookup and remove from lustre_profile_list
into the same critical section, otherwise we could race with
class_del_profiles or another class_del_profile.

Do not create duplicate mount opts in the client config,
otherwise we will add duplicate lustre_profile to
lustre_profile_list for a single mount.

WC-bug-id: https://jira.whamcloud.com/browse/LU-15305
Lustre-commit: 83d3f42118579d7fb ("LU-15305 obdclass: fix race in class_del_profile")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48802
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: James Simmons <jsimmons@infradead.org>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/obd_config.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/fs/lustre/obdclass/obd_config.c b/fs/lustre/obdclass/obd_config.c
index 2b24276..75fc6a6 100644
--- a/fs/lustre/obdclass/obd_config.c
+++ b/fs/lustre/obdclass/obd_config.c
@@ -622,21 +622,28 @@ static int class_del_conn(struct obd_device *obd, struct lustre_cfg *lcfg)
 static LIST_HEAD(lustre_profile_list);
 static DEFINE_SPINLOCK(lustre_profile_list_lock);
 
-struct lustre_profile *class_get_profile(const char *prof)
+static struct lustre_profile *class_get_profile_nolock(const char *prof)
 {
 	struct lustre_profile *lprof;
 
-	spin_lock(&lustre_profile_list_lock);
 	list_for_each_entry(lprof, &lustre_profile_list, lp_list) {
-		if (!strcmp(lprof->lp_profile, prof)) {
+		if (strcmp(lprof->lp_profile, prof) == 0) {
 			lprof->lp_refs++;
-			spin_unlock(&lustre_profile_list_lock);
 			return lprof;
 		}
 	}
-	spin_unlock(&lustre_profile_list_lock);
 	return NULL;
 }
+
+struct lustre_profile *class_get_profile(const char *prof)
+{
+	struct lustre_profile *lprof;
+
+	spin_lock(&lustre_profile_list_lock);
+	lprof = class_get_profile_nolock(prof);
+	spin_unlock(&lustre_profile_list_lock);
+	return lprof;
+}
 EXPORT_SYMBOL(class_get_profile);
 
 /** Create a named "profile".
@@ -701,9 +708,9 @@ void class_del_profile(const char *prof)
 
 	CDEBUG(D_CONFIG, "Del profile %s\n", prof);
 
-	lprof = class_get_profile(prof);
+	spin_lock(&lustre_profile_list_lock);
+	lprof = class_get_profile_nolock(prof);
 	if (lprof) {
-		spin_lock(&lustre_profile_list_lock);
 		/* because get profile increments the ref counter */
 		lprof->lp_refs--;
 		list_del(&lprof->lp_list);
@@ -711,6 +718,8 @@ void class_del_profile(const char *prof)
 		spin_unlock(&lustre_profile_list_lock);
 
 		class_put_profile(lprof);
+	} else {
+		spin_unlock(&lustre_profile_list_lock);
 	}
 }
 EXPORT_SYMBOL(class_del_profile);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
