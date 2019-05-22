From: Patrick Farrell <pfarrell@whamcloud.com>
Date: Wed, 22 May 2019 12:48:37 +0000
Subject: [lustre-devel] [PATCH v2 01/29] lustre: llite: ll_fault fixes
In-Reply-To: <87blzvw3cy.fsf@notabene.neil.brown.name>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
 <1558356671-29599-2-git-send-email-jsimmons@infradead.org>,
 <87blzvw3cy.fsf@notabene.neil.brown.name>
Message-ID: <DM6PR19MB25088E22AA6132C60758A34DC5000@DM6PR19MB2508.namprd19.prod.outlook.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Neil,

If you can?t find any, I imagine they don?t exist, at least in your branch, given that difference you cited.

The particular case we had is here:
https://jira.whamcloud.com/browse/LU-11403

Which is when the file exists but has no striping info, and hence no data.

- Patrick
________________________________
From: NeilBrown <neilb@suse.com>
Sent: Tuesday, May 21, 2019 10:54:37 PM
To: James Simmons; Andreas Dilger; Oleg Drokin
Cc: Lustre Development List; Patrick Farrell; James Simmons
Subject: Re: [PATCH v2 01/29] lustre: llite: ll_fault fixes

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
>        case 0:
>                result = VM_FAULT_LOCKED;
>                break;
> -     case -EFAULT:
> -             result = VM_FAULT_NOPAGE;
> -             break;
>        case -ENOMEM:
>                result = VM_FAULT_OOM;
>                break;
> @@ -366,7 +363,8 @@ static vm_fault_t ll_fault(struct vm_fault *vmf)
>
>  restart:
>        result = __ll_fault(vmf->vma, vmf);
> -     if (!(result & (VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED))) {
> +     if (vmf->page &&
> +         !(result & (VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED))) {
>                struct page *vmpage = vmf->page;
>
>                /* check if this page has been truncated */
> --
> 1.8.3.1
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190522/58f60308/attachment.html>
