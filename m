From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 11 May 2018 11:47:07 +0200
Subject: [lustre-devel] [PATCH v2] staging: lustre: o2iblnd: Fix crash
 in kiblnd_handle_early_rxs()
In-Reply-To: <1525975621-4978-1-git-send-email-dougso@me.com>
References: <1525975621-4978-1-git-send-email-dougso@me.com>
Message-ID: <20180511094707.GB18687@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Doug Oucharek <dougso@me.com>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, May 10, 2018 at 11:07:01AM -0700, Doug Oucharek wrote:
> Under upstream staging commit 5a2ca43fa54f561c252c2, the list handling
> code in kiblnd_handle_early_rxs() got changed to list_for_each_safe().
> That protects against the current thread from deleting the current entry
> it is looking at. It does not protect against another thread from deleting
> the next item in the list (which the tmp variable points to). The way this
> routine holds then releases a lock opens the door to other threads doing
> just that.
> 
> This patch reverts this commit on this routine.
> 
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9886

Please add a line like:
	Fixes: 5a2ca43fa54f ("Staging: lustre: Iterate list using list_for_each_entry")

when you know this information.

Also, I'm guessing you want this backported to the stable trees?  Or
does no one who actually runs lustre run a kernel.org stable kernel?

thanks,

greg k-h
