From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Mon, 12 Jun 2017 20:20:15 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: headers: potential UAPI
	headers
In-Reply-To: <20170121092459.GA29138@kroah.com>
References: <1482167207-22800-1-git-send-email-jsimmons@infradead.org>
	<20170103141248.GA8695@kroah.com>
	<alpine.LFD.2.20.1701162126170.27875@casper.infradead.org>
	<20170117074140.GA19328@kroah.com>
	<alpine.LFD.2.20.1701202331420.11070@casper.infradead.org>
	<20170121092459.GA29138@kroah.com>
Message-ID: <32AAAA94-0C88-40F5-8FAD-37F35A401AC3@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Jan 21, 2017, at 02:24, Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
> 
> On Fri, Jan 20, 2017 at 11:33:11PM +0000, James Simmons wrote:
>> 
>>>>> On Mon, Dec 19, 2016 at 12:06:47PM -0500, James Simmons wrote:
>>>>>> Not for landing. This is the purposed UAPI headers
>>>>>> with the removal of unlikely and debugging macros.
>>>>>> This is just for feedback to see if this is acceptable
>>>>>> for the upstream client.
>>>>>> 
>>>>>> Signed-off-by: James Simmons <jsimmons@infradead.org>
>>>>>> ---
>>>>>> .../lustre/lustre/include/lustre/lustre_fid.h      | 353 +++++++++++++++++++++
>>>>>> .../lustre/lustre/include/lustre/lustre_ostid.h    | 233 ++++++++++++++
>>>>> 
>>>>> Can you make a lustre "uapi" directory so we can see which files you
>>>>> really want to be UAPI and which you don't as time goes on?
>>>> 
>>>> Where do you want them placed? In uapi/linux/lustre or uapi/lustre. Does
>>>> it matter to you? The below was to forth coming UAPI headers which from
>>>> your response you seem okay with in general.
>>> 
>>> How many .h files are there going to be?  It's just a single filesystem,
>>> shouldn't you just need a single file?  If so, how about
>>> 	drivers/staging/lustre/include/uapi/lustre.h
>>> ?
>>> 
>>> If you really need multiple .h files, put them all in the same uapi/
>>> directory with a lustre_ prefix, you don't need a whole subdir just for
>>> yourself, right?
>> 
>> We have 12 UAPI headers and yes they all begin with lustre_*. Okay I will
>> create a driver/staging/lustre/include/uapi/linux directory and start
>> moving headers there.
> 
> 12 seems like a lot just for a single, tiny, filesystem :)
> 
> But moving them all to a single directory will see where we can later
> merge them together, sounds like a good plan.

Greg,
are you really adamantly against moving the Lustre headers into their own lustre/
subdirectory?  This change actually breaks userspace libraries/tools that are
using these headers to interface with the kernel (which is the whole point of
the UAPI headers).  Current Lustre tools/libraries include headers like, e.g.:

    #include <lustre/lustre_user.h>

(from /usr/include/lustre) but with this change tools will have to change to use:

    #ifdef HAVE_LINUX_LUSTRE_USER
    #include <linux/lustre_user.h>
    #else
    #include <lustre/lustre_user.h>
    #endif

and will need to have configure checks in the build environment to know which location
to use for include files.  If we put the Lustre headers into an "include/linux/lustre/"
subdir then the tools can continue to use "<lustre/lustre_user.h>" and similar, and
the Makefile can be changed to add "-I /usr/include/linux" (in addition to the normal
"/usr/include") but it will work transparently to the code, regardless of where the
headers are located or which kernel is being used.

On the maintainability point of view, I'd also think that putting headers into a
separate subdir would also be preferable just to avoid /usr/include/uapi/linux from
growing huge.  There are already several storage-related sybsystems that have their
headers in a subdirectory, like ceph, cifs, mtd, nfsd, raid, and sunrpc.

Cheers, Andreas
