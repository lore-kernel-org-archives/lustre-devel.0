From: Oleg Drokin <green@linuxhacker.ru>
Date: Mon, 29 May 2017 11:55:53 -0400
Subject: [lustre-devel] [PATCH] staging/lustre/lov: remove set_fs() call
	from lov_getstripe()
In-Reply-To: <20170529142843.GA11952@kroah.com>
References: <20170527034033.223677-1-green@linuxhacker.ru>
	<20170529142843.GA11952@kroah.com>
Message-ID: <BB2BB1AB-2956-4977-8244-9ACEAB57C033@linuxhacker.ru>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Al Viro <viro@ZenIV.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>, "John L . Hammond" <john.hammond@intel.com>


On May 29, 2017, at 10:28 AM, Greg Kroah-Hartman wrote:

> On Fri, May 26, 2017 at 11:40:33PM -0400, Oleg Drokin wrote:
>> lov_getstripe() calls set_fs(KERNEL_DS) so that it can handle a struct
>> lov_user_md pointer from user- or kernel-space.  This changes the
>> behavior of copy_from_user() on SPARC and may result in a misaligned
>> access exception which in turn oopses the kernel.  In fact the
>> relevant argument to lov_getstripe() is never called with a
>> kernel-space pointer and so changing the address limits is unnecessary
>> and so we remove the calls to save, set, and restore the address
>> limits.
>> 
>> Signed-off-by: John L. Hammond <john.hammond@intel.com>
>> Reviewed-on: http://review.whamcloud.com/6150
>> Intel-bug-id: https://jira.hpdd.intel.com/browse/LU-3221
>> Reviewed-by: Andreas Dilger <andreas.dilger@intel.com>
>> Reviewed-by: Li Wei <wei.g.li@intel.com>
>> Signed-off-by: Oleg Drokin <green@linuxhacker.ru>
>> ---
>> drivers/staging/lustre/lustre/lov/lov_pack.c | 9 ---------
>> 1 file changed, 9 deletions(-)
> 
> So is this the patch that you want applied to the staging tree(s) as
> well?  If so, please let me know, otherwise I have no clue?

Yes, this is it.
Thanks!
