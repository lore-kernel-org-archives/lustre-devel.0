From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Thu, 27 Oct 2016 15:12:42 +0200
Subject: [lustre-devel] [PATCH v2 1/2] staging: lustre: remove broken
 dead code in cfs_cpt_table_create_pattern
In-Reply-To: <20161025212310.2346367-1-arnd@arndb.de>
References: <20161025212310.2346367-1-arnd@arndb.de>
Message-ID: <20161027131242.GA11187@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>
Cc: Oleg Drokin <oleg.drokin@intel.com>, Patrick Farrell <paf@cray.com>, lustre-devel@lists.lustre.org, Bobi Jam <bobijam@hotmail.com>, James Simmons <uja.ornl@yahoo.com>, Olaf Weber <olaf@sgi.com>, James Simmons <jsimmons@infradead.org>, Jinshan Xiong <jinshan.xiong@intel.com>, "John L . Hammond" <john.hammond@intel.com>, Liang Zhen <liang.zhen@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Shivani Bhardwaj <shivanib134@gmail.com>, Andriy Skulysh <Andriy_Skulysh@xyratex.com>, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Tue, Oct 25, 2016 at 11:22:30PM +0200, Arnd Bergmann wrote:
> After a recent bugfix, we get a warning about the use of an uninitialized
> variable:
> 
> drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c: In function 'cfs_cpt_table_create_pattern':
> drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c:833:7: error: 'str' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> This part of the function used to not do anything as we would reassign
> the 'str' pointer to something else right away, but now we pass an
> uninitialized pointer into 'strchr', which can cause a kernel page fault
> or worse.
> 
> Fixes: 239fd5d41f9b ("staging: lustre: libcfs: shortcut to create CPT from NUMA topology")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
>  drivers/staging/lustre/lnet/libcfs/linux/linux-cpu.c | 7 -------
>  1 file changed, 7 deletions(-)

Hm, I already applied the v1 versions of these, right?  What changed
with these, they seem identical to me...

thanks,

greg k-h
