From: James Simmons <jsimmons@infradead.org>
Date: Tue, 15 May 2018 16:01:28 +0100 (BST)
Subject: [lustre-devel] [PATCH v2 1/5] staging: lustre: llite: add
 support set_acl method in inode operations
In-Reply-To: <878t8l7ext.fsf@notabene.neil.brown.name>
References: <1526350623-4616-1-git-send-email-jsimmons@infradead.org>
 <1526350623-4616-2-git-send-email-jsimmons@infradead.org>
 <878t8l7ext.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1805151600430.28403@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: devel@driverdev.osuosl.org, Dmitry Eremin <dmitry.eremin@intel.com>, James Simmons <uja.ornl@yahoo.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, "John L. Hammond" <john.hammond@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Mon, May 14 2018, James Simmons wrote:
> 
> > From: Dmitry Eremin <dmitry.eremin@intel.com>
> >
> > Linux kernel v3.14 adds set_acl method to inode operations.
> > This patch adds support to Lustre for proper acl management.
> >
> > Signed-off-by: Dmitry Eremin <dmitry.eremin@intel.com>
> > Signed-off-by: John L. Hammond <john.hammond@intel.com>
> > Signed-off-by: James Simmons <uja.ornl@yahoo.com>
> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9183
> > Reviewed-on: https://review.whamcloud.com/25965
> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10541
> > Reviewed-on: https://review.whamcloud.com/31588
> > Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-10926
> > Reviewed-on: https://review.whamcloud.com/32045
> > Reviewed-by: Bob Glossman <bob.glossman@intel.com>
> > Reviewed-by: James Simmons <uja.ornl@yahoo.com>
> > Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> > Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> > Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> > Signed-off-by: James Simmons <jsimmons@infradead.org>
> > ---
> > Changelog:
> >
> > v1) Initial patch ported to staging tree
> > v2) Fixed up goto handling and avoid BUG() when calling
> >     forget_cached_acl()with invalid type as pointed out by Dan Carpenter
> >
> >  drivers/staging/lustre/lustre/llite/file.c         | 62 ++++++++++++++++++++++
> >  .../staging/lustre/lustre/llite/llite_internal.h   |  4 ++
> >  drivers/staging/lustre/lustre/llite/namei.c        | 10 +++-
> >  3 files changed, 74 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> > index 0026fde..64a5698 100644
> > --- a/drivers/staging/lustre/lustre/llite/file.c
> > +++ b/drivers/staging/lustre/lustre/llite/file.c
> > @@ -3030,6 +3030,7 @@ static int ll_fiemap(struct inode *inode, struct fiemap_extent_info *fieinfo,
> >  	return rc;
> >  }
> >  
> > +#ifdef CONFIG_FS_POSIX_ACL
> 
> Using #ifdef in  .c files is generally discouraged.
> The "standard" approach here is:
> - put the acl code in a separate file (acl.c)
> - optionally include it via the Make file
>      lustre-$(CONFIG_FS_POSIX_ACL) += acl.o
> 
> - in the header where ll_get_acl and ll_set_acl are declared have
>  #ifdef CONFIG_FS_POSIX_ACL
>    declare the functions
>  #else
>  #define ll_get_acl NULL
>  #define ll_set_acl NULL
>  #endif
> 
> Now as this is staging and that is (presumably) an upstream patch
> lightly improved it is probably fine to include the patch as-is,
> but in that case we will probably want to fix it up later.

So you want Lustre to be like everyone else :-)
Okay I will fix up and send a new patch series.

> Thanks,
> NeilBrown
> 
> >  struct posix_acl *ll_get_acl(struct inode *inode, int type)
> >  {
> >  	struct ll_inode_info *lli = ll_i2info(inode);
> > @@ -3043,6 +3044,64 @@ struct posix_acl *ll_get_acl(struct inode *inode, int type)
> >  	return acl;
> >  }
> >  
> > +int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type)
> > +{
> > +	struct ll_sb_info *sbi = ll_i2sbi(inode);
> > +	struct ptlrpc_request *req = NULL;
> > +	const char *name = NULL;
> > +	size_t value_size = 0;
> > +	char *value = NULL;
> > +	int rc;
> > +
> > +	switch (type) {
> > +	case ACL_TYPE_ACCESS:
> > +		name = XATTR_NAME_POSIX_ACL_ACCESS;
> > +		if (acl)
> > +			rc = posix_acl_update_mode(inode, &inode->i_mode, &acl);
> > +		break;
> > +
> > +	case ACL_TYPE_DEFAULT:
> > +		name = XATTR_NAME_POSIX_ACL_DEFAULT;
> > +		if (!S_ISDIR(inode->i_mode))
> > +			rc = acl ? -EACCES : 0;
> > +		break;
> > +
> > +	default:
> > +		rc = -EINVAL;
> > +		break;
> > +	}
> > +	if (rc)
> > +		return rc;
> > +
> > +	if (acl) {
> > +		value_size = posix_acl_xattr_size(acl->a_count);
> > +		value = kmalloc(value_size, GFP_NOFS);
> > +		if (!value) {
> > +			rc = -ENOMEM;
> > +			goto out;
> > +		}
> > +
> > +		rc = posix_acl_to_xattr(&init_user_ns, acl, value, value_size);
> > +		if (rc < 0)
> > +			goto out_value;
> > +	}
> > +
> > +	rc = md_setxattr(sbi->ll_md_exp, ll_inode2fid(inode),
> > +			 value ? OBD_MD_FLXATTR : OBD_MD_FLXATTRRM,
> > +			 name, value, value_size, 0, 0, 0, &req);
> > +
> > +	ptlrpc_req_finished(req);
> > +out_value:
> > +	kfree(value);
> > +out:
> > +	if (rc)
> > +		forget_cached_acl(inode, type);
> > +	else
> > +		set_cached_acl(inode, type, acl);
> > +	return rc;
> > +}
> > +#endif /* CONFIG_FS_POSIX_ACL */
> > +
> >  int ll_inode_permission(struct inode *inode, int mask)
> >  {
> >  	struct ll_sb_info *sbi;
> > @@ -3164,7 +3223,10 @@ int ll_inode_permission(struct inode *inode, int mask)
> >  	.permission	= ll_inode_permission,
> >  	.listxattr	= ll_listxattr,
> >  	.fiemap		= ll_fiemap,
> > +#ifdef CONFIG_FS_POSIX_ACL
> >  	.get_acl	= ll_get_acl,
> > +	.set_acl	= ll_set_acl,
> > +#endif
> >  };
> >  
> >  /* dynamic ioctl number support routines */
> > diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> > index 6504850..2280327 100644
> > --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> > +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> > @@ -754,7 +754,11 @@ enum ldlm_mode ll_take_md_lock(struct inode *inode, __u64 bits,
> >  int ll_md_real_close(struct inode *inode, fmode_t fmode);
> >  int ll_getattr(const struct path *path, struct kstat *stat,
> >  	       u32 request_mask, unsigned int flags);
> > +#ifdef CONFIG_FS_POSIX_ACL
> >  struct posix_acl *ll_get_acl(struct inode *inode, int type);
> > +int ll_set_acl(struct inode *inode, struct posix_acl *acl, int type);
> > +#endif /* CONFIG_FS_POSIX_ACL */
> > +
> >  int ll_migrate(struct inode *parent, struct file *file, int mdtidx,
> >  	       const char *name, int namelen);
> >  int ll_get_fid_by_name(struct inode *parent, const char *name,
> > diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
> > index 9ac7f09..b41f189 100644
> > --- a/drivers/staging/lustre/lustre/llite/namei.c
> > +++ b/drivers/staging/lustre/lustre/llite/namei.c
> > @@ -1195,7 +1195,10 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
> >  	.getattr	    = ll_getattr,
> >  	.permission	 = ll_inode_permission,
> >  	.listxattr	  = ll_listxattr,
> > -	.get_acl	    = ll_get_acl,
> > +#ifdef CONFIG_FS_POSIX_ACL
> > +	.get_acl	= ll_get_acl,
> > +	.set_acl	= ll_set_acl,
> > +#endif
> >  };
> >  
> >  const struct inode_operations ll_special_inode_operations = {
> > @@ -1203,5 +1206,8 @@ static int ll_rename(struct inode *src, struct dentry *src_dchild,
> >  	.getattr	= ll_getattr,
> >  	.permission     = ll_inode_permission,
> >  	.listxattr      = ll_listxattr,
> > -	.get_acl	    = ll_get_acl,
> > +#ifdef CONFIG_FS_POSIX_ACL
> > +	.get_acl	= ll_get_acl,
> > +	.set_acl	= ll_set_acl,
> > +#endif
> >  };
> > -- 
> > 1.8.3.1
> 
