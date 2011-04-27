From: Peter =?iso-8859-1?q?Kjellstr=F6m?= <cap@nsc.liu.se>
Date: Wed, 27 Apr 2011 17:56:19 +0200
Subject: [Lustre-devel] [PATCH] Fix task IO accounting on reads
In-Reply-To: <alpine.LFD.2.01.1104270854090.20691@sys880.ldn.framestore.com>
References: <alpine.LFD.2.01.1104261356450.21670@sys880.ldn.framestore.com>
	<5870C1C1-3775-4CC8-B619-C79B6799D6E5@whamcloud.com>
	<alpine.LFD.2.01.1104270854090.20691@sys880.ldn.framestore.com>
Message-ID: <201104271756.24080.cap@nsc.liu.se>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wednesday, April 27, 2011 01:23:57 PM Mark Hills wrote:
> On Tue, 26 Apr 2011, Andreas Dilger wrote:
...
> > Mark,
> > It looks like this functionality was added to the kernel in Git commit
> > hash 7c3ab7381e79dfc7db14a67c6f4f3285664e1ec2, which was between 2.6.19
> > and 2.6.20.  This call needs to be made conditional so that it doesn't
> > break the client build on older kernels (it looks like it would break
> > RHEL5 and SLES10 clients, which don't have this functionality AFAICS).
> > 
> > It looks like it may be possible to create a compatibility macro in
> > lustre/include/linux/lustre_compat25.h so that it doesn't break for
> > clients running on older kernels:
> > 
> > #ifdef CONFIG_TASK_IO_ACCOUNTING
> > #include <linux/task_io_accounting_ops.h>
> > #else
> > #define task_io_accounting_read(bytes) do {} while (0)
> > #endif
> 
> Newer kernels always define task_io_account_read() as a function, even if
> it's a no-op. So to avoid redefining it it should check the kernel
> version, not the CONFIG_ flag.
> 
> A revised patch is below, which I tested with kernel 2.6.32.28.
> Unfortunately I odn't have a pre-2.6.20 platform for testing.

I suspect a real world complication that you'd have to handle is that the 
RHEL-5u6 kernel (2.6.18-238) has 
task_io_accounting_ops.h/task_io_accounting_read (yet another Redhat 
backport...)

/Peter
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 198 bytes
Desc: This is a digitally signed message part.
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20110427/1e720af5/attachment.pgp>
