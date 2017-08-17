From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 17 Aug 2017 08:47:52 -0700
Subject: [lustre-devel] [PATCH] staging: lustre: lustre: Off by two in
	lmv_fid2path()
In-Reply-To: <alpine.LFD.2.20.1708141559060.14369@casper.infradead.org>
References: <20170728144227.uml3x27mqug3ciox@mwanda>
	<alpine.LFD.2.20.1708141559060.14369@casper.infradead.org>
Message-ID: <20170817154752.GA18912@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Aug 14, 2017 at 04:01:17PM +0100, James Simmons wrote:
> 
> > We want to concatonate join string one, a '/' character, string two and
> > then a NUL terminator.  The destination buffer holds ori_gf->gf_pathlen
> > characters.  The strlen() function returns the number of characters not
> > counting the NUL terminator.  So we should be adding two extra spaces,
> > one for the foward slash and one for the NUL.
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > ---
> > Not tested.  Please review this one carefully.
> 
> This is a real bug which is impacting users. The bug is being tracked
> at https://jira.hpdd.intel.com/browse/LU-9863. It passed our test suite
> and its being reviewed.

So what am I supposed to do with this patch?
