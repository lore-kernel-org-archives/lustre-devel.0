From: Jay Lan <jay.zen.lan@gmail.com>
Date: Sun, 26 Dec 2010 22:41:36 -0800
Subject: [Lustre-devel] ldiskfs build problem with rhel5.5
In-Reply-To: <92290CF5-B024-4110-8214-979943201E7F@oracle.com>
References: <4D0C03AF.2060800@sgi.com>
	<92290CF5-B024-4110-8214-979943201E7F@oracle.com>
Message-ID: <4D183520.7090800@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> You shouldn't apply the ldiskfs patches to the kernel at all. They are applied to a copy if the ext3/4 sources during the Lustre build process. 
>   
Hi Andreas,

No matter if I applied ldiskfs patches to the kernel or not, the
/isr/src/kernels/2.6.18-194.3.1.el5.<variant>-x86_64/fs/ext4
contains only Kconfig and Makefile. None of the .c or .h files
were there. But building ldiskfs would try to apply patches
to files in that directory which were not present.

Which rpm provides you those files in your rhel5.5
build environment?

Thanks,
Jay

> Cheers, Andreas
>
> On 2010-12-17, at 17:43, Jay Lan <jlan@sgi.com> wrote:
>
>   
>> Hi,
>>
>> I ran into a problem in building ldiskfs-3.1.4 with 2.6.18-194.3.1.el5 
>> kernel.
>> The kernel was patched with kernel patches provided by lustre-1.8.5 and
>> ldiskfs-3.1.4.
>>
>> The problem I encountered was that the kernel and kernel-devel rpms
>> did not provide fs/ext4/*.[ch], which the build process would need.
>>
>> Is there a kernel patch for this problem?
>>
>> Regards,
>> Jay
>>
>>
>> _______________________________________________
>> Lustre-devel mailing list
>> Lustre-devel at lists.lustre.org
>> http://lists.lustre.org/mailman/listinfo/lustre-devel
>>     
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
