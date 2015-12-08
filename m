From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 8 Dec 2015 16:30:27 -0500
Subject: [lustre-devel] [PATCH] staging: lustre: add __user attributes
	to llite/file.c
In-Reply-To: <1449606856-21619-1-git-send-email-nauxuron@wimdewith.com>
References: <1449606856-21619-1-git-send-email-nauxuron@wimdewith.com>
Message-ID: <20151208213027.GA31006@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Dec 08, 2015 at 09:34:16PM +0100, Wim de With wrote:
> This fixes the following sparse warnings:
> 
> drivers/staging/lustre/lustre/llite/file.c:1310:38:    expected void const [noderef] <asn:1>*from
> drivers/staging/lustre/lustre/llite/file.c:1310:38:    got struct ll_recreate_obj *<noident>
> drivers/staging/lustre/lustre/llite/file.c:1328:35: warning: incorrect type in argument 2 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:1328:35:    expected void const [noderef] <asn:1>*from
> drivers/staging/lustre/lustre/llite/file.c:1328:35:    got struct lu_fid *<noident>
> drivers/staging/lustre/lustre/llite/file.c:1475:35: warning: incorrect type in argument 2 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:1475:35:    expected void const [noderef] <asn:1>*from
> drivers/staging/lustre/lustre/llite/file.c:1475:35:    got struct lov_user_md_v1 *<noident>
> drivers/staging/lustre/lustre/llite/file.c:1500:35: warning: incorrect type in argument 2 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:1500:35:    expected void const [noderef] <asn:1>*from
> drivers/staging/lustre/lustre/llite/file.c:1500:35:    got struct lov_user_md_v1 *lumv1p
> drivers/staging/lustre/lustre/llite/file.c:1505:44: warning: incorrect type in argument 2 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:1505:44:    expected void const [noderef] <asn:1>*from
> drivers/staging/lustre/lustre/llite/file.c:1505:44:    got struct lov_user_md_v3 *lumv3p
> drivers/staging/lustre/lustre/llite/file.c:1516:17: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:1516:17:    expected void const volatile [noderef] <asn:1>*<noident>
> drivers/staging/lustre/lustre/llite/file.c:1516:17:    got unsigned short *<noident>
> drivers/staging/lustre/lustre/llite/file.c:1829:27: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:1829:27:    expected void [noderef] <asn:1>*to
> drivers/staging/lustre/lustre/llite/file.c:1829:27:    got void *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2214:24: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2214:24:    expected void const volatile [noderef] <asn:1>*<noident>
> drivers/staging/lustre/lustre/llite/file.c:2214:24:    got int *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2221:21: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2221:21:    expected void const volatile [noderef] <asn:1>*<noident>
> drivers/staging/lustre/lustre/llite/file.c:2221:21:    got int *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2245:43: warning: incorrect type in argument 2 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2245:43:    expected void const [noderef] <asn:1>*from
> drivers/staging/lustre/lustre/llite/file.c:2245:43:    got char *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2275:24: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2275:24:    expected void const volatile [noderef] <asn:1>*<noident>
> drivers/staging/lustre/lustre/llite/file.c:2275:24:    got int *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2292:35: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2292:35:    expected void [noderef] <asn:1>*to
> drivers/staging/lustre/lustre/llite/file.c:2292:35:    got void *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2299:44: warning: incorrect type in argument 2 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2299:44:    expected void [noderef] <asn:1>*arg
> drivers/staging/lustre/lustre/llite/file.c:2299:44:    got void *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2304:43: warning: incorrect type in argument 2 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2304:43:    expected void const [noderef] <asn:1>*from
> drivers/staging/lustre/lustre/llite/file.c:2304:43:    got char *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2310:46: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2310:46:    expected void [noderef] <asn:1>*to
> drivers/staging/lustre/lustre/llite/file.c:2310:46:    got char *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2323:21: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2323:21:    expected void const volatile [noderef] <asn:1>*<noident>
> drivers/staging/lustre/lustre/llite/file.c:2323:21:    got int *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2350:35: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2350:35:    expected void [noderef] <asn:1>*to
> drivers/staging/lustre/lustre/llite/file.c:2350:35:    got void *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2361:36: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2361:36:    expected void const [noderef] <asn:1>*<noident>
> drivers/staging/lustre/lustre/llite/file.c:2361:36:    got char *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2389:35: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2389:35:    expected void [noderef] <asn:1>*to
> drivers/staging/lustre/lustre/llite/file.c:2389:35:    got char *<noident>
> drivers/staging/lustre/lustre/llite/file.c:2483:36: warning: incorrect type in argument 1 (different address spaces)
> drivers/staging/lustre/lustre/llite/file.c:2483:36:    expected void const [noderef] <asn:1>*<noident>
> drivers/staging/lustre/lustre/llite/file.c:2483:36:    got void *<noident>
> 
> It simply casts pointers to __user pointers in most cases, and changes a
> few pointers to __user pointers.

But that's not really fixing the issue here :(

Doing this type of work is non-trivial for lustre, I wouldn't even
recommend trying it out.  It is going to require changes in how some of
the structures are layed out, and probably some userspace tool changes
as well.

Sorry, I can't take this patch as-is.

greg k-h
