From: Ben Evans <bevans@cray.com>
Date: Thu, 22 Oct 2015 15:58:23 +0000
Subject: [lustre-devel] layout.c capsule dumps
Message-ID: <D24E7FDD.2745%jevans@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Are these completely unused at this point?  As far as I can tell, the main mechanism to dump info, req_capsule_(client|server)_dump are completely unreferenced by anything.

Would it make sense to remove all this as dead code, or am I missing something?

-Ben Evans
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20151022/6215e695/attachment.htm>
