From: Dilger, Andreas <andreas.dilger@intel.com>
Date: Fri, 18 Aug 2017 23:57:58 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: fix structure size for
	ARM OABI
In-Reply-To: <20170817162639.GA13066@kroah.com>
References: <1502894655-9731-1-git-send-email-cakturk@gmail.com>
	<20170817162639.GA13066@kroah.com>
Message-ID: <E541F5C8-64B1-4BA6-97B7-1C79B9BABB77@intel.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Cihangir Akturk <cakturk@gmail.com>, Lustre Development List <lustre-devel@lists.lustre.org>, "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Drokin, Oleg" <oleg.drokin@intel.com>, James Simmons <jsimmons@infradead.org>

On Aug 17, 2017, at 10:26, Greg KH <gregkh@linuxfoundation.org> wrote:
> 
> On Wed, Aug 16, 2017 at 05:44:15PM +0300, Cihangir Akturk wrote:
>> When building the kernel for the ARM architecture without setting
>> CONFIG_AEABI, size of struct lov_user_md_v3 and struct lov_mds_md_v3
>> differs, due to different alignment requirements of OABI and EABI.
>> 
>> Marking the anonymous union within struct lov_user_md_v3 as
>> '_packed' solves this issue. Otherwise we get the following
>> error:
>> 
>> drivers/staging/lustre/lustre/lov/lov_pack.c:352:2: note: in expansion
>> of macro ?BUILD_BUG_ON?
>>  BUILD_BUG_ON(sizeof(lum) != sizeof(struct lov_mds_md_v3));
>> 
>> Signed-off-by: Cihangir Akturk <cakturk@gmail.com>
>> ---
>> drivers/staging/lustre/lustre/include/lustre/lustre_user.h | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> This file is no longer in the tree :(

With James' recent patch series, this has moved to include/uapi/linux/lustre/lustre_user.h

Cheers, Andreas
--
Andreas Dilger
Lustre Principal Architect
Intel Corporation
