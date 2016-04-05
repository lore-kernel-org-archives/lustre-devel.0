From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 5 Apr 2016 06:01:09 -0700
Subject: [lustre-devel] [PATCH 08/27] staging: lustre: avoid to use
	bio->bi_vcnt directly
In-Reply-To: <1459857443-20611-9-git-send-email-tom.leiming@gmail.com>
References: <1459857443-20611-1-git-send-email-tom.leiming@gmail.com>
	<1459857443-20611-9-git-send-email-tom.leiming@gmail.com>
Message-ID: <20160405130109.GB32576@infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ming Lei <tom.leiming@gmail.com>
Cc: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Boaz Harrosh <boaz@plexistor.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "John L. Hammond" <john.hammond@intel.com>, Frank Zago <fzago@cray.com>, Mike Rapoport <mike.rapoport@gmail.com>, James Simmons <jsimmons@infradead.org>, Kent Overstreet <kent.overstreet@gmail.com>, Julia Lawall <Julia.Lawall@lip6.fr>, Al Viro <viro@zeniv.linux.org.uk>, "moderated list:STAGING - LUSTRE PARALLEL FILESYSTEM" <lustre-devel@lists.lustre.org>, "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>

The lloop driver should be removed entirely - use the loop driver
instead.
