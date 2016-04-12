From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Mon, 11 Apr 2016 20:46:32 -0700
Subject: [lustre-devel] [PATCH 2/3] staging/lustre: Fix blank line
	after/before {/} style
In-Reply-To: <1459538283-3031249-3-git-send-email-green@linuxhacker.ru>
References: <1459538283-3031249-1-git-send-email-green@linuxhacker.ru>
	<1459538283-3031249-3-git-send-email-green@linuxhacker.ru>
Message-ID: <20160412034632.GA17084@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: green@linuxhacker.ru
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Fri, Apr 01, 2016 at 03:18:02PM -0400, green at linuxhacker.ru wrote:
> From: Oleg Drokin <green@linuxhacker.ru>
> 
> This patch fixes all checkpatch occurences of
> CHECK: Blank lines aren't necessary after an open brace '{'
> CHECK: Blank lines aren't necessary before a close brace '}'
> in Lustre code.
> 
> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>

Doesn't apply anymore after merging with 4.6-rc3, can you rebase and
resend?

thanks,

greg k-h
