From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 23 Apr 2018 14:58:51 +0200
Subject: [lustre-devel] [PATCH 00/25] staging: lustre: libcfs: SMP rework
In-Reply-To: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
References: <1523851807-16573-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20180423125851.GB32162@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Apr 16, 2018 at 12:09:42AM -0400, James Simmons wrote:
> Recently lustre support has been expanded to extreme machines with as
> many as a 1000+ cores. On the other end lustre also has been ported
> to platforms like ARM and KNL which have uniquie NUMA and core setup.
> For example some devices exist that have NUMA nodes with no cores.
> With these new platforms the limitations of the Lustre's SMP code
> came to light so a lot of work was needed. This resulted in this
> patch set which has been tested on these platforms.

I'll wait for v2 of this patchset based on Dan's review before applying
them.

thanks,

greg k-h
