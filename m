From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 17:02:12 +0100 (BST)
Subject: [lustre-devel] [PATCH 08/27] staging: lustre: avoid to use
 bio->bi_vcnt directly
In-Reply-To: <20160410144145.GA24062@infradead.org>
References: <1459857443-20611-1-git-send-email-tom.leiming@gmail.com>
	<1459857443-20611-9-git-send-email-tom.leiming@gmail.com>
	<20160405130109.GB32576@infradead.org>
	<alpine.LFD.2.20.1604101527310.3112@casper.infradead.org>
	<20160410144145.GA24062@infradead.org>
Message-ID: <alpine.LFD.2.20.1604101658430.3112@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Ming Lei <tom.leiming@gmail.com>, Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, Boaz Harrosh <boaz@plexistor.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "John L. Hammond" <john.hammond@intel.com>, Frank Zago <fzago@cray.com>, Mike Rapoport <mike.rapoport@gmail.com>, Kent Overstreet <kent.overstreet@gmail.com>, Julia Lawall <Julia.Lawall@lip6.fr>, Al Viro <viro@zeniv.linux.org.uk>, "moderated list:STAGING - LUSTRE PARALLEL FILESYSTEM" <lustre-devel@lists.lustre.org>, "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>


> On Sun, Apr 10, 2016 at 03:37:42PM +0100, James Simmons wrote:
> > 
> > > The lloop driver should be removed entirely - use the loop driver
> > > instead.
> > 
> > I talked with Andreas last week at our annual Lustre users group meeting 
> > about this. The reason I was told for existance is that some users were
> > using files on a Lustre file system with the loop back device. The 
> > performance was really bad at the time so a lloop was developed to 
> > overcome those limitations. Its been a long time so perhaps its time
> > to look at the default loop driver again to see if can perform now. If
> > it doesn't we will go the route of reworking the lloop driver in the
> > spirit of the cryptoloop device.
> 
> The loop driver now supports using AIO/DIO on any file systems that
> implements ->read_iter and ->write_iter. If lustre doesn't support
> those or doesn't have proper performance using them it should be
> addressed in the file system.
> 
> Note that the dio mode in the loop device is not the default and you
> need to manually enabled it, keep that in mind when testing.

This is excellent news. The only sad thing is that most lustre users
are running distros that use kernels before the AIO/DIO enhancements
were landed :-( We will have to keep a copy around for those guys. But
first I need to test the performance of the loop back driver this
week before this can be dropped.
