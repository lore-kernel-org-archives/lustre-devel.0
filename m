From: Greg KH <gregkh@linuxfoundation.org>
Date: Fri, 6 Nov 2015 17:10:48 -0800
Subject: [lustre-devel] [PATCH v3 2/5] staging: lustre: hash.c: Replace
 IS_PO2 by is_power_of_2
In-Reply-To: <f31d304bb4f29a751f20323731b5a454f3e10460.1446079745.git.mahfouz.saif.elyazal@gmail.com>
References: <cover.1446079745.git.mahfouz.saif.elyazal@gmail.com>
	<f31d304bb4f29a751f20323731b5a454f3e10460.1446079745.git.mahfouz.saif.elyazal@gmail.com>
Message-ID: <20151107011048.GA7495@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Thu, Oct 29, 2015 at 02:55:50AM +0200, Aya Mahfouz wrote:
> Replaces IS_PO2 by is_power_of_2. It is more accurate to use
> is_power_of_2 since it returns 1 for numbers that are powers
> of 2 only whereas IS_PO2 returns 1 for 0 and numbers that are
> powers of 2.
> 
> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
> Signed-off-by: Aya Mahfouz <mahfouz.saif.elyazal@gmail.com>
> ---
> v2:
>         -changed commit message
> 	-added Andreas Reviewed by tag
> v3:
> 	-fixed checkpatch.pl warning
> 
>  drivers/staging/lustre/lustre/libcfs/hash.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

This doesn't apply to my tree, can you please refresh it and resend?

thanks,

greg k-h
