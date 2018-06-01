From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 1 Jun 2018 10:33:59 +0200
Subject: [lustre-devel] [PATCH v2 18/25] staging: lustre: libcfs: rename
 goto label in cfs_cpt_table_print
In-Reply-To: <1527603725-30560-19-git-send-email-jsimmons@infradead.org>
References: <1527603725-30560-1-git-send-email-jsimmons@infradead.org>
 <1527603725-30560-19-git-send-email-jsimmons@infradead.org>
Message-ID: <20180601083359.GD19242@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, NeilBrown <neilb@suse.com>, Dmitry Eremin <dmitry.eremin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Tue, May 29, 2018 at 10:21:58AM -0400, James Simmons wrote:
> From: Dmitry Eremin <dmitry.eremin@intel.com>
> 
> Change goto label out to err.

Again, this says what it does, not why.
