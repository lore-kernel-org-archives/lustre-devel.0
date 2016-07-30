From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 30 Jul 2016 08:24:46 +0200
Subject: [lustre-devel] staging: lustre: One function call less in
 class_register_type() after error detection
In-Reply-To: <C7CC7D8C-EDD1-4E8F-AA27-A0045C659826@intel.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
	<a92aee0c-7a2c-a509-c19e-44cc9d8335a1@users.sourceforge.net>
	<AD87A1DA-2C87-4A36-AA19-45961B51FBE7@intel.com>
	<0f9ecc7c-f98a-0296-563b-6fcfab459c31@users.sourceforge.net>
	<2BFF8460-ECEA-470D-ACD6-A9D7E540FE33@intel.com>
	<db6cbbce-d3ff-2b92-199b-a8e5fd99dd40@users.sourceforge.net>
	<C7CC7D8C-EDD1-4E8F-AA27-A0045C659826@intel.com>
Message-ID: <061d83fa-b1e6-651e-ccfe-c95544ae8bd2@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, kernel-janitors@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>, lustre-devel@lists.lustre.org

> In typical deployments outside of testing environment, this function is
> called 5 times every system boot and never again.

Does this information mean that a bit more fine-tuning is insignificant
at such a source code place?


>> Did the assignment for the local variable "rc" with a well-known error code
>> influence the run-time characteristics in unwanted ways?
>> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree/drivers/staging/lustre/lustre/obdclass/genops.c?id=6a5b99a46bedc2cfbba96dec6d255c4b90af9ff8#n140
> 
> I am not sure what do you mean here.

I suggest to take another look at corresponding implementation details.

An error code is assigned to the variable "rc" before four memory
allocations succeeded so far.
We hope that this function will usually return zero as a constant
for the indication of a successful execution. I find that this variable
should not be touched in the preferred case.
Will such an unnecessary assignment reduce the execution speed a bit
for the desired file system initialisation?

Regards,
Markus
