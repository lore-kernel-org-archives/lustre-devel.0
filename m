From: Andreas Dilger <adilger@sun.com>
Date: Tue, 19 Feb 2008 13:13:52 -0700
Subject: [Lustre-devel] storing SOM epoch in EA
In-Reply-To: <47BAE80A.8050702@sun.com>
References: <47BAA607.1000600@sun.com> <47BAAF3F.6030301@sun.com>
	<200802191359.47379.vitaly@sun.com> <47BAB962.8010901@sun.com>
	<47BABB01.8060402@sun.com> <47BAC53A.2030106@sun.com>
	<47BAC7D4.3010007@sun.com> <47BAE80A.8050702@sun.com>
Message-ID: <20080219201352.GP3029@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Feb 19, 2008  16:30 +0200, Yuriy Umanets wrote:
> Alex Zhuravlev wrote:
> by "LOV" you mean LOV EA? If yes, well, this is too radical idea seems, 
> but it may be worse to think on. Finally using IAM with it will cost 
> almost nothing in meaning of additional development. IAM should be ready 
> for that.
> 
> Nikita, is there any limitations for value size in IAM?

One of the major problems with IAM is that e2fsck doesn't work with it,
it will only exist for ldiskfs (though ZAP works for DMU), and there is
a consistency issue between items stored in IAM and in rest of filesystem.

If e2fsck deletes an inode, it will not delete entry in IAM, so now we
have to patch e2fsck to understand not only IAM, but also specific uses
of IAM that link items there to inodes in another place.  I don't think
that introducing dependence on IAM is practical.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
