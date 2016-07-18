From: Bockjoo Kim <bockjoo@phys.ufl.edu>
Date: Mon, 18 Jul 2016 11:38:30 -0400
Subject: [lustre-devel] Building 1.8.9 Kernel modules for Kernel 3.1
In-Reply-To: <5abef7fe5df24c359f20a721d4788a49@EXCHCS32.ornl.gov>
References: <f1c16047-ecbe-6b36-1ddc-a416c7a94b14@phys.ufl.edu>
	<5abef7fe5df24c359f20a721d4788a49@EXCHCS32.ornl.gov>
Message-ID: <2ed20d55-d686-2120-ca7a-af7b0a2f2468@phys.ufl.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Thanks for the info! Good to know.
No, I can not afford the second one.
Thanks,
Bockjoo
On 7/18/16 11:22 AM, Simmons, James A. wrote:
>> Hi,
>>
>> I need to mount a lustre 1.8.9 filesystem on Kernel 3.16.36.
>>
>> So, I need to build 1.8.9 Kernel module to mount lustre 1.8.9 filesystem
>> on Kernel 3.16.36.
>>
>> I am wondering if this is possible.
> Nope. The amount of changes needed to support that new of a kernel
> are huge. Can you set up a second file system to transfer the data over
> to? Parallel copy tools exist.
