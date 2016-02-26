From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 26 Feb 2016 06:03:44 +0000
Subject: [lustre-devel] [PATCH v2 0/6] staging: lustre: update modinfo
	data
In-Reply-To: <1456448832-959-1-git-send-email-jsimmons@infradead.org>
References: <1456448832-959-1-git-send-email-jsimmons@infradead.org>
Message-ID: <20160226060343.GA29216@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Feb 25, 2016 at 08:07:06PM -0500, James Simmons wrote:
> The module information for Lustre is stale or in some cases
> completely missing. This collection of patches brings the
> modinfo up to date as well as filling in any missing information.
> This patch set has been redone to rebase it on Oleg's latest
> patch set to avoid collisons in merging.
> 
> Andreas Dilger (4):
>   staging: lustre: add missing MODULE_AUTHOR for LNet selftest module
>   staging: lustre: update the MODULE_DESCRIPTION for all lustre modules
>   staging: lustre: make module_init/exit naming consistent
>   staging: lustre: update comment for lnet_lib_init/exit
> 
> James Simmons (2):
>   staging: lustre: move module info to end of libcfs module.c file
>   staging: lustre: update the MODULE_VERSION for all lustre modules

What changed to need a v2 of this series?

Please ALWAYS say what the difference is, don't expect us to "just
know".

Please send a v3 of this, describing the changes, in the correct format,
in each patch.  You know better than this...

thanks,

greg k-h
