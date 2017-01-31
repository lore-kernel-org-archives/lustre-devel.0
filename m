From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 31 Jan 2017 11:54:29 +0300
Subject: [lustre-devel] [PATCH 21/60] staging: lustre: ptlrpc: correct
 use of list_add_tail()
In-Reply-To: <1485648328-2141-22-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
	<1485648328-2141-22-git-send-email-jsimmons@infradead.org>
Message-ID: <20170131085429.GH6881@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, "John L. Hammond" <john.hammond@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Jan 28, 2017 at 07:04:49PM -0500, James Simmons wrote:
> From: "John L. Hammond" <john.hammond@intel.com>
> 
> In sptlrpc_gc_add_sec() swap the arguments to list_add_tail() so that
> it does what we meant it to do.
> 

Huh...  This is from before lustre was merged into staging.  What are
the user visible effects of this bug?  I would have expected it to get
caught earlier.


> Signed-off-by: John L. Hammond <john.hammond@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-8270

I bet the answer to my question is on this link but I'm reviewing
offline right now.  Plus that's not where the bug description belongs.

regards,
dan carpenter
