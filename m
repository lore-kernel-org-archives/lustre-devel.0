From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 30 Jul 2017 08:04:25 -0700
Subject: [lustre-devel] [PATCH 18/20] staging: lustre: llite: Remove
 filtering of seclabel xattr
In-Reply-To: <alpine.LFD.2.20.1707272034380.6670@casper.infradead.org>
References: <1501082556-17962-1-git-send-email-jsimmons@infradead.org>
	<1501082556-17962-19-git-send-email-jsimmons@infradead.org>
	<alpine.LFD.2.20.1707272034380.6670@casper.infradead.org>
Message-ID: <20170730150425.GA25625@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Robin Humble <plaguedbypenguins@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Jul 27, 2017 at 08:35:33PM +0100, James Simmons wrote:
> 
> > From: Robin Humble <plaguedbypenguins@gmail.com>
> > 
> > The security.capability xattr is used to implement File
> > Capabilities in recent Linux versions. Capabilities are a
> > fine grained approach to granting executables elevated
> > privileges. eg. /bin/ping can have capabilities
> > cap_net_admin, cap_net_raw+ep instead of being setuid root.
> > 
> > This xattr has long been filtered out by llite, initially for
> > stability reasons (b15587), and later over performance
> > concerns as this xattr is read for every file with eg.
> > 'ls --color'. Since LU-2869 xattr's are cached on clients,
> > alleviating most performance concerns.
> > 
> > Removing llite's filtering of the security.capability xattr
> > enables using Lustre as a root filesystem, which is used on
> > some large clusters.
> 
> The commit message for this patch is incorrect. Some how it got
> mixed up with another patch which I missed in this push. Please
> drop this patch and I will resent the correct patches later.

Now dropped.
