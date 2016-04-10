From: James Simmons <jsimmons@infradead.org>
Date: Sun, 10 Apr 2016 15:37:42 +0100 (BST)
Subject: [lustre-devel] [PATCH 08/27] staging: lustre: avoid to use
 bio->bi_vcnt directly
In-Reply-To: <20160405130109.GB32576@infradead.org>
References: <1459857443-20611-1-git-send-email-tom.leiming@gmail.com>
	<1459857443-20611-9-git-send-email-tom.leiming@gmail.com>
	<20160405130109.GB32576@infradead.org>
Message-ID: <alpine.LFD.2.20.1604101527310.3112@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: Ming Lei <tom.leiming@gmail.com>, Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, Boaz Harrosh <boaz@plexistor.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "John L. Hammond" <john.hammond@intel.com>, Frank Zago <fzago@cray.com>, Mike Rapoport <mike.rapoport@gmail.com>, Kent Overstreet <kent.overstreet@gmail.com>, Julia Lawall <Julia.Lawall@lip6.fr>, Al Viro <viro@zeniv.linux.org.uk>, "moderated list:STAGING - LUSTRE PARALLEL FILESYSTEM" <lustre-devel@lists.lustre.org>, "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>


> The lloop driver should be removed entirely - use the loop driver
> instead.

I talked with Andreas last week at our annual Lustre users group meeting 
about this. The reason I was told for existance is that some users were
using files on a Lustre file system with the loop back device. The 
performance was really bad at the time so a lloop was developed to 
overcome those limitations. Its been a long time so perhaps its time
to look at the default loop driver again to see if can perform now. If
it doesn't we will go the route of reworking the lloop driver in the
spirit of the cryptoloop device.
