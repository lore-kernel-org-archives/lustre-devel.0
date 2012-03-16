From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Fri, 16 Mar 2012 10:46:22 -0400
Subject: [Lustre-devel] [wc-discuss] Re: [Twg] Lustre and cross-platform
	portability
In-Reply-To: <FC3B1D44-ED0D-4EAD-8003-B3E458A46469@xyratex.com>
Message-ID: <201203161446.q2GEkNMO005460@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Also fuse client will able to run on any OS have a FUSE porting that is
>any BSD, OpenSolaris, MacOS, in additional to the windows.  That is
>easy way to maintain a single client for many OS.

It is, unfortunately, not quite that simple.

I can't claim to be a FUSE expert, but I've been paying attention
to it on other platforms.  From what I can tell, FUSE works great
on Linux, but on other platforms the support is iffy.  Also, it's
not quite implemented the same on other operating systems as it is
on Linux, making porting a Linux FUSE module to other platforms not
trivial; from what I've seen, this is due to the Linux filesystem
interface versus the vnode interface used by every Unix except Linux
(and this is part of what makes Lustre hard to port).

I guess what I'm saying is that don't fall into the underwear gnomes
trap of thinking:

1) Get liblustre working with FUSE
2) ???
3) Lustre client everywhere!

It might make it easier, but I doubt it will make it easy.

--Ken
