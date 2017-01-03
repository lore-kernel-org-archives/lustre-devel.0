From: Greg KH <gregkh@linuxfoundation.org>
Date: Tue, 3 Jan 2017 15:05:10 +0100
Subject: [lustre-devel] [PATCH] staging: lustre: selftest: Make
 brw_inject_one_error() static
In-Reply-To: <20161223154244.29145-1-Karthik.188@gmail.com>
References: <20161223154244.29145-1-Karthik.188@gmail.com>
Message-ID: <20170103140510.GA24530@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Karthik Nayak <karthik.188@gmail.com>
Cc: linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, andreas.dilger@intel.com, liang.zhen@intel.com, oleg.drokin@intel.com, kirill.shutemov@linux.intel.com, lustre-devel@lists.lustre.org

On Fri, Dec 23, 2016 at 09:12:44PM +0530, Karthik Nayak wrote:
> Since the function brw_inject_one_error() is used only within
> brw_test.c, make it static. This was reported as a warning by sparse.
> 
> Signed-off-by: Karthik Nayak <Karthik.188@gmail.com>
> ---
>  drivers/staging/lustre/lnet/selftest/brw_test.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Someone else sent this same patch before you did, sorry :(
