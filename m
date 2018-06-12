From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 12 Jun 2018 08:31:11 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: add error handling for
 try_module_get
In-Reply-To: <1528778968-42225-1-git-send-email-jiazhouyang09@gmail.com>
References: <1528778968-42225-1-git-send-email-jiazhouyang09@gmail.com>
Message-ID: <20180612063111.GC23073@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zhouyang Jia <jiazhouyang09@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, NeilBrown <neilb@suse.com>, Haneen Mohammed <hamohammed.sa@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, "Gustavo A. R. Silva" <garsilva@embeddedor.com>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Tue, Jun 12, 2018 at 12:49:26PM +0800, Zhouyang Jia wrote:
> When try_module_get fails, the lack of error-handling code may
> cause unexpected results.
> 
> This patch adds error-handling code after calling try_module_get.
> 
> Signed-off-by: Zhouyang Jia <jiazhouyang09@gmail.com>
> ---
>  drivers/staging/lustre/lnet/klnds/socklnd/socklnd.c | 5 ++++-

This patch does not apply to Linus's tree.  Always be sure to work
against linux-next to catch things like this.

thanks,

greg k-h
