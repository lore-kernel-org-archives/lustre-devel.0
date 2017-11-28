From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 28 Nov 2017 14:21:48 +0100
Subject: [lustre-devel] [PATCH 4/4] staging: most: Remove a attribute
 group from a kobject
In-Reply-To: <1511591971-8615-5-git-send-email-arvind.yadav.cs@gmail.com>
References: <1511591971-8615-1-git-send-email-arvind.yadav.cs@gmail.com>
 <1511591971-8615-5-git-send-email-arvind.yadav.cs@gmail.com>
Message-ID: <20171128132148.GA29890@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: gilad@benyossef.com, oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, paulmck@linux.vnet.ibm.com, vitaly_fertman@xyratex.com, yawei.niu@intel.com, linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org, driverdev-devel@linuxdriverproject.org, devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org

On Sat, Nov 25, 2017 at 12:09:31PM +0530, Arvind Yadav wrote:
> All attribute group created during dim2_sysfs_probe() should be removed
> in dim2_sysfs_destroy().
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> ---
>  drivers/staging/most/hdm-dim2/dim2_sysfs.c | 1 +

This file is not in the tree anymore.
