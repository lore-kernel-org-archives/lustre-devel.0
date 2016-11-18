From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 18 Nov 2016 14:01:27 +0300
Subject: [lustre-devel] [PATCH 12/19] staging: lustre: libcfs: remove ==
	0 testing
In-Reply-To: <1479411357-28979-13-git-send-email-jsimmons@infradead.org>
References: <1479411357-28979-1-git-send-email-jsimmons@infradead.org>
	<1479411357-28979-13-git-send-email-jsimmons@infradead.org>
Message-ID: <20161118105235.GB6266@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Thu, Nov 17, 2016 at 02:35:50PM -0500, James Simmons wrote:
> Testing == 0 is not kernel style so remove this
> type of testing from libcfs.
> 

That's not true.  Checkpatch.pl won't complain.

Not everyone has thought about it or agrees with me but there are time
when == 0 is idiomatic.  For example, if you are talking about the
*number* zero then it should probably be == 0.  If it's like "rc == 0"
then "rc" doesn't mean the number it means success/fail so it should be
"if (!rc) ".  But it's intuitive to say "if (len == 0) ".

The other place is strcmp() and friends where it's much more intuitive:

	strcmp(a, b) == 0 means a == b
	strcmp(a, b) < 0 means a < b
	strcmp(a, b) != 0 means a != b

regards,
dan carpenter
