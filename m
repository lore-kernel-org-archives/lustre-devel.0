From: Andreas Dilger <adilger@whamcloud.com>
Date: Wed, 27 Jul 2011 11:11:28 -0600
Subject: [Lustre-devel] Hangs with cgroup memory controller
In-Reply-To: <alpine.LFD.2.01.1107271556070.7176@sys880.ldn.framestore.com>
References: <alpine.LFD.2.01.1107271556070.7176@sys880.ldn.framestore.com>
Message-ID: <BE324D9D-3D7B-4D9E-8F3D-316F259871FC@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Two ideas come to mind. On is that the reason you are having difficulty to reproduce the problem is that it only happens after some fault condition. Possibly you need the client to do recovery to an OST and resend a bulk RPC, or resend due to a checksum error?  It might also be due to application IO types (e.g. mmap, direct IO, pwrite, splice, etc).

Possibly you can correlate reproducer cases with Lustre errors on the console?

Lustre also has memory debugging that can be enabled, but without a reasonably concise reproducer it would be difficult to log/analyze so much data for hours of runtime.

Cheers, Andreas

On 2011-07-27, at 10:21 AM, Mark Hills <Mark.Hills@framestore.com> wrote:

> We are unable to use the combination of Lustre and the cgroup memory 
> controller, because of intermittent hangs when trying to close the cgroup.
> 
> In a thread on LKML [1] we diagnosed that the problem was a leak of page 
> accounting or resources.
> 
> Memory pages are charged to the cgroup, but the cgroup is unable to 
> un-charge them, and so it spins. It suggests that, perhaps, at least one 
> page gets allocated but not placed in the LRU.
> 
> Using the NFS client, via a gateway, has never shown this problem.
> 
> I'm in the client code, but I really need some pointers. And disadvantaged 
> by being unable to find a reproducable test case. Any ideas?
> 
> Our system is Lustre 1.8.6 server, with clients on Linux 2.6.32 and Lustre 
> 1.8.5.
> 
> Thanks
> 
> [1] https://lkml.org/lkml/2010/9/9/534
> 
> -- 
> Mark
> 
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
