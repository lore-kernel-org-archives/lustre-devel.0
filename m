From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Mon, 9 Nov 2015 16:49:39 +0530
Subject: [lustre-devel] [PATCH] staging: lustre: Handle nodemask on UMP
	machines
In-Reply-To: <1447000500-29427-2-git-send-email-jsimmons@infradead.org>
References: <1447000500-29427-1-git-send-email-jsimmons@infradead.org>
	<1447000500-29427-2-git-send-email-jsimmons@infradead.org>
Message-ID: <20151109111939.GB3868@sudip-pc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Nov 08, 2015 at 11:34:55AM -0500, James Simmons wrote:
> For UMP and SMP machines the struct cfs_cpt_table are
> defined differently. In the case handled by this patch
> nodemask is defined as a integer for the UMP case and
> as a pointer for the SMP case. This will cause a problem
> for ost_setup which reads the nodemask directly. Instead
> we create a UMP version of cfs_cpt_nodemask and use that
> in ost_setup.
> 
> Signed-off-by: James Simmons <uja.ornl@gmail.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4199
> Reviewed-on: http://review.whamcloud.com/9219
> Reviewed-by: Liang Zhen <liang.zhen@intel.com>
> Reviewed-by: Li Xi <pkuelelixi@gmail.com>
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

Signed-off-by: and Reviewed-by: tags entered two times. Once here.
> 
> Starting in 3.14 kernels nodemask_t was changed from a
> a unsigned long to a linux bitmap so more than 32 cores
> could be supported. Using set_bit in cfs_cpt_table_alloc
> no longer compiles so this patch backports bits of the
> node management function that use a linux bitmap back
> end. Cleaned up libcfs bitmap.h to use the libcfs layers
> memory allocation function. This was pulling in lustre
> related code that was not defined.
> 
> Signed-off-by: James Simmons <uja.ornl@gmail.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-4993
> Reviewed-on: http://review.whamcloud.com/10332
> Reviewed-by: Liang Zhen <liang.zhen@intel.com>
> Reviewed-by: Bob Glossman <bob.glossman@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>

And then again here.

regards
sudip
