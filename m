From: Oleg Drokin <oleg.drokin@intel.com>
Date: Tue, 14 Jun 2016 23:15:40 -0400
Subject: [lustre-devel] [PATCH 2/5] staging/lustre: Replace sun.com
	GPLv2 URL with gnu.org one
In-Reply-To: <4da9baaf-6369-0eb0-850b-87c827d94c3b@gmail.com>
References: <4da9baaf-6369-0eb0-850b-87c827d94c3b@gmail.com>
Message-ID: <BB8DC5F8-9DB2-40E1-BC6A-1C5FB3DC8817@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Xose Vazquez Perez <xose.vazquez@gmail.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, Linux Driver Project Developer List <driverdev-devel@linuxdriverproject.org>, "Dilger,
 Andreas" <andreas.dilger@intel.com>, "<lustre-devel@lists.lustre.org> Development" <lustre-devel@lists.lustre.org>


On Jun 14, 2016, at 11:11 PM, Xose Vazquez Perez wrote:

> Oleg Drokin wrote:
> 
>> http://www.sun.com/software/products/lustre/docs/GPLv2.pdf is no
>> longer around, so replace it with (hopefully more permanent)
>> http://http://www.gnu.org/licenses/gpl-2.0.html
>        ^^^^^^
> 
>> [...]
>> drivers/staging/lustre/lustre/ptlrpc/service.c                        | 2 +-
>> drivers/staging/lustre/lustre/ptlrpc/wiretest.c                       | 2 +-
>> 240 files changed, 240 insertions(+), 240 deletions(-)
>> 
>> diff --git a/drivers/staging/lustre/include/linux/libcfs/curproc.h b/drivers/staging/lustre/include/linux/libcfs/curproc.h
>> index c673dfc..2ab5002 100644
>> --- a/drivers/staging/lustre/include/linux/libcfs/curproc.h
>> +++ b/drivers/staging/lustre/include/linux/libcfs/curproc.h
>> @@ -15,7 +15,7 @@
>>  *
>>  * You should have received a copy of the GNU General Public License
>>  * version 2 along with this program; If not, see
>> - * http://www.sun.com/software/products/lustre/docs/GPLv2.pdf
>> + * http://http://www.gnu.org/licenses/gpl-2.0.html
>            ^^^^^^^
> 
> "http://" was repeated.

duh, oh well. Resend time.

> And "http://www.gnu.org/licenses/" is preferred

Is it? I don't mind it either way, but since we do "GPLv2 only",
seemed to make sense to only link to that?

Also:
[green at intelbox2 linux]$ git grep gpl-2.0.html | grep -v staging/lustre | wc -l
62
[green at intelbox2 linux]$ git grep www.gnu.org/licenses'$' | grep -v staging/lustre | wc -l
3

So the gpl-2.0.html is used in a lot more places in the kernel code.
