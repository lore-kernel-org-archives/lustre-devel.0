From: NeilBrown <neilb@suse.com>
Date: Wed, 22 May 2019 13:54:37 +1000
Subject: [lustre-devel] [PATCH v2 01/29] lustre: llite: ll_fault fixes
In-Reply-To: <1558356671-29599-2-git-send-email-jsimmons@infradead.org>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
 <1558356671-29599-2-git-send-email-jsimmons@infradead.org>
Message-ID: <87blzvw3cy.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, May 20 2019, James Simmons wrote:

> From: Patrick Farrell <pfarrell@whamcloud.com>
>
> Various error conditions in the fault path can cause us to
> not return a page in vm_fault.  Check if it's present
> before accessing it.

I cannot find any error conditions that would leave ->page NULL,
but that wouldn't set one of
  VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED
in 'result'.

Can someone provide an example?

(I have seen crashes with vmf->page being NULL, but they were caused
 by VM_FAULT_RETRY being #defined to 0 as lustre/llite/llite_internal.h
 still does on OpenSFS lustre)

>
> Additionally, it's not valid to return VM_FAULT_NOPAGE for
> page faults.  The correct return when accessing a page that
> does not exist is VM_FAULT_SIGBUS.  Correcting this avoids
> looping infinitely in the testcase.

I agree with that.  VM_FAULT_NOPAGE is valid for page_mkwrite - and
ll_page_mkwrite() has separate code to choose VM_FAULT_NOPAGE.
So the change to to_fault_error() is valid.

NeilBrown


>
> Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
> WC-bug-id: https://jira.whamcloud.com/browse/LU-11403
> Reviewed-on: https://review.whamcloud.com/34247
> Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
> Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
> Reviewed-by: Oleg Drokin <green@whamcloud.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  fs/lustre/llite/llite_mmap.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
> index 1865db1..c8e57ad 100644
> --- a/fs/lustre/llite/llite_mmap.c
> +++ b/fs/lustre/llite/llite_mmap.c
> @@ -238,9 +238,6 @@ static inline vm_fault_t to_fault_error(int result)
>  	case 0:
>  		result = VM_FAULT_LOCKED;
>  		break;
> -	case -EFAULT:
> -		result = VM_FAULT_NOPAGE;
> -		break;
>  	case -ENOMEM:
>  		result = VM_FAULT_OOM;
>  		break;
> @@ -366,7 +363,8 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
>  
>  restart:
>  	result = __ll_fault(vmf->vma, vmf);
> -	if (!(result & (VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED))) {
> +	if (vmf->page &&
> +	    !(result & (VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED))) {
>  		struct page *vmpage = vmf->page;
>  
>  		/* check if this page has been truncated */
> -- 
> 1.8.3.1
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190522/29599858/attachment.sig>
