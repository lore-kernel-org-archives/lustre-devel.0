From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 13 Jan 2017 01:21:12 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: selftest:
	Make	brw_inject_one_error() static
In-Reply-To: <20161223154244.29145-1-Karthik.188@gmail.com>
References: <20161223154244.29145-1-Karthik.188@gmail.com>
Message-ID: <E7146D5C-6869-4DE4-ADED-11C727517555@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Karthik Nayak <karthik.188@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

On Dec 23, 2016, at 08:42, Karthik Nayak <karthik.188@gmail.com> wrote:
> 
> Since the function brw_inject_one_error() is used only within
> brw_test.c, make it static. This was reported as a warning by sparse.
> 
> Signed-off-by: Karthik Nayak <Karthik.188@gmail.com>

Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>

> ---
> drivers/staging/lustre/lnet/selftest/brw_test.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/lustre/lnet/selftest/brw_test.c b/drivers/staging/lustre/lnet/selftest/brw_test.c
> index 67b460f..b9ac34e 100644
> --- a/drivers/staging/lustre/lnet/selftest/brw_test.c
> +++ b/drivers/staging/lustre/lnet/selftest/brw_test.c
> @@ -136,7 +136,7 @@ brw_client_init(struct sfw_test_instance *tsi)
> 	return 0;
> }
> 
> -int brw_inject_one_error(void)
> +static int brw_inject_one_error(void)
> {
> 	struct timespec64 ts;
> 
> -- 
> 2.10.2
> 
> _______________________________________________
> lustre-devel mailing list
> lustre-devel at lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
