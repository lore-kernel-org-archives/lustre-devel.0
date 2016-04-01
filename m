From: green at linuxhacker.ru <green@linuxhacker.ru>
Date: Fri,  1 Apr 2016 15:18:01 -0400
Subject: [lustre-devel] [PATCH 1/3] staging/lustre: Fix braces {} style
In-Reply-To: <1459538283-3031249-1-git-send-email-green@linuxhacker.ru>
References: <1459538283-3031249-1-git-send-email-green@linuxhacker.ru>
Message-ID: <1459538283-3031249-2-git-send-email-green@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Oleg Drokin <green@linuxhacker.ru>

From: Oleg Drokin <green@linuxhacker.ru>

This fixes all checkpatch form of this from the Lustre tree:
CHECK: braces {} should be used on all arms of this statement

Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
---
 drivers/staging/lustre/lustre/fld/fld_cache.c        |  3 ++-
 .../lustre/lustre/include/lustre/lustre_idl.h        |  3 ++-
 drivers/staging/lustre/lustre/include/obd_class.h    |  3 ++-
 drivers/staging/lustre/lustre/llite/dir.c            | 20 +++++++++++---------
 drivers/staging/lustre/lustre/llite/llite_close.c    |  3 ++-
 drivers/staging/lustre/lustre/llite/llite_lib.c      |  9 +++++----
 drivers/staging/lustre/lustre/llite/lloop.c          |  3 ++-
 drivers/staging/lustre/lustre/llite/namei.c          |  6 ++++--
 drivers/staging/lustre/lustre/llite/rw.c             |  6 ++++--
 drivers/staging/lustre/lustre/llite/rw26.c           |  3 ++-
 drivers/staging/lustre/lustre/llite/vvp_dev.c        | 12 ++++++++----
 drivers/staging/lustre/lustre/llite/vvp_io.c         |  3 ++-
 drivers/staging/lustre/lustre/llite/xattr.c          |  3 ++-
 drivers/staging/lustre/lustre/lmv/lmv_obd.c          |  3 ++-
 drivers/staging/lustre/lustre/lov/lov_dev.c          | 10 ++++++----
 drivers/staging/lustre/lustre/lov/lov_io.c           |  9 ++++++---
 drivers/staging/lustre/lustre/lov/lov_object.c       |  6 ++++--
 drivers/staging/lustre/lustre/lov/lov_pack.c         |  4 ++--
 drivers/staging/lustre/lustre/lov/lovsub_dev.c       |  9 ++++++---
 drivers/staging/lustre/lustre/lov/lovsub_lock.c      |  3 ++-
 drivers/staging/lustre/lustre/lov/lovsub_object.c    |  6 ++++--
 drivers/staging/lustre/lustre/obdclass/cl_io.c       | 13 ++++++++-----
 drivers/staging/lustre/lustre/obdclass/cl_object.c   |  9 ++++++---
 .../staging/lustre/lustre/obdclass/lprocfs_status.c  |  3 ++-
 drivers/staging/lustre/lustre/obdclass/lu_object.c   |  3 ++-
 drivers/staging/lustre/lustre/obdclass/lustre_peer.c |  3 ++-
 drivers/staging/lustre/lustre/osc/osc_io.c           |  3 ++-
 drivers/staging/lustre/lustre/osc/osc_lock.c         |  3 ++-
 drivers/staging/lustre/lustre/osc/osc_object.c       |  3 ++-
 drivers/staging/lustre/lustre/osc/osc_page.c         |  3 ++-
 drivers/staging/lustre/lustre/osc/osc_request.c      |  3 ++-
 drivers/staging/lustre/lustre/ptlrpc/client.c        |  4 ++--
 drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c  |  9 +++++----
 33 files changed, 117 insertions(+), 69 deletions(-)

diff --git a/drivers/staging/lustre/lustre/fld/fld_cache.c b/drivers/staging/lustre/lustre/fld/fld_cache.c
index 062f388..5a04e99 100644
--- a/drivers/staging/lustre/lustre/fld/fld_cache.c
+++ b/drivers/staging/lustre/lustre/fld/fld_cache.c
@@ -178,8 +178,9 @@ restart_fixup:
 				if (n_range->lsr_end <= c_range->lsr_end) {
 					*n_range = *c_range;
 					fld_cache_entry_delete(cache, f_curr);
-				} else
+				} else {
 					n_range->lsr_start = c_range->lsr_end;
+				}
 			}
 
 			/* we could have overlap over next
diff --git a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
index 12e6718..2543eb1 100644
--- a/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
+++ b/drivers/staging/lustre/lustre/include/lustre/lustre_idl.h
@@ -1001,8 +1001,9 @@ static inline int lu_dirent_calc_size(int namelen, __u16 attr)
 
 		size = (sizeof(struct lu_dirent) + namelen + align) & ~align;
 		size += sizeof(struct luda_type);
-	} else
+	} else {
 		size = sizeof(struct lu_dirent) + namelen;
+	}
 
 	return (size + 7) & ~7;
 }
diff --git a/drivers/staging/lustre/lustre/include/obd_class.h b/drivers/staging/lustre/lustre/include/obd_class.h
index 706869f..40f7a23 100644
--- a/drivers/staging/lustre/lustre/include/obd_class.h
+++ b/drivers/staging/lustre/lustre/include/obd_class.h
@@ -490,8 +490,9 @@ static inline int obd_setup(struct obd_device *obd, struct lustre_cfg *cfg)
 				obd->obd_lu_dev = d;
 				d->ld_obd = obd;
 				rc = 0;
-			} else
+			} else {
 				rc = PTR_ERR(d);
+			}
 		}
 		lu_context_exit(&session_ctx);
 		lu_context_fini(&session_ctx);
diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index b085fb4..4837894 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -1497,8 +1497,9 @@ free_lmv:
 					       cmd == LL_IOC_MDC_GETINFO)) {
 				rc = 0;
 				goto skip_lmm;
-			} else
+			} else {
 				goto out_req;
+			}
 		}
 
 		if (cmd == IOC_MDC_GETFILESTRIPE ||
@@ -1711,15 +1712,16 @@ out_quotactl:
 		return ll_flush_ctx(inode);
 #ifdef CONFIG_FS_POSIX_ACL
 	case LL_IOC_RMTACL: {
-	    if (sbi->ll_flags & LL_SBI_RMT_CLIENT && is_root_inode(inode)) {
-		struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
+		if (sbi->ll_flags & LL_SBI_RMT_CLIENT && is_root_inode(inode)) {
+			struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
 
-		rc = rct_add(&sbi->ll_rct, current_pid(), arg);
-		if (!rc)
-			fd->fd_flags |= LL_FILE_RMTACL;
-		return rc;
-	    } else
-		return 0;
+			rc = rct_add(&sbi->ll_rct, current_pid(), arg);
+			if (!rc)
+				fd->fd_flags |= LL_FILE_RMTACL;
+			return rc;
+		} else {
+			return 0;
+		}
 	}
 #endif
 	case LL_IOC_GETOBDCOUNT: {
diff --git a/drivers/staging/lustre/lustre/llite/llite_close.c b/drivers/staging/lustre/lustre/llite/llite_close.c
index 8d23980..92b73ef 100644
--- a/drivers/staging/lustre/lustre/llite/llite_close.c
+++ b/drivers/staging/lustre/lustre/llite/llite_close.c
@@ -323,8 +323,9 @@ static struct ll_inode_info *ll_close_next_lli(struct ll_close_queue *lcq)
 		lli = list_entry(lcq->lcq_head.next, struct ll_inode_info,
 				 lli_close_list);
 		list_del_init(&lli->lli_close_list);
-	} else if (atomic_read(&lcq->lcq_stop))
+	} else if (atomic_read(&lcq->lcq_stop)) {
 		lli = ERR_PTR(-EALREADY);
+	}
 
 	spin_unlock(&lcq->lcq_lock);
 	return lli;
diff --git a/drivers/staging/lustre/lustre/llite/llite_lib.c b/drivers/staging/lustre/lustre/llite/llite_lib.c
index 95c55c3..80f0306 100644
--- a/drivers/staging/lustre/lustre/llite/llite_lib.c
+++ b/drivers/staging/lustre/lustre/llite/llite_lib.c
@@ -1596,8 +1596,9 @@ void ll_update_inode(struct inode *inode, struct lustre_md *md)
 				 " to the "DFID", inode %lu/%u(%p)\n",
 				 PFID(&lli->lli_fid), PFID(&body->fid1),
 				 inode->i_ino, inode->i_generation, inode);
-		} else
+		} else {
 			lli->lli_fid = body->fid1;
+		}
 	}
 
 	LASSERT(fid_seq(&lli->lli_fid) != 0);
@@ -2065,11 +2066,11 @@ int ll_obd_statfs(struct inode *inode, void __user *arg)
 	}
 
 	memcpy(&type, data->ioc_inlbuf1, sizeof(__u32));
-	if (type & LL_STATFS_LMV)
+	if (type & LL_STATFS_LMV) {
 		exp = sbi->ll_md_exp;
-	else if (type & LL_STATFS_LOV)
+	} else if (type & LL_STATFS_LOV) {
 		exp = sbi->ll_dt_exp;
-	else {
+	} else {
 		rc = -ENODEV;
 		goto out_statfs;
 	}
diff --git a/drivers/staging/lustre/lustre/llite/lloop.c b/drivers/staging/lustre/lustre/llite/lloop.c
index b725fc1..cfa2752 100644
--- a/drivers/staging/lustre/lustre/llite/lloop.c
+++ b/drivers/staging/lustre/lustre/llite/lloop.c
@@ -274,8 +274,9 @@ static void loop_add_bio(struct lloop_device *lo, struct bio *bio)
 	if (lo->lo_biotail) {
 		lo->lo_biotail->bi_next = bio;
 		lo->lo_biotail = bio;
-	} else
+	} else {
 		lo->lo_bio = lo->lo_biotail = bio;
+	}
 	spin_unlock_irqrestore(&lo->lo_lock, flags);
 
 	atomic_inc(&lo->lo_pending);
diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
index f8f98e4..8561707 100644
--- a/drivers/staging/lustre/lustre/llite/namei.c
+++ b/drivers/staging/lustre/lustre/llite/namei.c
@@ -128,10 +128,12 @@ struct inode *ll_iget(struct super_block *sb, ino_t hash,
 			if (rc != 0) {
 				iget_failed(inode);
 				inode = NULL;
-			} else
+			} else {
 				unlock_new_inode(inode);
-		} else if (!(inode->i_state & (I_FREEING | I_CLEAR)))
+			}
+		} else if (!(inode->i_state & (I_FREEING | I_CLEAR))) {
 			ll_update_inode(inode, md);
+		}
 		CDEBUG(D_VFSTRACE, "got inode: %p for "DFID"\n",
 		       inode, PFID(&md->body->fid1));
 	}
diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
index 7d5dd38..ebf1ddb 100644
--- a/drivers/staging/lustre/lustre/llite/rw.c
+++ b/drivers/staging/lustre/lustre/llite/rw.c
@@ -132,8 +132,9 @@ struct ll_cl_context *ll_cl_init(struct file *file, struct page *vmpage)
 			lcc->lcc_page = page;
 			lu_ref_add(&page->cp_reference, "cl_io", io);
 			result = 0;
-		} else
+		} else {
 			result = PTR_ERR(page);
+		}
 	}
 	if (result) {
 		ll_cl_fini(lcc);
@@ -488,8 +489,9 @@ static int ll_read_ahead_pages(const struct lu_env *env,
 			if (rc == 1) {
 				(*reserved_pages)--;
 				count++;
-			} else if (rc == -ENOLCK)
+			} else if (rc == -ENOLCK) {
 				break;
+			}
 		} else if (stride_ria) {
 			/* If it is not in the read-ahead window, and it is
 			 * read-ahead mode, then check whether it should skip
diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
index 65baeeb..021415b 100644
--- a/drivers/staging/lustre/lustre/llite/rw26.c
+++ b/drivers/staging/lustre/lustre/llite/rw26.c
@@ -98,8 +98,9 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
 					cl_page_delete(env, page);
 					cl_page_put(env, page);
 				}
-			} else
+			} else {
 				LASSERT(vmpage->private == 0);
+			}
 			cl_env_put(env, &refcheck);
 		}
 	}
diff --git a/drivers/staging/lustre/lustre/llite/vvp_dev.c b/drivers/staging/lustre/lustre/llite/vvp_dev.c
index e35c1a1..d252e10 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_dev.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_dev.c
@@ -342,8 +342,9 @@ int cl_sb_init(struct super_block *sb)
 			sbi->ll_site = cl2lu_dev(cl)->ld_site;
 		}
 		cl_env_put(env, &refcheck);
-	} else
+	} else {
 		rc = PTR_ERR(env);
+	}
 	return rc;
 }
 
@@ -589,16 +590,19 @@ static int vvp_pgcache_show(struct seq_file *f, void *v)
 			if (page) {
 				vvp_pgcache_page_show(env, f, page);
 				cl_page_put(env, page);
-			} else
+			} else {
 				seq_puts(f, "missing\n");
+			}
 			lu_object_ref_del(&clob->co_lu, "dump", current);
 			cl_object_put(env, clob);
-		} else
+		} else {
 			seq_printf(f, "%llx missing\n", pos);
+		}
 		cl_env_put(env, &refcheck);
 		result = 0;
-	} else
+	} else {
 		result = PTR_ERR(env);
+	}
 	return result;
 }
 
diff --git a/drivers/staging/lustre/lustre/llite/vvp_io.c b/drivers/staging/lustre/lustre/llite/vvp_io.c
index aed7b8e..9103c6a 100644
--- a/drivers/staging/lustre/lustre/llite/vvp_io.c
+++ b/drivers/staging/lustre/lustre/llite/vvp_io.c
@@ -1179,8 +1179,9 @@ static int vvp_io_fault_start(const struct lu_env *env,
 				if (result == -EDQUOT)
 					result = -ENOSPC;
 				goto out;
-			} else
+			} else {
 				cl_page_disown(env, io, page);
+			}
 		}
 	}
 
diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
index b68dcc9..be5cb21 100644
--- a/drivers/staging/lustre/lustre/llite/xattr.c
+++ b/drivers/staging/lustre/lustre/llite/xattr.c
@@ -181,8 +181,9 @@ int ll_setxattr_common(struct inode *inode, const char *name,
 			size = rc;
 
 			pv = (const char *)new_value;
-		} else
+		} else {
 			return -EOPNOTSUPP;
+		}
 
 		valid |= rce_ops2valid(rce->rce_ops);
 	}
diff --git a/drivers/staging/lustre/lustre/lmv/lmv_obd.c b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
index 8bd2dc5..1b1dff2 100644
--- a/drivers/staging/lustre/lustre/lmv/lmv_obd.c
+++ b/drivers/staging/lustre/lustre/lmv/lmv_obd.c
@@ -1122,8 +1122,9 @@ static int lmv_iocontrol(unsigned int cmd, struct obd_export *exp,
 					if (!rc)
 						rc = err;
 				}
-			} else
+			} else {
 				set = 1;
+			}
 		}
 		if (!set && !rc)
 			rc = -EIO;
diff --git a/drivers/staging/lustre/lustre/lov/lov_dev.c b/drivers/staging/lustre/lustre/lov/lov_dev.c
index dccc634..dae8e89 100644
--- a/drivers/staging/lustre/lustre/lov/lov_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lov_dev.c
@@ -262,8 +262,9 @@ static int lov_req_init(const struct lu_env *env, struct cl_device *dev,
 	if (lr) {
 		cl_req_slice_add(req, &lr->lr_cl, dev, &lov_req_ops);
 		result = 0;
-	} else
+	} else {
 		result = -ENOMEM;
+	}
 	return result;
 }
 
@@ -332,14 +333,15 @@ static struct lov_device_emerg **lov_emerg_alloc(int nr)
 			cl_page_list_init(&em->emrg_page_list);
 			em->emrg_env = cl_env_alloc(&em->emrg_refcheck,
 						    LCT_REMEMBER | LCT_NOREF);
-			if (!IS_ERR(em->emrg_env))
+			if (!IS_ERR(em->emrg_env)) {
 				em->emrg_env->le_ctx.lc_cookie = 0x2;
-			else {
+			} else {
 				result = PTR_ERR(em->emrg_env);
 				em->emrg_env = NULL;
 			}
-		} else
+		} else {
 			result = -ENOMEM;
+		}
 	}
 	if (result != 0) {
 		lov_emerg_free(emerg, nr);
diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
index 4151237..f443778 100644
--- a/drivers/staging/lustre/lustre/lov/lov_io.c
+++ b/drivers/staging/lustre/lustre/lov/lov_io.c
@@ -225,8 +225,9 @@ struct lov_io_sub *lov_sub_get(const struct lu_env *env,
 	if (!sub->sub_io_initialized) {
 		sub->sub_stripe = stripe;
 		rc = lov_io_sub_init(env, lio, sub);
-	} else
+	} else {
 		rc = 0;
+	}
 	if (rc == 0)
 		lov_sub_enter(sub);
 	else
@@ -294,8 +295,9 @@ static int lov_io_subio_init(const struct lu_env *env, struct lov_io *lio,
 		lio->lis_single_subio_index = -1;
 		lio->lis_active_subios = 0;
 		result = 0;
-	} else
+	} else {
 		result = -ENOMEM;
+	}
 	return result;
 }
 
@@ -413,8 +415,9 @@ static int lov_io_iter_init(const struct lu_env *env,
 			lov_sub_put(sub);
 			CDEBUG(D_VFSTRACE, "shrink: %d [%llu, %llu)\n",
 			       stripe, start, end);
-		} else
+		} else {
 			rc = PTR_ERR(sub);
+		}
 
 		if (!rc)
 			list_add_tail(&sub->sub_linkage, &lio->lis_active);
diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
index 6a353d1..561d493 100644
--- a/drivers/staging/lustre/lustre/lov/lov_object.c
+++ b/drivers/staging/lustre/lustre/lov/lov_object.c
@@ -283,8 +283,9 @@ static int lov_init_raid0(const struct lu_env *env,
 		}
 		if (result == 0)
 			cl_object_header(&lov->lo_cl)->coh_page_bufsize += psz;
-	} else
+	} else {
 		result = -ENOMEM;
+	}
 out:
 	return result;
 }
@@ -935,8 +936,9 @@ struct lu_object *lov_object_alloc(const struct lu_env *env,
 		 * for object with different layouts.
 		 */
 		obj->lo_ops = &lov_lu_obj_ops;
-	} else
+	} else {
 		obj = NULL;
+	}
 	return obj;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lov_pack.c b/drivers/staging/lustre/lustre/lov/lov_pack.c
index 3925633..9723d2e 100644
--- a/drivers/staging/lustre/lustre/lov/lov_pack.c
+++ b/drivers/staging/lustre/lustre/lov/lov_pack.c
@@ -457,9 +457,9 @@ int lov_getstripe(struct obd_export *exp, struct lov_stripe_md *lsm,
 	}
 
 	/* User wasn't expecting this many OST entries */
-	if (lum.lmm_stripe_count == 0)
+	if (lum.lmm_stripe_count == 0) {
 		lmm_size = lum_size;
-	else if (lum.lmm_stripe_count < lmmk->lmm_stripe_count) {
+	} else if (lum.lmm_stripe_count < lmmk->lmm_stripe_count) {
 		rc = -EOVERFLOW;
 		goto out_set;
 	}
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_dev.c b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
index c335c02..35f6b1d 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_dev.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_dev.c
@@ -151,8 +151,9 @@ static int lovsub_req_init(const struct lu_env *env, struct cl_device *dev,
 	if (lsr) {
 		cl_req_slice_add(req, &lsr->lsrq_cl, dev, &lovsub_req_ops);
 		result = 0;
-	} else
+	} else {
 		result = -ENOMEM;
+	}
 	return result;
 }
 
@@ -182,10 +183,12 @@ static struct lu_device *lovsub_device_alloc(const struct lu_env *env,
 			d = lovsub2lu_dev(lsd);
 			d->ld_ops	 = &lovsub_lu_ops;
 			lsd->acid_cl.cd_ops = &lovsub_cl_ops;
-		} else
+		} else {
 			d = ERR_PTR(result);
-	} else
+		}
+	} else {
 		d = ERR_PTR(-ENOMEM);
+	}
 	return d;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_lock.c b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
index 670d203..e92edfb 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_lock.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_lock.c
@@ -77,8 +77,9 @@ int lovsub_lock_init(const struct lu_env *env, struct cl_object *obj,
 		INIT_LIST_HEAD(&lsk->lss_parents);
 		cl_lock_slice_add(lock, &lsk->lss_cl, obj, &lovsub_lock_ops);
 		result = 0;
-	} else
+	} else {
 		result = -ENOMEM;
+	}
 	return result;
 }
 
diff --git a/drivers/staging/lustre/lustre/lov/lovsub_object.c b/drivers/staging/lustre/lustre/lov/lovsub_object.c
index 6c5430d..3f51f0d 100644
--- a/drivers/staging/lustre/lustre/lov/lovsub_object.c
+++ b/drivers/staging/lustre/lustre/lov/lovsub_object.c
@@ -67,8 +67,9 @@ int lovsub_object_init(const struct lu_env *env, struct lu_object *obj,
 		lu_object_add(obj, below);
 		cl_object_page_init(lu2cl(obj), sizeof(struct lovsub_page));
 		result = 0;
-	} else
+	} else {
 		result = -ENOMEM;
+	}
 	return result;
 
 }
@@ -154,8 +155,9 @@ struct lu_object *lovsub_object_alloc(const struct lu_env *env,
 		lu_object_add_top(&hdr->coh_lu, obj);
 		los->lso_cl.co_ops = &lovsub_ops;
 		obj->lo_ops = &lovsub_lu_obj_ops;
-	} else
+	} else {
 		obj = NULL;
+	}
 	return obj;
 }
 
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
index f4b3178..583fb5f 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
@@ -504,9 +504,9 @@ int cl_io_lock_add(const struct lu_env *env, struct cl_io *io,
 {
 	int result;
 
-	if (cl_lockset_merge(&io->ci_lockset, &link->cill_descr))
+	if (cl_lockset_merge(&io->ci_lockset, &link->cill_descr)) {
 		result = 1;
-	else {
+	} else {
 		list_add(&link->cill_linkage, &io->ci_lockset.cls_todo);
 		result = 0;
 	}
@@ -536,8 +536,9 @@ int cl_io_lock_alloc_add(const struct lu_env *env, struct cl_io *io,
 		result = cl_io_lock_add(env, io, link);
 		if (result) /* lock match */
 			link->cill_fini(env, link);
-	} else
+	} else {
 		result = -ENOMEM;
+	}
 
 	return result;
 }
@@ -1202,14 +1203,16 @@ struct cl_req *cl_req_alloc(const struct lu_env *env, struct cl_page *page,
 		if (req->crq_o) {
 			req->crq_nrobjs = nr_objects;
 			result = cl_req_init(env, req, page);
-		} else
+		} else {
 			result = -ENOMEM;
+		}
 		if (result != 0) {
 			cl_req_completion(env, req, result);
 			req = ERR_PTR(result);
 		}
-	} else
+	} else {
 		req = ERR_PTR(-ENOMEM);
+	}
 	return req;
 }
 EXPORT_SYMBOL(cl_req_alloc);
diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
index 395b92c..a068e08 100644
--- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
@@ -654,8 +654,9 @@ static struct lu_env *cl_env_new(__u32 ctx_tags, __u32 ses_tags, void *debug)
 				lu_context_enter(&cle->ce_ses);
 				env->le_ses = &cle->ce_ses;
 				cl_env_init0(cle, debug);
-			} else
+			} else {
 				lu_env_fini(env);
+			}
 		}
 		if (rc != 0) {
 			kmem_cache_free(cl_env_kmem, cle);
@@ -664,8 +665,9 @@ static struct lu_env *cl_env_new(__u32 ctx_tags, __u32 ses_tags, void *debug)
 			CL_ENV_INC(create);
 			CL_ENV_INC(total);
 		}
-	} else
+	} else {
 		env = ERR_PTR(-ENOMEM);
+	}
 	return env;
 }
 
@@ -1095,8 +1097,9 @@ struct cl_device *cl_type_setup(const struct lu_env *env, struct lu_site *site,
 			CERROR("can't init device '%s', %d\n", typename, rc);
 			d = ERR_PTR(rc);
 		}
-	} else
+	} else {
 		CERROR("Cannot allocate device: '%s'\n", typename);
+	}
 	return lu2cl_dev(d);
 }
 EXPORT_SYMBOL(cl_type_setup);
diff --git a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
index d93f42f..9824c88 100644
--- a/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
+++ b/drivers/staging/lustre/lustre/obdclass/lprocfs_status.c
@@ -694,8 +694,9 @@ int lprocfs_rd_import(struct seq_file *m, void *data)
 
 		do_div(sum, ret.lc_count);
 		ret.lc_sum = sum;
-	} else
+	} else {
 		ret.lc_sum = 0;
+	}
 	seq_printf(m,
 		   "    rpcs:\n"
 		   "       inflight: %u\n"
diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
index 770d5bd..a0d3f0c 100644
--- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
+++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
@@ -716,8 +716,9 @@ struct lu_object *lu_object_find_slice(const struct lu_env *env,
 		obj = lu_object_locate(top->lo_header, dev->ld_type);
 		if (!obj)
 			lu_object_put(env, top);
-	} else
+	} else {
 		obj = top;
+	}
 	return obj;
 }
 EXPORT_SYMBOL(lu_object_find_slice);
diff --git a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
index 5f81246..b1abe02 100644
--- a/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
+++ b/drivers/staging/lustre/lustre/obdclass/lustre_peer.c
@@ -163,8 +163,9 @@ int class_del_uuid(const char *uuid)
 				break;
 			}
 		}
-	} else
+	} else {
 		list_splice_init(&g_uuid_list, &deathrow);
+	}
 	spin_unlock(&g_uuid_lock);
 
 	if (uuid && list_empty(&deathrow)) {
diff --git a/drivers/staging/lustre/lustre/osc/osc_io.c b/drivers/staging/lustre/lustre/osc/osc_io.c
index cf7743d..bc08f38 100644
--- a/drivers/staging/lustre/lustre/osc/osc_io.c
+++ b/drivers/staging/lustre/lustre/osc/osc_io.c
@@ -842,8 +842,9 @@ int osc_req_init(const struct lu_env *env, struct cl_device *dev,
 	if (or) {
 		cl_req_slice_add(req, &or->or_cl, dev, &osc_req_ops);
 		result = 0;
-	} else
+	} else {
 		result = -ENOMEM;
+	}
 	return result;
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
index 49dfe9f..7ea6489 100644
--- a/drivers/staging/lustre/lustre/osc/osc_lock.c
+++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
@@ -624,8 +624,9 @@ static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
 			result = -ELDLM_NO_LOCK_DATA;
 		}
 		cl_env_nested_put(&nest, env);
-	} else
+	} else {
 		result = PTR_ERR(env);
+	}
 	req->rq_status = result;
 	return result;
 }
diff --git a/drivers/staging/lustre/lustre/osc/osc_object.c b/drivers/staging/lustre/lustre/osc/osc_object.c
index a06bdf1..738ab10 100644
--- a/drivers/staging/lustre/lustre/osc/osc_object.c
+++ b/drivers/staging/lustre/lustre/osc/osc_object.c
@@ -292,8 +292,9 @@ struct lu_object *osc_object_alloc(const struct lu_env *env,
 		lu_object_init(obj, NULL, dev);
 		osc->oo_cl.co_ops = &osc_ops;
 		obj->lo_ops = &osc_lu_obj_ops;
-	} else
+	} else {
 		obj = NULL;
+	}
 	return obj;
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
index 82979f4..74aca89 100644
--- a/drivers/staging/lustre/lustre/osc/osc_page.c
+++ b/drivers/staging/lustre/lustre/osc/osc_page.c
@@ -421,8 +421,9 @@ static int osc_cache_too_much(struct client_obd *cli)
 			return lru_shrink_max;
 		else if (pages >= budget / 2)
 			return lru_shrink_min;
-	} else if (pages >= budget * 2)
+	} else if (pages >= budget * 2) {
 		return lru_shrink_min;
+	}
 	return 0;
 }
 
diff --git a/drivers/staging/lustre/lustre/osc/osc_request.c b/drivers/staging/lustre/lustre/osc/osc_request.c
index 547539c..2f6f6be 100644
--- a/drivers/staging/lustre/lustre/osc/osc_request.c
+++ b/drivers/staging/lustre/lustre/osc/osc_request.c
@@ -3065,8 +3065,9 @@ static int osc_import_event(struct obd_device *obd,
 
 			ldlm_namespace_cleanup(ns, LDLM_FL_LOCAL_ONLY);
 			cl_env_put(env, &refcheck);
-		} else
+		} else {
 			rc = PTR_ERR(env);
+		}
 		break;
 	}
 	case IMP_EVENT_ACTIVE: {
diff --git a/drivers/staging/lustre/lustre/ptlrpc/client.c b/drivers/staging/lustre/lustre/ptlrpc/client.c
index 32a7c87..93746ec 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/client.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/client.c
@@ -595,9 +595,9 @@ static int __ptlrpc_request_bufs_pack(struct ptlrpc_request *request,
 	struct obd_import *imp = request->rq_import;
 	int rc;
 
-	if (unlikely(ctx))
+	if (unlikely(ctx)) {
 		request->rq_cli_ctx = sptlrpc_cli_ctx_get(ctx);
-	else {
+	} else {
 		rc = sptlrpc_req_get_ctx(request);
 		if (rc)
 			goto out_free;
diff --git a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
index cee04ef..419478b 100644
--- a/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
+++ b/drivers/staging/lustre/lustre/ptlrpc/lproc_ptlrpc.c
@@ -679,11 +679,11 @@ static ssize_t ptlrpc_lprocfs_nrs_seq_write(struct file *file,
 	/**
 	 * The second token is either NULL, or an optional [reg|hp] string
 	 */
-	if (strcmp(cmd, "reg") == 0)
+	if (strcmp(cmd, "reg") == 0) {
 		queue = PTLRPC_NRS_QUEUE_REG;
-	else if (strcmp(cmd, "hp") == 0)
+	} else if (strcmp(cmd, "hp") == 0) {
 		queue = PTLRPC_NRS_QUEUE_HP;
-	else {
+	} else {
 		rc = -EINVAL;
 		goto out;
 	}
@@ -693,8 +693,9 @@ default_queue:
 	if (queue == PTLRPC_NRS_QUEUE_HP && !nrs_svc_has_hp(svc)) {
 		rc = -ENODEV;
 		goto out;
-	} else if (queue == PTLRPC_NRS_QUEUE_BOTH && !nrs_svc_has_hp(svc))
+	} else if (queue == PTLRPC_NRS_QUEUE_BOTH && !nrs_svc_has_hp(svc)) {
 		queue = PTLRPC_NRS_QUEUE_REG;
+	}
 
 	/**
 	 * Serialize NRS core lprocfs operations with policy registration/
-- 
2.1.0
