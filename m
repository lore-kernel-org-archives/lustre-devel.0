From: James Simmons <jsimmons@infradead.org>
Date: Sun, 18 Sep 2016 16:38:13 -0400
Subject: [lustre-devel] [PATCH 074/124] staging: lustre: changelog: Proper
	record remapping
In-Reply-To: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1474231143-4061-75-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Henri Doreau <henri.doreau@cea.fr>, James Simmons <jsimmons@infradead.org>

From: Henri Doreau <henri.doreau@cea.fr>

Fixed changelog_remap_rec() to correctly remap records emitted
with jobid_var=disabled, i.e. delivered by new servers but with
no jobid field.

Signed-off-by: Henri Doreau <henri.doreau@cea.fr>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-5862
Reviewed-on: http://review.whamcloud.com/12574
Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
Reviewed-by: Robert Read <robert.read@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_user.h     |   66 +++++++++++++-------
 1 files changed, 44 insertions(+), 22 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
index e8f81a5..ba679ad 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_user.h
@@ -881,41 +881,63 @@ static inline char *changelog_rec_sname(struct changelog_rec *rec)
 	return cr_name + strlen(cr_name) + 1;
 }
 
-/*
+/**
  * Remap a record to the desired format as specified by the crf flags.
  * The record must be big enough to contain the final remapped version.
+ * Superfluous extension fields are removed and missing ones are added
+ * and zeroed. The flags of the record are updated accordingly.
+ *
+ * The jobid and rename extensions can be added to a record, to match the
+ * format an application expects, typically. In this case, the newly added
+ * fields will be zeroed.
+ * The Jobid field can be removed, to guarantee compatibility with older
+ * clients that don't expect this field in the records they process.
+ *
+ * The following assumptions are being made:
+ *	- CLF_RENAME will not be removed
+ *	- CLF_JOBID will not be added without CLF_RENAME being added too
+ *
+ * @param[in,out]  rec		The record to remap.
+ * @param[in]	   crf_wanted	Flags describing the desired extensions.
  */
 static inline void changelog_remap_rec(struct changelog_rec *rec,
-				       enum changelog_rec_flags crf)
+				       enum changelog_rec_flags crf_wanted)
 {
-	size_t var_size;
-	char *var_part;
+	char *jid_mov, *rnm_mov;
 
-	crf &= CLF_SUPPORTED;
+	crf_wanted &= CLF_SUPPORTED;
 
-	if ((rec->cr_flags & CLF_SUPPORTED) == crf)
+	if ((rec->cr_flags & CLF_SUPPORTED) == crf_wanted)
 		return;
 
-	if ((crf & CLF_JOBID) && rec->cr_flags & CLF_JOBID) {
-		var_part = (char *)changelog_rec_jobid(rec);
-		var_size = rec->cr_namelen + sizeof(struct changelog_ext_jobid);
-	} else {
-		var_part = changelog_rec_name(rec);
-		var_size = rec->cr_namelen;
-	}
+	/* First move the variable-length name field */
+	memmove((char *)rec + changelog_rec_offset(crf_wanted),
+		changelog_rec_name(rec), rec->cr_namelen);
+
+	/* Locations of jobid and rename extensions in the remapped record */
+	jid_mov = (char *)rec +
+		  changelog_rec_offset(crf_wanted & ~CLF_JOBID);
+	rnm_mov = (char *)rec +
+		  changelog_rec_offset(crf_wanted & ~(CLF_JOBID | CLF_RENAME));
+
+	/* Move the extension fields to the desired positions */
+	if ((crf_wanted & CLF_JOBID) && (rec->cr_flags & CLF_JOBID))
+		memmove(jid_mov, changelog_rec_jobid(rec),
+			sizeof(struct changelog_ext_jobid));
 
-	memmove((char *)rec + changelog_rec_offset(crf & ~CLF_JOBID), var_part,
-		var_size);
+	if ((crf_wanted & CLF_RENAME) && (rec->cr_flags & CLF_RENAME))
+		memmove(rnm_mov, changelog_rec_rename(rec),
+			sizeof(struct changelog_ext_rename));
 
-	if ((crf & CLF_RENAME) && !(rec->cr_flags & CLF_RENAME))
-		memset(changelog_rec_rename(rec), 0,
-		       sizeof(struct changelog_ext_rename));
+	/* Clear newly added fields */
+	if ((crf_wanted & CLF_JOBID) && !(rec->cr_flags & CLF_JOBID))
+		memset(jid_mov, 0, sizeof(struct changelog_ext_jobid));
 
-	if ((crf & CLF_JOBID) && !(rec->cr_flags & CLF_JOBID))
-		memset(changelog_rec_jobid(rec), 0,
-		       sizeof(struct changelog_ext_jobid));
+	if ((crf_wanted & CLF_RENAME) && !(rec->cr_flags & CLF_RENAME))
+		memset(rnm_mov, 0, sizeof(struct changelog_ext_rename));
 
-	rec->cr_flags = (rec->cr_flags & CLF_FLAGMASK) | crf;
+	/* Update the record's flags accordingly */
+	rec->cr_flags = (rec->cr_flags & CLF_FLAGMASK) | crf_wanted;
 }
 
 struct ioc_changelog {
-- 
1.7.1
