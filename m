From: Greg KH <gregkh@linuxfoundation.org>
Date: Mon, 28 Aug 2017 10:24:26 +0200
Subject: [lustre-devel] [PATCH] staging: lustre: constify
	cl_lock_operations
In-Reply-To: <b86916f54cd6a22e0aa1d7570c0e1c793a3025e2.1503813780.git.arvind.yadav.cs@gmail.com>
References: <b86916f54cd6a22e0aa1d7570c0e1c793a3025e2.1503813780.git.arvind.yadav.cs@gmail.com>
Message-ID: <20170828082426.GA1401@kroah.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: oleg.drokin@intel.com, andreas.dilger@intel.com, jsimmons@infradead.org, john.hammond@intel.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, lustre-devel@lists.lustre.org

On Sun, Aug 27, 2017 at 11:35:27AM +0530, Arvind Yadav wrote:
> cl_lock_operations are not supposed to change at runtime.
> cl_lock_slice_add is working with const cl_lock_operations.
> So mark the non-const cl_lock_operations structs as const.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
> ---
>  drivers/staging/lustre/lustre/obdecho/echo_client.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Someone else already sent this same patch in, and it's already applied
in my tree :(
