From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 15 Jan 2018 16:02:59 +0100
Subject: [lustre-devel] [PATCH 4/8] staging: lustre: Fix comment style
In-Reply-To: <1515691022-22729-5-git-send-email-fabian_huegel@web.de>
References: <1515691022-22729-1-git-send-email-fabian_huegel@web.de>
 <1515691022-22729-5-git-send-email-fabian_huegel@web.de>
Message-ID: <20180115150259.GA17991@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Fabian Huegel <fabian_huegel@web.de>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Lai Siyao <lai.siyao@intel.com>, "John L . Hammond" <john.hammond@intel.com>, devel@driverdev.osuosl.org, Ben Evans <bevans@cray.com>, NeilBrown <neilb@suse.com>, Christoph Volkert <linux@christoph-volkert.de>, linux-kernel@i4.cs.fau.de, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Thu, Jan 11, 2018 at 06:16:58PM +0100, Fabian Huegel wrote:
> Most multi-line comments started on the first line, but the preferred
> linux kernel style is to start multi-line comments on the second line.
> Some comments became less readable after the change, so we changed them
> to single-line comments.
> 
> Signed-off-by: Fabian Huegel <fabian_huegel@web.de>
> Signed-off-by: Christoph Volkert <linux@christoph-volkert.de>
> ---
>  drivers/staging/lustre/lustre/include/obd_class.h | 47 +++++++++++++----------
>  1 file changed, 27 insertions(+), 20 deletions(-)

This, and another patch, did not apply to my tree, probably because I
didn't take the first one.  Please rebase and resend the remaining ones.

thanks,

greg k-h
