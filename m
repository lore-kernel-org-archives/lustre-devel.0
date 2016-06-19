From: Oleg Drokin <green@linuxhacker.ru>
Date: Sat, 18 Jun 2016 23:53:13 -0400
Subject: [lustre-devel] [PATCH 4/4] staging/lustre: Update FID documentation
	link.
In-Reply-To: <1466308393-1183295-1-git-send-email-green@linuxhacker.ru>
References: <1466308393-1183295-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1466308393-1183295-5-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

When OpenSFS took over lustre.org, there was some reshuffling.
FIDs on ZFS document is now at
http://wiki.old.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs
instead of the old location, so update comments accordingly.

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
Reported-by: Xose Vazquez Perez <xose.vazquez@gmail.com>
---
 drivers/staging/lustre/lustre/include/lustre/lustre_idl.h | 4 ++--
 drivers/staging/lustre/lustre/include/lustre_fid.h        | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index bf8a0cd..fac7215 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -382,7 +382,7 @@ static inline __u64 fid_ver_oid(const struct lu_fid *fid)
  * used for other purposes and not risk collisions with existing inodes.
  *
  * Different FID Format
- * http://arch.lustre.org/index.php?title=Interoperability_fids_zfs#NEW.0
+ * http://wiki.old.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs
  */
 enum fid_seq {
 	FID_SEQ_OST_MDT0	= 0,
@@ -700,7 +700,7 @@ static inline int fid_set_id(struct lu_fid *fid, __u64 oid)
  * be passed through unchanged.  Only legacy OST objects in "group 0"
  * will be mapped into the IDIF namespace so that they can fit into the
  * struct lu_fid fields without loss.  For reference see:
- * http://arch.lustre.org/index.php?title=Interoperability_fids_zfs
+ * http://wiki.old.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs
  */
 static inline int ostid_to_fid(struct lu_fid *fid, struct ost_id *ostid,
 			       __u32 ost_idx)
diff --git a/drivers/staging/lustre/lustre/include/lustre_fid.h b/drivers/staging/lustre/lustre/include/lustre_fid.h
index cbdd91a..743671a 100644
--- a/drivers/staging/lustre/lustre/include/lustre_fid.h
+++ b/drivers/staging/lustre/lustre/include/lustre_fid.h
@@ -41,7 +41,7 @@
  *
  * @{
  *
- * http://wiki.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs
+ * http://wiki.old.lustre.org/index.php/Architecture_-_Interoperability_fids_zfs
  * describes the FID namespace and interoperability requirements for FIDs.
  * The important parts of that document are included here for reference.
  *
-- 
2.7.4
