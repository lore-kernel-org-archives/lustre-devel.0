From: Djalal Harouni <tixxdz@gmail.com>
Date: Tue, 24 May 2016 16:41:33 +0100
Subject: [lustre-devel] [PATCH] posix acls: Move namespace conversion
 into filesystem / xattr handlers
In-Reply-To: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
References: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
Message-ID: <20160524153949.GA2830@dztty.fritz.box>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Steve French <sfrench@samba.org>, linux-fsdevel@vger.kernel.org, lustre-devel@lists.lustre.org, linux-cifs@vger.kernel.org

Hi,

On Mon, May 23, 2016 at 03:09:49PM +0200, Andreas Gruenbacher wrote:
> Currently, getxattr() and setxattr() check for the xattr names
> "system.posix_acl_{access,default}" and perform in-place UID / GID
> namespace mappings in the xattr values. Filesystems then again check for
> the same xattr names to handle those attributes, almost always using the
> standard posix_acl_{access,default}_xattr_handler handlers.  This is
> unnecessary overhead; move the namespace conversion into the xattr
> handlers instead.
Please, are you sure that the changes in posix_acl_xattr_get() and
posix_acl_xattr_set() are safe ? you are reading into current user
namespace, from a first view this is not safe unless I'm missing
something... they should map into init_user_ns...

Please Cc the user namespace maintainers before. Thank you!


> For filesystems that use the POSIX ACL xattr handlers, no change is
> required.  Filesystems that don't use those handlers (cifs and lustre)
> need to take care of the namespace mapping themselves now.
> 
> The only user left of the posix_acl_fix_xattr_{from,to}_user helpers is
> lustre, so this patch moves them into lustre.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
> 
> I'm reasonably confident about the core and cifs changes in this patch.
> The lustre code is pretty weird though, so could I please get a careful
> review on the changes there?
> 
> Thanks,
> Andreas
> 
>  drivers/staging/lustre/lustre/llite/Makefile       |  1 +
>  .../staging/lustre/lustre/llite/llite_internal.h   |  3 ++
>  drivers/staging/lustre/lustre/llite/posix_acl.c    | 62 ++++++++++++++++++++++
>  drivers/staging/lustre/lustre/llite/xattr.c        |  8 ++-
>  fs/cifs/cifssmb.c                                  | 41 ++++++++++----
>  fs/posix_acl.c                                     | 62 +---------------------
>  fs/xattr.c                                         |  7 ---
>  include/linux/posix_acl_xattr.h                    | 12 -----
>  8 files changed, 107 insertions(+), 89 deletions(-)
>  create mode 100644 drivers/staging/lustre/lustre/llite/posix_acl.c
> 
> diff --git a/drivers/staging/lustre/lustre/llite/Makefile b/drivers/staging/lustre/lustre/llite/Makefile
> index 2ce10ff..67125f8 100644
> --- a/drivers/staging/lustre/lustre/llite/Makefile
> +++ b/drivers/staging/lustre/lustre/llite/Makefile
> @@ -7,5 +7,6 @@ lustre-y := dcache.o dir.o file.o llite_close.o llite_lib.o llite_nfs.o \
>  	    glimpse.o lcommon_cl.o lcommon_misc.o \
>  	    vvp_dev.o vvp_page.o vvp_lock.o vvp_io.o vvp_object.o vvp_req.o \
>  	    lproc_llite.o
> +lustre-$(CONFIG_FS_POSIX_ACL) += posix_acl.o
>  
>  llite_lloop-y := lloop.o
> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> index ce1f949..d454dfb 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> @@ -1402,4 +1402,7 @@ int cl_local_size(struct inode *inode);
>  __u64 cl_fid_build_ino(const struct lu_fid *fid, int api32);
>  __u32 cl_fid_build_gen(const struct lu_fid *fid);
>  
> +void posix_acl_fix_xattr_from_user(void *value, size_t size);
> +void posix_acl_fix_xattr_to_user(void *value, size_t size);
> +
>  #endif /* LLITE_INTERNAL_H */
> diff --git a/drivers/staging/lustre/lustre/llite/posix_acl.c b/drivers/staging/lustre/lustre/llite/posix_acl.c
> new file mode 100644
> index 0000000..4fabd0f
> --- /dev/null
> +++ b/drivers/staging/lustre/lustre/llite/posix_acl.c
> @@ -0,0 +1,62 @@
> +#include <linux/kernel.h>
> +#include <linux/fs.h>
> +#include <linux/posix_acl_xattr.h>
> +#include <linux/user_namespace.h>
> +
> +/*
> + * Fix up the uids and gids in posix acl extended attributes in place.
> + */
> +static void posix_acl_fix_xattr_userns(
> +	struct user_namespace *to, struct user_namespace *from,
> +	void *value, size_t size)
> +{
> +	posix_acl_xattr_header *header = (posix_acl_xattr_header *)value;
> +	posix_acl_xattr_entry *entry = (posix_acl_xattr_entry *)(header+1), *end;
> +	int count;
> +	kuid_t uid;
> +	kgid_t gid;
> +
> +	if (!value)
> +		return;
> +	if (size < sizeof(posix_acl_xattr_header))
> +		return;
> +	if (header->a_version != cpu_to_le32(POSIX_ACL_XATTR_VERSION))
> +		return;
> +
> +	count = posix_acl_xattr_count(size);
> +	if (count < 0)
> +		return;
> +	if (count == 0)
> +		return;
> +
> +	for (end = entry + count; entry != end; entry++) {
> +		switch(le16_to_cpu(entry->e_tag)) {
> +		case ACL_USER:
> +			uid = make_kuid(from, le32_to_cpu(entry->e_id));
> +			entry->e_id = cpu_to_le32(from_kuid(to, uid));
> +			break;
> +		case ACL_GROUP:
> +			gid = make_kgid(from, le32_to_cpu(entry->e_id));
> +			entry->e_id = cpu_to_le32(from_kgid(to, gid));
> +			break;
> +		default:
> +			break;
> +		}
> +	}
> +}
> +
> +void posix_acl_fix_xattr_from_user(void *value, size_t size)
> +{
> +	struct user_namespace *user_ns = current_user_ns();
> +	if (user_ns == &init_user_ns)
> +		return;
> +	posix_acl_fix_xattr_userns(&init_user_ns, user_ns, value, size);
> +}
> +
> +void posix_acl_fix_xattr_to_user(void *value, size_t size)
> +{
> +	struct user_namespace *user_ns = current_user_ns();
> +	if (user_ns == &init_user_ns)
> +		return;
> +	posix_acl_fix_xattr_userns(user_ns, &init_user_ns, value, size);
> +}
> diff --git a/drivers/staging/lustre/lustre/llite/xattr.c b/drivers/staging/lustre/lustre/llite/xattr.c
> index ed4de04..c721b44 100644
> --- a/drivers/staging/lustre/lustre/llite/xattr.c
> +++ b/drivers/staging/lustre/lustre/llite/xattr.c
> @@ -144,6 +144,9 @@ int ll_setxattr_common(struct inode *inode, const char *name,
>  		return -EOPNOTSUPP;
>  
>  #ifdef CONFIG_FS_POSIX_ACL
> +	if (xattr_type == XATTR_ACL_ACCESS_T ||
> +	    xattr_type == XATTR_ACL_DEFAULT_T)
> +		posix_acl_fix_xattr_from_user((void *)value, size);
>  	if (sbi->ll_flags & LL_SBI_RMT_CLIENT &&
>  	    (xattr_type == XATTR_ACL_ACCESS_T ||
>  	    xattr_type == XATTR_ACL_DEFAULT_T)) {
> @@ -348,7 +351,7 @@ int ll_getxattr_common(struct inode *inode, const char *name,
>  		if (!acl)
>  			return -ENODATA;
>  
> -		rc = posix_acl_to_xattr(&init_user_ns, acl, buffer, size);
> +		rc = posix_acl_to_xattr(current_user_ns(), acl, buffer, size);
>  		posix_acl_release(acl);
>  		return rc;
>  	}
> @@ -436,6 +439,9 @@ getxattr_nocache:
>  			goto out;
>  		}
>  	}
> +	if (rc >= 0 && (xattr_type == XATTR_ACL_ACCESS_T ||
> +			xattr_type == XATTR_ACL_DEFAULT_T))
> +		posix_acl_fix_xattr_to_user(buffer, rc);
>  #endif
>  
>  out_xattr:
> diff --git a/fs/cifs/cifssmb.c b/fs/cifs/cifssmb.c
> index d47197e..9dc001f 100644
> --- a/fs/cifs/cifssmb.c
> +++ b/fs/cifs/cifssmb.c
> @@ -3337,10 +3337,25 @@ CIFSSMB_set_compression(const unsigned int xid, struct cifs_tcon *tcon,
>  static void cifs_convert_ace(posix_acl_xattr_entry *ace,
>  			     struct cifs_posix_ace *cifs_ace)
>  {
> +	u32 cifs_id, id = -1;
> +
>  	/* u8 cifs fields do not need le conversion */
>  	ace->e_perm = cpu_to_le16(cifs_ace->cifs_e_perm);
>  	ace->e_tag  = cpu_to_le16(cifs_ace->cifs_e_tag);
> -	ace->e_id   = cpu_to_le32(le64_to_cpu(cifs_ace->cifs_uid));
> +	switch(cifs_ace->cifs_e_tag) {
> +	case ACL_USER:
> +		cifs_id = le64_to_cpu(cifs_ace->cifs_uid);
> +		id = from_kuid(current_user_ns(),
> +			       make_kuid(&init_user_ns, cifs_id));
> +		break;
> +
> +	case ACL_GROUP:
> +		cifs_id = le64_to_cpu(cifs_ace->cifs_uid);
> +		id = from_kgid(current_user_ns(),
> +			       make_kgid(&init_user_ns, cifs_id));
> +		break;
> +	}
> +	ace->e_id = cpu_to_le32(id);
>  /*
>  	cifs_dbg(FYI, "perm %d tag %d id %d\n",
>  		 ace->e_perm, ace->e_tag, ace->e_id);
> @@ -3408,21 +3423,29 @@ static int cifs_copy_posix_acl(char *trgt, char *src, const int buflen,
>  static __u16 convert_ace_to_cifs_ace(struct cifs_posix_ace *cifs_ace,
>  				     const posix_acl_xattr_entry *local_ace)
>  {
> -	__u16 rc = 0; /* 0 = ACL converted ok */
> +	u32 cifs_id = -1, id;
>  
>  	cifs_ace->cifs_e_perm = le16_to_cpu(local_ace->e_perm);
>  	cifs_ace->cifs_e_tag =  le16_to_cpu(local_ace->e_tag);
> -	/* BB is there a better way to handle the large uid? */
> -	if (local_ace->e_id == cpu_to_le32(-1)) {
> -	/* Probably no need to le convert -1 on any arch but can not hurt */
> -		cifs_ace->cifs_uid = cpu_to_le64(-1);
> -	} else
> -		cifs_ace->cifs_uid = cpu_to_le64(le32_to_cpu(local_ace->e_id));
> +	switch(cifs_ace->cifs_e_tag) {
> +	case ACL_USER:
> +		id = le32_to_cpu(local_ace->e_id);
> +		cifs_id = from_kuid(&init_user_ns,
> +				    make_kuid(current_user_ns(), id));
> +		break;
> +
> +	case ACL_GROUP:
> +		id = le32_to_cpu(local_ace->e_id);
> +		cifs_id = from_kgid(&init_user_ns,
> +				    make_kgid(current_user_ns(), id));
> +		break;
> +	}
> +	cifs_ace->cifs_uid = cpu_to_le64(cifs_id);
>  /*
>  	cifs_dbg(FYI, "perm %d tag %d id %d\n",
>  		 ace->e_perm, ace->e_tag, ace->e_id);
>  */
> -	return rc;
> +	return 0;
>  }
>  
>  /* Convert ACL from local Linux POSIX xattr to CIFS POSIX ACL wire format */
> diff --git a/fs/posix_acl.c b/fs/posix_acl.c
> index 2c60f17..fca281c 100644
> --- a/fs/posix_acl.c
> +++ b/fs/posix_acl.c
> @@ -627,64 +627,6 @@ no_mem:
>  EXPORT_SYMBOL_GPL(posix_acl_create);
>  
>  /*
> - * Fix up the uids and gids in posix acl extended attributes in place.
> - */
> -static void posix_acl_fix_xattr_userns(
> -	struct user_namespace *to, struct user_namespace *from,
> -	void *value, size_t size)
> -{
> -	posix_acl_xattr_header *header = (posix_acl_xattr_header *)value;
> -	posix_acl_xattr_entry *entry = (posix_acl_xattr_entry *)(header+1), *end;
> -	int count;
> -	kuid_t uid;
> -	kgid_t gid;
> -
> -	if (!value)
> -		return;
> -	if (size < sizeof(posix_acl_xattr_header))
> -		return;
> -	if (header->a_version != cpu_to_le32(POSIX_ACL_XATTR_VERSION))
> -		return;
> -
> -	count = posix_acl_xattr_count(size);
> -	if (count < 0)
> -		return;
> -	if (count == 0)
> -		return;
> -
> -	for (end = entry + count; entry != end; entry++) {
> -		switch(le16_to_cpu(entry->e_tag)) {
> -		case ACL_USER:
> -			uid = make_kuid(from, le32_to_cpu(entry->e_id));
> -			entry->e_id = cpu_to_le32(from_kuid(to, uid));
> -			break;
> -		case ACL_GROUP:
> -			gid = make_kgid(from, le32_to_cpu(entry->e_id));
> -			entry->e_id = cpu_to_le32(from_kgid(to, gid));
> -			break;
> -		default:
> -			break;
> -		}
> -	}
> -}
> -
> -void posix_acl_fix_xattr_from_user(void *value, size_t size)
> -{
> -	struct user_namespace *user_ns = current_user_ns();
> -	if (user_ns == &init_user_ns)
> -		return;
> -	posix_acl_fix_xattr_userns(&init_user_ns, user_ns, value, size);
> -}
> -
> -void posix_acl_fix_xattr_to_user(void *value, size_t size)
> -{
> -	struct user_namespace *user_ns = current_user_ns();
> -	if (user_ns == &init_user_ns)
> -		return;
> -	posix_acl_fix_xattr_userns(user_ns, &init_user_ns, value, size);
> -}
> -
> -/*
>   * Convert from extended attribute to in-memory representation.
>   */
>  struct posix_acl *
> @@ -814,7 +756,7 @@ posix_acl_xattr_get(const struct xattr_handler *handler,
>  	if (acl == NULL)
>  		return -ENODATA;
>  
> -	error = posix_acl_to_xattr(&init_user_ns, acl, value, size);
> +	error = posix_acl_to_xattr(current_user_ns(), acl, value, size);
>  	posix_acl_release(acl);
>  
>  	return error;
> @@ -840,7 +782,7 @@ posix_acl_xattr_set(const struct xattr_handler *handler,
>  		return -EPERM;
>  
>  	if (value) {
> -		acl = posix_acl_from_xattr(&init_user_ns, value, size);
> +		acl = posix_acl_from_xattr(current_user_ns(), value, size);
>  		if (IS_ERR(acl))
>  			return PTR_ERR(acl);
>  
> diff --git a/fs/xattr.c b/fs/xattr.c
> index b11945e..b648b05 100644
> --- a/fs/xattr.c
> +++ b/fs/xattr.c
> @@ -20,7 +20,6 @@
>  #include <linux/fsnotify.h>
>  #include <linux/audit.h>
>  #include <linux/vmalloc.h>
> -#include <linux/posix_acl_xattr.h>
>  
>  #include <asm/uaccess.h>
>  
> @@ -329,9 +328,6 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
>  			error = -EFAULT;
>  			goto out;
>  		}
> -		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
> -		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
> -			posix_acl_fix_xattr_from_user(kvalue, size);
>  	}
>  
>  	error = vfs_setxattr(d, kname, kvalue, size, flags);
> @@ -426,9 +422,6 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
>  
>  	error = vfs_getxattr(d, kname, kvalue, size);
>  	if (error > 0) {
> -		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
> -		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
> -			posix_acl_fix_xattr_to_user(kvalue, size);
>  		if (size && copy_to_user(value, kvalue, error))
>  			error = -EFAULT;
>  	} else if (error == -ERANGE && size >= XATTR_SIZE_MAX) {
> diff --git a/include/linux/posix_acl_xattr.h b/include/linux/posix_acl_xattr.h
> index e5e8ec4..9789aba 100644
> --- a/include/linux/posix_acl_xattr.h
> +++ b/include/linux/posix_acl_xattr.h
> @@ -48,18 +48,6 @@ posix_acl_xattr_count(size_t size)
>  	return size / sizeof(posix_acl_xattr_entry);
>  }
>  
> -#ifdef CONFIG_FS_POSIX_ACL
> -void posix_acl_fix_xattr_from_user(void *value, size_t size);
> -void posix_acl_fix_xattr_to_user(void *value, size_t size);
> -#else
> -static inline void posix_acl_fix_xattr_from_user(void *value, size_t size)
> -{
> -}
> -static inline void posix_acl_fix_xattr_to_user(void *value, size_t size)
> -{
> -}
> -#endif
> -
>  struct posix_acl *posix_acl_from_xattr(struct user_namespace *user_ns, 
>  				       const void *value, size_t size);
>  int posix_acl_to_xattr(struct user_namespace *user_ns,
> -- 
> 2.5.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo at vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Djalal Harouni
http://opendz.org
