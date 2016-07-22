From: James Simmons <jsimmons@infradead.org>
Date: Thu, 21 Jul 2016 22:44:35 -0400
Subject: [lustre-devel] [PATCH 42/58] staging: lustre: don't need to const
	__u64 parameters for lustre_idl.h
In-Reply-To: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
References: <1469155491-15265-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1469155491-15265-43-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L. Hammond" <john.hammond@intel.com>, James Simmons <jsimmons@infradead.org>

From: John L. Hammond <john.hammond@intel.com>

Remove the const for the __u64 parameters for inline functions
in lustre_idl.h.

Signed-off-by: John L. Hammond <john.hammond@intel.com>
Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-2675
Reviewed-on: http://review.whamcloud.com/8641
Reviewed-by: wangdi <di.wang@intel.com>
Reviewed-by: Fan Yong <fan.yong@intel.com>
Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 6853f62..87e79b9 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -442,7 +442,7 @@ static inline int fid_seq_is_mdt0(__u64 seq)
 	return (seq == FID_SEQ_OST_MDT0);
 }
 
-static inline int fid_seq_is_mdt(const __u64 seq)
+static inline int fid_seq_is_mdt(__u64 seq)
 {
 	return seq == FID_SEQ_OST_MDT0 || seq >= FID_SEQ_NORMAL;
 };
@@ -468,33 +468,33 @@ static inline int fid_is_llog(const struct lu_fid *fid)
 	return fid_seq_is_llog(fid_seq(fid)) && fid_oid(fid) > 0;
 }
 
-static inline int fid_seq_is_rsvd(const __u64 seq)
+static inline int fid_seq_is_rsvd(__u64 seq)
 {
 	return (seq > FID_SEQ_OST_MDT0 && seq <= FID_SEQ_RSVD);
 };
 
-static inline int fid_seq_is_special(const __u64 seq)
+static inline int fid_seq_is_special(__u64 seq)
 {
 	return seq == FID_SEQ_SPECIAL;
 };
 
-static inline int fid_seq_is_local_file(const __u64 seq)
+static inline int fid_seq_is_local_file(__u64 seq)
 {
 	return seq == FID_SEQ_LOCAL_FILE ||
 	       seq == FID_SEQ_LOCAL_NAME;
 };
 
-static inline int fid_seq_is_root(const __u64 seq)
+static inline int fid_seq_is_root(__u64 seq)
 {
 	return seq == FID_SEQ_ROOT;
 }
 
-static inline int fid_seq_is_dot(const __u64 seq)
+static inline int fid_seq_is_dot(__u64 seq)
 {
 	return seq == FID_SEQ_DOT_LUSTRE;
 }
 
-static inline int fid_seq_is_default(const __u64 seq)
+static inline int fid_seq_is_default(__u64 seq)
 {
 	return seq == FID_SEQ_LOV_DEFAULT;
 }
@@ -516,7 +516,7 @@ static inline void lu_root_fid(struct lu_fid *fid)
  * \param fid the fid to be tested.
  * \return true if the fid is a igif; otherwise false.
  */
-static inline int fid_seq_is_igif(const __u64 seq)
+static inline int fid_seq_is_igif(__u64 seq)
 {
 	return seq >= FID_SEQ_IGIF && seq <= FID_SEQ_IGIF_MAX;
 }
@@ -531,7 +531,7 @@ static inline int fid_is_igif(const struct lu_fid *fid)
  * \param fid the fid to be tested.
  * \return true if the fid is a idif; otherwise false.
  */
-static inline int fid_seq_is_idif(const __u64 seq)
+static inline int fid_seq_is_idif(__u64 seq)
 {
 	return seq >= FID_SEQ_IDIF && seq <= FID_SEQ_IDIF_MAX;
 }
@@ -546,7 +546,7 @@ static inline int fid_is_local_file(const struct lu_fid *fid)
 	return fid_seq_is_local_file(fid_seq(fid));
 }
 
-static inline int fid_seq_is_norm(const __u64 seq)
+static inline int fid_seq_is_norm(__u64 seq)
 {
 	return (seq >= FID_SEQ_NORMAL);
 }
-- 
1.7.1
