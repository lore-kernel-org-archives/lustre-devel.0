From: James Simmons <jsimmons@infradead.org>
Date: Thu,  4 Aug 2016 12:53:06 -0400
Subject: [lustre-devel] [PATCH 30/31] staging: lustre: include: fix one off
	errors in lustre_id.h
In-Reply-To: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
References: <1470329587-18768-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1470329587-18768-31-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, James Simmons <jsimmons@infradead.org>

During inspection of another patch Dan Carpenter noticed some
one off errors in lustre_id.h. Fix the condition test for
OBIF_MAX_OID.

Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 .../lustre/lustre/include/lustre/lustre_idl.h      |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 17581ba..9545451 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -659,7 +659,7 @@ static inline void ostid_set_id(struct ost_id *oi, __u64 oid)
 		oi->oi_fid.f_oid = oid;
 		oi->oi_fid.f_ver = oid >> 48;
 	} else {
-		if (oid > OBIF_MAX_OID) {
+		if (oid >= OBIF_MAX_OID) {
 			CERROR("Bad %llu to set " DOSTID "\n", oid, POSTID(oi));
 			return;
 		}
@@ -684,7 +684,7 @@ static inline int fid_set_id(struct lu_fid *fid, __u64 oid)
 		fid->f_oid = oid;
 		fid->f_ver = oid >> 48;
 	} else {
-		if (oid > OBIF_MAX_OID) {
+		if (oid >= OBIF_MAX_OID) {
 			CERROR("Too large OID %#llx to set REG "DFID"\n",
 			       (unsigned long long)oid, PFID(fid));
 			return -EBADF;
-- 
1.7.1
