From: NeilBrown <neilb@suse.com>
Date: Thu, 23 May 2019 09:26:47 +1000
Subject: [lustre-devel] [PATCH v2 01/29] lustre: llite: ll_fault fixes
In-Reply-To: <DM6PR19MB25088E22AA6132C60758A34DC5000@DM6PR19MB2508.namprd19.prod.outlook.com>
References: <1558356671-29599-1-git-send-email-jsimmons@infradead.org>
 <1558356671-29599-2-git-send-email-jsimmons@infradead.org>
 <87blzvw3cy.fsf@notabene.neil.brown.name>
 <DM6PR19MB25088E22AA6132C60758A34DC5000@DM6PR19MB2508.namprd19.prod.outlook.com>
Message-ID: <87r28qul3c.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, May 22 2019, Patrick Farrell wrote:

> Neil,
>
> If you can?t find any, I imagine they don?t exist, at least in your branch, given that difference you cited.
>
> The particular case we had is here:
> https://jira.whamcloud.com/browse/LU-11403
>
> Which is when the file exists but has no striping info, and hence no data.

Hi Patrick,
Thanks for the reply.  Looking at that issue it appears that the root
cause is -EFAULT being returned from lov_io_init_empty, which then got
returned by ll_fault_io_init and then was converted by to_fault_error
into VM_FAULT_NOPAGE.

The test

 	if (!(result & (VM_FAULT_RETRY | VM_FAULT_ERROR | VM_FAULT_LOCKED))) {

in ll_fault() doesn't notice VM_FAULT_NOPAGE (it is not part of
VM_FAULT_ERROR), so the 'then' branch is run, which triggers the
problem.

Just changing to_fault_error() to convert  -EFAULT to VM_FAULT_SIGBUS,
as you did, cause the 'if' to do "the right thing", as VM_FAULT_SIGBUS
is one of the flags in VM_FAULT_ERROR.

So the extra test on vmf->page is redundant.  If there has been no
error, and we don't need to retry, then vmf->page *must* exist.


I've changed the commit message to explain this, so what I have now is
below.

Thanks,
NeilBrown

From: Patrick Farrell <pfarrell@whamcloud.com>
Date: Mon, 20 May 2019 08:50:43 -0400
Subject: [PATCH] lustre: llite: ll_fault fix

Error conditions in the fault path such as a fault on a file without
stripes (see lov_io_init_emtpy()) can cause us to
not return a page in vm_fault, and to report -EFAULT.

-EFAULT is currently mapped to VM_FAULT_NOPAGE by to_fault_error(),
and ll_fault doesn't recognize this as an error which might leave
->page unset, and tries to dereference vmf->page.

VM_FAULT_NOPAGE is *not* a valid status for .fault, only for
.page_mkwrite and .pfn_mkwrite.  So change to_fault_error() to
instead map -EFAULT to VM_FAULT_SIGBUS.  This is part of
VM_FAULT_ERROR, so ll_fault will *not* dereference vmf->page when that
error code is set.

Signed-off-by: Patrick Farrell <pfarrell@whamcloud.com>
WC-bug-id: https://jira.whamcloud.com/browse/LU-11403
Reviewed-on: https://review.whamcloud.com/34247
Reviewed-by: Alex Zhuravlev <bzzz@whamcloud.com>
Reviewed-by: Alexander Zarochentsev <c17826@cray.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lustre/llite/llite_mmap.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/lustre/llite/llite_mmap.c b/fs/lustre/llite/llite_mmap.c
index 1865db1237ce..59fb40029306 100644
--- a/fs/lustre/llite/llite_mmap.c
+++ b/fs/lustre/llite/llite_mmap.c
@@ -238,9 +238,6 @@ static inline vm_fault_t to_fault_error(int result)
 	case 0:
 		result = VM_FAULT_LOCKED;
 		break;
-	case -EFAULT:
-		result = VM_FAULT_NOPAGE;
-		break;
 	case -ENOMEM:
 		result = VM_FAULT_OOM;
 		break;
-- 
2.14.0.rc0.dirty

-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20190523/22d8361d/attachment.sig>
