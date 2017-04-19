From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Wed, 19 Apr 2017 01:21:04 +0000
Subject: [lustre-devel] [Patch v3 1/2] lustre: Parantheses added for
 Macro argument to avoid precedence issues
In-Reply-To: <20170418155019.GA7263@kroah.com>
References: <a2e734ab4562ded68cb7e7b8d55f51f757189fcd.1492255078>
	<VI1PR0901MB16166F494E9CECB93E1CD478A4040@VI1PR0901MB1616.eurprd09.prod.outlook.com>
	<20170418155019.GA7263@kroah.com>
Message-ID: <288867FC-FBC8-4E2B-B018-409822B24232@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "greg@kroah.com" <greg@kroah.com>
Cc: Rishiraj Manwatkar <manwatkar@outlook.com>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>

On Apr 18, 2017, at 09:50, greg at kroah.com wrote:
> 
> On Sat, Apr 15, 2017 at 01:50:42PM +0000, Rishiraj Manwatkar wrote:
>> Subject: [Patch v3 1/2] lustre: Parantheses added for Macro argument to avoid precedence issues

(typo) s/Parantheses/parenthesis/ s/Macro/macro/

The Subject line (excluding [PATCH] part) should be under 60

>> Parantheses are added for Macro argument, to avoid precedence issues.


Should be something like:

Subject: [PATCH v4 1/2] staging/lustre: add parenthesis to macro arguments

Add parenthesis to cl_io_for_each() macro to avoid potential issues with
unexpected argument expansion in CPP.

>> Signed-off-by: Rishiraj Manwatkar <manwatkar@outlook.com>
>> ---
>> v1 -> v2: Added mailing list in cc.
>> v2 -> v3: Changed From: to be same as Signed-off-by:.
>> drivers/staging/lustre/lustre/obdclass/cl_io.c | 4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/lustre/obdclass/cl_io.c b/drivers/staging/lustre/lustre/obdclass/cl_io.c
>> index ee7d677..0997254 100755
>> --- a/drivers/staging/lustre/lustre/obdclass/cl_io.c
>> +++ b/drivers/staging/lustre/lustre/obdclass/cl_io.c
>> @@ -52,9 +52,9 @@
>>  */
>> 
>> #define cl_io_for_each(slice, io) \
>> -	list_for_each_entry((slice), &io->ci_layers, cis_linkage)
>> +	list_for_each_entry((slice), &(io)->ci_layers, cis_linkage)
> 
> Really?  There is no precedence issues that I can see here, sorry.


Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
