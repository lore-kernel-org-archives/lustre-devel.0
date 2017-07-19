From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 18 Jul 2017 22:51:34 -0400
Subject: [lustre-devel] [PATCH 03/12] staging: lustre: llite: fix
	various issues with ll_splice_alias.
In-Reply-To: <150042040744.20736.6110134708456645941.stgit@noble>
References: <150041997277.20736.17112251996623587423.stgit@noble>
	<150042040744.20736.6110134708456645941.stgit@noble>
Message-ID: <030281CD-CC74-429C-910F-86706CFC57DA@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>, Al Viro <viro@ZenIV.linux.org.uk>
Cc: Greg Kroah-Hartman <greg@kroah.com>, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

Unfortunately this patch causes insta-crash on first stat call after mount.
Sorry, I cannot dig into this deeper right this moment, but I will a bit later.
I am adding Al that we discussed this code at some length and he found no problems
here, so I am a bit surprised by your findings.
Also the reason we reinvent the d_splice_alias is because we need to
splice not just directories, but also regular files.

I also am less sure by your previous DCACHE_DISCONECTED patch that we in fact might
still need, I just need to dig up a test case for that.

Thanks for looking into it!

[  170.000858] Lustre: Mounted lustre-client
[  172.799813] Lustre: DEBUG MARKER: Using TIMEOUT=20
[  186.627954] BUG: unable to handle kernel NULL pointer dereference at 00000000000000a8
[  186.628742] IP: __lock_acquire+0x125/0x1370
[  186.629137] PGD 0 
[  186.629138] P4D 0 
[  186.629496] 
[  186.630216] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  186.630613] Modules linked in: osc(C) mgc(C) lustre(C) lmv(C) fld(C) mdc(C) fid(C) lov(C) ksocklnd(C) ptlrpc(C) obdclass(C) lnet(C) sha512_ssse3 sha512_generic crc32_generic libcfs(C) joydev pcspkr i2c_piix4 virtio_console rpcsec_gss_krb5 ttm drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops drm serio_raw virtio_blk floppy
[  186.633238] CPU: 2 PID: 10897 Comm: sh Tainted: G         C      4.13.0-rc1-vm-nfs+ #154
[  186.633990] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  186.634402] task: ffff8800d6a1c180 task.stack: ffffc900066a0000
[  186.634807] RIP: 0010:__lock_acquire+0x125/0x1370
[  186.635206] RSP: 0018:ffffc900066a3750 EFLAGS: 00010002
[  186.635597] RAX: 0000000000000046 RBX: 0000000000000001 RCX: 0000000000000000
[  186.636013] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 0000000000000000
[  186.636432] RBP: ffffc900066a3810 R08: ffffffffa05221a9 R09: 0000000000000000
[  186.636844] R10: 0000000000000000 R11: ffff8800d6a1c180 R12: 0000000000000001
[  186.637264] R13: 0000000000000000 R14: 0000000000000001 R15: 00000000000000a8
[  186.637679] FS:  00007fd679eaa700(0000) GS:ffff88011a200000(0000) knlGS:0000000000000000
[  186.638402] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  186.638803] CR2: 00000000000000a8 CR3: 0000000109c0b000 CR4: 00000000000006e0
[  186.639228] Call Trace:
[  186.639589]  lock_acquire+0xe3/0x1d0
[  186.639962]  ? lock_acquire+0xe3/0x1d0
[  186.640352]  ? ll_lookup_it_finish+0x379/0xca0 [lustre]
[  186.640747]  _raw_spin_lock+0x34/0x70
[  186.641130]  ? ll_lookup_it_finish+0x379/0xca0 [lustre]
[  186.641529]  ll_lookup_it_finish+0x379/0xca0 [lustre]
[  186.641943]  ? req_capsule_server_get+0x15/0x20 [ptlrpc]
[  186.642368]  ? lmv_revalidate_slaves+0x790/0x790 [lmv]
[  186.642779]  ll_lookup_it+0x26d/0x820 [lustre]
[  186.643175]  ll_lookup_nd+0x162/0x1a0 [lustre]
[  186.643575]  lookup_slow+0x132/0x220
[  186.643947]  ? __wake_up+0x23/0x50
[  186.644322]  walk_component+0x1bf/0x350
[  186.644714]  link_path_walk+0x1b8/0x630
[  186.645097]  path_lookupat+0x99/0x220
[  186.645459]  ? __kernel_map_pages+0x131/0x140
[  186.645830]  ? __kernel_map_pages+0x131/0x140
[  186.646206]  filename_lookup+0xb8/0x1a0
[  186.646575]  ? __check_object_size+0xb1/0x1a0
[  186.646952]  ? strncpy_from_user+0x4d/0x160
[  186.647326]  user_path_at_empty+0x36/0x40
[  186.647694]  ? user_path_at_empty+0x36/0x40
[  186.648068]  vfs_statx+0x76/0xe0
[  186.648429]  SYSC_newstat+0x3d/0x70
[  186.648789]  ? trace_hardirqs_on_caller+0xf4/0x190
[  186.649171]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[  186.649547]  SyS_newstat+0xe/0x10
[  186.649906]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[  186.650289] RIP: 0033:0x7fd679599475
[  186.650651] RSP: 002b:00007ffc2e568fc8 EFLAGS: 00000246 ORIG_RAX: 0000000000000004
[  186.651350] RAX: ffffffffffffffda RBX: 00007fd679862ae0 RCX: 00007fd679599475
[  186.651758] RDX: 00007ffc2e568fe0 RSI: 00007ffc2e568fe0 RDI: 000000eec2877730
[  186.652171] RBP: 00007fd679862ae0 R08: 000000eec2cafcb0 R09: 0000000000000008
[  186.652579] R10: 000000eec2cafcb0 R11: 0000000000000246 R12: 0000000000000020
[  186.652982] R13: 000000eec2cc7e10 R14: 000000eec2cb2190 R15: 00007ffc2e5690f8
[  186.653393] Code: c8 65 48 33 3c 25 28 00 00 00 44 89 e0 0f 85 91 0d 00 00 48 81 c4 90 00 00 00 5b 41 5a 41 5c 41 5d 41 5e 41 5f 5d 49 8d 62 f8 c3 <49> 81 3f 00 90 6f 82 41 bc 00 00 00 00 44 0f 45 e2 83 fe 01 0f 
[  186.654536] RIP: __lock_acquire+0x125/0x1370 RSP: ffffc900066a3750
[  186.654933] CR2: 00000000000000a8


On Jul 18, 2017, at 7:26 PM, NeilBrown wrote:

> 1/ The testing of DCACHE_DISCONNECTED is wrong.
>  see upstream commit da093a9b76ef ("dcache: d_splice_alias should
>  ignore DCACHE_DISCONNECTED")
> 
>  As this is a notoriously difficult piece of code to get right,
>  it makes sense to use d_splice_alias() directly and no try to
>  create a local version of it.
> 
> 2/ ll_find_alias() currently:
>     locks and alias
>     checks that it is the one we want
>     unlock it
>     locks it again
>     gets a reference
>     unlocks it
> 
>   This isn't safe.  Anything could happen to the dentry while we
>   don't hold a reference.  We need to dget the reference while
>   still holding the lock.
> 
> 3/ The d_move() in ll_splice_alias() is pointless.  We have
>    already checked the hash, name, and parent are the same, and
>    these are the only fields that d_move() will change.
> 
> 4/ The call to d_add() is outside of any locking. This makes it
>   possible for two identical dentries to be added to the same
>   inode, which would cause confusion.
> 
>   Prior to 4.7, i_mutex would have provided exclusion, but since
>   the VFS supports parallel lookups, only a shared lock is held
>   on i_mutex.
> 
>   Because ll_d_init() creates a dentry in a state where
>   ll_dcompare will no recognize it, the VFS provides no guarantee
>   that we won't have two concurrent calls to ll_lookup_dn() for
>   the same parent/name.
> 
> 
> So: rename ll_find_alias() to ll_find_invalid_alias() and have it
> just focus on finding an invalid alias.
> 
> For directories, we can just use d__splice_alias() directly.
> There must only be one alias for a directory, and
> ll_splice_alias() will find it where it is "invalid" or not.
> 
> For non-directories, we call ll_find_invalid_alias(), and either
> use the result or call d_add().  We need a lock to protect from
> races with other threads calling ll_find_invalid_alias() and
> d_add() at the same time. lli_lock seems suitable for this
> purpose.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> drivers/staging/lustre/lustre/llite/namei.c |   69 +++++++++++++--------------
> 1 file changed, 34 insertions(+), 35 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/namei.c b/drivers/staging/lustre/lustre/llite/namei.c
> index 293a3180ec70..6204c3e70d45 100644
> --- a/drivers/staging/lustre/lustre/llite/namei.c
> +++ b/drivers/staging/lustre/lustre/llite/namei.c
> @@ -378,75 +378,74 @@ void ll_i2gids(__u32 *suppgids, struct inode *i1, struct inode *i2)
> }
> 
> /*
> - * try to reuse three types of dentry:
> - * 1. unhashed alias, this one is unhashed by d_invalidate (but it may be valid
> - *    by concurrent .revalidate).
> - * 2. INVALID alias (common case for no valid ldlm lock held, but this flag may
> - *    be cleared by others calling d_lustre_revalidate).
> - * 3. DISCONNECTED alias.
> + * Try to find an "invalid" alias.  i.e. one that was unhashed by
> + * d_invalidate(), or that was instantiated with no valid ldlm lock.
> + * These can be rehased by d_lustre_revalidate(), which could race
> + * with this code.
>  */
> -static struct dentry *ll_find_alias(struct inode *inode, struct dentry *dentry)
> +static struct dentry *ll_find_invalid_alias(struct inode *inode,
> +					    struct dentry *dentry)
> {
> -	struct dentry *alias, *discon_alias, *invalid_alias;
> +	struct dentry *alias, *invalid_alias = NULL;
> 
> 	if (hlist_empty(&inode->i_dentry))
> 		return NULL;
> 
> -	discon_alias = NULL;
> -	invalid_alias = NULL;
> -
> 	spin_lock(&inode->i_lock);
> 	hlist_for_each_entry(alias, &inode->i_dentry, d_u.d_alias) {
> 		LASSERT(alias != dentry);
> 
> 		spin_lock(&alias->d_lock);
> -		if ((alias->d_flags & DCACHE_DISCONNECTED) &&
> -		    S_ISDIR(inode->i_mode))
> -			/* LASSERT(last_discon == NULL); LU-405, bz 20055 */
> -			discon_alias = alias;
> -		else if (alias->d_parent == dentry->d_parent	     &&
> -			 alias->d_name.hash == dentry->d_name.hash       &&
> -			 alias->d_name.len == dentry->d_name.len	 &&
> -			 memcmp(alias->d_name.name, dentry->d_name.name,
> -				dentry->d_name.len) == 0)
> +		if (alias->d_parent == dentry->d_parent       &&
> +		    alias->d_name.hash == dentry->d_name.hash &&
> +		    alias->d_name.len == dentry->d_name.len   &&
> +		    memcmp(alias->d_name.name, dentry->d_name.name,
> +			   dentry->d_name.len) == 0) {
> +			dget_dlock(alias);
> 			invalid_alias = alias;
> +		}
> 		spin_unlock(&alias->d_lock);
> 
> 		if (invalid_alias)
> 			break;
> 	}
> -	alias = invalid_alias ?: discon_alias ?: NULL;
> -	if (alias) {
> -		spin_lock(&alias->d_lock);
> -		dget_dlock(alias);
> -		spin_unlock(&alias->d_lock);
> -	}
> 	spin_unlock(&inode->i_lock);
> 
> -	return alias;
> +	return invalid_alias;
> }
> 
> /*
> - * Similar to d_splice_alias(), but lustre treats invalid alias
> - * similar to DCACHE_DISCONNECTED, and tries to use it anyway.
> + * Similar to d_splice_alias(), but also look for an "invalid" alias,
> + * specific to lustre, and use that if found.
>  */
> struct dentry *ll_splice_alias(struct inode *inode, struct dentry *de)
> {
> -	if (inode) {
> -		struct dentry *new = ll_find_alias(inode, de);
> +	if (inode && !S_ISDIR(inode->i_mode)) {
> +		struct ll_inode_info *lli = ll_i2info(inode);
> +		struct dentry *new;
> +
> +		/* We need lli_lock here as another thread could
> +		 * be running this code, and i_lock cannot protect us.
> +		 */
> +		spin_lock(&lli->lli_lock);
> +		new = ll_find_invalid_alias(inode, de);
> +		if (!new)
> +			d_add(de, inode);
> +		spin_lock(&lli->lli_lock);
> 
> 		if (new) {
> -			d_move(new, de);
> 			iput(inode);
> 			CDEBUG(D_DENTRY,
> 			       "Reuse dentry %p inode %p refc %d flags %#x\n",
> 			      new, d_inode(new), d_count(new), new->d_flags);
> 			return new;
> 		}
> +		return de;
> 	}
> -	d_add(de, inode);
> -	CDEBUG(D_DENTRY, "Add dentry %p inode %p refc %d flags %#x\n",
> -	       de, d_inode(de), d_count(de), de->d_flags);
> +	de = d_splice_alias(inode, de);
> +	if (!IS_ERR(de))
> +		CDEBUG(D_DENTRY, "Add dentry %p inode %p refc %d flags %#x\n",
> +		       de, d_inode(de), d_count(de), de->d_flags);
> 	return de;
> }
> 
> 
