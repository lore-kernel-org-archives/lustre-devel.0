From: Olaf Weber <olaf@sgi.com>
Date: Wed, 1 Feb 2017 14:32:13 +0100
Subject: [lustre-devel] [PATCH 60/60] staging: lustre: libcfs: fix
 minimum size check for libcfs ioctl
In-Reply-To: <alpine.LFD.2.20.1701310203320.7738@casper.infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
	<1485648328-2141-61-git-send-email-jsimmons@infradead.org>
	<20170130105156.GA6881@mwanda>
	<alpine.LFD.2.20.1701310203320.7738@casper.infradead.org>
Message-ID: <57e8b9b1-e1c8-a5df-e34d-7124671c6888@sgi.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>, Dan Carpenter <dan.carpenter@oracle.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Drokin <oleg.drokin@intel.com>, Amir Shehata <amir.shehata@intel.com>, Lustre Development List <lustre-devel@lists.lustre.org>

On 31-01-17 03:25, James Simmons wrote:

[...]

>> Also I'm uncomfortable with:
>>
>> 	data = container_of(hdr, struct libcfs_ioctl_data, ioc_hdr);
>>
>> If hdr isn't the first member of the struct then the code is broken but
>> container_of() implies that that isn't a hard requirement.  It should
>> just be:
>>
>> 	data = (struct libcfs_ioctl_data *)hdr;
>
> Don't know if hdr being first is a hard requirment. Doug, Amir do you know
> if it is an requirement?

It's a requirement.

-- 
Olaf Weber                 SGI               Phone:  +31(0)30-6696796
                            Veldzigt 2b       Fax:    +31(0)30-6696799
Sr Software Engineer       3454 PW de Meern  Vnet:   955-6796
Storage Software           The Netherlands   Email:  olaf at sgi.com
