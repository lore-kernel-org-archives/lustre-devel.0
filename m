From: Greg KH <gregkh@linuxfoundation.org>
Date: Mon, 15 Feb 2016 18:28:12 -0800
Subject: [lustre-devel] [PATCH] staging: lustre: Fixed the parenthesis
In-Reply-To: <1455507422-13568-1-git-send-email-shalinmehta85@gmail.com>
References: <1455507422-13568-1-git-send-email-shalinmehta85@gmail.com>
Message-ID: <20160216022812.GA25122@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Shalin Mehta <shalinmehta85@gmail.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, kernel-janitors@lists.osdl.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Sun, Feb 14, 2016 at 07:37:02PM -0800, Shalin Mehta wrote:
> The parentehsis are fixed in the macro for the ldlm lock to set and
> clear the flags.

"fixed" in what way?  Did you test-build this patch?  Also, you
mispelled a word here...

thanks,

greg k-h
