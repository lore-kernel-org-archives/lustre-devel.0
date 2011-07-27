From: Mark Hills <Mark.Hills@framestore.com>
Date: Wed, 27 Jul 2011 17:21:52 +0100 (BST)
Subject: [Lustre-devel] Hangs with cgroup memory controller
Message-ID: <alpine.LFD.2.01.1107271556070.7176@sys880.ldn.framestore.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

We are unable to use the combination of Lustre and the cgroup memory 
controller, because of intermittent hangs when trying to close the cgroup.

In a thread on LKML [1] we diagnosed that the problem was a leak of page 
accounting or resources.

Memory pages are charged to the cgroup, but the cgroup is unable to 
un-charge them, and so it spins. It suggests that, perhaps, at least one 
page gets allocated but not placed in the LRU.

Using the NFS client, via a gateway, has never shown this problem.

I'm in the client code, but I really need some pointers. And disadvantaged 
by being unable to find a reproducable test case. Any ideas?

Our system is Lustre 1.8.6 server, with clients on Linux 2.6.32 and Lustre 
1.8.5.

Thanks

[1] https://lkml.org/lkml/2010/9/9/534

-- 
Mark
