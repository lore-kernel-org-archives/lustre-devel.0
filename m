From: Alexey Lyashkov <alexey_lyashkov@xyratex.com>
Date: Sat, 17 Mar 2012 14:42:48 +0400
Subject: [Lustre-devel] [wc-discuss] [Twg] Lustre and cross-platform
	portability
In-Reply-To: <201203161446.q2GEkNMO005460@hedwig.cmf.nrl.navy.mil>
References: <201203161446.q2GEkNMO005460@hedwig.cmf.nrl.navy.mil>
Message-ID: <C930EE77-BA97-4065-B3B1-1A26ED284407@xyratex.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Trust me.
I (with two friends) write  a FUSE client for a FreeBSD in past.
Most issues related to a porting libcfs/libsysio to FreeBSD, but anyway patch isn''t huge ~200kb.
I have plan to send that patch in near time, as 2.3 landing window open.



On Mar 16, 2012, at 18:46, Ken Hornstein wrote:

>> Also fuse client will able to run on any OS have a FUSE porting that is
>> any BSD, OpenSolaris, MacOS, in additional to the windows.  That is
>> easy way to maintain a single client for many OS.
> 
> It is, unfortunately, not quite that simple.
> 
> I can't claim to be a FUSE expert, but I've been paying attention
> to it on other platforms.  From what I can tell, FUSE works great
> on Linux, but on other platforms the support is iffy.  Also, it's
> not quite implemented the same on other operating systems as it is
> on Linux, making porting a Linux FUSE module to other platforms not
> trivial; from what I've seen, this is due to the Linux filesystem
> interface versus the vnode interface used by every Unix except Linux
> (and this is part of what makes Lustre hard to port).
> 
> I guess what I'm saying is that don't fall into the underwear gnomes
> trap of thinking:
> 
> 1) Get liblustre working with FUSE
> 2) ???
> 3) Lustre client everywhere!
> 
> It might make it easier, but I doubt it will make it easy.
> 
> --Ken
