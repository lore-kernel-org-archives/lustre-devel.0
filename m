From: James Simmons <jsimmons@infradead.org>
Date: Thu, 27 Feb 2020 16:11:06 -0500
Subject: [lustre-devel] [PATCH 198/622] lustre: llite: remove
 cl_file_inode_init() LASSERT
In-Reply-To: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
References: <1582838290-17243-1-git-send-email-jsimmons@infradead.org>
Message-ID: <1582838290-17243-199-git-send-email-jsimmons@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

From: Andreas Dilger <adilger@whamcloud.com>

If there is some corruption or other reason that the file layout
cannot be used, the first call to cl_file_inode_init() will fail.
If it is called a second time on the same file then it will hit
an LASSERT() since I_NEW is no longer set on the inode.

It would be good to handle the error in lov_init_raid0() better,
but we still want to avoid this LASSERT() if there is an error.

Convert the LASSERT() in cl_file_inode_init() into a CERROR() and
error return.  This is being triggered due to corruption on the
server, but that shouldn't cause the client to assert.

    lov_dump_lmm_common() oid 0xdf4e:311367, magic 0x0bd10bd0
    lov_dump_lmm_common() stripe_size 1048576, stripe_count 4
    lov_dump_lmm_objects() stripe 0 idx 10 subobj 0x0:151194471
    lov_dump_lmm_objects() stripe 1 idx 12 subobj 0x0:152477530
    lov_dump_lmm_objects() stripe 2 idx 25 subobj 0x0:151589797
    lov_dump_lmm_objects() stripe 3 idx 2 subobj 0x0:150332564
    lov_init_raid0() fsname-clilov: OST0019 is not initialized
    cl_file_inode_init() Failure to initialize cl object
        [0x20004c047:0xdf4e:0x0]: -5

    cl_file_inode_init() ASSERTION(inode->i_state & (1 << 3) ) failed
    cl_file_inode_init() LBUG
    Pid: 37233, comm: ll_sa_4709 3.10.0-862.14.4.el7.x86_64 #1 SMP
    Call Trace:
    libcfs_call_trace+0x8c/0xc0 [libcfs]
    lbug_with_loc+0x4c/0xa0 [libcfs]
    cl_file_inode_init+0x2ac/0x300 [lustre]
    ll_update_inode+0x315/0x600 [lustre]
    ll_iget+0x163/0x350 [lustre]
    ll_prep_inode+0x232/0xc80 [lustre]
    sa_handle_callback+0x3a4/0xf70 [lustre]
    ll_statahead_thread+0x40e/0x2080 [lustre]

Instead, return an IO error instead of killing the client.

WC-bug-id: https://jira.whamcloud.com/browse/LU-11579
Lustre-commit: 0baa3eb1a4ab ("LU-11579 llite: remove cl_file_inode_init() LASSERT")
Signed-off-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-on: https://review.whamcloud.com/33505
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Bobi Jam <bobijam@hotmail.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/lcommon_cl.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/lustre/llite/lcommon_cl.c b/fs/lustre/llite/lcommon_cl.c
index 978e05b..9ac80e0 100644
--- a/fs/lustre/llite/lcommon_cl.c
+++ b/fs/lustre/llite/lcommon_cl.c
@@ -171,7 +171,14 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 		 * unnecessary to perform lookup-alloc-lookup-insert, just
 		 * alloc and insert directly.
 		 */
-		LASSERT(inode->i_state & I_NEW);
+		if (!(inode->i_state & I_NEW)) {
+			result = -EIO;
+			CERROR("%s: unexpected not-NEW inode "DFID": rc = %d\n",
+			       ll_get_fsname(inode->i_sb, NULL, 0), PFID(fid),
+			       result);
+			goto out;
+		}
+
 		conf.coc_lu.loc_flags = LOC_F_NEW;
 		clob = cl_object_find(env, lu2cl_dev(site->ls_top_dev),
 				      fid, &conf);
@@ -193,11 +200,13 @@ int cl_file_inode_init(struct inode *inode, struct lustre_md *md)
 		}
 	}
 
+	if (result)
+		CERROR("%s: failed to initialize cl_object "DFID": rc = %d\n",
+			ll_get_fsname(inode->i_sb, NULL, 0), PFID(fid), result);
+
+out:
 	cl_env_put(env, &refcheck);
 
-	if (result != 0)
-		CERROR("Failure to initialize cl object " DFID ": %d\n",
-		       PFID(fid), result);
 	return result;
 }
 
-- 
1.8.3.1
