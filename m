From: Xiong, Jinshan <jinshan.xiong@intel.com>
Date: Fri, 3 Feb 2017 23:44:57 +0000
Subject: [lustre-devel] [PATCH] mm: Avoid returning VM_FAULT_RETRY from
 ->page_mkwrite handlers
In-Reply-To: <20170203150729.15863-1-jack@suse.cz>
References: <20170203150729.15863-1-jack@suse.cz>
Message-ID: <E91BA9E8-7469-46BB-B3B2-072F95D061EE@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jan Kara <jack@suse.cz>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, "cluster-devel@redhat.com" <cluster-devel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew
 Morton <akpm@linux-foundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

Hi Jan,

Thanks for the patch. 

The proposed patch should be able to fix the problem, however, do you think it would be a better approach by revising it as:

?
case -EAGAIN:
	if (vmf->flags & FAULT_FLAG_ALLOW_RETRY) {
		up_read(&mm->mmap_sem);
		return VM_FAULT_RETRY;
	}
	return VM_FAULT_NOPAGE;
?

This way it can retry fault routine in mm instead of letting CPU have a new fault access.

Thanks,
Jinshan

> On Feb 3, 2017, at 7:07 AM, Jan Kara <jack@suse.cz> wrote:
> 
> Some ->page_mkwrite handlers may return VM_FAULT_RETRY as its return
> code (GFS2 or Lustre can definitely do this). However VM_FAULT_RETRY
> from ->page_mkwrite is completely unhandled by the mm code and results
> in locking and writeably mapping the page which definitely is not what
> the caller wanted. Fix Lustre and block_page_mkwrite_ret() used by other
> filesystems (notably GFS2) to return VM_FAULT_NOPAGE instead which
> results in bailing out from the fault code, the CPU then retries the
> access, and we fault again effectively doing what the handler wanted.
> 
> CC: lustre-devel at lists.lustre.org
> CC: cluster-devel at redhat.com
> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
> drivers/staging/lustre/lustre/llite/llite_mmap.c | 4 +---
> include/linux/buffer_head.h                      | 4 +---
> 2 files changed, 2 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/staging/lustre/lustre/llite/llite_mmap.c
> index ee01f20d8b11..9afa6bec3e6f 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
> @@ -390,15 +390,13 @@ static int ll_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> 		result = VM_FAULT_LOCKED;
> 		break;
> 	case -ENODATA:
> +	case -EAGAIN:
> 	case -EFAULT:
> 		result = VM_FAULT_NOPAGE;
> 		break;
> 	case -ENOMEM:
> 		result = VM_FAULT_OOM;
> 		break;
> -	case -EAGAIN:
> -		result = VM_FAULT_RETRY;
> -		break;
> 	default:
> 		result = VM_FAULT_SIGBUS;
> 		break;
> diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
> index d67ab83823ad..79591c3660cc 100644
> --- a/include/linux/buffer_head.h
> +++ b/include/linux/buffer_head.h
> @@ -243,12 +243,10 @@ static inline int block_page_mkwrite_return(int err)
> {
> 	if (err == 0)
> 		return VM_FAULT_LOCKED;
> -	if (err == -EFAULT)
> +	if (err == -EFAULT || err == -EAGAIN)
> 		return VM_FAULT_NOPAGE;
> 	if (err == -ENOMEM)
> 		return VM_FAULT_OOM;
> -	if (err == -EAGAIN)
> -		return VM_FAULT_RETRY;
> 	/* -ENOSPC, -EDQUOT, -EIO ... */
> 	return VM_FAULT_SIGBUS;
> }
> -- 
> 2.10.2
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
