From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 30 Apr 2018 14:15:35 +0300
Subject: [lustre-devel] [PATCH] staging: luster: llite: fix a potential
 missing-check bug when copying lumv
In-Reply-To: <CAAa=b7dPWAsqfQOWzvecHqAHYuhA63_+ya6nOMdPQ7ZaL6JB9w@mail.gmail.com>
References: <1524872704-13391-1-git-send-email-wang6495@umn.edu>
 <8E6ADED8-592E-4794-8CAB-913A325B1971@intel.com>
 <20180429132058.GB5972@kroah.com>
 <CAAa=b7dPWAsqfQOWzvecHqAHYuhA63_+ya6nOMdPQ7ZaL6JB9w@mail.gmail.com>
Message-ID: <20180430111535.gnycdzkok7cgi3ue@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Wenwen Wang <wang6495@umn.edu>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Aastha Gupta <aastha.gupta4104@gmail.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, Jeff Layton <jlayton@redhat.com>, "Drokin, Oleg" <oleg.drokin@intel.com>, "kjlu@umn.edu" <kjlu@umn.edu>, NeilBrown <neilb@suse.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ben Evans <bevans@cray.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On Sun, Apr 29, 2018 at 03:58:55PM -0500, Wenwen Wang wrote:
> It is worth fixing this bug, since it offers an opportunity for adversaries
> to provide inconsistent user data. In addition to the unwanted version
> LOV_USER_MAGIC_V1, a malicious user can also use the version
> LMV_USER_MAGIC, which is also unexpected but allowed in the function
> ll_dir_setstripe(). These inconsistent data can cause potential logical
> errors in the following execution. Hence it is necessary to re-verify the
> data copied from userspace.
> 

This change doesn't really prevent any bugs in current kernels since
LMV_USER_MAGIC is the same thing as LOV_USER_MAGIC_V1 and the users are
allowed to use LOV_USER_MAGIC_V1 if they want.

But we should probably verify it just to make the code easier to read
and because there are static analysis tools which will warn about read
verify re-read type bugs.

regards,
dan carpenter
