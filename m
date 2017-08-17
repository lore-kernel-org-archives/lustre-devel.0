From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 17 Aug 2017 09:23:48 -0700
Subject: [lustre-devel] [PATCH v2 01/14] staging: lustre: llite: Remove
 filtering of seclabel xattr
In-Reply-To: <1502727664-29438-2-git-send-email-jsimmons@infradead.org>
References: <1502727664-29438-1-git-send-email-jsimmons@infradead.org>
	<1502727664-29438-2-git-send-email-jsimmons@infradead.org>
Message-ID: <20170817162348.GA22834@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Robin Humble <plaguedbypenguins@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Mon, Aug 14, 2017 at 12:20:51PM -0400, James Simmons wrote:
> From: Robin Humble <plaguedbypenguins@gmail.com>
> 
> The security.capability xattr is used to implement File
> Capabilities in recent Linux versions. Capabilities are a
> fine grained approach to granting executables elevated
> privileges. eg. /bin/ping can have capabilities
> cap_net_admin, cap_net_raw+ep instead of being setuid root.
> 
> This xattr has long been filtered out by llite, initially for
> stability reasons (b15587), and later over performance
> concerns as this xattr is read for every file with eg.
> 'ls --color'. Since LU-2869 xattr's are cached on clients,
> alleviating most performance concerns.
> 
> Removing llite's filtering of the security.capability xattr
> enables using Lustre as a root filesystem, which is used on
> some large clusters.
> 
> Signed-off-by: Robin Humble <plaguedbypenguins@gmail.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9562
> Reviewed-on: https://review.whamcloud.com/27292
> Reviewed-by: John L. Hammond <john.hammond@intel.com>
> Reviewed-by: Sebastien Buisson <sbuisson@ddn.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
> Changelog:
> 
> v1) Initial submit with wrong patch attached.
> v2) Proper patch this time.

I don't see a v1 patch anywhere...

Anyway, when you do this, please make your subject such that I can sort
the emails properly and they show up in the correct order, so put the
"v2" after the patch number like this:

   Subject: [PATCH 01/14 v2] staging: lustre: llite: Remove filtering of

I think git does that correctly for you automatically if you use it...

thanks,

greg k-h
