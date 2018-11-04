From: James Simmons <jsimmons@infradead.org>
Date: Sun, 4 Nov 2018 21:35:30 +0000 (GMT)
Subject: [lustre-devel] [PATCH 15/28] lustre: llite: fix for stat under
 kthread and X86_X32
In-Reply-To: <87h8he8wfq.fsf@notabene.neil.brown.name>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-16-git-send-email-jsimmons@infradead.org>
 <87ftx4c9e6.fsf@notabene.neil.brown.name>
 <87h8he8wfq.fsf@notabene.neil.brown.name>
Message-ID: <alpine.LFD.2.21.1811042134360.27308@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


> On Thu, Oct 18 2018, NeilBrown wrote:
> 
> > On Sun, Oct 14 2018, James Simmons wrote:
> >
> >> From: Frank Zago <fzago@cray.com>
> >>
> >> Under the following conditions, ll_getattr will flatten the inode
> >> number when it shouldn't:
> >>
> >>  - the X86_X32 architecture is defined CONFIG_X86_X32, and not even
> >>    used,
> >>  - ll_getattr is called from a kernel thread (though vfs_getattr for
> >>    instance.)
> >>
> >> This has the result that inode numbers are different whether the same
> >> file is stat'ed from a kernel thread, or from a syscall. For instance,
> >> 4198401 vs. 144115205272502273.
> >>
> >> ll_getattr calls ll_need_32bit_api to determine whether the task is 32
> >> bits. When the combination is kthread+X86_X32, that function returns
> >> that the task is 32 bits, which is incorrect, as the kernel is 64
> >> bits.
> >>
> >> The solution is to check whether the call is from a kernel thread
> >> (which is 64 bits) and act consequently.
> >>
> >> Signed-off-by: Frank Zago <fzago@cray.com>
> >> WC-bug-id: https://jira.whamcloud.com/browse/LU-9468
> >> Reviewed-on: https://review.whamcloud.com/26992
> >> Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
> >> Reviewed-by: Dmitry Eremin <dmitry.eremin@intel.com>
> >> Signed-off-by: James Simmons <jsimmons@infradead.org>
> >> ---
> >>  drivers/staging/lustre/lustre/llite/dir.c          |  6 +++---
> >>  drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  2 +-
> >>  .../staging/lustre/lustre/llite/llite_internal.h   | 22 +++++++++++++++++-----
> >>  3 files changed, 21 insertions(+), 9 deletions(-)
> >>
> >> diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
> >> index 231b351..19c5e9c 100644
> >> --- a/drivers/staging/lustre/lustre/llite/dir.c
> >> +++ b/drivers/staging/lustre/lustre/llite/dir.c
> >> @@ -202,7 +202,7 @@ int ll_dir_read(struct inode *inode, __u64 *ppos, struct md_op_data *op_data,
> >>  {
> >>  	struct ll_sb_info    *sbi	= ll_i2sbi(inode);
> >>  	__u64		   pos		= *ppos;
> >> -	int		   is_api32 = ll_need_32bit_api(sbi);
> >> +	bool is_api32 = ll_need_32bit_api(sbi);
> >>  	int		   is_hash64 = sbi->ll_flags & LL_SBI_64BIT_HASH;
> >>  	struct page	  *page;
> >>  	bool		   done = false;
> >> @@ -296,7 +296,7 @@ static int ll_readdir(struct file *filp, struct dir_context *ctx)
> >>  	struct ll_sb_info	*sbi	= ll_i2sbi(inode);
> >>  	__u64 pos = lfd ? lfd->lfd_pos : 0;
> >>  	int			hash64	= sbi->ll_flags & LL_SBI_64BIT_HASH;
> >> -	int			api32	= ll_need_32bit_api(sbi);
> >> +	bool api32 = ll_need_32bit_api(sbi);
> >>  	struct md_op_data *op_data;
> >>  	int			rc;
> >>  
> >> @@ -1674,7 +1674,7 @@ static loff_t ll_dir_seek(struct file *file, loff_t offset, int origin)
> >>  	struct inode *inode = file->f_mapping->host;
> >>  	struct ll_file_data *fd = LUSTRE_FPRIVATE(file);
> >>  	struct ll_sb_info *sbi = ll_i2sbi(inode);
> >> -	int api32 = ll_need_32bit_api(sbi);
> >> +	bool api32 = ll_need_32bit_api(sbi);
> >>  	loff_t ret = -EINVAL;
> >>  
> >>  	switch (origin) {
> >> diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> >> index 30f17ea..20a3c74 100644
> >> --- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> >> +++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> >> @@ -267,7 +267,7 @@ void cl_inode_fini(struct inode *inode)
> >>  /**
> >>   * build inode number from passed @fid
> >>   */
> >> -__u64 cl_fid_build_ino(const struct lu_fid *fid, int api32)
> >> +u64 cl_fid_build_ino(const struct lu_fid *fid, bool api32)
> >>  {
> >>  	if (BITS_PER_LONG == 32 || api32)
> >>  		return fid_flatten32(fid);
> >> diff --git a/drivers/staging/lustre/lustre/llite/llite_internal.h b/drivers/staging/lustre/lustre/llite/llite_internal.h
> >> index dcb2fed..796a8ae 100644
> >> --- a/drivers/staging/lustre/lustre/llite/llite_internal.h
> >> +++ b/drivers/staging/lustre/lustre/llite/llite_internal.h
> >> @@ -651,13 +651,25 @@ static inline struct inode *ll_info2i(struct ll_inode_info *lli)
> >>  __u32 ll_i2suppgid(struct inode *i);
> >>  void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2);
> >>  
> >> -static inline int ll_need_32bit_api(struct ll_sb_info *sbi)
> >> +static inline bool ll_need_32bit_api(struct ll_sb_info *sbi)
> >>  {
> >>  #if BITS_PER_LONG == 32
> >> -	return 1;
> >> +	return true;
> >>  #elif defined(CONFIG_COMPAT)
> >> -	return unlikely(in_compat_syscall() ||
> >> -			(sbi->ll_flags & LL_SBI_32BIT_API));
> >> +	if (unlikely(sbi->ll_flags & LL_SBI_32BIT_API))
> >> +		return true;
> >> +
> >> +#ifdef CONFIG_X86_X32
> >> +	/* in_compat_syscall() returns true when called from a kthread
> >> +	 * and CONFIG_X86_X32 is enabled, which is wrong. So check
> >> +	 * whether the caller comes from a syscall (ie. not a kthread)
> >> +	 * before calling in_compat_syscall().
> >> +	 */
> >> +	if (current->flags & PF_KTHREAD)
> >> +		return false;
> >> +#endif
> >
> > This is wrong.  We should fix in_compat_syscall(), not work around it
> > here.
> > (and then there is that fact that the patch changes 'int' to 'bool'
> > without explaining that in the change description).
> >
> > I've sent a query to some relevant people (Cc:ed to James) to ask about
> > fixing in_compat_syscall().
> 
> Upstream say in_compat_syscall() should only be called from a syscall,
> so I have change the patch to the below.
> 
> We probably need to remove this in_compat_syscall() before going
> mainline.

Do you know the progress of this work?
 
> NeilBrown
> 
> -static inline int ll_need_32bit_api(struct ll_sb_info *sbi)
> +static inline bool ll_need_32bit_api(struct ll_sb_info *sbi)
>  {
>  #if BITS_PER_LONG == 32
> -	return 1;
> -#elif defined(CONFIG_COMPAT)
> -	return unlikely(in_compat_syscall() ||
> -			(sbi->ll_flags & LL_SBI_32BIT_API));
> +	return true;
> +#else
> +	if (unlikely(sbi->ll_flags & LL_SBI_32BIT_API))
> +		return true;
> +
> +#if defined(CONFIG_COMPAT)
> +	/* in_compat_syscall() is only meaningful inside a syscall.
> +	 * As this can be called from a kthread (e.g. nfsd), we
> +	 * need to catch that case first.  kthreads never need the
> +	 * 32bit api.
> +	 */
> +	if (current->flags & PF_KTHREAD)
> +		return false;
> +
> +	return unlikely(in_compat_syscall());
>  #else
> -	return unlikely(sbi->ll_flags & LL_SBI_32BIT_API);
> +	return false;
> +#endif
>  #endif
>  }
> 
