From: Jay Lan <jay.zen.lan@gmail.com>
Date: Sun, 26 Dec 2010 22:48:17 -0800
Subject: [Lustre-devel] ldiskfs build problem with rhel5.5
In-Reply-To: <alpine.LFD.2.00.1012201345350.18487@casper.infradead.org>
References: <4D0C03AF.2060800@sgi.com>
	<alpine.LFD.2.00.1012201345350.18487@casper.infradead.org>
Message-ID: <4D1836B1.4060702@gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

James Simmons wrote:
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
>
> Does it deal with export_decode_fh ? Do you build againt OFED 1.5.2 ? If 
> that is the case then I ran into that issue last week. OFED alters your 
> kernel to build the modules but it doesn't alter the source tree. When  
> lustre builds it looks at your source tree which is different then what 
> the biniaries export. The solution is to copy what is in include-nfs/linux 
> from OFED to your kernel source tree include/linux directory.
>   

Hi James,

I was building against ofed 1.5.2, but I did not run into the
problem you described though. But thanks for sharing your
solution.

Thanks,
Jay

> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
