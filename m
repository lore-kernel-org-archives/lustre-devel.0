From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 19 Sep 2016 09:51:13 +0200
Subject: [lustre-devel] [PATCH 070/124] staging: lustre: statahead:
 small fixes and cleanup
In-Reply-To: <1474231143-4061-71-git-send-email-jsimmons@infradead.org>
References: <1474231143-4061-1-git-send-email-jsimmons@infradead.org>
	<1474231143-4061-71-git-send-email-jsimmons@infradead.org>
Message-ID: <20160919075113.GA11295@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Lai Siyao <lai.siyao@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sun, Sep 18, 2016 at 04:38:09PM -0400, James Simmons wrote:
> From: Lai Siyao <lai.siyao@intel.com>
> 
> small fixes:
>  * when 'unplug' is set for ll_statahead(), sa_put() shouldn't kill
>    the entry found, because its inflight RPC may not finish yet.
>  * remove 'sai_generation', add 'lli_sa_generation' because the
>    former one is not safe to access without lock.
>  * revalidate_statahead_dentry() may fail to wait for statahead
>    entry to become ready, in this case it should not release this
>    entry, because it may be used by inflight statahead RPC.
> 
> cleanups:
>  * rename ll_statahead_enter() to ll_statahead().
>  * move dentry 'lld_sa_generation' update to ll_statahead() to
>    simplify code and logic.
>  * other small cleanups.

That's a lot of different things to be doing all at once in a single
patch.  I know this came from your tree, but in the future, please push
back and ask for broken up patches, as that is required for "upstream"
here.  I'll take this for now :(

greg k-h
