From: Simmons, James A. <simmonsja@ornl.gov>
Date: Tue, 15 Dec 2015 18:14:19 +0000
Subject: [lustre-devel] [PATCH 13/40] staging: lustre: Dynamic LNet
 Configuration (DLC) show command
In-Reply-To: <20151202112055.GM18797@mwanda>
References: <1448062576-23757-1-git-send-email-jsimmons@infradead.org>
	<1448062576-23757-14-git-send-email-jsimmons@infradead.org>
	<20151202112055.GM18797@mwanda>
Message-ID: <944b6e806bc44a3fa4d6d5e1904a894a@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

  
>>  struct libcfs_ioctl_hdr {
>>  	__u32 ioc_len;
>> @@ -87,6 +88,13 @@ do {						    \
>>  	data.ioc_hdr.ioc_len = sizeof(data);			\
>>  } while (0)
>>  
>> +#define LIBCFS_IOC_INIT_V2(data, hdr)			\
>> +do {							\
>> +	memset(&(data), 0, sizeof(data));		\
>> +	(data).hdr.ioc_version = LIBCFS_IOCTL_VERSION2;	\
>> +	(data).hdr.ioc_len = sizeof(data);		\
>> +} while (0)
>> +
>
>Do we really need this?

Would you be okay if this was a inline function? This is used by user land and kernel space code.
