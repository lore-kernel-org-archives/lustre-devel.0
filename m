From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Sun, 6 May 2018 18:47:34 -0700
Subject: [lustre-devel] [PATCH 4/4] staging: lustre: obdclass: change
 object lookup to no wait mode
In-Reply-To: <1525285308-15347-5-git-send-email-jsimmons@infradead.org>
References: <1525285308-15347-1-git-send-email-jsimmons@infradead.org>
 <1525285308-15347-5-git-send-email-jsimmons@infradead.org>
Message-ID: <20180507014734.GA7146@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, NeilBrown <neilb@suse.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Jinshan Xiong <jinshan.xiong@intel.com>, Lai Siyao <lai.siyao@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On Wed, May 02, 2018 at 02:21:48PM -0400, James Simmons wrote:
> From: Lai Siyao <lai.siyao@intel.com>
> 
> Currently we set LU_OBJECT_HEARD_BANSHEE on object when we want
> to remove object from cache, but this may lead to deadlock, because
> when other process lookup such object, it needs to wait for this
> object until release (done at last refcount put), while that process
> maybe already hold an LDLM lock.
> 
> Now that current code can handle dying object correctly, we can just
> return such object in lookup, thus the above deadlock can be avoided.
> 
> Signed-off-by: Lai Siyao <lai.siyao@intel.com>
> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-9049
> Reviewed-on: https://review.whamcloud.com/26965
> Reviewed-by: Alex Zhuravlev <alexey.zhuravlev@intel.com>
> Tested-by: Cliff White <cliff.white@intel.com>
> Reviewed-by: Fan Yong <fan.yong@intel.com>
> Reviewed-by: Oleg Drokin <oleg.drokin@intel.com>
> Signed-off-by: James Simmons <jsimmons@infradead.org>
> ---
>  drivers/staging/lustre/lustre/include/lu_object.h  |  2 +-
>  drivers/staging/lustre/lustre/obdclass/lu_object.c | 82 +++++++++-------------
>  2 files changed, 36 insertions(+), 48 deletions(-)

Patch does not apply to my tree :(
