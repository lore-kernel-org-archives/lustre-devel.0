From: Alex Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Sat, 09 Feb 2008 07:14:38 +0200
Subject: [Lustre-devel] 2.6.23 kernel struct file_operations sendfile
In-Reply-To: <3b98d27b-5256-4adf-8e83-5efe1231a25b@s13g2000prd.googlegroups.com>
References: <243f2731-0369-4d16-9e1c-74ab010ea343@m34g2000hsb.googlegroups.com>
	<1202493272.6760.27.camel@bear.shadowland>
	<3b98d27b-5256-4adf-8e83-5efe1231a25b@s13g2000prd.googlegroups.com>
Message-ID: <1202534078.6760.42.camel@bear.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Ron,

Patch created against sources from cvs - branch b1_6 date 20080116.
Patch tested for first with 2.6.23.8 and later with 2.6.24-rc8.
if you found any problems with this patch, please submit info into
bugzilla. I'm will be fix in next patch version.

On Fri, 2008-02-08 at 11:03 -0800, Ron wrote:
> Hi Alex,
> great!, Thanks.
> I'm having trouble finding a version of the source that the patch will
> apply cleaning to.
> I've tried releases 1.6.0.1, 1.6.3, 1.6.4.1, 1.6.4.2 and then, from
> cvs, a checkout of a few days ago.
> Could you please, perhaps give me a cvs tag that I can use? or some
> other way to get a source tree (to apply the patch to) and then build
> against patchless 2.6.23.12?
> Thanks.
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
