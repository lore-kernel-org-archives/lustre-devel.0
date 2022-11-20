Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 818FEC4332F
	for <lustre-devel@archiver.kernel.org>; Sun, 20 Nov 2022 14:32:20 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4NFXjG2yfpz21By;
	Sun, 20 Nov 2022 06:20:02 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4NFXhr16gKz1y7d
 for <lustre-devel@lists.lustre.org>; Sun, 20 Nov 2022 06:19:40 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id D29D610084C5;
 Sun, 20 Nov 2022 09:17:09 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id CE4FCE8B88; Sun, 20 Nov 2022 09:17:09 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun, 20 Nov 2022 09:16:57 -0500
Message-Id: <1668953828-10909-12-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
References: <1668953828-10909-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 11/22] lustre: obdclass: fill jobid in a safe
 way
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
Cc: Lei Feng <flei@whamcloud.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Lei Feng <flei@whamcloud.com>

Ensure jobid_interpret_string() fills jobid in an atomic way.
Make sure we use the proper length. The Linux native client
got this mostly right.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16251
Lustre-commit: 9a0a89520e8b57bd6 ("LU-16251 obdclass: fill jobid in a safe way")
Signed-off-by: Lei Feng <flei@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/48915
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Jian Yu <yujian@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/obdclass/jobid.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/lustre/obdclass/jobid.c b/fs/lustre/obdclass/jobid.c
index da1af51..77ea5b2 100644
--- a/fs/lustre/obdclass/jobid.c
+++ b/fs/lustre/obdclass/jobid.c
@@ -308,7 +308,8 @@ static int jobid_interpret_string(const char *jobfmt, char *jobid,
  */
 int lustre_get_jobid(char *jobid, size_t joblen)
 {
-	char tmp_jobid[LUSTRE_JOBID_SIZE] = "";
+	char id[LUSTRE_JOBID_SIZE] = "";
+	int len = min_t(int, joblen, LUSTRE_JOBID_SIZE);
 
 	if (unlikely(joblen < 2)) {
 		if (joblen == 1)
@@ -324,14 +325,14 @@ int lustre_get_jobid(char *jobid, size_t joblen)
 	if (strcmp(obd_jobid_var, JOBSTATS_NODELOCAL) == 0 ||
 	    strnstr(obd_jobid_name, "%j", LUSTRE_JOBID_SIZE)) {
 		int rc2 = jobid_interpret_string(obd_jobid_name,
-						 tmp_jobid, joblen);
+						 id, len);
 		if (!rc2)
 			goto out_cache_jobid;
 	}
 
 	/* Use process name + fsuid as jobid */
 	if (strcmp(obd_jobid_var, JOBSTATS_PROCNAME_UID) == 0) {
-		snprintf(tmp_jobid, LUSTRE_JOBID_SIZE, "%s.%u",
+		snprintf(id, LUSTRE_JOBID_SIZE, "%s.%u",
 			 current->comm,
 			 from_kuid(&init_user_ns, current_fsuid()));
 		goto out_cache_jobid;
@@ -343,7 +344,7 @@ int lustre_get_jobid(char *jobid, size_t joblen)
 		rcu_read_lock();
 		jid = jobid_current();
 		if (jid)
-			strlcpy(tmp_jobid, jid, sizeof(tmp_jobid));
+			strlcpy(id, jid, sizeof(id));
 		rcu_read_unlock();
 		goto out_cache_jobid;
 	}
@@ -352,8 +353,8 @@ int lustre_get_jobid(char *jobid, size_t joblen)
 
 out_cache_jobid:
 	/* Only replace the job ID if it changed. */
-	if (strcmp(jobid, tmp_jobid) != 0)
-		strcpy(jobid, tmp_jobid);
+	if (strcmp(jobid, id) != 0)
+		strcpy(jobid, id);
 
 	return 0;
 }
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
