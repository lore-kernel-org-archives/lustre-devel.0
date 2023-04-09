Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 40875C77B70
	for <lustre-devel@archiver.kernel.org>; Sun,  9 Apr 2023 12:37:30 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PvWQK4yz1z22Sn;
	Sun,  9 Apr 2023 05:20:09 -0700 (PDT)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PvWKD6ZM9z21B2
 for <lustre-devel@lists.lustre.org>; Sun,  9 Apr 2023 05:15:44 -0700 (PDT)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 232501008483;
 Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 21DD42B2; Sun,  9 Apr 2023 08:13:28 -0400 (EDT)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  9 Apr 2023 08:13:01 -0400
Message-Id: <1681042400-15491-22-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
References: <1681042400-15491-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 21/40] lustre: fid: clean up OBIF_MAX_OID and
 IDIF_MAX_OID
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

Define the OBIF|IDIF_MAX_OID macros to 1ULL << OBIF|IDIF_MAX_BITS - 1
Clean up the callers and remove OBIF|IDIF_OID_MASK which are not used.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11912
Lustre-commit: bb2f0dac868cf1321 ("LU-11912 fid: clean up OBIF_MAX_OID and IDIF_MAX_OID")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/45659
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Sergey Cheremencev <scherementsev@ddn.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/lustre_fid.h           | 6 +++---
 include/uapi/linux/lustre/lustre_idl.h   | 6 ++----
 include/uapi/linux/lustre/lustre_ostid.h | 4 ++--
 3 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/fs/lustre/include/lustre_fid.h b/fs/lustre/include/lustre_fid.h
index b8a3f2e..88a6061 100644
--- a/fs/lustre/include/lustre_fid.h
+++ b/fs/lustre/include/lustre_fid.h
@@ -481,18 +481,18 @@ static inline int ostid_res_name_eq(const struct ost_id *oi,
 static inline int ostid_set_id(struct ost_id *oi, u64 oid)
 {
 	if (fid_seq_is_mdt0(oi->oi.oi_seq)) {
-		if (oid >= IDIF_MAX_OID)
+		if (oid > IDIF_MAX_OID)
 			return -E2BIG;
 		oi->oi.oi_id = oid;
 	} else if (fid_is_idif(&oi->oi_fid)) {
-		if (oid >= IDIF_MAX_OID)
+		if (oid > IDIF_MAX_OID)
 			return -E2BIG;
 		oi->oi_fid.f_seq = fid_idif_seq(oid,
 						fid_idif_ost_idx(&oi->oi_fid));
 		oi->oi_fid.f_oid = oid;
 		oi->oi_fid.f_ver = oid >> 48;
 	} else {
-		if (oid >= OBIF_MAX_OID)
+		if (oid > OBIF_MAX_OID)
 			return -E2BIG;
 		oi->oi_fid.f_oid = oid;
 	}
diff --git a/include/uapi/linux/lustre/lustre_idl.h b/include/uapi/linux/lustre/lustre_idl.h
index b4185a7..a752639 100644
--- a/include/uapi/linux/lustre/lustre_idl.h
+++ b/include/uapi/linux/lustre/lustre_idl.h
@@ -295,11 +295,9 @@ enum fid_seq {
 };
 
 #define OBIF_OID_MAX_BITS	32
-#define OBIF_MAX_OID		((1ULL << OBIF_OID_MAX_BITS))
-#define OBIF_OID_MASK		((1ULL << OBIF_OID_MAX_BITS) - 1)
+#define OBIF_MAX_OID		((1ULL << OBIF_OID_MAX_BITS) - 1)
 #define IDIF_OID_MAX_BITS	48
-#define IDIF_MAX_OID		((1ULL << IDIF_OID_MAX_BITS))
-#define IDIF_OID_MASK		((1ULL << IDIF_OID_MAX_BITS) - 1)
+#define IDIF_MAX_OID		((1ULL << IDIF_OID_MAX_BITS) - 1)
 
 /** OID for FID_SEQ_SPECIAL */
 enum special_oid {
diff --git a/include/uapi/linux/lustre/lustre_ostid.h b/include/uapi/linux/lustre/lustre_ostid.h
index 90fa213..baf7c8f 100644
--- a/include/uapi/linux/lustre/lustre_ostid.h
+++ b/include/uapi/linux/lustre/lustre_ostid.h
@@ -91,7 +91,7 @@ static inline __u64 ostid_seq(const struct ost_id *ostid)
 static inline __u64 ostid_id(const struct ost_id *ostid)
 {
 	if (fid_seq_is_mdt0(ostid->oi.oi_seq))
-		return ostid->oi.oi_id & IDIF_OID_MASK;
+		return ostid->oi.oi_id & IDIF_MAX_OID;
 
 	if (fid_seq_is_default(ostid->oi.oi_seq))
 		return ostid->oi.oi_id;
@@ -212,7 +212,7 @@ static inline int ostid_to_fid(struct lu_fid *fid, const struct ost_id *ostid,
 		 * been in production for years.  This can handle create rates
 		 * of 1M objects/s/OST for 9 years, or combinations thereof.
 		 */
-		if (oid >= IDIF_MAX_OID)
+		if (oid > IDIF_MAX_OID)
 			return -EBADF;
 
 		fid->f_seq = fid_idif_seq(oid, ost_idx);
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
