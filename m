From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 26 Jul 2016 17:49:49 -0400
Subject: [lustre-devel] staging: lustre: One function call less in
	class_register_type() after error detection
In-Reply-To: <0f9ecc7c-f98a-0296-563b-6fcfab459c31@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
	<a92aee0c-7a2c-a509-c19e-44cc9d8335a1@users.sourceforge.net>
	<AD87A1DA-2C87-4A36-AA19-45961B51FBE7@intel.com>
	<0f9ecc7c-f98a-0296-563b-6fcfab459c31@users.sourceforge.net>
Message-ID: <2BFF8460-ECEA-470D-ACD6-A9D7E540FE33@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>


On Jul 26, 2016, at 3:56 PM, SF Markus Elfring wrote:

>> But kobject_put() already checks for NULL, right?
> 
> Yes. - Such an input parameter validation is performed by the
> function implementation.
> 
> 
>> you just submitted another batch about that in other area.
> 
> I sent update suggestions because of this function property for two
> Linux software modules in the year 2015.
> 
> 
>>> Adjust jump targets according to the Linux coding style convention.
>> 
>> Not that I am totally against this patch,
> 
> Thanks for your feedback.
> 
> 
>> but when we do not need the extra checks, a single jump target is ok too in my mind
> 
> A single goto label will look convenient for a while. It will often work
> for several use cases.
> 
> 
>> (extra benefit - there's not going to be any chance of a mistake to where to jump to).
> 
> I have got an other opinion when you would like to care for a bit
> more software efficiency.
> 
> 
>> And when we have a single jump target, there's no supersmart naming
>> like free_this_and_that_and_that_other_thing_too.
> 
> How often do you care for efficient exception handling in the shown
> function implementations?

This function is called several times during lustre module insert.
Namely it's called 5 times for 5 types:
osc, mdc, lov, lmv, mgc.

It's not called any more than that, so it's not exactly a super hot-path function
to overoptimize it, and the failure is presumed to never happen too
(or the module would be non-functional).

I guess you have already did all the work so I don't have any principal objections
here, it's just like I said, in a non-super contended path, a single
"fail" label is probably easier on the developer when they need to add another
check there, as opposed to figuring and possibly adding a correct another
label that would do something sensible.

Thank you for your contributions.
