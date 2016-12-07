From: James Simmons <jsimmons@infradead.org>
Date: Wed, 7 Dec 2016 19:05:28 +0000 (GMT)
Subject: [lustre-devel] Remaining work needed for moving Lustre out of
	staging
In-Reply-To: <0F617FFB-4BD0-4477-890B-2CDC56436DCC@intel.com>
References: <1E1B324A-F545-417D-9C35-550FA58665C7@intel.com>
	<20161203085550.GA5375@kroah.com>
	<0F617FFB-4BD0-4477-890B-2CDC56436DCC@intel.com>
Message-ID: <alpine.LFD.2.20.1612071902300.1427@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: gregkh@linuxfoundation.org, "Dilger, Andreas" <andreas.dilger@intel.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>


> On Dec 3, 2016, at 3:55 AM, gregkh at linuxfoundation.org wrote:
> 
> > On Fri, Dec 02, 2016 at 09:53:08PM +0000, Dilger, Andreas wrote:
> >> Al,
> >> Greg recently raised the issue of what still needs to be done to
> >> move the Lustre code out of staging/ and into the fs/ tree. 
> >> 
> >> James has been doing a great job of cleaning up various checkpatch
> >> issues and keeping the code updated with the latest fixes, but we
> >> were wondering what you were aware of that needed to be cleaned
> >> up in Lustre?
> > 
> > Is the whole "mixing kernel structures in userspace structures" all
> > resolved now?  For some reason I thought that you had kernel locks being
> > passed to userspace and then back into the kernel, but it's been a long
> > time since I last looked...
> 
> While we certainly had our share of mixing user/kernelspace structures,
> I don't think we ever passed anything with locks around back and forth.

I think he means the use of linux list structures as a parameter for the
ioctls in LNet selftest. The work is being done under:

https://jira.hpdd.intel.com/browse/LU-8915

No patch ready just yet.
