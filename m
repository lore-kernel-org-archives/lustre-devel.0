From: Simmons, James A. <simmonsja@ornl.gov>
Date: Wed, 27 May 2015 15:01:37 +0000
Subject: [lustre-devel] [PATCH 5/6] staging:lustre: style cleanups
	for	lib-socket.c
In-Reply-To: <20150525093737.GS4150@mwanda>
References: <uja.ornl@gmail.com>
	<1432319552-10479-6-git-send-email-jsimmons@infradead.org>
	<20150525093737.GS4150@mwanda>
Message-ID: <dd9883629dd64028b5c4e6a33d17a431@EXCHCS32.ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>>On Fri, May 22, 2015 at 02:32:31PM -0400, James Simmons wrote:
>> @@ -167,13 +164,14 @@ lnet_ipif_enumerate (char ***namesp)
>>  		if (nalloc * sizeof(*ifr) > PAGE_CACHE_SIZE) {
>>  			toobig = 1;
>>  			nalloc = PAGE_CACHE_SIZE/sizeof(*ifr);
>> -			CWARN("Too many interfaces: only enumerating first %d\n",
>> -			      nalloc);
>> +			CWARN("Too many interfaces: only enumerating "
>> +			      "first %d\n", nalloc);
>>  		}
>
>Don't split string literals, it makes them hard to grep for.

Will fix. The CWARN will go over 80 characters but from the recent emails that is more acceptable.
If this is the only problem then this patch set it ready.  I have more patch series that are dependent
on this first one. Should I push the other patch series with a note that it is dependent on the tcpip
cleanup or wait until it is merged? Also how does one find out when the patch has been merged?
