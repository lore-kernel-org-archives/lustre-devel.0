From: Andreas Dilger <adilger@whamcloud.com>
Date: Mon, 17 Dec 2012 11:34:05 -0700
Subject: [Lustre-devel] [wc-discuss] Important changes to libcfs
	primitives usage.
In-Reply-To: <50CF51D4.2090101@tacc.utexas.edu>
References: <6BCDB937-AB0C-44E5-8DD7-AB801A673FDC@whamcloud.com>
	<50CF51D4.2090101@tacc.utexas.edu>
Message-ID: <C4DC6E07-A098-4778-A98B-A3FE9FFCBA87@whamcloud.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 2012-12-17, at 10:09 AM, John Hammond wrote:
> On 12/05/2012 07:54 AM, Oleg Drokin wrote:
>>    I just landed first patch of the series to reduce usage of our libcfs_ wrappers for kernel primitives like libcfs_spin_lock/unlock...
>>    You can see actual change here: http://review.whamcloud.com/#change,2829
>> 
>>    It's highly likely that plenty of patches will be affected. To make our job easier, there is a
>>    build/libcfs_cleanup.sed script included, you can run it on all your .c and .h files to make necessary replacements:
>>    sed -i -f build/libcfs_cleanup.sed3  `find . -name "*.h" -or -name "*.c"`
>> 
>>    Please be also advised that there are more changes like this are coming (timeline is not very clear ATM, we might be able to wait with the rest until
>>    after feature freeze) and the sed script will be updated accordingly.
> 
> I have been wondering about wrappers and typedefs not affected by this change, for example cfs_get_cpu(), cfs_atomic_read() and cfs_proc_dir_entry_t.  In new code and patches should we use the cfs names or their Linux equivalents, get_cpu(), atomic_read(), and struct proc_dir_entry?

Ideally, new patches would use the Linux primitives.  However, if they are in client-side code that is compiled for liblustre, then the liblustre builds would fail until the wrappers are renamed to their Linux equivalents (i.e. removing "cfs_" prefix).

For server-side code and/or llite it should be fine to use the native Linux functions.

Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/
