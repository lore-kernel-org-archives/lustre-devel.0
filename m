From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 7 Nov 2015 23:53:50 +0300
Subject: [lustre-devel] [PATCH 07/10] staging: lustre: Handle nodemask
 on UMP machines
In-Reply-To: <cafafd1c8db141899d9c9757422451dd@EXCHCS32.ornl.gov>
References: <1446662406-4590-7-git-send-email-jsimmons@infradead.org>
	<201511050801.fy1GmLxM%fengguang.wu@intel.com>
	<cafafd1c8db141899d9c9757422451dd@EXCHCS32.ornl.gov>
Message-ID: <20151107205350.GL18797@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

The tree has to be git bisectable.  Don't break and then fix, send the
combo.

regards,
dan carpenter
