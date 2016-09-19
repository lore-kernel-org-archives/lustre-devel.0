From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 19 Sep 2016 09:28:59 +0200
Subject: [lustre-devel] [PATCH 030/124] staging: lustre: llite: Replace
 write mutex with range lock
In-Reply-To: <1474231143-4061-31-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
	<1474231143-4061-31-git-send-email-jsimmons@infradead.org>
Message-ID: <20160919072859.GA15407@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Patrick Farrell <paf@cray.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Jinshan Xiong <jinshan.xiong@intel.com>, Prakash Surya <surya1@llnl.gov>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sun, Sep 18, 2016 at 04:37:29PM -0400, James Simmons wrote:
> + * Range lock is used to allow multiple threads writing a single shared
> + * file given each thread is writing to a non-overlapping portion of the
> + * file.
> + *
> + * Refer to the possible upstream kernel version of range lock by
> + * Jan Kara <jack@suse.cz>: https://lkml.org/lkml/2013/1/31/480
> + *
> + * This file could later replaced by the upstream kernel version.

It doesn't look like range_lock ever got accepted in the kernel tree,
any idea what happened to it?  Having a per-filesystem lock type seems
odd to me...

thanks,

greg k-h
