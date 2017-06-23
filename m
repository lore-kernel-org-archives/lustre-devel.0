From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sat, 24 Jun 2017 00:17:25 +0800
Subject: [lustre-devel] [PATCH 6/6] staging: lustre: lustre: fix all
 braces issues reported by checkpatch
In-Reply-To: <1497452481-31124-7-git-send-email-jsimmons@infradead.org>
References: <1497452481-31124-1-git-send-email-jsimmons@infradead.org>
	<1497452481-31124-7-git-send-email-jsimmons@infradead.org>
Message-ID: <20170623161725.GA20423@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, Jun 14, 2017 at 11:01:21AM -0400, James Simmons wrote:
> Cleanup all braces that was reported by checkpatch. The only
> issue not fixed up is in mdc_lock.c. Removing the braces in
> the case of mdc_lock.c will break the build.
> 
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/fld/fld_cache.c  | 3 ++-
>  drivers/staging/lustre/lustre/ldlm/ldlm_lock.c | 9 +++++----
>  drivers/staging/lustre/lustre/llite/vvp_dev.c  | 5 +++--
>  3 files changed, 10 insertions(+), 7 deletions(-)

As I skipped patch 5/6, this doesn't apply :(
