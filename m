From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 17 May 2016 19:39:22 +0300
Subject: [lustre-devel] [PATCH v2] staging/lustre/ptlrpc: Removes
 potential null dereference
In-Reply-To: <573B291C.2020609@oracle.com>
References: <1463408271-18079-1-git-send-email-lidza.louina@oracle.com>
	<573A0A23.2010705@cray.com>
	<alpine.LFD.2.20.1605161912310.9721@casper.infradead.org>
	<8AEE9006-6CF8-4BB7-A236-808ACE3AB302@intel.com>
	<20160517065330.GA10957@mwanda> <573B291C.2020609@oracle.com>
Message-ID: <20160517163922.GB10957@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, May 17, 2016 at 10:22:20AM -0400, Lidza Louina wrote:
> if (rc < 0) and if (rc) pretty much translates to the same thing.

I wasn't talking about this patch in particular; it's just something I
have thinking about recently.  For example, there are a lot of functions
that don't initialize parameters if they return a non-zero value, but
the caller checks for negatives.  It's often tricky or impossible to
determine that these mean the same thing just from analysing the code
without making assumptions.

I think "if (rc) " is more common than "if (rc < 0)".  I also think it's
prettier code.  But mostly I wish people would do it all consistently.

regards,
dan carpenter
