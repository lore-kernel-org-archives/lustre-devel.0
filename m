From: Kit Westneat <kwestneat@datadirectnet.com>
Date: Thu, 06 Dec 2007 16:04:45 -0500
Subject: [Lustre-devel] Problems with make rpms
Message-ID: <475863ED.30908@datadirectnet.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello,

I'm trying to compile the b1_6 CVS branch, but I'm running into problems 
with 'make rpms'. 'make' works fine, but when I do 'make rpms' I get:

make[4]: *** No rule to make target 
`/usr/src/redhat/BUILD/lustre-1.6.4.50/ldiskfs/Module.symvers', needed 
by `Module.symvers'.  Stop.

Any thoughts?

Thanks,
Kit
