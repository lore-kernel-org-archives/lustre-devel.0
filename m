From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Mon, 28 Sep 2015 23:43:45 -0400
Subject: [lustre-devel] [PATCH 02/29] staging/lustre: Remove unused
	lustre_acl_xattr_merge2posix()
In-Reply-To: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
References: <1443498252-1974801-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1443498252-1974801-3-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Oleg Drokin <green@linuxhacker.ru>

Apparently this is only used only on the metadata server.

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 .../staging/lustre/lustre/include/lustre_eacl.h    |   4 -
 drivers/staging/lustre/lustre/obdclass/acl.c       | 119 ---------------------
 2 files changed, 123 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/lustre_eacl.h b/drivers/staging/lustre/lustre/include/lustre_eacl.h
index 0f8f76c..499f9c8 100644
--- a/drivers/staging/lustre/lustre/include/lustre_eacl.h
+++ b/drivers/staging/lustre/lustre/include/lustre_eacl.h
@@ -80,10 +80,6 @@ extern void
 lustre_posix_acl_xattr_free(posix_acl_xattr_header *header, int size);
 extern void
 lustre_ext_acl_xattr_free(ext_acl_xattr_header *header);
-extern int
-lustre_acl_xattr_merge2posix(posix_acl_xattr_header *posix_header, int size,
-			     ext_acl_xattr_header *ext_header,
-			     posix_acl_xattr_header **out);
 extern ext_acl_xattr_header *
 lustre_acl_xattr_merge2ext(posix_acl_xattr_header *posix_header, int size,
 			   ext_acl_xattr_header *ext_header);
diff --git a/drivers/staging/lustre/lustre/obdclass/acl.c b/drivers/staging/lustre/lustre/obdclass/acl.c
index 933456c..1dace14 100644
--- a/drivers/staging/lustre/lustre/obdclass/acl.c
+++ b/drivers/staging/lustre/lustre/obdclass/acl.c
@@ -287,125 +287,6 @@ again:
 }
 
 /*
- * Merge the posix ACL and the extended ACL into new posix ACL.
- */
-int lustre_acl_xattr_merge2posix(posix_acl_xattr_header *posix_header, int size,
-				 ext_acl_xattr_header *ext_header,
-				 posix_acl_xattr_header **out)
-{
-	int posix_count, posix_size, i, j;
-	int ext_count = le32_to_cpu(ext_header->a_count), pos = 0, rc = 0;
-	posix_acl_xattr_entry pe = {ACL_MASK, 0, ACL_UNDEFINED_ID};
-	posix_acl_xattr_header *new;
-	ext_acl_xattr_entry *ee, ae;
-
-	lustre_posix_acl_cpu_to_le(&pe, &pe);
-	ee = lustre_ext_acl_xattr_search(ext_header, &pe, &pos);
-	if (ee == NULL || le32_to_cpu(ee->e_stat) == ES_DEL) {
-		/* there are only base ACL entries at most. */
-		posix_count = 3;
-		posix_size = CFS_ACL_XATTR_SIZE(posix_count, posix_acl_xattr);
-		new = kzalloc(posix_size, GFP_NOFS);
-		if (unlikely(new == NULL))
-			return -ENOMEM;
-
-		new->a_version = cpu_to_le32(CFS_ACL_XATTR_VERSION);
-		for (i = 0, j = 0; i < ext_count; i++) {
-			lustre_ext_acl_le_to_cpu(&ae,
-						 &ext_header->a_entries[i]);
-			switch (ae.e_tag) {
-			case ACL_USER_OBJ:
-			case ACL_GROUP_OBJ:
-			case ACL_OTHER:
-				if (ae.e_id != ACL_UNDEFINED_ID) {
-					rc = -EIO;
-					goto _out;
-				}
-
-				if (ae.e_stat != ES_DEL) {
-					new->a_entries[j].e_tag =
-						ext_header->a_entries[i].e_tag;
-					new->a_entries[j].e_perm =
-						ext_header->a_entries[i].e_perm;
-					new->a_entries[j++].e_id =
-						ext_header->a_entries[i].e_id;
-				}
-				break;
-			case ACL_MASK:
-			case ACL_USER:
-			case ACL_GROUP:
-				if (ae.e_stat == ES_DEL)
-					break;
-			default:
-				rc = -EIO;
-				goto _out;
-			}
-		}
-	} else {
-		/* maybe there are valid ACL_USER or ACL_GROUP entries in the
-		 * original server-side ACL, they are regarded as ES_UNC stat.*/
-		int ori_posix_count;
-
-		if (unlikely(size < 0))
-			return -EINVAL;
-		else if (!size)
-			ori_posix_count = 0;
-		else
-			ori_posix_count =
-				CFS_ACL_XATTR_COUNT(size, posix_acl_xattr);
-		posix_count = ori_posix_count + ext_count;
-		posix_size =
-			CFS_ACL_XATTR_SIZE(posix_count, posix_acl_xattr);
-		new = kzalloc(posix_size, GFP_NOFS);
-		if (unlikely(new == NULL))
-			return -ENOMEM;
-
-		new->a_version = cpu_to_le32(CFS_ACL_XATTR_VERSION);
-		/* 1. process the unchanged ACL entries
-		 *    in the original server-side ACL. */
-		pos = 0;
-		for (i = 0, j = 0; i < ori_posix_count; i++) {
-			ee = lustre_ext_acl_xattr_search(ext_header,
-					&posix_header->a_entries[i], &pos);
-			if (ee == NULL)
-				memcpy(&new->a_entries[j++],
-				       &posix_header->a_entries[i],
-				       sizeof(posix_acl_xattr_entry));
-		}
-
-		/* 2. process the non-deleted entries
-		 *    from client-side extended ACL. */
-		for (i = 0; i < ext_count; i++) {
-			if (le16_to_cpu(ext_header->a_entries[i].e_stat) !=
-			    ES_DEL) {
-				new->a_entries[j].e_tag =
-						ext_header->a_entries[i].e_tag;
-				new->a_entries[j].e_perm =
-						ext_header->a_entries[i].e_perm;
-				new->a_entries[j++].e_id =
-						ext_header->a_entries[i].e_id;
-			}
-		}
-	}
-
-	/* free unused space. */
-	rc = lustre_posix_acl_xattr_reduce_space(&new, posix_count, j);
-	if (rc >= 0) {
-		posix_size = rc;
-		*out = new;
-		rc = 0;
-	}
-
-_out:
-	if (rc) {
-		kfree(new);
-		posix_size = rc;
-	}
-	return posix_size;
-}
-EXPORT_SYMBOL(lustre_acl_xattr_merge2posix);
-
-/*
  * Merge the posix ACL and the extended ACL into new extended ACL.
  */
 ext_acl_xattr_header *
-- 
2.1.0
