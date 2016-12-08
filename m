From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 8 Dec 2016 22:36:21 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: Fix variable type
 declaration after refactoring
In-Reply-To: <20161208160759.19649-1-lambert.quentin@gmail.com>
References: <20161208160759.19649-1-lambert.quentin@gmail.com>
Message-ID: <20161208193620.GX8176@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Quentin Lambert <lambert.quentin@gmail.com>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org

On Thu, Dec 08, 2016 at 05:07:59PM +0100, Quentin Lambert wrote:
> A recent clean-up declared och_flags as a int rather than fmode_t. This
> lead to the following sparse warning:
> 
> drivers/staging/lustre/lustre/llite/file.c:106:30: warning: restricted
> fmode_t degrades to integer
> 
> This patch fixes this issue.
> 
> Fixes: 1200991234f7 ("staging: lustre: cleanup lustre_lib.h")
       0a1200991234f7

Fixes hash is wrong.  It should start with "0a".

regards,
dan carpenter
