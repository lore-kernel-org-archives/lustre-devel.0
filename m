From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 23 Jan 2018 12:28:59 +0300
Subject: [lustre-devel] [bug report] staging: lustre: replace simple
 cases of LIBCFS_ALLOC with kzalloc.
In-Reply-To: <4EDC2CF6-F999-4B09-B7CE-71281845F6F6@intel.com>
References: <20180115092657.om2gdrcwlajo2tvi@mwanda>
 <87r2qh83np.fsf@notabene.neil.brown.name>
 <D6E57F1D-7686-43A5-A8E2-ED9CC29B3D0F@intel.com>
 <4EDC2CF6-F999-4B09-B7CE-71281845F6F6@intel.com>
Message-ID: <20180123092859.ghhehynmuxstdijv@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jan 23, 2018 at 09:25:41AM +0000, Zhen, Liang wrote:
> Hi, I just realized the ?free_conn? parameter is unused in kernel source, but it?s actually used in the original patch: https://review.whamcloud.com/#/c/17892  , so I think it should be fixed in the kernel.
> 

Dmitry already sent a patch for this.

regards,
dan carpenter
