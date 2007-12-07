From: Alex Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Fri, 07 Dec 2007 06:54:31 +0200
Subject: [Lustre-devel] Problems with make rpms
In-Reply-To: <475863ED.30908@datadirectnet.com>
References: <475863ED.30908@datadirectnet.com>
Message-ID: <1197003271.3550.26.camel@bear.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello Kit,

What kernel you used? is you build new kernel before build lustre?
I'm ask about it, because some times ago in kernel series was added new
patch for correctly create Module.symvers, if kernel sources not have
this patch - this will be produce similar error.

On Thu, 2007-12-06 at 16:04 -0500, Kit Westneat wrote:
> Hello,
> 
> I'm trying to compile the b1_6 CVS branch, but I'm running into problems 
> with 'make rpms'. 'make' works fine, but when I do 'make rpms' I get:
> 
> make[4]: *** No rule to make target 
> `/usr/src/redhat/BUILD/lustre-1.6.4.50/ldiskfs/Module.symvers', needed 
> by `Module.symvers'.  Stop.
> 
> Any thoughts?
> 
> Thanks,
> Kit
> 
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at clusterfs.com
> https://mail.clusterfs.com/mailman/listinfo/lustre-devel
