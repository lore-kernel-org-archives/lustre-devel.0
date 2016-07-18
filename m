From: Simmons, James A. <simmonsja@ornl.gov>
Date: Mon, 18 Jul 2016 15:22:15 +0000
Subject: [lustre-devel] Building 1.8.9 Kernel modules for Kernel 3.1
In-Reply-To: <f1c16047-ecbe-6b36-1ddc-a416c7a94b14@phys.ufl.edu>
References: <f1c16047-ecbe-6b36-1ddc-a416c7a94b14@phys.ufl.edu>
Message-ID: <5abef7fe5df24c359f20a721d4788a49@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Hi,
>
>I need to mount a lustre 1.8.9 filesystem on Kernel 3.16.36.
>
>So, I need to build 1.8.9 Kernel module to mount lustre 1.8.9 filesystem 
>on Kernel 3.16.36.
>
>I am wondering if this is possible.

Nope. The amount of changes needed to support that new of a kernel
are huge. Can you set up a second file system to transfer the data over
to? Parallel copy tools exist.
