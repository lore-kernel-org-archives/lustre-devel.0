From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 20 Sep 2016 08:47:02 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: ptlrpc: re-export
 lustre_swab_[lmv|lov]_mds_md
In-Reply-To: <1474306025-1942-1-git-send-email-jsimmons@infradead.org>
References: <1474306025-1942-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20160920064702.GB8527@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, James Simmons <uja.ornl@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Sep 19, 2016 at 01:27:05PM -0400, James Simmons wrote:
> Being over zealous in removing unused EXPORT_SYMBOLs two functions
> lustre_swab_[lmv|lov]_mds_md exports were removed. They need to be
> exported so this patch restores those EXPORT_SYMBOLS. Same mistake
> was done when porting to the upstream client.

How did our build testing not catch this?  What needs these exports?  Is
it any in-kernel code?

confused,

greg k-h
