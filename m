From: SF Markus Elfring <elfring@users.sourceforge.net>
Date: Tue, 26 Jul 2016 22:11:00 +0200
Subject: [lustre-devel] staging: lustre: Optimize error handling in
	class_register_type()
In-Reply-To: <3F437188-382B-46C8-9C30-7DBAB17F62E3@intel.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	<566D7733.1030102@users.sourceforge.net>
	<56784D83.7080108@users.sourceforge.net>
	<56784F0C.6040007@users.sourceforge.net>
	<20151221234857.GA27079@kroah.com>
	<59d94e70-7476-728e-5f63-013557ec2db9@users.sourceforge.net>
	<d1f69f4d-539b-e97d-fc0e-cb0a8754bd3a@users.sourceforge.net>
	<3F437188-382B-46C8-9C30-7DBAB17F62E3@intel.com>
Message-ID: <9f6275cc-6e7a-e26a-9aa0-3fec17648132@users.sourceforge.net>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Oleg Drokin <oleg.drokin@intel.com>
Cc: devel@driverdev.osuosl.org, lustre-devel@lists.lustre.org, Andreas Dilger <andreas.dilger@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Bhumika Goyal <bhumirks@gmail.com>

> NAK.
> when you do this, the next statement below breaks:

I wonder about this conclusion.


>> 	type = kzalloc(sizeof(*type), GFP_NOFS);
>> 	if (!type)
>> -		return rc;
>> +		return -ENOMEM;
>>
>> 	type->typ_dt_ops = kzalloc(sizeof(*type->typ_dt_ops), GFP_NOFS);
>> 	if (!type->typ_dt_ops) {
> ?
>                 goto failed;
> 
>  failed:
> ?
> return rc;
> 
> So we are now returning an unitialized rc, did you get a gcc warning about it when compiling?

I do not get such an impression if my corresponding update suggestion
"[PATCH 04/12] staging: lustre: Split a condition check in class_register_type()"
will be considered for this use case once more.
https://lkml.org/lkml/2016/7/26/462
https://www.mail-archive.com/linux-kernel at vger.kernel.org/msg1197227.html

Regards,
Markus
