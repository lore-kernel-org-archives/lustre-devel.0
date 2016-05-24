From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Wed, 25 May 2016 00:40:54 +0200
Subject: [lustre-devel] [PATCH] posix acls: Move namespace conversion
 into filesystem / xattr handlers
In-Reply-To: <alpine.LFD.2.20.1605242122110.4622@casper.infradead.org>
References: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
	<alpine.LFD.2.20.1605232035110.24983@casper.infradead.org>
	<CF8AFD90-BC52-43BD-BB1E-BBFEC5086727@intel.com>
	<alpine.LFD.2.20.1605242122110.4622@casper.infradead.org>
Message-ID: <CAHc6FU5s-W=fGcg+Liq2546Ss=fbwURGtr7gAzDtqSTUy1A=rQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: "Dilger, Andreas" <andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org" <devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org>, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, "linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, "Drokin, Oleg" <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Lustre Developement <lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org>

On Tue, May 24, 2016 at 10:35 PM, James Simmons <jsimmons@infradead.org> wrote:
> That is a huge cleanup which will make Greg very happy. The tools and test
> are going to be updated so the landing has to be just right so we
> don't have a flood of test failures. Gruenbacher with the 19789 patch
> Dilger pointed out Lustre's POSIX ACL code just becomes ordinary which
> means we can use the default POSIS xattr handler. You wouldn't have to
> keep posix_acl.c around with these changes.

Change http://review.whamcloud.com/19789 doesn't switch Lustre over to
using xattr handlers. As long as Lustre doesn't use those (i.e., use
posix_acl_access_xattr_handler and posix_acl_default_xattr_handler),
it will still need the uid/gid namespace conversion code in ll_getxattr and
ll_setxattr for this patch to be correct.

The merge conflict between this patch and http://review.whamcloud.com/19789
is easily resolved though.

Andreas
