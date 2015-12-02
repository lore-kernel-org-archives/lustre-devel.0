From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 2 Dec 2015 15:44:47 +0300
Subject: [lustre-devel] [PATCH 20/40] staging: lustre: fix kernel crash
 when network failed to start
In-Reply-To: <1448062576-23757-21-git-send-email-jsimmons@infradead.org>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-21-git-send-email-jsimmons@infradead.org>
Message-ID: <20151202124447.GR18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Fold this into the original patch.  (Which you're going to have to redo
anyway to fix the other bug and because of the GW-BASIC label names).

regards,
dan carpenter
