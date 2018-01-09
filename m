From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 9 Jan 2018 16:00:00 +0100
Subject: [lustre-devel] [PATCH 00/14] staging:lustre: convert most
 LIBCFS*ALLOC to k*malloc - V2
In-Reply-To: <151546052331.9776.7408338350463291753.stgit@noble>
References: <151546052331.9776.7408338350463291753.stgit@noble>
Message-ID: <20180109150000.GA9846@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: NeilBrown <neilb@suse.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, lkml <linux-kernel@vger.kernel.org>, lustre <lustre-devel@lists.lustre.org>

On Tue, Jan 09, 2018 at 12:19:38PM +1100, NeilBrown wrote:
> This is a revised version of my LIBCFS*ALLOC cleanup series.
> - the compile error is fixed
> - some cases of "if (x) kfree(x)" have been simplified
> - LIBCFS_CPT_ALLOC() has been replaced as well.

Very nice, I've been wanting to see this happen for a very long time
now.

All now queued up, thanks.

greg k-h
