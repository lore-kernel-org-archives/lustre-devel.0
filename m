From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 5 Apr 2016 08:59:27 -0400
Subject: [lustre-devel] [PATCH 08/27] staging: lustre: avoid to use
	bio->bi_vcnt directly
In-Reply-To: <1459857443-20611-9-git-send-email-tom.leiming@gmail.com>
References: <1459857443-20611-1-git-send-email-tom.leiming@gmail.com>
	<1459857443-20611-9-git-send-email-tom.leiming@gmail.com>
Message-ID: <20160405125927.GA25853@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ming Lei <tom.leiming@gmail.com>
Cc: Jens Axboe <axboe@fb.com>, linux-kernel@vger.kernel.org, "open list:STAGING SUBSYSTEM" <devel@driverdev.osuosl.org>, Christoph Hellwig <hch@infradead.org>, Julia Lawall <Julia.Lawall@lip6.fr>, Andreas Dilger <andreas.dilger@intel.com>, Boaz Harrosh <boaz@plexistor.com>, Oleg Drokin <oleg.drokin@intel.com>, linux-block@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, James Simmons <jsimmons@infradead.org>, "John L. Hammond" <john.hammond@intel.com>, Frank Zago <fzago@cray.com>, Kent Overstreet <kent.overstreet@gmail.com>, "moderated list:STAGING - LUSTRE PARALLEL FILESYSTEM" <lustre-devel@lists.lustre.org>

On Tue, Apr 05, 2016 at 07:56:53PM +0800, Ming Lei wrote:
> Signed-off-by: Ming Lei <tom.leiming@gmail.com>

A bit more of a commit message is always nice :)

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
