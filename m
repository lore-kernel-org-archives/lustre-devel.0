From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 4 Nov 2015 21:25:29 +0300
Subject: [lustre-devel] [patch] staging: lustre: potential underflow in
 libcfs_kkuc_group_add()
In-Reply-To: <563947EC.9020502@cray.com>
References: <20151029135122.GA7709@mwanda>
	<b7e8511d07d84cfaa9e437729795f179@EXCHCS32.ornl.gov>
	<563947EC.9020502@cray.com>
Message-ID: <20151104182529.GK7289@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Nov 03, 2015 at 05:49:00PM -0600, Frank Zago wrote:
> Yes, but for consistency, all 4 functions should be changed.

Thanks for the review.  I will send a v2.

regards,
dan carpenter
