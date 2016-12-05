From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 5 Dec 2016 21:55:04 +0000
Subject: [lustre-devel] [PATCH 3/6] staging: lustre: obdclass: Create a
 header for obdo related functions
In-Reply-To: <20161205205005.GA31243@mwanda>
References: <1480707650-24089-1-git-send-email-jsimmons@infradead.org>
	<1480707650-24089-4-git-send-email-jsimmons@infradead.org>
	<20161205205005.GA31243@mwanda>
Message-ID: <2394CAB0-41C1-4F3B-AF94-03D302F6ABF5@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: James Simmons <jsimmons@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>


> On Dec 5, 2016, at 13:50, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> 
> On Fri, Dec 02, 2016 at 02:40:47PM -0500, James Simmons wrote:
>> -	__u32 local_flags = 0;
>> +	u32 local_flags = 0;
> 
>> -	if (local_flags != 0) {
>> +	if (local_flags) {
> 
> Please avoid these unrelated white space changes.

Some projects (e.g. ext4 that I work with most) allow whitespace changes
as part of related changes to the code, since the code is being modified
anyway, and frown upon whitespace-only changes because they cause churn
in the code and otherwise introduce patch merge conflicts for relatively
minor benefits by themselves.

My preference is to allow whitespace cleanups in code being modified as
part of a patch that is making other fixes, since a few whitespace changes
don't typically make it any harder to review the patch.  If it gets so
far as moving blocks of code between files and this doesn't appear cleanly
in the patch then I'd ask for a separate patch.

Cheers, Andreas
