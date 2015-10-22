From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 22 Oct 2015 22:48:19 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: fix misleading
	indentation
In-Reply-To: <1445449240-30305-1-git-send-email-luisbg@osg.samsung.com>
References: <1445449240-30305-1-git-send-email-luisbg@osg.samsung.com>
Message-ID: <20151022194819.GR7340@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Wed, Oct 21, 2015 at 06:40:40PM +0100, Luis de Bethencourt wrote:
> The code is correct, the indentation is misleading. Only the the return rc
> is part of the conditional statement if rc != 0.
> 
> Fix a smatch warning:
> drivers/staging/lustre/lnet/klnds/o2iblnd/o2iblnd.c:2157
> kiblnd_hdev_setup_mrs() warn: curly braces intended?
> 
> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
> ---
> 
> Hi,
> 
> This patch gives a warning in checkpatch.pl for the line:
> if (hdev->ibh_mrs == NULL)
> 
> It would be cleaner if this was 'if (!hdev->ibh_mrs)' instead. I didn't fix
> this as well because the file has 41 instances of comparisons with NULL. I
> would be happy to do so in a patch in reply to this one if it would be good.
> 

You did the right thing.  One thing per patch.

regards,
dan carpenter
