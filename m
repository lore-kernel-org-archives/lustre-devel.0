From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Fri,  7 Apr 2017 17:57:01 -0700
Subject: [lustre-devel] [PATCH 03/12] fs: cifs: Replace CURRENT_TIME by
	other appropriate apis
In-Reply-To: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
References: <1491613030-11599-1-git-send-email-deepa.kernel@gmail.com>
Message-ID: <1491613030-11599-4-git-send-email-deepa.kernel@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Cc: yuchao0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, clm-b10kYP2dOMg@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, dushistov-JGs/UdohzUI@public.gmane.org, jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, y2038-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, dsterba-IBi9RG/b67k@public.gmane.org, jaegeuk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbacik-b10kYP2dOMg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, samba-technical-w/Ol4Ecudpl8XjKLYN78aQ@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-btrfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org

CURRENT_TIME macro is not y2038 safe on 32 bit systems.

The patch replaces all the uses of CURRENT_TIME by
current_time() for filesystem times, and ktime_get_*
functions for authentication timestamps and timezone
calculations.

This is also in preparation for the patch that transitions
vfs timestamps to use 64 bit time and hence make them
y2038 safe.

CURRENT_TIME macro will be deleted before merging the
aforementioned change.

The inode timestamps read from the server are assumed
to have correct granularity and range.

The patch also assumes that the difference between server and
client times lie in the range INT_MIN..INT_MAX. This is valid
because this is the difference between current times between
server and client, and the largest timezone difference is in the
range of one day.

All cifs timestamps currently use timespec representation internally.
Authentication and timezone timestamps can also be transitioned into
using timespec64 when all other timestamps for cifs is transitioned
to use timespec64.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 fs/cifs/cifsencrypt.c |  4 +++-
 fs/cifs/cifssmb.c     | 10 +++++-----
 fs/cifs/inode.c       | 28 +++++++++++++++-------------
 3 files changed, 23 insertions(+), 19 deletions(-)

diff --git a/fs/cifs/cifsencrypt.c b/fs/cifs/cifsencrypt.c
index 058ac9b..68abbb0 100644
--- a/fs/cifs/cifsencrypt.c
+++ b/fs/cifs/cifsencrypt.c
@@ -478,6 +478,7 @@ find_timestamp(struct cifs_ses *ses)
 	unsigned char *blobptr;
 	unsigned char *blobend;
 	struct ntlmssp2_name *attrptr;
+	struct timespec ts;
 
 	if (!ses->auth_key.len || !ses->auth_key.response)
 		return 0;
@@ -502,7 +503,8 @@ find_timestamp(struct cifs_ses *ses)
 		blobptr += attrsize; /* advance attr value */
 	}
 
-	return cpu_to_le64(cifs_UnixTimeToNT(CURRENT_TIME));
+	ktime_get_real_ts(&ts);
+	return cpu_to_le64(cifs_UnixTimeToNT(ts));
 }
 
 static int calc_ntlmv2_hash(struct cifs_ses *ses, char *ntlmv2_hash,
diff --git a/fs/cifs/cifssmb.c b/fs/cifs/cifssmb.c
index 0669506..2f279b7 100644
--- a/fs/cifs/cifssmb.c
+++ b/fs/cifs/cifssmb.c
@@ -478,14 +478,14 @@ decode_lanman_negprot_rsp(struct TCP_Server_Info *server, NEGOTIATE_RSP *pSMBr)
 		 * this requirement.
 		 */
 		int val, seconds, remain, result;
-		struct timespec ts, utc;
-		utc = CURRENT_TIME;
+		struct timespec ts;
+		unsigned long utc = ktime_get_real_seconds();
 		ts = cnvrtDosUnixTm(rsp->SrvTime.Date,
 				    rsp->SrvTime.Time, 0);
 		cifs_dbg(FYI, "SrvTime %d sec since 1970 (utc: %d) diff: %d\n",
-			 (int)ts.tv_sec, (int)utc.tv_sec,
-			 (int)(utc.tv_sec - ts.tv_sec));
-		val = (int)(utc.tv_sec - ts.tv_sec);
+			 (int)ts.tv_sec, (int)utc,
+			 (int)(utc - ts.tv_sec));
+		val = (int)(utc - ts.tv_sec);
 		seconds = abs(val);
 		result = (seconds / MIN_TZ_ADJ) * MIN_TZ_ADJ;
 		remain = seconds % MIN_TZ_ADJ;
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index b261db3..c3b2fa0 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -322,9 +322,9 @@ cifs_create_dfs_fattr(struct cifs_fattr *fattr, struct super_block *sb)
 	fattr->cf_mode = S_IFDIR | S_IXUGO | S_IRWXU;
 	fattr->cf_uid = cifs_sb->mnt_uid;
 	fattr->cf_gid = cifs_sb->mnt_gid;
-	fattr->cf_atime = CURRENT_TIME;
-	fattr->cf_ctime = CURRENT_TIME;
-	fattr->cf_mtime = CURRENT_TIME;
+	ktime_get_real_ts(&fattr->cf_mtime);
+	fattr->cf_mtime = timespec_trunc(fattr->cf_mtime, sb->s_time_gran);
+	fattr->cf_atime = fattr->cf_ctime = fattr->cf_mtime;
 	fattr->cf_nlink = 2;
 	fattr->cf_flags |= CIFS_FATTR_DFS_REFERRAL;
 }
@@ -586,9 +586,10 @@ static int cifs_sfu_mode(struct cifs_fattr *fattr, const unsigned char *path,
 /* Fill a cifs_fattr struct with info from FILE_ALL_INFO */
 static void
 cifs_all_info_to_fattr(struct cifs_fattr *fattr, FILE_ALL_INFO *info,
-		       struct cifs_sb_info *cifs_sb, bool adjust_tz,
+		       struct super_block *sb, bool adjust_tz,
 		       bool symlink)
 {
+	struct cifs_sb_info *cifs_sb = CIFS_SB(sb);
 	struct cifs_tcon *tcon = cifs_sb_master_tcon(cifs_sb);
 
 	memset(fattr, 0, sizeof(*fattr));
@@ -598,8 +599,10 @@ cifs_all_info_to_fattr(struct cifs_fattr *fattr, FILE_ALL_INFO *info,
 
 	if (info->LastAccessTime)
 		fattr->cf_atime = cifs_NTtimeToUnix(info->LastAccessTime);
-	else
-		fattr->cf_atime = CURRENT_TIME;
+	else {
+		ktime_get_real_ts(&fattr->cf_atime);
+		fattr->cf_atime = timespec_trunc(fattr->cf_atime, sb->s_time_gran);
+	}
 
 	fattr->cf_ctime = cifs_NTtimeToUnix(info->ChangeTime);
 	fattr->cf_mtime = cifs_NTtimeToUnix(info->LastWriteTime);
@@ -659,7 +662,6 @@ cifs_get_file_info(struct file *filp)
 	FILE_ALL_INFO find_data;
 	struct cifs_fattr fattr;
 	struct inode *inode = file_inode(filp);
-	struct cifs_sb_info *cifs_sb = CIFS_SB(inode->i_sb);
 	struct cifsFileInfo *cfile = filp->private_data;
 	struct cifs_tcon *tcon = tlink_tcon(cfile->tlink);
 	struct TCP_Server_Info *server = tcon->ses->server;
@@ -671,7 +673,7 @@ cifs_get_file_info(struct file *filp)
 	rc = server->ops->query_file_info(xid, tcon, &cfile->fid, &find_data);
 	switch (rc) {
 	case 0:
-		cifs_all_info_to_fattr(&fattr, &find_data, cifs_sb, false,
+		cifs_all_info_to_fattr(&fattr, &find_data, inode->i_sb, false,
 				       false);
 		break;
 	case -EREMOTE:
@@ -753,7 +755,7 @@ cifs_get_inode_info(struct inode **inode, const char *full_path,
 	}
 
 	if (!rc) {
-		cifs_all_info_to_fattr(&fattr, data, cifs_sb, adjust_tz,
+		cifs_all_info_to_fattr(&fattr, data, sb, adjust_tz,
 				       symlink);
 	} else if (rc == -EREMOTE) {
 		cifs_create_dfs_fattr(&fattr, sb);
@@ -1363,9 +1365,9 @@ int cifs_unlink(struct inode *dir, struct dentry *dentry)
 		cifs_inode = CIFS_I(inode);
 		cifs_inode->time = 0;	/* will force revalidate to get info
 					   when needed */
-		inode->i_ctime = current_fs_time(sb);
+		inode->i_ctime = current_time(inode);
 	}
-	dir->i_ctime = dir->i_mtime = current_fs_time(sb);
+	dir->i_ctime = dir->i_mtime = current_time(dir);
 	cifs_inode = CIFS_I(dir);
 	CIFS_I(dir)->time = 0;	/* force revalidate of dir as well */
 unlink_out:
@@ -1633,7 +1635,7 @@ int cifs_rmdir(struct inode *inode, struct dentry *direntry)
 	cifsInode->time = 0;
 
 	d_inode(direntry)->i_ctime = inode->i_ctime = inode->i_mtime =
-		current_fs_time(inode->i_sb);
+		current_time(inode);
 
 rmdir_exit:
 	kfree(full_path);
@@ -1806,7 +1808,7 @@ cifs_rename2(struct inode *source_dir, struct dentry *source_dentry,
 	CIFS_I(source_dir)->time = CIFS_I(target_dir)->time = 0;
 
 	source_dir->i_ctime = source_dir->i_mtime = target_dir->i_ctime =
-		target_dir->i_mtime = current_fs_time(source_dir->i_sb);
+		target_dir->i_mtime = current_time(source_dir);
 
 cifs_rename_exit:
 	kfree(info_buf_source);
-- 
2.7.4
