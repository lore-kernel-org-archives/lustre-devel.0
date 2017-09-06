From: Tyson Whitehead <twhitehead@gmail.com>
Date: Wed, 06 Sep 2017 15:25:30 -0400
Subject: [lustre-devel] [PATCH 0/2] LU-6808: ported to upstream staging
	driver
In-Reply-To: <20170906172852.GA29067@kroah.com>
References: <9525089.uibW5qMffG@whitehead.beowulf.uwo.ca>
	<20170906172852.GA29067@kroah.com>
Message-ID: <2026203.e3uc1VY80x@whitehead.beowulf.uwo.ca>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wednesday, September 6, 2017 7:28:52 PM EDT Greg Kroah-Hartman wrote:
> On Wed, Sep 06, 2017 at 12:04:04PM -0400, Tyson Whitehead wrote:
> > Please find enclosed in the next two emails the two patches for LU-6808 ported to the in-tree staging lustre client driver in the 4.12 release.
> 
> What does that mean?  What can I do with these?  4.12 is about to be end-of-life in a few days...
> 
> confused,

Those were some Lustre client driver patches I ported forward to the in-tree 4.12 kernel driver (as that is what our Fedora based system is running).

I was asked to pass them along on the Lustre bug tracking system for inclusion.

I see though that they should be against your staging-testing branch and not the previous release branch.  I'll move them over to this and post again.

Thanks!  -Tyson
