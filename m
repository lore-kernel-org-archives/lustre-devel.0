From: James Simmons <jsimmons@infradead.org>
Date: Mon, 7 Nov 2016 01:53:06 +0000 (GMT)
Subject: [lustre-devel] [PATCH 05/14] staging/lustre: Get rid of cl_env
	hash table
In-Reply-To: <1478136304-867780-6-git-send-email-green@linuxhacker.ru>
References: <1478136304-867780-1-git-send-email-green@linuxhacker.ru>
	<1478136304-867780-6-git-send-email-green@linuxhacker.ru>
Message-ID: <alpine.LFD.2.20.1611070152550.21293@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, Jinshan Xiong <jinshan.xiong@intel.com>


> From: Jinshan Xiong <jinshan.xiong@intel.com>
> 
> cl_env hash table is under heavy contention when there are lots of
> processes doing IO at the same time;
> reduce lock contention by replacing cl_env cache with percpu array;
> remove cl_env_nested_get() and cl_env_nested_put();
> remove cl_env_reenter() and cl_env_reexit();

Reviewed-by: James Simmons <jsimmons@infradead.org>
 
> Signed-off-by: Jinshan Xiong <jinshan.xiong@intel.com>
> Reviewed-on: http://review.whamcloud.com/20254
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4257
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Reviewed-by: Bobi Jam <bobijam@hotmail.com>
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
> ---
>  drivers/staging/lustre/lustre/include/cl_object.h  |  22 --
>  drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |   9 -
>  drivers/staging/lustre/lustre/llite/file.c         |  18 +-
>  drivers/staging/lustre/lustre/llite/lcommon_cl.c   |  11 +-
>  drivers/staging/lustre/lustre/llite/lcommon_misc.c |   8 +-
>  drivers/staging/lustre/lustre/llite/llite_mmap.c   |  59 ++--
>  drivers/staging/lustre/lustre/llite/rw.c           |   6 +-
>  drivers/staging/lustre/lustre/llite/rw26.c         |  16 +-
>  drivers/staging/lustre/lustre/lov/lov_io.c         |   5 -
>  drivers/staging/lustre/lustre/lov/lov_object.c     |   7 +-
>  .../staging/lustre/lustre/obdclass/cl_internal.h   |  23 --
>  drivers/staging/lustre/lustre/obdclass/cl_io.c     |   1 -
>  drivers/staging/lustre/lustre/obdclass/cl_object.c | 389 ++++-----------------
>  drivers/staging/lustre/lustre/obdclass/lu_object.c |   4 -
>  .../staging/lustre/lustre/obdecho/echo_client.c    |  14 +-
>  drivers/staging/lustre/lustre/osc/osc_cache.c      |   6 +-
>  drivers/staging/lustre/lustre/osc/osc_lock.c       | 116 +++---
>  drivers/staging/lustre/lustre/osc/osc_page.c       |   6 +-
>  18 files changed, 183 insertions(+), 537 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/include/cl_object.h b/drivers/staging/lustre/lustre/include/cl_object.h
> index 514d650..3fe26e7 100644
> --- a/drivers/staging/lustre/lustre/include/cl_object.h
> +++ b/drivers/staging/lustre/lustre/include/cl_object.h
> @@ -2640,35 +2640,13 @@ void cl_sync_io_end(const struct lu_env *env, struct cl_sync_io *anchor);
>   *     - allocation and destruction of environment is amortized by caching no
>   *     longer used environments instead of destroying them;
>   *
> - *     - there is a notion of "current" environment, attached to the kernel
> - *     data structure representing current thread Top-level lustre code
> - *     allocates an environment and makes it current, then calls into
> - *     non-lustre code, that in turn calls lustre back. Low-level lustre
> - *     code thus called can fetch environment created by the top-level code
> - *     and reuse it, avoiding additional environment allocation.
> - *       Right now, three interfaces can attach the cl_env to running thread:
> - *       - cl_env_get
> - *       - cl_env_implant
> - *       - cl_env_reexit(cl_env_reenter had to be called priorly)
> - *
>   * \see lu_env, lu_context, lu_context_key
>   * @{
>   */
>  
> -struct cl_env_nest {
> -	int   cen_refcheck;
> -	void *cen_cookie;
> -};
> -
>  struct lu_env *cl_env_get(int *refcheck);
>  struct lu_env *cl_env_alloc(int *refcheck, __u32 tags);
> -struct lu_env *cl_env_nested_get(struct cl_env_nest *nest);
>  void cl_env_put(struct lu_env *env, int *refcheck);
> -void cl_env_nested_put(struct cl_env_nest *nest, struct lu_env *env);
> -void *cl_env_reenter(void);
> -void cl_env_reexit(void *cookie);
> -void cl_env_implant(struct lu_env *env, int *refcheck);
> -void cl_env_unplant(struct lu_env *env, int *refcheck);
>  unsigned int cl_env_cache_purge(unsigned int nr);
>  struct lu_env *cl_env_percpu_get(void);
>  void cl_env_percpu_put(struct lu_env *env);
> diff --git a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> index b29c9561..19831c5 100644
> --- a/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> +++ b/drivers/staging/lustre/lustre/ldlm/ldlm_pool.c
> @@ -794,7 +794,6 @@ static unsigned long ldlm_pools_count(ldlm_side_t client, gfp_t gfp_mask)
>  	int nr_ns;
>  	struct ldlm_namespace *ns;
>  	struct ldlm_namespace *ns_old = NULL; /* loop detection */
> -	void *cookie;
>  
>  	if (client == LDLM_NAMESPACE_CLIENT && !(gfp_mask & __GFP_FS))
>  		return 0;
> @@ -802,8 +801,6 @@ static unsigned long ldlm_pools_count(ldlm_side_t client, gfp_t gfp_mask)
>  	CDEBUG(D_DLMTRACE, "Request to count %s locks from all pools\n",
>  	       client == LDLM_NAMESPACE_CLIENT ? "client" : "server");
>  
> -	cookie = cl_env_reenter();
> -
>  	/*
>  	 * Find out how many resources we may release.
>  	 */
> @@ -812,7 +809,6 @@ static unsigned long ldlm_pools_count(ldlm_side_t client, gfp_t gfp_mask)
>  		mutex_lock(ldlm_namespace_lock(client));
>  		if (list_empty(ldlm_namespace_list(client))) {
>  			mutex_unlock(ldlm_namespace_lock(client));
> -			cl_env_reexit(cookie);
>  			return 0;
>  		}
>  		ns = ldlm_namespace_first_locked(client);
> @@ -838,7 +834,6 @@ static unsigned long ldlm_pools_count(ldlm_side_t client, gfp_t gfp_mask)
>  		ldlm_namespace_put(ns);
>  	}
>  
> -	cl_env_reexit(cookie);
>  	return total;
>  }
>  
> @@ -847,13 +842,10 @@ static unsigned long ldlm_pools_scan(ldlm_side_t client, int nr, gfp_t gfp_mask)
>  	unsigned long freed = 0;
>  	int tmp, nr_ns;
>  	struct ldlm_namespace *ns;
> -	void *cookie;
>  
>  	if (client == LDLM_NAMESPACE_CLIENT && !(gfp_mask & __GFP_FS))
>  		return -1;
>  
> -	cookie = cl_env_reenter();
> -
>  	/*
>  	 * Shrink at least ldlm_namespace_nr_read(client) namespaces.
>  	 */
> @@ -883,7 +875,6 @@ static unsigned long ldlm_pools_scan(ldlm_side_t client, int nr, gfp_t gfp_mask)
>  		freed += ldlm_pool_shrink(&ns->ns_pool, cancel, gfp_mask);
>  		ldlm_namespace_put(ns);
>  	}
> -	cl_env_reexit(cookie);
>  	/*
>  	 * we only decrease the SLV in server pools shrinker, return
>  	 * SHRINK_STOP to kernel to avoid needless loop. LU-1128
> diff --git a/drivers/staging/lustre/lustre/llite/file.c b/drivers/staging/lustre/lustre/llite/file.c
> index 0ae78c7..c1c7551 100644
> --- a/drivers/staging/lustre/lustre/llite/file.c
> +++ b/drivers/staging/lustre/lustre/llite/file.c
> @@ -1584,11 +1584,11 @@ int ll_data_version(struct inode *inode, __u64 *data_version, int flags)
>   */
>  int ll_hsm_release(struct inode *inode)
>  {
> -	struct cl_env_nest nest;
>  	struct lu_env *env;
>  	struct obd_client_handle *och = NULL;
>  	__u64 data_version = 0;
>  	int rc;
> +	int refcheck;
>  
>  	CDEBUG(D_INODE, "%s: Releasing file "DFID".\n",
>  	       ll_get_fsname(inode->i_sb, NULL, 0),
> @@ -1605,14 +1605,14 @@ int ll_hsm_release(struct inode *inode)
>  	if (rc != 0)
>  		goto out;
>  
> -	env = cl_env_nested_get(&nest);
> +	env = cl_env_get(&refcheck);
>  	if (IS_ERR(env)) {
>  		rc = PTR_ERR(env);
>  		goto out;
>  	}
>  
>  	ll_merge_attr(env, inode);
> -	cl_env_nested_put(&nest, env);
> +	cl_env_put(env, &refcheck);
>  
>  	/* Release the file.
>  	 * NB: lease lock handle is released in mdc_hsm_release_pack() because
> @@ -2268,17 +2268,17 @@ static int ll_flush(struct file *file, fl_owner_t id)
>  int cl_sync_file_range(struct inode *inode, loff_t start, loff_t end,
>  		       enum cl_fsync_mode mode, int ignore_layout)
>  {
> -	struct cl_env_nest nest;
>  	struct lu_env *env;
>  	struct cl_io *io;
>  	struct cl_fsync_io *fio;
>  	int result;
> +	int refcheck;
>  
>  	if (mode != CL_FSYNC_NONE && mode != CL_FSYNC_LOCAL &&
>  	    mode != CL_FSYNC_DISCARD && mode != CL_FSYNC_ALL)
>  		return -EINVAL;
>  
> -	env = cl_env_nested_get(&nest);
> +	env = cl_env_get(&refcheck);
>  	if (IS_ERR(env))
>  		return PTR_ERR(env);
>  
> @@ -2301,7 +2301,7 @@ int cl_sync_file_range(struct inode *inode, loff_t start, loff_t end,
>  	if (result == 0)
>  		result = fio->fi_nr_written;
>  	cl_io_fini(env, io);
> -	cl_env_nested_put(&nest, env);
> +	cl_env_put(env, &refcheck);
>  
>  	return result;
>  }
> @@ -3149,14 +3149,14 @@ int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
>  {
>  	struct ll_inode_info *lli = ll_i2info(inode);
>  	struct cl_object *obj = lli->lli_clob;
> -	struct cl_env_nest nest;
>  	struct lu_env *env;
>  	int rc;
> +	int refcheck;
>  
>  	if (!obj)
>  		return 0;
>  
> -	env = cl_env_nested_get(&nest);
> +	env = cl_env_get(&refcheck);
>  	if (IS_ERR(env))
>  		return PTR_ERR(env);
>  
> @@ -3190,7 +3190,7 @@ int ll_layout_conf(struct inode *inode, const struct cl_object_conf *conf)
>  		ll_layout_version_set(lli, cl.cl_layout_gen);
>  	}
>  out:
> -	cl_env_nested_put(&nest, env);
> +	cl_env_put(env, &refcheck);
>  	return rc;
>  }
>  
> diff --git a/drivers/staging/lustre/lustre/llite/lcommon_cl.c b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> index 56e414b..dd1cfd8 100644
> --- a/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> +++ b/drivers/staging/lustre/lustre/llite/lcommon_cl.c
> @@ -246,15 +246,11 @@ void cl_inode_fini(struct inode *inode)
>  	int emergency;
>  
>  	if (clob) {
> -		void		    *cookie;
> -
> -		cookie = cl_env_reenter();
>  		env = cl_env_get(&refcheck);
>  		emergency = IS_ERR(env);
>  		if (emergency) {
>  			mutex_lock(&cl_inode_fini_guard);
>  			LASSERT(cl_inode_fini_env);
> -			cl_env_implant(cl_inode_fini_env, &refcheck);
>  			env = cl_inode_fini_env;
>  		}
>  		/*
> @@ -266,13 +262,10 @@ void cl_inode_fini(struct inode *inode)
>  		lu_object_ref_del(&clob->co_lu, "inode", inode);
>  		cl_object_put_last(env, clob);
>  		lli->lli_clob = NULL;
> -		if (emergency) {
> -			cl_env_unplant(cl_inode_fini_env, &refcheck);
> +		if (emergency)
>  			mutex_unlock(&cl_inode_fini_guard);
> -		} else {
> +		else
>  			cl_env_put(env, &refcheck);
> -		}
> -		cl_env_reexit(cookie);
>  	}
>  }
>  
> diff --git a/drivers/staging/lustre/lustre/llite/lcommon_misc.c b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
> index 1558b55..f48660e 100644
> --- a/drivers/staging/lustre/lustre/llite/lcommon_misc.c
> +++ b/drivers/staging/lustre/lustre/llite/lcommon_misc.c
> @@ -162,13 +162,11 @@ int cl_get_grouplock(struct cl_object *obj, unsigned long gid, int nonblock,
>  		return rc;
>  	}
>  
> -	cg->lg_env  = cl_env_get(&refcheck);
> +	cg->lg_env  = env;
>  	cg->lg_io   = io;
>  	cg->lg_lock = lock;
>  	cg->lg_gid  = gid;
> -	LASSERT(cg->lg_env == env);
>  
> -	cl_env_unplant(env, &refcheck);
>  	return 0;
>  }
>  
> @@ -177,14 +175,10 @@ void cl_put_grouplock(struct ll_grouplock *cg)
>  	struct lu_env  *env  = cg->lg_env;
>  	struct cl_io   *io   = cg->lg_io;
>  	struct cl_lock *lock = cg->lg_lock;
> -	int	     refcheck;
>  
>  	LASSERT(cg->lg_env);
>  	LASSERT(cg->lg_gid);
>  
> -	cl_env_implant(env, &refcheck);
> -	cl_env_put(env, &refcheck);
> -
>  	cl_lock_release(env, lock);
>  	cl_io_fini(env, io);
>  	cl_env_put(env, NULL);
> diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
> index 4366918..ad2a699 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
> @@ -80,43 +80,24 @@ struct vm_area_struct *our_vma(struct mm_struct *mm, unsigned long addr,
>   * API independent part for page fault initialization.
>   * \param vma - virtual memory area addressed to page fault
>   * \param env - corespondent lu_env to processing
> - * \param nest - nested level
>   * \param index - page index corespondent to fault.
>   * \parm ra_flags - vma readahead flags.
>   *
> - * \return allocated and initialized env for fault operation.
> - * \retval EINVAL if env can't allocated
> - * \return other error codes from cl_io_init.
> + * \return error codes from cl_io_init.
>   */
>  static struct cl_io *
> -ll_fault_io_init(struct vm_area_struct *vma, struct lu_env **env_ret,
> -		 struct cl_env_nest *nest, pgoff_t index,
> -		 unsigned long *ra_flags)
> +ll_fault_io_init(struct lu_env *env, struct vm_area_struct *vma,
> +		 pgoff_t index, unsigned long *ra_flags)
>  {
>  	struct file	       *file = vma->vm_file;
>  	struct inode	       *inode = file_inode(file);
>  	struct cl_io	       *io;
>  	struct cl_fault_io     *fio;
> -	struct lu_env	       *env;
>  	int			rc;
>  
> -	*env_ret = NULL;
>  	if (ll_file_nolock(file))
>  		return ERR_PTR(-EOPNOTSUPP);
>  
> -	/*
> -	 * page fault can be called when lustre IO is
> -	 * already active for the current thread, e.g., when doing read/write
> -	 * against user level buffer mapped from Lustre buffer. To avoid
> -	 * stomping on existing context, optionally force an allocation of a new
> -	 * one.
> -	 */
> -	env = cl_env_nested_get(nest);
> -	if (IS_ERR(env))
> -		return ERR_PTR(-EINVAL);
> -
> -	*env_ret = env;
> -
>  restart:
>  	io = vvp_env_thread_io(env);
>  	io->ci_obj = ll_i2info(inode)->lli_clob;
> @@ -155,7 +136,6 @@ ll_fault_io_init(struct vm_area_struct *vma, struct lu_env **env_ret,
>  		if (io->ci_need_restart)
>  			goto restart;
>  
> -		cl_env_nested_put(nest, env);
>  		io = ERR_PTR(rc);
>  	}
>  
> @@ -169,13 +149,17 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
>  	struct lu_env	   *env;
>  	struct cl_io	    *io;
>  	struct vvp_io	   *vio;
> -	struct cl_env_nest       nest;
>  	int		      result;
> +	int refcheck;
>  	sigset_t	     set;
>  	struct inode	     *inode;
>  	struct ll_inode_info     *lli;
>  
> -	io = ll_fault_io_init(vma, &env,  &nest, vmpage->index, NULL);
> +	env = cl_env_get(&refcheck);
> +	if (IS_ERR(env))
> +		return PTR_ERR(env);
> +
> +	io = ll_fault_io_init(env, vma, vmpage->index, NULL);
>  	if (IS_ERR(io)) {
>  		result = PTR_ERR(io);
>  		goto out;
> @@ -240,8 +224,8 @@ static int ll_page_mkwrite0(struct vm_area_struct *vma, struct page *vmpage,
>  
>  out_io:
>  	cl_io_fini(env, io);
> -	cl_env_nested_put(&nest, env);
>  out:
> +	cl_env_put(env, &refcheck);
>  	CDEBUG(D_MMAP, "%s mkwrite with %d\n", current->comm, result);
>  	LASSERT(ergo(result == 0, PageLocked(vmpage)));
>  
> @@ -285,13 +269,19 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
>  	struct vvp_io	   *vio = NULL;
>  	struct page	     *vmpage;
>  	unsigned long	    ra_flags;
> -	struct cl_env_nest       nest;
> -	int		      result;
> +	int		      result = 0;
>  	int		      fault_ret = 0;
> +	int refcheck;
>  
> -	io = ll_fault_io_init(vma, &env,  &nest, vmf->pgoff, &ra_flags);
> -	if (IS_ERR(io))
> -		return to_fault_error(PTR_ERR(io));
> +	env = cl_env_get(&refcheck);
> +	if (IS_ERR(env))
> +		return PTR_ERR(env);
> +
> +	io = ll_fault_io_init(env, vma, vmf->pgoff, &ra_flags);
> +	if (IS_ERR(io)) {
> +		result = to_fault_error(PTR_ERR(io));
> +		goto out;
> +	}
>  
>  	result = io->ci_result;
>  	if (result == 0) {
> @@ -322,14 +312,15 @@ static int ll_fault0(struct vm_area_struct *vma, struct vm_fault *vmf)
>  		}
>  	}
>  	cl_io_fini(env, io);
> -	cl_env_nested_put(&nest, env);
>  
>  	vma->vm_flags |= ra_flags;
> +
> +out:
> +	cl_env_put(env, &refcheck);
>  	if (result != 0 && !(fault_ret & VM_FAULT_RETRY))
>  		fault_ret |= to_fault_error(result);
>  
> -	CDEBUG(D_MMAP, "%s fault %d/%d\n",
> -	       current->comm, fault_ret, result);
> +	CDEBUG(D_MMAP, "%s fault %d/%d\n", current->comm, fault_ret, result);
>  	return fault_ret;
>  }
>  
> diff --git a/drivers/staging/lustre/lustre/llite/rw.c b/drivers/staging/lustre/lustre/llite/rw.c
> index 80cb8e0..d2515a8 100644
> --- a/drivers/staging/lustre/lustre/llite/rw.c
> +++ b/drivers/staging/lustre/lustre/llite/rw.c
> @@ -896,17 +896,17 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
>  	struct cl_io	   *io;
>  	struct cl_page	 *page;
>  	struct cl_object       *clob;
> -	struct cl_env_nest      nest;
>  	bool redirtied = false;
>  	bool unlocked = false;
>  	int result;
> +	int refcheck;
>  
>  	LASSERT(PageLocked(vmpage));
>  	LASSERT(!PageWriteback(vmpage));
>  
>  	LASSERT(ll_i2dtexp(inode));
>  
> -	env = cl_env_nested_get(&nest);
> +	env = cl_env_get(&refcheck);
>  	if (IS_ERR(env)) {
>  		result = PTR_ERR(env);
>  		goto out;
> @@ -971,7 +971,7 @@ int ll_writepage(struct page *vmpage, struct writeback_control *wbc)
>  		}
>  	}
>  
> -	cl_env_nested_put(&nest, env);
> +	cl_env_put(env, &refcheck);
>  	goto out;
>  
>  out:
> diff --git a/drivers/staging/lustre/lustre/llite/rw26.c b/drivers/staging/lustre/lustre/llite/rw26.c
> index 67010be..1a08a9d 100644
> --- a/drivers/staging/lustre/lustre/llite/rw26.c
> +++ b/drivers/staging/lustre/lustre/llite/rw26.c
> @@ -103,7 +103,6 @@ static void ll_invalidatepage(struct page *vmpage, unsigned int offset,
>  static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
>  {
>  	struct lu_env     *env;
> -	void			*cookie;
>  	struct cl_object  *obj;
>  	struct cl_page    *page;
>  	struct address_space *mapping;
> @@ -129,7 +128,6 @@ static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
>  	if (!page)
>  		return 1;
>  
> -	cookie = cl_env_reenter();
>  	env = cl_env_percpu_get();
>  	LASSERT(!IS_ERR(env));
>  
> @@ -155,7 +153,6 @@ static int ll_releasepage(struct page *vmpage, gfp_t gfp_mask)
>  	cl_page_put(env, page);
>  
>  	cl_env_percpu_put(env);
> -	cl_env_reexit(cookie);
>  	return result;
>  }
>  
> @@ -340,7 +337,8 @@ static ssize_t ll_direct_IO_26_seg(const struct lu_env *env, struct cl_io *io,
>  		       PAGE_SIZE) & ~(DT_MAX_BRW_SIZE - 1))
>  static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
>  {
> -	struct lu_env *env;
> +	struct ll_cl_context *lcc;
> +	const struct lu_env *env;
>  	struct cl_io *io;
>  	struct file *file = iocb->ki_filp;
>  	struct inode *inode = file->f_mapping->host;
> @@ -348,7 +346,6 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
>  	ssize_t count = iov_iter_count(iter);
>  	ssize_t tot_bytes = 0, result = 0;
>  	long size = MAX_DIO_SIZE;
> -	int refcheck;
>  
>  	/* FIXME: io smaller than PAGE_SIZE is broken on ia64 ??? */
>  	if ((file_offset & ~PAGE_MASK) || (count & ~PAGE_MASK))
> @@ -363,9 +360,13 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
>  	if (iov_iter_alignment(iter) & ~PAGE_MASK)
>  		return -EINVAL;
>  
> -	env = cl_env_get(&refcheck);
> +	lcc = ll_cl_find(file);
> +	if (!lcc)
> +		return -EIO;
> +
> +	env = lcc->lcc_env;
>  	LASSERT(!IS_ERR(env));
> -	io = vvp_env_io(env)->vui_cl.cis_io;
> +	io = lcc->lcc_io;
>  	LASSERT(io);
>  
>  	while (iov_iter_count(iter)) {
> @@ -422,7 +423,6 @@ static ssize_t ll_direct_IO_26(struct kiocb *iocb, struct iov_iter *iter)
>  		vio->u.write.vui_written += tot_bytes;
>  	}
>  
> -	cl_env_put(env, &refcheck);
>  	return tot_bytes ? tot_bytes : result;
>  }
>  
> diff --git a/drivers/staging/lustre/lustre/lov/lov_io.c b/drivers/staging/lustre/lustre/lov/lov_io.c
> index 011ab0f..002326c 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_io.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_io.c
> @@ -167,12 +167,7 @@ static int lov_io_sub_init(const struct lu_env *env, struct lov_io *lio,
>  		sub->sub_env = ld->ld_emrg[stripe]->emrg_env;
>  		sub->sub_borrowed = 1;
>  	} else {
> -		void *cookie;
> -
> -		/* obtain new environment */
> -		cookie = cl_env_reenter();
>  		sub->sub_env = cl_env_get(&sub->sub_refcheck);
> -		cl_env_reexit(cookie);
>  		if (IS_ERR(sub->sub_env))
>  			result = PTR_ERR(sub->sub_env);
>  
> diff --git a/drivers/staging/lustre/lustre/lov/lov_object.c b/drivers/staging/lustre/lustre/lov/lov_object.c
> index 711a3b9..317311c 100644
> --- a/drivers/staging/lustre/lustre/lov/lov_object.c
> +++ b/drivers/staging/lustre/lustre/lov/lov_object.c
> @@ -729,19 +729,15 @@ static int lov_layout_change(const struct lu_env *unused,
>  	union lov_layout_state *state = &lov->u;
>  	const struct lov_layout_operations *old_ops;
>  	const struct lov_layout_operations *new_ops;
> -	void *cookie;
>  	struct lu_env *env;
>  	int refcheck;
>  	int rc;
>  
>  	LASSERT(0 <= lov->lo_type && lov->lo_type < ARRAY_SIZE(lov_dispatch));
>  
> -	cookie = cl_env_reenter();
>  	env = cl_env_get(&refcheck);
> -	if (IS_ERR(env)) {
> -		cl_env_reexit(cookie);
> +	if (IS_ERR(env))
>  		return PTR_ERR(env);
> -	}
>  
>  	LASSERT(0 <= llt && llt < ARRAY_SIZE(lov_dispatch));
>  
> @@ -782,7 +778,6 @@ static int lov_layout_change(const struct lu_env *unused,
>  	lov->lo_type = llt;
>  out:
>  	cl_env_put(env, &refcheck);
> -	cl_env_reexit(cookie);
>  	return rc;
>  }
>  
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_internal.h b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
> index e866754..7b403fb 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_internal.h
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_internal.h
> @@ -50,25 +50,6 @@ enum clt_nesting_level {
>  };
>  
>  /**
> - * Counters used to check correctness of cl_lock interface usage.
> - */
> -struct cl_thread_counters {
> -	/**
> -	 * Number of outstanding calls to cl_lock_mutex_get() made by the
> -	 * current thread. For debugging.
> -	 */
> -	int	   ctc_nr_locks_locked;
> -	/** List of locked locks. */
> -	struct lu_ref ctc_locks_locked;
> -	/** Number of outstanding holds on locks. */
> -	int	   ctc_nr_held;
> -	/** Number of outstanding uses on locks. */
> -	int	   ctc_nr_used;
> -	/** Number of held extent locks. */
> -	int	   ctc_nr_locks_acquired;
> -};
> -
> -/**
>   * Thread local state internal for generic cl-code.
>   */
>  struct cl_thread_info {
> @@ -83,10 +64,6 @@ struct cl_thread_info {
>  	 */
>  	struct cl_lock_descr clt_descr;
>  	struct cl_page_list  clt_list;
> -	/**
> -	 * Counters for every level of lock nesting.
> -	 */
> -	struct cl_thread_counters clt_counters[CNL_NR];
>  	/** @} debugging */
>  
>  	/*
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> index c5621ad..af8e4d6 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
> @@ -412,7 +412,6 @@ void cl_io_unlock(const struct lu_env *env, struct cl_io *io)
>  			scan->cis_iop->op[io->ci_type].cio_unlock(env, scan);
>  	}
>  	io->ci_state = CIS_UNLOCKED;
> -	LASSERT(!cl_env_info(env)->clt_counters[CNL_TOP].ctc_nr_locks_acquired);
>  }
>  EXPORT_SYMBOL(cl_io_unlock);
>  
> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_object.c b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> index b4600c4..f5d4e23 100644
> --- a/drivers/staging/lustre/lustre/obdclass/cl_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/cl_object.c
> @@ -544,36 +544,20 @@ EXPORT_SYMBOL(cl_site_stats_print);
>   * bz20044, bz22683.
>   */
>  
> -static LIST_HEAD(cl_envs);
> -static unsigned int cl_envs_cached_nr;
> -static unsigned int cl_envs_cached_max = 128; /* XXX: prototype: arbitrary limit
> -					       * for now.
> -					       */
> -static DEFINE_SPINLOCK(cl_envs_guard);
> +static unsigned int cl_envs_cached_max = 32; /* XXX: prototype: arbitrary limit
> +					      * for now.
> +					      */
> +static struct cl_env_cache {
> +	rwlock_t		cec_guard;
> +	unsigned int		cec_count;
> +	struct list_head	cec_envs;
> +} *cl_envs = NULL;
>  
>  struct cl_env {
>  	void	     *ce_magic;
>  	struct lu_env     ce_lu;
>  	struct lu_context ce_ses;
>  
> -	/**
> -	 * This allows cl_env to be entered into cl_env_hash which implements
> -	 * the current thread -> client environment lookup.
> -	 */
> -	struct hlist_node  ce_node;
> -	/**
> -	 * Owner for the current cl_env.
> -	 *
> -	 * If LL_TASK_CL_ENV is defined, this point to the owning current,
> -	 * only for debugging purpose ;
> -	 * Otherwise hash is used, and this is the key for cfs_hash.
> -	 * Now current thread pid is stored. Note using thread pointer would
> -	 * lead to unbalanced hash because of its specific allocation locality
> -	 * and could be varied for different platforms and OSes, even different
> -	 * OS versions.
> -	 */
> -	void	     *ce_owner;
> -
>  	/*
>  	 * Linkage into global list of all client environments. Used for
>  	 * garbage collection.
> @@ -597,122 +581,13 @@ static void cl_env_init0(struct cl_env *cle, void *debug)
>  {
>  	LASSERT(cle->ce_ref == 0);
>  	LASSERT(cle->ce_magic == &cl_env_init0);
> -	LASSERT(!cle->ce_debug && !cle->ce_owner);
> +	LASSERT(!cle->ce_debug);
>  
>  	cle->ce_ref = 1;
>  	cle->ce_debug = debug;
>  	CL_ENV_INC(busy);
>  }
>  
> -/*
> - * The implementation of using hash table to connect cl_env and thread
> - */
> -
> -static struct cfs_hash *cl_env_hash;
> -
> -static unsigned cl_env_hops_hash(struct cfs_hash *lh,
> -				 const void *key, unsigned mask)
> -{
> -#if BITS_PER_LONG == 64
> -	return cfs_hash_u64_hash((__u64)key, mask);
> -#else
> -	return cfs_hash_u32_hash((__u32)key, mask);
> -#endif
> -}
> -
> -static void *cl_env_hops_obj(struct hlist_node *hn)
> -{
> -	struct cl_env *cle = hlist_entry(hn, struct cl_env, ce_node);
> -
> -	LASSERT(cle->ce_magic == &cl_env_init0);
> -	return (void *)cle;
> -}
> -
> -static int cl_env_hops_keycmp(const void *key, struct hlist_node *hn)
> -{
> -	struct cl_env *cle = cl_env_hops_obj(hn);
> -
> -	LASSERT(cle->ce_owner);
> -	return (key == cle->ce_owner);
> -}
> -
> -static void cl_env_hops_noop(struct cfs_hash *hs, struct hlist_node *hn)
> -{
> -	struct cl_env *cle = hlist_entry(hn, struct cl_env, ce_node);
> -
> -	LASSERT(cle->ce_magic == &cl_env_init0);
> -}
> -
> -static struct cfs_hash_ops cl_env_hops = {
> -	.hs_hash	= cl_env_hops_hash,
> -	.hs_key		= cl_env_hops_obj,
> -	.hs_keycmp      = cl_env_hops_keycmp,
> -	.hs_object      = cl_env_hops_obj,
> -	.hs_get		= cl_env_hops_noop,
> -	.hs_put_locked  = cl_env_hops_noop,
> -};
> -
> -static inline struct cl_env *cl_env_fetch(void)
> -{
> -	struct cl_env *cle;
> -
> -	cle = cfs_hash_lookup(cl_env_hash, (void *)(long)current->pid);
> -	LASSERT(ergo(cle, cle->ce_magic == &cl_env_init0));
> -	return cle;
> -}
> -
> -static inline void cl_env_attach(struct cl_env *cle)
> -{
> -	if (cle) {
> -		int rc;
> -
> -		LASSERT(!cle->ce_owner);
> -		cle->ce_owner = (void *)(long)current->pid;
> -		rc = cfs_hash_add_unique(cl_env_hash, cle->ce_owner,
> -					 &cle->ce_node);
> -		LASSERT(rc == 0);
> -	}
> -}
> -
> -static inline void cl_env_do_detach(struct cl_env *cle)
> -{
> -	void *cookie;
> -
> -	LASSERT(cle->ce_owner == (void *)(long)current->pid);
> -	cookie = cfs_hash_del(cl_env_hash, cle->ce_owner,
> -			      &cle->ce_node);
> -	LASSERT(cookie == cle);
> -	cle->ce_owner = NULL;
> -}
> -
> -static int cl_env_store_init(void)
> -{
> -	cl_env_hash = cfs_hash_create("cl_env",
> -				      HASH_CL_ENV_BITS, HASH_CL_ENV_BITS,
> -				      HASH_CL_ENV_BKT_BITS, 0,
> -				      CFS_HASH_MIN_THETA,
> -				      CFS_HASH_MAX_THETA,
> -				      &cl_env_hops,
> -				      CFS_HASH_RW_BKTLOCK);
> -	return cl_env_hash ? 0 : -ENOMEM;
> -}
> -
> -static void cl_env_store_fini(void)
> -{
> -	cfs_hash_putref(cl_env_hash);
> -}
> -
> -static inline struct cl_env *cl_env_detach(struct cl_env *cle)
> -{
> -	if (!cle)
> -		cle = cl_env_fetch();
> -
> -	if (cle && cle->ce_owner)
> -		cl_env_do_detach(cle);
> -
> -	return cle;
> -}
> -
>  static struct lu_env *cl_env_new(__u32 ctx_tags, __u32 ses_tags, void *debug)
>  {
>  	struct lu_env *env;
> @@ -762,16 +637,20 @@ static struct lu_env *cl_env_obtain(void *debug)
>  {
>  	struct cl_env *cle;
>  	struct lu_env *env;
> +	int cpu = get_cpu();
>  
> -	spin_lock(&cl_envs_guard);
> -	LASSERT(equi(cl_envs_cached_nr == 0, list_empty(&cl_envs)));
> -	if (cl_envs_cached_nr > 0) {
> +	read_lock(&cl_envs[cpu].cec_guard);
> +	LASSERT(equi(cl_envs[cpu].cec_count == 0,
> +		     list_empty(&cl_envs[cpu].cec_envs)));
> +	if (cl_envs[cpu].cec_count > 0) {
>  		int rc;
>  
> -		cle = container_of(cl_envs.next, struct cl_env, ce_linkage);
> +		cle = container_of(cl_envs[cpu].cec_envs.next, struct cl_env,
> +				   ce_linkage);
>  		list_del_init(&cle->ce_linkage);
> -		cl_envs_cached_nr--;
> -		spin_unlock(&cl_envs_guard);
> +		cl_envs[cpu].cec_count--;
> +		read_unlock(&cl_envs[cpu].cec_guard);
> +		put_cpu();
>  
>  		env = &cle->ce_lu;
>  		rc = lu_env_refill(env);
> @@ -784,7 +663,8 @@ static struct lu_env *cl_env_obtain(void *debug)
>  			env = ERR_PTR(rc);
>  		}
>  	} else {
> -		spin_unlock(&cl_envs_guard);
> +		read_unlock(&cl_envs[cpu].cec_guard);
> +		put_cpu();
>  		env = cl_env_new(lu_context_tags_default,
>  				 lu_session_tags_default, debug);
>  	}
> @@ -796,27 +676,6 @@ static inline struct cl_env *cl_env_container(struct lu_env *env)
>  	return container_of(env, struct cl_env, ce_lu);
>  }
>  
> -static struct lu_env *cl_env_peek(int *refcheck)
> -{
> -	struct lu_env *env;
> -	struct cl_env *cle;
> -
> -	CL_ENV_INC(lookup);
> -
> -	/* check that we don't go far from untrusted pointer */
> -	CLASSERT(offsetof(struct cl_env, ce_magic) == 0);
> -
> -	env = NULL;
> -	cle = cl_env_fetch();
> -	if (cle) {
> -		CL_ENV_INC(hit);
> -		env = &cle->ce_lu;
> -		*refcheck = ++cle->ce_ref;
> -	}
> -	CDEBUG(D_OTHER, "%d@%p\n", cle ? cle->ce_ref : 0, cle);
> -	return env;
> -}
> -
>  /**
>   * Returns lu_env: if there already is an environment associated with the
>   * current thread, it is returned, otherwise, new environment is allocated.
> @@ -834,17 +693,13 @@ struct lu_env *cl_env_get(int *refcheck)
>  {
>  	struct lu_env *env;
>  
> -	env = cl_env_peek(refcheck);
> -	if (!env) {
> -		env = cl_env_obtain(__builtin_return_address(0));
> -		if (!IS_ERR(env)) {
> -			struct cl_env *cle;
> +	env = cl_env_obtain(__builtin_return_address(0));
> +	if (!IS_ERR(env)) {
> +		struct cl_env *cle;
>  
> -			cle = cl_env_container(env);
> -			cl_env_attach(cle);
> -			*refcheck = cle->ce_ref;
> -			CDEBUG(D_OTHER, "%d@%p\n", cle->ce_ref, cle);
> -		}
> +		cle = cl_env_container(env);
> +		*refcheck = cle->ce_ref;
> +		CDEBUG(D_OTHER, "%d@%p\n", cle->ce_ref, cle);
>  	}
>  	return env;
>  }
> @@ -859,7 +714,6 @@ struct lu_env *cl_env_alloc(int *refcheck, __u32 tags)
>  {
>  	struct lu_env *env;
>  
> -	LASSERT(!cl_env_peek(refcheck));
>  	env = cl_env_new(tags, tags, __builtin_return_address(0));
>  	if (!IS_ERR(env)) {
>  		struct cl_env *cle;
> @@ -874,7 +728,6 @@ EXPORT_SYMBOL(cl_env_alloc);
>  
>  static void cl_env_exit(struct cl_env *cle)
>  {
> -	LASSERT(!cle->ce_owner);
>  	lu_context_exit(&cle->ce_lu.le_ctx);
>  	lu_context_exit(&cle->ce_ses);
>  }
> @@ -887,20 +740,25 @@ static void cl_env_exit(struct cl_env *cle)
>  unsigned int cl_env_cache_purge(unsigned int nr)
>  {
>  	struct cl_env *cle;
> +	unsigned int i;
>  
> -	spin_lock(&cl_envs_guard);
> -	for (; !list_empty(&cl_envs) && nr > 0; --nr) {
> -		cle = container_of(cl_envs.next, struct cl_env, ce_linkage);
> -		list_del_init(&cle->ce_linkage);
> -		LASSERT(cl_envs_cached_nr > 0);
> -		cl_envs_cached_nr--;
> -		spin_unlock(&cl_envs_guard);
> +	for_each_possible_cpu(i) {
> +		write_lock(&cl_envs[i].cec_guard);
> +		for (; !list_empty(&cl_envs[i].cec_envs) && nr > 0; --nr) {
> +			cle = container_of(cl_envs[i].cec_envs.next,
> +					   struct cl_env, ce_linkage);
> +			list_del_init(&cle->ce_linkage);
> +			LASSERT(cl_envs[i].cec_count > 0);
> +			cl_envs[i].cec_count--;
> +			write_unlock(&cl_envs[i].cec_guard);
>  
> -		cl_env_fini(cle);
> -		spin_lock(&cl_envs_guard);
> +			cl_env_fini(cle);
> +			write_lock(&cl_envs[i].cec_guard);
> +		}
> +		LASSERT(equi(cl_envs[i].cec_count == 0,
> +			     list_empty(&cl_envs[i].cec_envs)));
> +		write_unlock(&cl_envs[i].cec_guard);
>  	}
> -	LASSERT(equi(cl_envs_cached_nr == 0, list_empty(&cl_envs)));
> -	spin_unlock(&cl_envs_guard);
>  	return nr;
>  }
>  EXPORT_SYMBOL(cl_env_cache_purge);
> @@ -923,8 +781,9 @@ void cl_env_put(struct lu_env *env, int *refcheck)
>  
>  	CDEBUG(D_OTHER, "%d@%p\n", cle->ce_ref, cle);
>  	if (--cle->ce_ref == 0) {
> +		int cpu = get_cpu();
> +
>  		CL_ENV_DEC(busy);
> -		cl_env_detach(cle);
>  		cle->ce_debug = NULL;
>  		cl_env_exit(cle);
>  		/*
> @@ -933,107 +792,22 @@ void cl_env_put(struct lu_env *env, int *refcheck)
>  		 * Return environment to the cache only when it was allocated
>  		 * with the standard tags.
>  		 */
> -		if (cl_envs_cached_nr < cl_envs_cached_max &&
> +		if (cl_envs[cpu].cec_count < cl_envs_cached_max &&
>  		    (env->le_ctx.lc_tags & ~LCT_HAS_EXIT) == LCT_CL_THREAD &&
>  		    (env->le_ses->lc_tags & ~LCT_HAS_EXIT) == LCT_SESSION) {
> -			spin_lock(&cl_envs_guard);
> -			list_add(&cle->ce_linkage, &cl_envs);
> -			cl_envs_cached_nr++;
> -			spin_unlock(&cl_envs_guard);
> +			read_lock(&cl_envs[cpu].cec_guard);
> +			list_add(&cle->ce_linkage, &cl_envs[cpu].cec_envs);
> +			cl_envs[cpu].cec_count++;
> +			read_unlock(&cl_envs[cpu].cec_guard);
>  		} else {
>  			cl_env_fini(cle);
>  		}
> +		put_cpu();
>  	}
>  }
>  EXPORT_SYMBOL(cl_env_put);
>  
>  /**
> - * Declares a point of re-entrancy.
> - *
> - * \see cl_env_reexit()
> - */
> -void *cl_env_reenter(void)
> -{
> -	return cl_env_detach(NULL);
> -}
> -EXPORT_SYMBOL(cl_env_reenter);
> -
> -/**
> - * Exits re-entrancy.
> - */
> -void cl_env_reexit(void *cookie)
> -{
> -	cl_env_detach(NULL);
> -	cl_env_attach(cookie);
> -}
> -EXPORT_SYMBOL(cl_env_reexit);
> -
> -/**
> - * Setup user-supplied \a env as a current environment. This is to be used to
> - * guaranteed that environment exists even when cl_env_get() fails. It is up
> - * to user to ensure proper concurrency control.
> - *
> - * \see cl_env_unplant()
> - */
> -void cl_env_implant(struct lu_env *env, int *refcheck)
> -{
> -	struct cl_env *cle = cl_env_container(env);
> -
> -	LASSERT(cle->ce_ref > 0);
> -
> -	cl_env_attach(cle);
> -	cl_env_get(refcheck);
> -	CDEBUG(D_OTHER, "%d@%p\n", cle->ce_ref, cle);
> -}
> -EXPORT_SYMBOL(cl_env_implant);
> -
> -/**
> - * Detach environment installed earlier by cl_env_implant().
> - */
> -void cl_env_unplant(struct lu_env *env, int *refcheck)
> -{
> -	struct cl_env *cle = cl_env_container(env);
> -
> -	LASSERT(cle->ce_ref > 1);
> -
> -	CDEBUG(D_OTHER, "%d@%p\n", cle->ce_ref, cle);
> -
> -	cl_env_detach(cle);
> -	cl_env_put(env, refcheck);
> -}
> -EXPORT_SYMBOL(cl_env_unplant);
> -
> -struct lu_env *cl_env_nested_get(struct cl_env_nest *nest)
> -{
> -	struct lu_env *env;
> -
> -	nest->cen_cookie = NULL;
> -	env = cl_env_peek(&nest->cen_refcheck);
> -	if (env) {
> -		if (!cl_io_is_going(env))
> -			return env;
> -		cl_env_put(env, &nest->cen_refcheck);
> -		nest->cen_cookie = cl_env_reenter();
> -	}
> -	env = cl_env_get(&nest->cen_refcheck);
> -	if (IS_ERR(env)) {
> -		cl_env_reexit(nest->cen_cookie);
> -		return env;
> -	}
> -
> -	LASSERT(!cl_io_is_going(env));
> -	return env;
> -}
> -EXPORT_SYMBOL(cl_env_nested_get);
> -
> -void cl_env_nested_put(struct cl_env_nest *nest, struct lu_env *env)
> -{
> -	cl_env_put(env, &nest->cen_refcheck);
> -	cl_env_reexit(nest->cen_cookie);
> -}
> -EXPORT_SYMBOL(cl_env_nested_put);
> -
> -/**
>   * Converts struct ost_lvb to struct cl_attr.
>   *
>   * \see cl_attr2lvb
> @@ -1060,6 +834,10 @@ static int cl_env_percpu_init(void)
>  	for_each_possible_cpu(i) {
>  		struct lu_env *env;
>  
> +		rwlock_init(&cl_envs[i].cec_guard);
> +		INIT_LIST_HEAD(&cl_envs[i].cec_envs);
> +		cl_envs[i].cec_count = 0;
> +
>  		cle = &cl_env_percpu[i];
>  		env = &cle->ce_lu;
>  
> @@ -1127,7 +905,6 @@ void cl_env_percpu_put(struct lu_env *env)
>  	LASSERT(cle->ce_ref == 0);
>  
>  	CL_ENV_DEC(busy);
> -	cl_env_detach(cle);
>  	cle->ce_debug = NULL;
>  
>  	put_cpu();
> @@ -1141,7 +918,6 @@ struct lu_env *cl_env_percpu_get(void)
>  	cle = &cl_env_percpu[get_cpu()];
>  	cl_env_init0(cle, __builtin_return_address(0));
>  
> -	cl_env_attach(cle);
>  	return &cle->ce_lu;
>  }
>  EXPORT_SYMBOL(cl_env_percpu_get);
> @@ -1205,51 +981,19 @@ LU_KEY_INIT_FINI(cl0, struct cl_thread_info);
>  static void *cl_key_init(const struct lu_context *ctx,
>  			 struct lu_context_key *key)
>  {
> -	struct cl_thread_info *info;
> -
> -	info = cl0_key_init(ctx, key);
> -	if (!IS_ERR(info)) {
> -		size_t i;
> -
> -		for (i = 0; i < ARRAY_SIZE(info->clt_counters); ++i)
> -			lu_ref_init(&info->clt_counters[i].ctc_locks_locked);
> -	}
> -	return info;
> +	return cl0_key_init(ctx, key);
>  }
>  
>  static void cl_key_fini(const struct lu_context *ctx,
>  			struct lu_context_key *key, void *data)
>  {
> -	struct cl_thread_info *info;
> -	size_t i;
> -
> -	info = data;
> -	for (i = 0; i < ARRAY_SIZE(info->clt_counters); ++i)
> -		lu_ref_fini(&info->clt_counters[i].ctc_locks_locked);
>  	cl0_key_fini(ctx, key, data);
>  }
>  
> -static void cl_key_exit(const struct lu_context *ctx,
> -			struct lu_context_key *key, void *data)
> -{
> -	struct cl_thread_info *info = data;
> -	size_t i;
> -
> -	for (i = 0; i < ARRAY_SIZE(info->clt_counters); ++i) {
> -		LASSERT(info->clt_counters[i].ctc_nr_held == 0);
> -		LASSERT(info->clt_counters[i].ctc_nr_used == 0);
> -		LASSERT(info->clt_counters[i].ctc_nr_locks_acquired == 0);
> -		LASSERT(info->clt_counters[i].ctc_nr_locks_locked == 0);
> -		lu_ref_fini(&info->clt_counters[i].ctc_locks_locked);
> -		lu_ref_init(&info->clt_counters[i].ctc_locks_locked);
> -	}
> -}
> -
>  static struct lu_context_key cl_key = {
>  	.lct_tags = LCT_CL_THREAD,
>  	.lct_init = cl_key_init,
>  	.lct_fini = cl_key_fini,
> -	.lct_exit = cl_key_exit
>  };
>  
>  static struct lu_kmem_descr cl_object_caches[] = {
> @@ -1273,13 +1017,15 @@ int cl_global_init(void)
>  {
>  	int result;
>  
> -	result = cl_env_store_init();
> -	if (result)
> -		return result;
> +	cl_envs = kzalloc(sizeof(*cl_envs) * num_possible_cpus(), GFP_KERNEL);
> +	if (!cl_envs) {
> +		result = -ENOMEM;
> +		goto out;
> +	}
>  
>  	result = lu_kmem_init(cl_object_caches);
>  	if (result)
> -		goto out_store;
> +		goto out_envs;
>  
>  	LU_CONTEXT_KEY_INIT(&cl_key);
>  	result = lu_context_key_register(&cl_key);
> @@ -1289,16 +1035,17 @@ int cl_global_init(void)
>  	result = cl_env_percpu_init();
>  	if (result)
>  		/* no cl_env_percpu_fini on error */
> -		goto out_context;
> +		goto out_keys;
>  
>  	return 0;
>  
> -out_context:
> +out_keys:
>  	lu_context_key_degister(&cl_key);
>  out_kmem:
>  	lu_kmem_fini(cl_object_caches);
> -out_store:
> -	cl_env_store_fini();
> +out_envs:
> +	kfree(cl_envs);
> +out:
>  	return result;
>  }
>  
> @@ -1310,5 +1057,5 @@ void cl_global_fini(void)
>  	cl_env_percpu_fini();
>  	lu_context_key_degister(&cl_key);
>  	lu_kmem_fini(cl_object_caches);
> -	cl_env_store_fini();
> +	kfree(cl_envs);
>  }
> diff --git a/drivers/staging/lustre/lustre/obdclass/lu_object.c b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> index e031fd2..14ca82d 100644
> --- a/drivers/staging/lustre/lustre/obdclass/lu_object.c
> +++ b/drivers/staging/lustre/lustre/obdclass/lu_object.c
> @@ -1521,10 +1521,6 @@ void lu_context_key_quiesce(struct lu_context_key *key)
>  
>  	if (!(key->lct_tags & LCT_QUIESCENT)) {
>  		/*
> -		 * XXX layering violation.
> -		 */
> -		cl_env_cache_purge(~0);
> -		/*
>  		 * XXX memory barrier has to go here.
>  		 */
>  		spin_lock(&lu_keys_guard);
> diff --git a/drivers/staging/lustre/lustre/obdecho/echo_client.c b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> index 30caf5f..25ecfb3 100644
> --- a/drivers/staging/lustre/lustre/obdecho/echo_client.c
> +++ b/drivers/staging/lustre/lustre/obdecho/echo_client.c
> @@ -563,16 +563,10 @@ static void echo_thread_key_fini(const struct lu_context *ctx,
>  	kmem_cache_free(echo_thread_kmem, info);
>  }
>  
> -static void echo_thread_key_exit(const struct lu_context *ctx,
> -				 struct lu_context_key *key, void *data)
> -{
> -}
> -
>  static struct lu_context_key echo_thread_key = {
>  	.lct_tags = LCT_CL_THREAD,
>  	.lct_init = echo_thread_key_init,
>  	.lct_fini = echo_thread_key_fini,
> -	.lct_exit = echo_thread_key_exit
>  };
>  
>  static void *echo_session_key_init(const struct lu_context *ctx,
> @@ -594,16 +588,10 @@ static void echo_session_key_fini(const struct lu_context *ctx,
>  	kmem_cache_free(echo_session_kmem, session);
>  }
>  
> -static void echo_session_key_exit(const struct lu_context *ctx,
> -				  struct lu_context_key *key, void *data)
> -{
> -}
> -
>  static struct lu_context_key echo_session_key = {
>  	.lct_tags = LCT_SESSION,
>  	.lct_init = echo_session_key_init,
>  	.lct_fini = echo_session_key_fini,
> -	.lct_exit = echo_session_key_exit
>  };
>  
>  LU_TYPE_INIT_FINI(echo, &echo_thread_key, &echo_session_key);
> @@ -787,6 +775,8 @@ static struct lu_device *echo_device_free(const struct lu_env *env,
>  	cl_device_fini(&ed->ed_cl);
>  	kfree(ed);
>  
> +	cl_env_cache_purge(~0);
> +
>  	return NULL;
>  }
>  
> diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
> index b645957..cbbe85e 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_cache.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
> @@ -977,7 +977,6 @@ static int osc_extent_wait(const struct lu_env *env, struct osc_extent *ext,
>  static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
>  			       bool partial)
>  {
> -	struct cl_env_nest nest;
>  	struct lu_env *env;
>  	struct cl_io *io;
>  	struct osc_object *obj = ext->oe_obj;
> @@ -990,6 +989,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
>  	int grants = 0;
>  	int nr_pages = 0;
>  	int rc = 0;
> +	int refcheck;
>  
>  	LASSERT(sanity_check(ext) == 0);
>  	EASSERT(ext->oe_state == OES_TRUNC, ext);
> @@ -999,7 +999,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
>  	 * We can't use that env from osc_cache_truncate_start() because
>  	 * it's from lov_io_sub and not fully initialized.
>  	 */
> -	env = cl_env_nested_get(&nest);
> +	env = cl_env_get(&refcheck);
>  	io  = &osc_env_info(env)->oti_io;
>  	io->ci_obj = cl_object_top(osc2cl(obj));
>  	rc = cl_io_init(env, io, CIT_MISC, io->ci_obj);
> @@ -1085,7 +1085,7 @@ static int osc_extent_truncate(struct osc_extent *ext, pgoff_t trunc_index,
>  
>  out:
>  	cl_io_fini(env, io);
> -	cl_env_nested_put(&nest, env);
> +	cl_env_put(env, &refcheck);
>  	return rc;
>  }
>  
> diff --git a/drivers/staging/lustre/lustre/osc/osc_lock.c b/drivers/staging/lustre/lustre/osc/osc_lock.c
> index 45d5e6d..e337e87 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_lock.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_lock.c
> @@ -294,10 +294,10 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
>  	struct osc_lock *oscl = cookie;
>  	struct cl_lock_slice *slice = &oscl->ols_cl;
>  	struct lu_env *env;
> -	struct cl_env_nest nest;
>  	int rc;
> +	int refcheck;
>  
> -	env = cl_env_nested_get(&nest);
> +	env = cl_env_get(&refcheck);
>  	/* should never happen, similar to osc_ldlm_blocking_ast(). */
>  	LASSERT(!IS_ERR(env));
>  
> @@ -336,7 +336,7 @@ static int osc_lock_upcall(void *cookie, struct lustre_handle *lockh,
>  
>  	if (oscl->ols_owner)
>  		cl_sync_io_note(env, oscl->ols_owner, rc);
> -	cl_env_nested_put(&nest, env);
> +	cl_env_put(env, &refcheck);
>  
>  	return rc;
>  }
> @@ -347,9 +347,9 @@ static int osc_lock_upcall_agl(void *cookie, struct lustre_handle *lockh,
>  	struct osc_object *osc = cookie;
>  	struct ldlm_lock *dlmlock;
>  	struct lu_env *env;
> -	struct cl_env_nest nest;
> +	int refcheck;
>  
> -	env = cl_env_nested_get(&nest);
> +	env = cl_env_get(&refcheck);
>  	LASSERT(!IS_ERR(env));
>  
>  	if (errcode == ELDLM_LOCK_MATCHED) {
> @@ -374,7 +374,7 @@ static int osc_lock_upcall_agl(void *cookie, struct lustre_handle *lockh,
>  
>  out:
>  	cl_object_put(env, osc2cl(osc));
> -	cl_env_nested_put(&nest, env);
> +	cl_env_put(env, &refcheck);
>  	return ldlm_error2errno(errcode);
>  }
>  
> @@ -382,11 +382,11 @@ static int osc_lock_flush(struct osc_object *obj, pgoff_t start, pgoff_t end,
>  			  enum cl_lock_mode mode, int discard)
>  {
>  	struct lu_env *env;
> -	struct cl_env_nest nest;
> +	int refcheck;
>  	int rc = 0;
>  	int rc2 = 0;
>  
> -	env = cl_env_nested_get(&nest);
> +	env = cl_env_get(&refcheck);
>  	if (IS_ERR(env))
>  		return PTR_ERR(env);
>  
> @@ -404,7 +404,7 @@ static int osc_lock_flush(struct osc_object *obj, pgoff_t start, pgoff_t end,
>  	if (rc == 0 && rc2 < 0)
>  		rc = rc2;
>  
> -	cl_env_nested_put(&nest, env);
> +	cl_env_put(env, &refcheck);
>  	return rc;
>  }
>  
> @@ -536,7 +536,7 @@ static int osc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
>  	}
>  	case LDLM_CB_CANCELING: {
>  		struct lu_env *env;
> -		struct cl_env_nest nest;
> +		int refcheck;
>  
>  		/*
>  		 * This can be called in the context of outer IO, e.g.,
> @@ -549,14 +549,14 @@ static int osc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
>  		 * new environment has to be created to not corrupt outer
>  		 * context.
>  		 */
> -		env = cl_env_nested_get(&nest);
> +		env = cl_env_get(&refcheck);
>  		if (IS_ERR(env)) {
>  			result = PTR_ERR(env);
>  			break;
>  		}
>  
>  		result = osc_dlm_blocking_ast0(env, dlmlock, data, flag);
> -		cl_env_nested_put(&nest, env);
> +		cl_env_put(env, &refcheck);
>  		break;
>  		}
>  	default:
> @@ -568,61 +568,61 @@ static int osc_ldlm_blocking_ast(struct ldlm_lock *dlmlock,
>  static int osc_ldlm_glimpse_ast(struct ldlm_lock *dlmlock, void *data)
>  {
>  	struct ptlrpc_request *req = data;
> -	struct cl_env_nest nest;
>  	struct lu_env *env;
>  	struct ost_lvb *lvb;
>  	struct req_capsule *cap;
> +	struct cl_object *obj = NULL;
>  	int result;
> +	int refcheck;
>  
>  	LASSERT(lustre_msg_get_opc(req->rq_reqmsg) == LDLM_GL_CALLBACK);
>  
> -	env = cl_env_nested_get(&nest);
> -	if (!IS_ERR(env)) {
> -		struct cl_object *obj = NULL;
> +	env = cl_env_get(&refcheck);
> +	if (IS_ERR(env)) {
> +		result = PTR_ERR(env);
> +		goto out;
> +	}
>  
> -		lock_res_and_lock(dlmlock);
> -		if (dlmlock->l_ast_data) {
> -			obj = osc2cl(dlmlock->l_ast_data);
> -			cl_object_get(obj);
> -		}
> -		unlock_res_and_lock(dlmlock);
> +	lock_res_and_lock(dlmlock);
> +	if (dlmlock->l_ast_data) {
> +		obj = osc2cl(dlmlock->l_ast_data);
> +		cl_object_get(obj);
> +	}
> +	unlock_res_and_lock(dlmlock);
>  
> -		if (obj) {
> -			/* Do not grab the mutex of cl_lock for glimpse.
> -			 * See LU-1274 for details.
> -			 * BTW, it's okay for cl_lock to be cancelled during
> -			 * this period because server can handle this race.
> -			 * See ldlm_server_glimpse_ast() for details.
> -			 * cl_lock_mutex_get(env, lock);
> -			 */
> -			cap = &req->rq_pill;
> -			req_capsule_extend(cap, &RQF_LDLM_GL_CALLBACK);
> -			req_capsule_set_size(cap, &RMF_DLM_LVB, RCL_SERVER,
> -					     sizeof(*lvb));
> -			result = req_capsule_server_pack(cap);
> -			if (result == 0) {
> -				lvb = req_capsule_server_get(cap, &RMF_DLM_LVB);
> -				result = cl_object_glimpse(env, obj, lvb);
> -			}
> -			if (!exp_connect_lvb_type(req->rq_export))
> -				req_capsule_shrink(&req->rq_pill,
> -						   &RMF_DLM_LVB,
> -						   sizeof(struct ost_lvb_v1),
> -						   RCL_SERVER);
> -			cl_object_put(env, obj);
> -		} else {
> -			/*
> -			 * These errors are normal races, so we don't want to
> -			 * fill the console with messages by calling
> -			 * ptlrpc_error()
> -			 */
> -			lustre_pack_reply(req, 1, NULL, NULL);
> -			result = -ELDLM_NO_LOCK_DATA;
> +	if (obj) {
> +		/* Do not grab the mutex of cl_lock for glimpse.
> +		 * See LU-1274 for details.
> +		 * BTW, it's okay for cl_lock to be cancelled during
> +		 * this period because server can handle this race.
> +		 * See ldlm_server_glimpse_ast() for details.
> +		 * cl_lock_mutex_get(env, lock);
> +		 */
> +		cap = &req->rq_pill;
> +		req_capsule_extend(cap, &RQF_LDLM_GL_CALLBACK);
> +		req_capsule_set_size(cap, &RMF_DLM_LVB, RCL_SERVER,
> +				     sizeof(*lvb));
> +		result = req_capsule_server_pack(cap);
> +		if (result == 0) {
> +			lvb = req_capsule_server_get(cap, &RMF_DLM_LVB);
> +			result = cl_object_glimpse(env, obj, lvb);
>  		}
> -		cl_env_nested_put(&nest, env);
> +		if (!exp_connect_lvb_type(req->rq_export))
> +		req_capsule_shrink(&req->rq_pill, &RMF_DLM_LVB,
> +				   sizeof(struct ost_lvb_v1), RCL_SERVER);
> +		cl_object_put(env, obj);
>  	} else {
> -		result = PTR_ERR(env);
> +		/*
> +		 * These errors are normal races, so we don't want to
> +		 * fill the console with messages by calling
> +		 * ptlrpc_error()
> +		 */
> +		lustre_pack_reply(req, 1, NULL, NULL);
> +		result = -ELDLM_NO_LOCK_DATA;
>  	}
> +	cl_env_put(env, &refcheck);
> +
> +out:
>  	req->rq_status = result;
>  	return result;
>  }
> @@ -677,12 +677,12 @@ static unsigned long osc_lock_weight(const struct lu_env *env,
>   */
>  unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
>  {
> -	struct cl_env_nest       nest;
>  	struct lu_env           *env;
>  	struct osc_object	*obj;
>  	struct osc_lock		*oscl;
>  	unsigned long            weight;
>  	bool			 found = false;
> +	int refcheck;
>  
>  	might_sleep();
>  	/*
> @@ -692,7 +692,7 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
>  	 * the upper context because cl_lock_put don't modify environment
>  	 * variables. But just in case ..
>  	 */
> -	env = cl_env_nested_get(&nest);
> +	env = cl_env_get(&refcheck);
>  	if (IS_ERR(env))
>  		/* Mostly because lack of memory, do not eliminate this lock */
>  		return 1;
> @@ -722,7 +722,7 @@ unsigned long osc_ldlm_weigh_ast(struct ldlm_lock *dlmlock)
>  	weight = osc_lock_weight(env, obj, &dlmlock->l_policy_data.l_extent);
>  
>  out:
> -	cl_env_nested_put(&nest, env);
> +	cl_env_put(env, &refcheck);
>  	return weight;
>  }
>  
> diff --git a/drivers/staging/lustre/lustre/osc/osc_page.c b/drivers/staging/lustre/lustre/osc/osc_page.c
> index 2fb0e53..93248d1 100644
> --- a/drivers/staging/lustre/lustre/osc/osc_page.c
> +++ b/drivers/staging/lustre/lustre/osc/osc_page.c
> @@ -644,15 +644,15 @@ long osc_lru_shrink(const struct lu_env *env, struct client_obd *cli,
>  
>  long osc_lru_reclaim(struct client_obd *cli)
>  {
> -	struct cl_env_nest nest;
>  	struct lu_env *env;
>  	struct cl_client_cache *cache = cli->cl_cache;
>  	int max_scans;
> +	int refcheck;
>  	long rc = 0;
>  
>  	LASSERT(cache);
>  
> -	env = cl_env_nested_get(&nest);
> +	env = cl_env_get(&refcheck);
>  	if (IS_ERR(env))
>  		return 0;
>  
> @@ -704,7 +704,7 @@ long osc_lru_reclaim(struct client_obd *cli)
>  	spin_unlock(&cache->ccc_lru_lock);
>  
>  out:
> -	cl_env_nested_put(&nest, env);
> +	cl_env_put(env, &refcheck);
>  	CDEBUG(D_CACHE, "%s: cli %p freed %ld pages.\n",
>  	       cli->cl_import->imp_obd->obd_name, cli, rc);
>  	return rc;
> -- 
> 2.7.4
> 
> 
