From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 5 Apr 2017 09:54:37 +0000
Subject: [lustre-devel] [PATCH] drivers/staging/lustre:
 Coding-guideline: Missing a blank line after declarations
In-Reply-To: <20170404093851.GB4521@mwanda>
References: <1491297326-28973-1-git-send-email-pushkar.iit@gmail.com>
	<20170404093851.GB4521@mwanda>
Message-ID: <83E1BF85-E9B7-44D4-96A0-2D6C41DFC6A6@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Pushkar Jambhlekar <pushkar.iit@gmail.com>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Perepechko <andrew.perepechko@seagate.com>, lustre-devel <lustre-devel@lists.lustre.org>

On Apr 4, 2017, at 03:38, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> On Tue, Apr 04, 2017 at 02:45:26PM +0530, Pushkar Jambhlekar wrote:
>> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_page.c b/drivers/staging/lustre/lustre/obdclass/cl_page.c
>> index cd9a40c..71fcc4c 100644
>> --- a/drivers/staging/lustre/lustre/obdclass/cl_page.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/cl_page.c
>> @@ -482,6 +482,7 @@ void cl_page_disown0(const struct lu_env *env,
>> int cl_page_is_owned(const struct cl_page *pg, const struct cl_io *io)
>> {
>> 	struct cl_io *top = cl_io_top((struct cl_io *)io);
>> +
>> 	LINVRNT(cl_object_same(pg->cp_obj, io->ci_obj));
>> 	return pg->cp_state == CPS_OWNED && pg->cp_owner == top;
>> }
> 
> This is not related to the patch but I don't understand CLOBINVRNT() and
> LINVRNT().
> 
> # define LINVRNT(exp) LASSERT(exp)
> # define LINVRNT(exp) ((void)sizeof !!(exp))
> 
> Why do we do the sizeof() instead of just an empty define?  The compiler
> calculates the size at compile time and doesn't execute the expression
> so it's the same as an empty define so far as I can tell.

Even though sizeof() is evaluated at compile time and not runtime, it will at
least evaluate the expression "exp" at compile time.  This is useful to avoid
"unused variable" warnings, syntax errors, etc. in that code when the more
expensive LINVRNT() checking is enabled, but is disabled most of the time.

With an empty expression this wouldn't happen at all, and errors may creep in.

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
