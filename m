From: Simmons, James A. <simmonsja@ornl.gov>
Date: Thu, 31 Mar 2016 20:33:34 +0000
Subject: [lustre-devel] [PATCH 2/6] staging: lustre: libcfs: move
 memory_pressure functions to libcfs_prim.h
In-Reply-To: <20160331200358.GA28146@kroah.com>
References: <1459433920-23644-1-git-send-email-jsimmons@infradead.org>
	<1459433920-23644-3-git-send-email-jsimmons@infradead.org>
	<20160331200358.GA28146@kroah.com>
Message-ID: <647018c9fc784e15832340a614e205cc@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>, James Simmons <jsimmons@infradead.org>
Cc: "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>, James Simmons <uja.ornl@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

>On Thu, Mar 31, 2016 at 10:18:36AM -0400, James Simmons wrote:
>> Long ago libcfs_prim.h was used for userland code which is why
>> memory_pressure_*() handling is in both libcfs_prim.h and
>> linux-mem.h headers. So lets just move the memory_pressure_*()
>> to libcfs_prim.h.
>> 
>> Signed-off-by: James Simmons <uja.ornl@gmail.com>
>> ntel-bug-id: https://jira.hpdd.intel.com/browse/LU-6245
>
>"ntel-bug-id:"?  :)

Thanks for fixing that.
