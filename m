From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Wed, 25 May 2016 00:08:33 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: llite: drop acl from
	cache
In-Reply-To: <alpine.LFD.2.20.1605242135500.4622@casper.infradead.org>
References: <1464050108-28015-1-git-send-email-jsimmons@infradead.org>
	<CAHpGcMJtzz4MYcRKkG-ybKgDArchQ_CFOtFjpJ8axe8Ls2G7rw@mail.gmail.com>
	<alpine.LFD.2.20.1605242135500.4622@casper.infradead.org>
Message-ID: <CAHc6FU7RpdNmj5HxcHizKHdsDb9myPBmDNXPNSQOGdLHvvwTcQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, May 24, 2016 at 10:38 PM, James Simmons <jsimmons@infradead.org> wrote:
>> 2016-05-24 2:35 GMT+02:00 James Simmons <jsimmons@infradead.org>:
>> > Commit b8a7a3a6 change get_acl() for posix xattr to always cache
>> > the ACL which increases the reference count. That reference count
>> > can be reduced by have ll_get_acl() call forget_cached_acl() which
>> > it wasn't. When an inode gets deleted by Lustre the POSIX ACL
>> > reference count is tested to ensure its 1 and if not produces an error.
>>
>> Lustre shouldn't assume that the VFS immediately drops the reference
>> it is passed. Please remove that check as well.
>
> The piece of code in question from ll_delete_inode() is
>
> #ifdef CONFIG_FS_POSIX_ACL
>         else if (lli->lli_posix_acl) {
>                 LASSERT(atomic_read(&lli->lli_posix_acl->a_refcount) ==
> 1);
>                 LASSERT(!lli->lli_remote_perms);
>                 posix_acl_release(lli->lli_posix_acl);
>                 lli->lli_posix_acl = NULL;
>         }
> #endif
>
> So we want to prevent a leak should I do a
>
> while (atomic_read(&lli->lli_posix_acl->a_refcount))
>         posix_acl_release(lli->lli_posix_acl);
> lli->lli_posix_acl = NULL;
>
> Or does the VFS do this cleanup for us?

This conversation is unreal. Just remove the misguided assert and
you're good. After that, please have someone explain basic reference
counting to you.

Thanks,
Andreas
