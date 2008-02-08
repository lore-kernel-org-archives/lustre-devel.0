From: Alex Lyashkov <Alexey.Lyashkov@Sun.COM>
Date: Fri, 08 Feb 2008 19:54:32 +0200
Subject: [Lustre-devel] 2.6.23 kernel struct file_operations sendfile
In-Reply-To: <243f2731-0369-4d16-9e1c-74ab010ea343@m34g2000hsb.googlegroups.com>
References: <243f2731-0369-4d16-9e1c-74ab010ea343@m34g2000hsb.googlegroups.com>
Message-ID: <1202493272.6760.27.camel@bear.shadowland>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi Ron,

look into bugzilla bug 14250. 
This bug include patch for buuld patchless client against vanila
2.4.23/24.24 kernels.

On Fri, 2008-02-08 at 07:21 -0800, Ron wrote:
> Hi,
> In trying (just to see what happens) to build against patchless
> 2.6.23, I see that the
> file_operations structure no longer has the sendfile field.  Has
> anyone in the development
> team thought of a way around this?
> Thanks,
> Ron
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
