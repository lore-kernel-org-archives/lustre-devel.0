From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
Date: Tue, 24 May 2016 00:30:07 +0200
Subject: [lustre-devel] [PATCH] posix acls: Move namespace conversion
 into filesystem / xattr handlers
In-Reply-To: <alpine.LFD.2.20.1605232035110.24983@casper.infradead.org>
References: <1464008989-3812-1-git-send-email-agruenba@redhat.com>
	<alpine.LFD.2.20.1605232035110.24983@casper.infradead.org>
Message-ID: <CAHpGcMJPnNeF0DqFO_hZyJD-OUB7E7PN5bikV6GMLafzkt_hdQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Andreas Gruenbacher <agruenba-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Oleg Drokin <oleg.drokin-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Andreas Dilger <andreas.dilger-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Steve French <sfrench-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, Linux FS-devel Mailing List <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Lustre Developement <lustre-devel-aLEFhgZF4x6X6Mz3xDxJMA@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org

2016-05-23 23:06 GMT+02:00 James Simmons <jsimmons@infradead.org>:
> Nak on the Lustre changes. POSIX ACLs are also handled in mdc_request.c.
> Besides POSIX ACLs lustre has created a extended ACL as well that is
> grouped in with posix ACL handling. This extended ACL is like POSIX acls
> except it also contains the state (deleted, modified, ...) of the ACL.
> Besides normal local access control list handling Lustre manages remote
> access control list handling. You can read about this handling is in
> llite_rmtacl.c. This code was written long before I became involved with
> lustre so the exact details are fuzzy to me. The guts of this are handled
> is located at:
>
> drivers/staging/lustre/lustre/obdclass/acl.c

I'm not sure we're talking about the same thing here. As far as I can
see, the only code path from getxattr(2) and settxattr(2) into lustre
is through ll_getxattr and ll_setxattr. So far, the vfs performed the
uid/gid mappings before calling into the filesystem. With this patch,
the filesystem performs this mapping instead. In the lustre case,
pretty much directly after entering ll_getxattr and immediately before
leaving ll_setxattr. The rest of the code has and still does operate
in the "init uid/gid namespace". Did I miss anything?

>     A you probably have noticed Lustre has had an uptick in development
> which means the code is now changing all the time in staging. How should
> we handle the changes you are working in your own trees verses what is
> happing in staging. For example I'm looking at moving lustre to the
> xattr_handles.

Okay, great.

> Should I push it to you and wait until it works it way
> into Greg's tree.

Changing lustre to use xattr handlers does not dependent on any of my
pending xattr changes, only the other way around. Please copy me for
review and merge through Greg's tree as usual. Once I have your
changes on a public branch, I can merge that into my xattr inode
operation removal branch.

> What do the merge schedules look like.

I hope the {get,set,remove}xattr inode operations will go away in the
next merge window, so it would be good to have the lustre xattr
handler convestion on a public branch relatively soon if possible.

> Lastly the a_refcount for the POSIX acl changed with your xattr updates which now
> causes lustre to crash :-(

You mean commit b8a7a3a6 "posix_acl: Inode acl caching fixes"? It
seems a "forget_cached_acl(inode, type);" before returning the acl in
ll_get_acl is missing -- but lustre still shouldn't crash because of
that.

Thanks,
Andreas
