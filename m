From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 2 Dec 2015 14:27:33 +0300
Subject: [lustre-devel] [PATCH 14/40] staging: lustre: fix crash due to
 NULL networks string
In-Reply-To: <1448062576-23757-15-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-15-git-send-email-jsimmons@infradead.org>
Message-ID: <20151202112733.GN18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

This feels like we are fixing a bug introduce in PATCH 11 when we
removed a NULL check.  Don't introduce bugs and then fix them in the
same patchset; the fix has to be folded into the original patch.

regards,
dan carpenter
